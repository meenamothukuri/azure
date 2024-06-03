#The key of the Map is the name of the rule
#The name of the inboud and outbound rules must be unique
nsg_inbound_rules = {
    "R1" = {
    priority                                   = 100
    direction                                  = "Inbound"
    access                                     = "Deny"
    protocol                                   = "Tcp"
    source_port_range                          = "*"
    destination_port_range                     = "*"
    source_address_prefix                      = "*"
    destination_address_prefix                 = "*"
    description                                = "R1"
    }

    "R2" = {
    priority                                   = 200
    direction                                  = "Inbound"
    access                                     = "Deny"
    protocol                                   = "Tcp"
    source_port_range                          = "*"
    destination_port_range                     = "*"
    source_address_prefix                      = "*"
    destination_address_prefix                 = "*"
    description                                = "R2"
    }
}


#The key of the Map is the name of the rule
#The name of the inboud and outbound rules must be unique
nsg_outbound_rules = {
    "R3" = {
    priority                                   = 100
    direction                                  = "Outbound"
    access                                     = "Deny"
    protocol                                   = "Tcp"
    source_port_range                          = "*"
    destination_port_range                     = "*"
    source_address_prefix                      = "*"
    destination_address_prefix                 = "*"
    description                                = "R3"
    }

    "R4" = {
    priority                                   = 200
    direction                                  = "Outbound"
    access                                     = "Deny"
    protocol                                   = "Tcp"
    source_port_range                          = "*"
    destination_port_range                     = "*"
    source_address_prefix                      = "*"
    destination_address_prefix                 = "*"
    description                                = "R4"
    }
}