
################ ################################################ ########
################ Module [[[load balancers]]] Input Variables List ########
################ ################################################ ########


### ############################# ###
### [[variable]] in_service_names ###
### ############################# ###

variable in_service_names {

    description = "The list of known service names whose ports and descriptions are mapped in the traffic lookup."
    type        = "list"
}


### ################################# ###
### [[variable]] in_health_check_uris ###
### ################################# ###

variable in_health_check_uris {

    description = "The path without the leading forward slash used by the load balancer to assess service health."
    type        = "list"
}


### ######################### ###
### [[variable]] in_dns_names ###
### ######################### ###

variable in_dns_names {

    description = "The load balancer looks up TLS (Certificate Manager) certs based on these Route53 DNS names."
    type        = "list"
}


### ###################### ###
### [[variable]] in_vpc_id ###
### ###################### ###

variable in_vpc_id {
    description = "The ID of the VPC (Virtual Private Cloud)  that this load balancer will be created in."
}


### ################################## ###
### [[variable]] in_security_group_ids ###
### ################################## ###

variable in_security_group_ids {
    description = "ID of security group that constrains the flow of load balancer traffic."
    type        = "list"
}


### ########################## ###
### [[variable]] in_subnet_ids ###
### ########################## ###

variable in_subnet_ids {
    description = "IDs of subnets the network interfaces are attached to."
    type = "list"
}


### ################# ###
### in_ecosystem_name ###
### ################# ###

variable in_ecosystem_name {
    description = "Creational stamp binding all infrastructure components created on behalf of this ecosystem instance."
}


### ################ ###
### in_tag_timestamp ###
### ################ ###

variable in_tag_timestamp {
    description = "A timestamp for resource tags in the format ymmdd-hhmm like 80911-1435"
}


### ################## ###
### in_tag_description ###
### ################## ###

variable in_tag_description {
    description = "Ubiquitous note detailing who, when, where and why for every infrastructure component."
}
