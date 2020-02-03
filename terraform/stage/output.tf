output "elb_dns" {
  value       = "${module.elb.this_elb_dns_name}"
  description = "ELB DNS"
}
output "elb_zone_id" {
  value       = "${module.elb.this_elb_zone_id}"
  description = "ELB DNS"
}
