#custome AWS VPC module

this is developed for joindevops.com
we are creating follwing resources
this module creates resources in first 2AZ for its HA
 ## RESOURCES ##
* vpc
* internet gate way
* public subnet 2
* private subnets 2
* database subnets 2
* EIP
* NAT gateway
* public route tables 
* private route table
* database route table
* route table and subnet association
* routes in all tables
* peering if required for user
* routes of peering in requestor and acceptor VPC
* database subnet group

## INPUTS ##
* project_name (required) : user should mention  their project name
* environment (optional)  : default is dev . Type is string
* common_tags (required) : user should provide their tags related to their project.Type is map
* vpc_cidr (optional) : default value is 10.0.0.0/16 . Type is string.
* enable_dns_hostnames (optional) : default value is true. Type is bool.
* vpc_tags (optional) : default value is empty.type is map
* igw_tags (optional) : default value is empty .Type is map
* public_subnet_cidrs(required) : user has to provide 2 valid subnet CIDR
* public_subnet_cidr_tags(optional) : default value is empty .Type is map
* private_subnet_cidrs (required) : user has to provide 2 valid subnet CIDR
* private_subnet_cidr_tags(optional) : default value is empty .Type is map
* database_subnet_cidrs (required) : user has to provide 2 valid subnet CIDR
* database_subnet_cidr_tags(optional) : default value is empty .Type is map
* database_subnet_cidr_group_tags(optional) : default value is empty .Type is map
* nat_gateway_tags (optional) : default is empty . type is map
* public_route_tags ( optional) : default is empty . type is map
* private_route_table_tags ( optional) : default is empty . type is map
* database_route_table_tags ( optional) : default is empty . type is map
* is_peering_required (optional) : default is false: type is bool
* acceptor_vpc_id(optional) : default is empty,default VPC ID would be taken.type is string
* vpc_peering_tags (optional) : default is empty . type is map

## OUTPUTS ##
 * vpc_id : VPC ID
 * public_subnet_ids : a list of 2 subnet IDS created.
 * private_subnet_ids : a list of 2 subnet IDS created.
 * database_subnet_ids : a list of 2 subnet IDS created.
 * database_subnet_group_id : A database subnet group ID created.
 