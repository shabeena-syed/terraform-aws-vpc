resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge (
    var.common_tags,
    var.vpc_peering_tags,
    { 
        Name = "${local.resource_name}" #expense-dev
    }
  )
}

resource "aws_db_subnet_group" "default" {
  name       = "${local.resource_name}"
  subnet_ids = aws_subnet.database[*].id
  tags =  merge (
      var.common_tags,
      var.database_subnet_group_tags,
      {
        Name = "${local.resource_name}"
      }
    )
}

## internet-gateway ##
resource "aws_internet_gateway" "expense-gw" {
  vpc_id = aws_vpc.main.id

  tags = merge (
    var.common_tags,
    var.igw_tags,
    {
        Name = "${local.resource_name}"
    }
  )
   
}
## public sunet ##
resource "aws_subnet" "public" {
    count = length(var.public_subnet_cidrs)
    availability_zone = local.az_names[count.index]
    map_public_ip_on_launch = true
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]

  tags = merge(
    var.common_tags,
    var.public_subnet_cidr_tags,
    {
        Name = "${local.resource_name}-${local.az_names[count.index]}"
    }
  )
}
## private subnets ##
resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidrs)
    availability_zone = local.az_names[count.index]
    vpc_id     = aws_vpc.main.id
   cidr_block = var.private_subnet_cidrs[count.index]

  tags = merge(
    var.common_tags,
    var.private_subnet_cidr_tags,
    {
        Name = "${local.resource_name}-${local.az_names[count.index]}"
    }
  )
}
## database subnet CIDR ##
resource "aws_subnet" "database" {
    count = length(var.private_subnet_cidrs)
    availability_zone = local.az_names[count.index]
    vpc_id     = aws_vpc.main.id
   cidr_block = var.database_subnet_cidrs[count.index]

  tags = merge(
    var.common_tags,
    var.database_subnet_cidr_tags,
    {
        Name = "${local.resource_name}-${local.az_names[count.index]}"
    }
  )
}



## eip ##
resource "aws_eip" "nat_eip" {
  domain   = "vpc"
}

## NAT-gateway ##
resource "aws_nat_gateway" "NAT" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[0].id
  tags = merge (
   var.common_tags,
    var.nat_gateway_tags,
    {
         Name = "${local.resource_name}" #expense-dev
    }
  )
 depends_on = [aws_internet_gateway.expense-gw]
 }

## public-route-table ##
 resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge (
    var.common_tags,
    var.nat_gateway_tags,
    {
         Name = "${local.resource_name}-public" #expense-dev
    }
  )   
  }

## private-route-table ##
 resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge (
    var.common_tags,
    var.nat_gateway_tags,
    {
         Name = "${local.resource_name}-private" #expense-dev
    }
  )   
 }
##database-route-table ##
 resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge (
    var.common_tags,
    var.nat_gateway_tags,
    {
         Name = "${local.resource_name}-database" #expense-dev
    }
  )   
 }
## route-table ##
 resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id   = aws_internet_gateway.expense-gw.id
 }

  resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id   = aws_nat_gateway.NAT.id
 }
  resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id   = aws_nat_gateway.NAT.id
 }
## route table and subnet association ##
 resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public[*].id ,count.index)
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private[*].id , count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id      = element(aws_subnet.database[*].id ,count.index)
  route_table_id = aws_route_table.database.id
}


  



  
  
  
  


   


   