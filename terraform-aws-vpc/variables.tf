##project##
variable "project_name" {
  type = string

}
variable "environment" {
    type = string
    default = "dev"
  
}

variable "common_tags" {
    type = map   
}
 ##vpc ##
variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
  
}
variable "enable_dns_hostnames" {
    type = bool
    default = true
  
}

variable "vpc_tags" {
    type = map
    default = {}
}
## ig ##
variable "ig_tags" {
    type = map
    default = {}
}
## public subnets
variable "public_subnet_cidrs" {
    type = list
    validation {
     condition = length(var.public_subnet_cidrs) == 2
     error_message = "please provide 2 valid public subnet CIDR"
    }
  
}
# private subnets
variable "private_subnet_cidrs" {
    type = list
    validation {
        condition = length(var.private_subnet_cidrs)==2
        error_message = "please provide 2 valid subnet CIDR"
      
    }
}
variable "database_subnet_cidrs" {
    type = list
    validation {
        condition = length(var.database_subnet_cidrs)==2
        error_message = "please provide 2 valid database CIDR"
      
    }
}
variable "private_subnet_cidr_tags" {
    default = {}
  
}
variable "database_subnet_cidr_tags" {
    default = {}
  
}

variable "database_subnet_group_tags" {
    default = {}
  
}


#natgateway##
variable "nat_gateway_tags" {
  type = map
  default = {}
}
## public route table tags
variable "public_route_table_tags" {
    default = {}
  
}
## private route table tags

variable "private_route_table_tags" {
  default = {}
}
## database route table tags
variable "database_route_table_tags" {
    default = {}
  
}
## peering ###
variable "is_peering_required" {
    type = bool
    default = false
  
} 
variable "acceptor_vpc_id" {
    type = string
    default = ""
  
}


variable "vpc_peering_tags" { 
  type=map
  default = {}
  }
