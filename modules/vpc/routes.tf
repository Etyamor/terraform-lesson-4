# Створюємо маршрутну таблицю для публічних підмереж
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id # Прив'язуємо таблицю до нашої VPC

  tags = {
    Name = "${var.vpc_name}-public-rt" # Тег для таблиці маршрутів
  }
}

# Додаємо маршрут для виходу в інтернет через Internet Gateway
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id   # ID таблиці маршрутів
  destination_cidr_block = "0.0.0.0/0"                 # Всі IP-адреси
  gateway_id             = aws_internet_gateway.igw.id # Вказуємо Internet Gateway як вихід
}

# Прив'язуємо таблицю маршрутів до публічних підмереж
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets) # Прив'язуємо кожну підмережу
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Створюємо Elastic IP для NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc" # Виділяємо статичну IP-адресу в межах VPC

  tags = {
    Name = "${var.vpc_name}-nat-eip"
  }
}

# Створюємо NAT Gateway у першій публічній підмережі
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id          # Прив'язуємо Elastic IP до NAT Gateway
  subnet_id     = aws_subnet.public[0].id # Розміщуємо в першій публічній підмережі

  tags = {
    Name = "${var.vpc_name}-nat-gw"
  }

  depends_on = [aws_internet_gateway.igw] # NAT Gateway потребує Internet Gateway
}

# Створюємо маршрутну таблицю для приватних підмереж
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}

# Додаємо маршрут для виходу в інтернет через NAT Gateway
resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"             # Весь трафік назовні
  nat_gateway_id         = aws_nat_gateway.main.id # Направляємо через NAT Gateway
}

# Прив'язуємо приватну таблицю маршрутів до приватних підмереж
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
