package org.apereo.cas.util.services;

import org.apereo.cas.services.util.RegisteredServiceJsonSerializer;

import lombok.val;
import org.junit.Test;

import static org.junit.Assert.*;

/**
 * This is {@link RegisteredServiceJsonSerializerTests}.
 *
 * @author Misagh Moayyed
 * @since 5.1.0
 */
public class RegisteredServiceJsonSerializerTests {

    @Test
    public void checkNullability() {
        val zer = new RegisteredServiceJsonSerializer();
        val json = "    {\n"
            + "        \"@class\" : \"org.apereo.cas.services.RegexRegisteredService\",\n"
            + "            \"serviceId\" : \"^https://xyz.*\",\n"
            + "            \"name\" : \"XYZ\",\n"
            + "            \"id\" : \"20161214\"\n"
            + "    }";

        val s = zer.from(json);
        assertNotNull(s);
        assertNotNull(s.getAccessStrategy());
        assertNotNull(s.getAttributeReleasePolicy());
        assertNotNull(s.getProxyPolicy());
        assertNotNull(s.getUsernameAttributeProvider());
        assertNotNull(s.getContacts());
        assertNotNull(s.getEnvironments());
        assertNotNull(s.getExpirationPolicy());
        assertNotNull(s.getMultifactorPolicy());
    }
}
