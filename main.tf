provider "aws" {
  region  =  var.region_name
  profile =  var.profile_name
}

resource "null_resource" "examle1"{
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file(var.private_key)
    host     = aws_instance.myin.public_ip
  }
  provisioner "remote-exec"{
    inline = [
        "sudo yum install amazon-efs-utils nfs-utils httpd php git -y",
        "sudo systemctl restart httpd",
        "sudo systemctl enable httpd",
        "sudo mount -t efs ${aws_efs_file_system.myvol.id}:/ /var/www/html",
        "sudo chmod 666 /etc/fstab",
        "sudo echo '${aws_efs_file_system.myvol.id}:/ /var/www/html efs defaults,_netdev 0 0' >> /etc/fstab",
        "sudo rm -rf /var/www/html/*",
        "sudo git clone ${var.website_code} /var/www/html/",
    ]  
  }
  depends_on = [
     aws_efs_mount_target.efs_att
  ]
}
