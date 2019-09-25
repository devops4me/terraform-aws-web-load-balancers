
### #################### ###
### in_service_protocols ###
### #################### ###

variable in_service_protocols {

    description = "The list of service protocols whose ports and descriptions are mapped in the traffic lookup."
    type        = list
}


### #################### ###
### in_health_check_uris ###
### #################### ###

variable in_health_check_uris {

    description = "The path without the leading forward slash used by the load balancer to assess service health."
    type        = list
}


### ############ ###
### in_dns_names ###
### ############ ###

variable in_dns_names {

    description = "The load balancer looks up TLS (Certificate Manager) certs based on these Route53 DNS names."
    type        = list
}


### ######### ###
### in_vpc_id ###
### ######### ###

variable in_vpc_id {
    description = "The ID of the VPC (Virtual Private Cloud)  that this load balancer will be created in."
    type        = string
}


### ##################### ###
### in_security_group_ids ###
### ##################### ###

variable in_security_group_ids {
    description = "ID of security group that constrains the flow of load balancer traffic."
    type        = list
}


### ############# ###
### in_subnet_ids ###
### ############# ###

variable in_subnet_ids {
    description = "IDs of subnets the network interfaces are attached to."
    type = list
}


### ################ ###
### in_mandated_tags ###
### ################ ###

variable in_mandated_tags {

    description = "Optional tags unless your organization mandates that a set of given tags must be set."
    type        = map
    default     = { }
}


### ############ ###
### in_ecosystem ###
### ############ ###

variable in_ecosystem {
    description = "The name of the ecosystem (environment superclass) being created or changed."
    default = "ecosystem"
    type = string
}


### ############ ###
### in_timestamp ###
### ############ ###

variable in_timestamp {
    description = "The numerical timestamp denoting the time this eco instance was instantiated."
    type = string
}


### ############## ###
### in_description ###
### ############## ###

variable in_description {
    description = "The when and where description of this ecosystem creation."
    type = string
}
