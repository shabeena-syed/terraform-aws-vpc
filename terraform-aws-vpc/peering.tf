resource "aws_vpc_peering_connection" "peering" {
  count = var.is_peering_required ? 1 : 0 # it will give on main module
  peer_vpc_id   = aws_vpc.main.id # requestor vpc
  vpc_id        = var.acceptor_vpc_id == "" ? data.aws_vpc.default.id : var.acceptor_vpc_id  #acceptor vpc id willbe given in main module
  auto_accept = var.acceptor_vpc_id == "" ? true : false # othrs should give the permission to approve the perring
  tags = merge(
    var.common_tags,
    var.vpc_peering_tags,
    {
      Name = "${local.resource_name}" #expense-dev
    }
  )
}
## count is useful to control whn resource is required
resource "aws_route" "public_peering" { # requstor details
  count = var.is_peering_required && var.acceptor_vpc_id == "" ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}


resource "aws_route" "private_peering" {
  count = var.is_peering_required && var.acceptor_vpc_id == "" ? 1 : 0 # blank ,true,false
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
 vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
  
}

resource "aws_route" "databse_peering" {
  count = var.is_peering_required && var.acceptor_vpc_id == "" ? 1 : 0 # blank ,true,false
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
 vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id # count is set in peering connection id so list must e declared
  
}

resource "aws_route" "default_peering" {
  count = var.is_peering_required && var.acceptor_vpc_id == "" ? 1 : 0 # blank ,true,false
  route_table_id            = data.aws_route_table.main.id #default vpc route table
  destination_cidr_block    = var.vpc_cidr
 vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id # count is set in peering connection id so list must e declared
  
}








  

