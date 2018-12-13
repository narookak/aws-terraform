output "Bastion Elastic IP" {
  value = "${aws_eip.bastion_eip.public_ip}"
}

#output "web-server private ips" {
#  value = "${zipmap(aws_instance.web-server.*.id, aws_instance.web-server.*.private_ip)}"
#}
output "DB Master Password" {
  value = "${random_string.password.result}"
}
