output "cicd_machine_ip" {
  value = aws_instance.cicd_machine.public_ip
}

output "production_machine_ip" {
  value = aws_instance.production_machine.public_ip
}
