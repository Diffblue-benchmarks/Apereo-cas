#!/bin/bash
invokeJavadoc=false
invokeDoc=false
branchVersion="development"

# Only invoke the javadoc deployment process
# for the first job in the build matrix, so as
# to avoid multiple deployments.

if [ "$TRAVIS_PULL_REQUEST" == "false" ] && [ "$TRAVIS_BRANCH" == "master" ]; then
  case "${TRAVIS_JOB_NUMBER}" in
       *\.1)
        echo -e "Invoking auto-doc deployment for Travis job ${TRAVIS_JOB_NUMBER}"
        # Do not deploy javadocs to gh-pages as they are pulled from Maven Central
        # invokeJavadoc=true;
        invokeDoc=true;;
  esac
fi

echo -e "Starting with project documentation...\n"

if [ "$invokeDoc" == true ]; then

  echo -e "Copying project documentation over to $HOME/docs-latest...\n"
  cp -R docs/cas-server-documentation $HOME/docs-latest

fi

echo -e "Finished with project documentation...\n"

echo -e "Staring with project Javadocs...\n"

if [ "$invokeJavadoc" == true ]; then

  echo -e "Started to publish latest Javadoc to gh-pages...\n"

  echo -e "Invoking build to generate the project site...\n"
  ./gradlew javadoc -q -Dorg.gradle.configureondemand=true -Dorg.gradle.workers.max=8 --parallel

  echo -e "Copying the generated docs over...\n"
  cp -R build/javadoc $HOME/javadoc-latest

fi

echo -e "Finished with project Javadocs...\n"

if [[ "$invokeJavadoc" == true || "$invokeDoc" == true ]]; then

  cd $HOME
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "travis-ci"
  echo -e "Cloning the gh-pages branch...\n"
  git clone --quiet https://${GH_TOKEN}@github.com/apereo/cas gh-pages > /dev/null
  cd gh-pages
  
  echo -e "Switching to gh-pages branch\n"
  
  git checkout gh-pages
  git status

  echo -e "\nStaring to move project documentation over...\n"

  if [ "$invokeDoc" == true ]; then
    echo -e "Removing previous documentation from $branchVersion...\n"
    git rm -rf ./"$branchVersion" > /dev/null

    echo -e "Creating $branchVersion directory...\n"
    test -d "./$branchVersion" || mkdir -m777 -v "./$branchVersion"

    echo -e "Copying new docs from $HOME/docs-latest over to $branchVersion...\n"
    cp -Rf $HOME/docs-latest/* "./$branchVersion"
    echo -e "Copied project documentation...\n"
  fi

  if [ "$invokeJavadoc" == true ]; then
    echo -e "Staring to move project Javadocs over...\n"

    echo -e "Removing previous Javadocs from /$branchVersion/javadocs...\n"
    git rm -rf ./"$branchVersion"/javadocs > /dev/null

    echo -e "Creating $branchVersion directory...\n"
    test -d "./$branchVersion" || mkdir -m777 -v ./"$branchVersion"

    echo -e "Creating Javadocs directory at /$branchVersion/javadocs...\n"
    test -d "./$branchVersion/javadocs" || mkdir -m777 -v ./"$branchVersion"/javadocs

    echo -e "Copying new Javadocs...\n"
    cp -Rf $HOME/javadoc-latest/* ./"$branchVersion"/javadocs
    echo -e "Copied project Javadocs...\n"

  fi

  echo -e "Adding changes to the git index...\n"
  git add -f . > /dev/null

  echo -e "Committing changes...\n"
  git commit -m "Published documentation from $TRAVIS_BRANCH to [gh-pages]. Build $TRAVIS_BUILD_NUMBER " > /dev/null
  
  echo -e "Before: Calculating git repository disk usage:\n"
  du -sh .git/

  echo -e "Before: Counting git objects in the repository:\n"
  git count-objects -vH
  
  echo -e "\nCleaning up repository...\n"
  git config pack.threads "24"
  git gc --prune=now && git gc --aggressive --prune=now --auto
  
  echo -e "After: Calculating git repository disk usage:\n"
  du -sh .git/
  
  echo -e "After: Counting git objects in the repository:\n"
  git count-objects -vH
  
  echo -e "Pushing upstream to origin/gh-pages...\n"
  git push -fq origin gh-pages > /dev/null

  echo -e "Successfully published documentation to [gh-pages] branch.\n"

fi
