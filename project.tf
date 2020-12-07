################################################################
# Provider Configuration
################################################################

provider "aws"  {
  region     = "us-east-2"
  access_key = "AKIA6NZZHG62M6QY3G74"
  secret_key = "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"
}


################################################################
# VPC creation
################################################################

resource "aws_vpc" "blog" {
  cidr_block       = "172.18.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "blog"
  }
}


################################################################
#public subnet - 1  creation
################################################################

resource "aws_subnet" "blog-public1" {
  vpc_id     = aws_vpc.blog.id
  cidr_block = "172.18.0.0/18"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "blog-public1"
  }
}

################################################################
#public subnet - 2  creation
################################################################

resource "aws_subnet" "blog-public2" {
  vpc_id     = aws_vpc.blog.id
  cidr_block = "172.18.64.0/18"
  availability_zone = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "blog-public2"
  }
}

################################################################
#private subnet - 1  creation
################################################################

resource "aws_subnet" "blog-private1" {
  vpc_id     = aws_vpc.blog.id
  cidr_block = "172.18.128.0/18"
  availability_zone = "us-east-2c"
  tags = {
    Name = "blog-private1"
  }
}

################################################################
#private subnet - 2  creation
################################################################


resource "aws_subnet" "blog-private2" {
  vpc_id     = aws_vpc.blog.id
  cidr_block = "172.18.192.0/18"
  availability_zone = "us-east-2a"
  tags = {
    Name = "blog-private2"
  }
}

################################################################
#internet gateway  creation
################################################################


resource "aws_internet_gateway" "blog-igw" {
  vpc_id = aws_vpc.blog.id

  tags = {
    Name = "blog-igw"
  }
}

################################################################
#public route table  creation
################################################################

resource "aws_route_table" "blog-public-RT" {
  vpc_id = aws_vpc.blog.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.blog-igw.id
        }

route {
    cidr_block = "10.0.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.blog-app.id
  }

   tags = {
        Name ="blog-public-RT"
        }
}


################################################################
#public route table  association
################################################################

resource "aws_route_table_association" "blog-public-RT" {
  subnet_id      = aws_subnet.blog-public1.id
  route_table_id = aws_route_table.blog-public-RT.id
}

################################################################
#public subnet 2 and  route table  association
################################################################

resource "aws_route_table_association" "blog-public2-RT" {
  subnet_id      = aws_subnet.blog-public2.id
  route_table_id = aws_route_table.blog-public-RT.id
}


################################################################
#eip creation
################################################################

resource "aws_eip" "nat" {
  vpc      = true
  tags = {
    Name = "blog-eip"
  }
}

################################################################
#nat gateway creation
################################################################


resource "aws_nat_gateway" "blog-nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.blog-public2.id

  tags = {
    Name = "blog-NAT"
  }
}

################################################################
#private route table  creation
################################################################

resource "aws_route_table" "blog-private-RT" {
  vpc_id = aws_vpc.blog.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.blog-nat.id
  }

route {
    cidr_block = "10.0.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.blog-app.id
  }

  tags = {
    Name = "blog-private-RT"
         }
}


################################################################
#private subnet 1 to route table  association
################################################################

resource "aws_route_table_association" "blog-private1-RT" {
  subnet_id      = aws_subnet.blog-private1.id
  route_table_id = aws_route_table.blog-private-RT.id
}


################################################################
#private subnet 2 to route table  association
################################################################

resource "aws_route_table_association" "blog-private1-RT2" {
  subnet_id      = aws_subnet.blog-private2.id
  route_table_id = aws_route_table.blog-private-RT.id
}

################################################################
# VPC2 creation
################################################################

resource "aws_vpc" "app" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "app"
  }
}

################################################################
#VPC  public subnet  creation
################################################################

resource "aws_subnet" "app-public" {
  vpc_id     = aws_vpc.app.id
  cidr_block = "10.0.0.0/17"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "app-public"
  }
}

################################################################
# VPC 2 private subnet  creation
################################################################

resource "aws_subnet" "app-private" {
  vpc_id     = aws_vpc.app.id
  cidr_block = "10.0.128.0/17"
  availability_zone = "us-east-2c"
  tags = {
    Name = "app-private"
  }
}

################################################################
#VPC2 internet gateway  creation
################################################################


resource "aws_internet_gateway" "app-igw" {
  vpc_id = aws_vpc.app.id

  tags = {
    Name = "app-igw"
  }
}

################################################################
#vpc 2 public route table  creation
################################################################

resource "aws_route_table" "app-public-RT" {
  vpc_id = aws_vpc.app.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app-igw.id
        }
   tags = {
        Name ="app-public-RT"
        }
}

################################################################
#VPC 2 public route table  association
################################################################

resource "aws_route_table_association" "app-public-RT" {
  subnet_id      = aws_subnet.app-public.id
  route_table_id = aws_route_table.app-public-RT.id
}

################################################################
#eip2 creation
################################################################

resource "aws_eip" "app-nat" {
  vpc      = true
  tags = {
    Name = "app-eip"
  }
}

################################################################
#nat gateway creation
################################################################


resource "aws_nat_gateway" "app-nat" {
  allocation_id = aws_eip.app-nat.id
  subnet_id     = aws_subnet.app-public.id

  tags = {
    Name = "app-NAT"
  }
}

################################################################
#private route table  creation
################################################################

resource "aws_route_table" "app-private-RT" {
  vpc_id = aws_vpc.app.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.app-nat.id
  }

route {
    cidr_block = "172.18.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.blog-app.id
  }

  tags = {
    Name = "app-private-RT"
         }
}


################################################################
#private subnet 1 to route table  association
################################################################

resource "aws_route_table_association" "app-private-RT" {
  subnet_id      = aws_subnet.app-private.id
  route_table_id = aws_route_table.app-private-RT.id
}

################################################################
#peering
################################################################

resource "aws_vpc_peering_connection" "blog-app" {
  peer_vpc_id   = aws_vpc.blog.id
  vpc_id        = aws_vpc.app.id
}


################################################################
#peering accepter
################################################################

resource "aws_vpc_peering_connection_accepter" "blog-app" {
  vpc_peering_connection_id = aws_vpc_peering_connection.blog-app.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}

################################################################
#server1 server creation
################################################################

resource "aws_instance" "webserver" {
  ami           = "ami-09558250a3419e7d0"
  instance_type = "t2.micro"
  key_name = "ohio"
  subnet_id = aws_subnet.blog-public1.id
    tags = {
    Name = "server1"
  }
}

################################################################
#server2 server creation
################################################################

resource "aws_instance" "server2" {
  ami           = "ami-09558250a3419e7d0"
  instance_type = "t2.micro"
  key_name = "ohio"
  subnet_id = aws_subnet.app-private.id
    tags = {
    Name = "server2"
  }
}
