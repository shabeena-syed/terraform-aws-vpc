resource "aws_vpc" "main" { # naming convenstion should be unique 
  cidr_block       = var.vpc_cidr
   instance_tenancy = "default"
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    var.common_tags,
    var.vpc_tags,
    {
        Name = local.resource_name

    }

    
  )
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.ig_tags,
    {
        Name = local.resource_name #"${var.project_name}-${var.environment}"=expense-dev
    }

  )
}

resource "aws_subnet" "public" { # first public[0],second public[1]
    count = length(var.public_subnet_cidrs)
    availability_zone = local.az_names[count.index] #us-east-1a,us-east-1b
   
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]

 tags = merge(
    var.common_tags,
    var.private_subnet_cidr_tags,
    {
        Name = "${local.resource_name}-public-${local.az_names[count.index]}"  #expense-dev-us-east-1a,expense-dev-us-east-1b
    }
)

}

resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidrs)
    availability_zone = local.az_names[count.index]
   
    vpc_id     = aws_vpc.main.id
    cidr_block = var.private_subnet_cidrs[count.index]

 tags = merge(
    var.common_tags,
    var.private_subnet_cidr_tags,
    {
        Name = "${local.resource_name}-private-${local.az_names[count.index]}"  #expense-dev-us-east-1a,expense-dev-us-east-1b
    }
)

}

resource "aws_subnet" "database" { #first name is database[0],second name is database [1]
    count = length(var.database_subnet_cidrs)
    availability_zone = local.az_names[count.index]
   
   vpc_id     = aws_vpc.main.id
   cidr_block = var.database_subnet_cidrs[count.index]

   tags = merge(
     var.common_tags,
     var.database_subnet_cidr_tags,
    {
        Name = "${local.resource_name}-database-${local.az_names[count.index]}"  #expense-dev-us-east-1a,expense-dev-us-east-1b
    }
   )
}

resource "aws_db_subnet_group" "default" {
  name       = "${local.resource_name}"
  subnet_ids = aws_subnet.database[*].id

  tags = merge(
    var.common_tags,
    var.database_subnet_group_tags,
    {
         Name = "${local.resource_name}" 
    }
  )
    
  }


resource "aws_eip" "nat" {
  
  domain   = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge (
    var.common_tags,
    var.nat_gateway_tags,
    {

    Name = "${local.resource_name}" #expense_dev
    }
)
 depends_on = [aws_internet_gateway.gw] #explicit dependency
}

## public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.public_route_table_tags,

{
  Name = "${local.resource_name}-public" #expense-dev
}
  )
}

## private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.private_route_table_tags,

{
  Name = "${local.resource_name}-private" #expense-dev
}
  )
}

## database route table
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.database_route_table_tags,

{
  Name = "${local.resource_name}-database" #expense-dev
}
  )
}
## routes ##
resource "aws_route" "public_route" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
  
}

resource "aws_route" "private_route" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

resource "aws_route" "database_route" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}
## route table and subnet associations
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public[*].id,count.index) # *== all
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private[*].id,count.index) ## y shoudnt take count.index here
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id      =  element(aws_subnet.database[*].id,count.index)
  route_table_id = aws_route_table.database.id
}



   
  

   
 
