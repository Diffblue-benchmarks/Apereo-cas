package org.apereo.cas.ticket;

import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import lombok.val;
import org.springframework.core.OrderComparator;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * This is {@link DefaultTicketCatalog}.
 *
 * @author Misagh Moayyed
 * @since 5.1.0
 */
@Slf4j
@NoArgsConstructor
public class DefaultTicketCatalog implements TicketCatalog {

    private final Map<String, TicketDefinition> ticketMetadataMap = new HashMap<>();

    @Override
    public TicketDefinition find(final String ticketId) {
        val defn = ticketMetadataMap.values()
            .stream()
            .filter(md -> ticketId.startsWith(md.getPrefix()))
            .findFirst()
            .orElse(null);
        if (defn == null) {
            LOGGER.error("Ticket definition for [{}] cannot be found in the ticket catalog "
                + "which only contains the following ticket types: [{}]", ticketId, ticketMetadataMap.keySet());
        }
        return defn;
    }

    @Override
    public TicketDefinition find(final Ticket ticket) {
        LOGGER.trace("Locating ticket definition for ticket [{}]", ticket);
        return find(ticket.getPrefix());
    }

    @Override
    public Collection<TicketDefinition> find(final Class<? extends Ticket> ticketClass) {
        val list = ticketMetadataMap.values().stream()
            .filter(t -> t.getImplementationClass().isAssignableFrom(ticketClass))
            .collect(Collectors.toList());
        OrderComparator.sort(list);
        LOGGER.trace("Located all registered and known sorted ticket definitions [{}] that match [{}]", list, ticketClass);
        return list;
    }

    @Override
    public void register(final TicketDefinition ticketDefinition) {
        LOGGER.trace("Registering/Updating ticket definition [{}]", ticketDefinition);
        ticketMetadataMap.put(ticketDefinition.getPrefix(), ticketDefinition);
    }

    @Override
    public void update(final TicketDefinition metadata) {
        register(metadata);
    }

    @Override
    public boolean contains(final String ticketId) {
        LOGGER.trace("Locating ticket definition for [{}]", ticketId);
        return ticketMetadataMap.containsKey(ticketId);
    }

    @Override
    public Collection<TicketDefinition> findAll() {
        val list = new ArrayList<TicketDefinition>(ticketMetadataMap.values());
        OrderComparator.sort(list);
        LOGGER.trace("Located all registered and known sorted ticket definitions [{}]", list);
        return list;
    }
}
