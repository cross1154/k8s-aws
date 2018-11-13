resource "aws_instance" "demo01" {
  count           = "${var.ec2_instance_count}"
  ami             = "${lookup(var.ami_ids, var.os_type)}"
  instance_type   = "${var.instance_type}"
  key_name        = "${var.ssh_key_name}"

  subnet_id              = "${aws_subnet.demo01.id}"
  vpc_security_group_ids = ["${aws_vpc.demo01.default_security_group_id}", "${aws_security_group.demo01.id}"]

  tags {
    Name = "demo01-${count.index}"
    "kubernetes.io/cluster/aws.devops.demo" = "owned"
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 10",
      "curl https://releases.rancher.com/install-docker/17.09.sh | sed s/17.09.0/17.09.1/g | sh",
      "sleep 10",
      "sudo usermod -aG docker ${lookup(var.ssh_users, var.os_type)}"
    ]
    on_failure = "fail"

    connection {
      type        = "ssh"
      user        = "${lookup(var.ssh_users, var.os_type)}"
      private_key = "${file("${var.ssh_key_path}")}"
      timeout     = "10m"
    }
  }
}
