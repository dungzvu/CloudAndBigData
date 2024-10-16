output "ips" {
  value = tolist([for instance in libvirt_domain.domain-bigdata-vm : instance.network_interface[0].addresses[0]])
}