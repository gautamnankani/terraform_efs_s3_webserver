// variable for image_id
variable "image_id" {
  type = string
  default  =  "ami-0447a12f28fddb066"
}


//key creation
resource "aws_key_pair" "deployer" {
  key_name   = var.key_Name
  public_key = file(var.public_key)
}

// instace creation using above image id
resource "aws_instance" "myin" {
  ami           = var.image_id
  instance_type = var.instance_Type
  security_groups = [ aws_security_group.my_sec.name ]
  key_name =  var.key_Name
  tags = {
    Name = "os2"
  }
  depends_on = [
    aws_key_pair.deployer,
    aws_security_group.my_sec,
  ]
}
