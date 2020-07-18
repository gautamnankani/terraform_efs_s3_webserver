// efs volume creation 
resource "aws_efs_file_system" "myvol" {
  creation_token = "my-efs"
  tags = {
    Name = "myefs"
  }
}


// Mounting above efs volume and instance
resource "aws_efs_mount_target" "efs_att" {
  file_system_id = aws_efs_file_system.myvol.id
  subnet_id      = aws_instance.myin.subnet_id
  security_groups = [ aws_security_group.my_sec.id ]
}
