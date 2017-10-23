resource "digitalocean_droplet" "test" {
    image = "centos-7-x64"
    name = "test"
    region = "lon1"
    size = "512mb"
    private_networking = true
    ssh_keys = [
      "${var.ssh_fingerprint}"
    ]

  connection {
      user = "root"
      type = "ssh"
      private_key = "${file(var.pvt_key)}"
      timeout = "2m"
  }

#  provisioner "remote-exec" {
#    inline = [
#      "export PATH=$PATH:/usr/bin",
#      "sudo yum -y update"
#    ]
#  }
#     command = "sleep 30 && echo -e \"[webserver]\n${digitalocean_droplet.web.ipv4_address} ansible_connection=ssh ansible_ssh_user=root\" > inventory &&  ansible-playbook -i inventory oc-playbook.yml"
# Can this use EOF
  provisioner "local-exec" {
  command = <<EOF
            sleep 30
            echo "[webserver]\n${digitalocean_droplet.test.ipv4_address} ansible_connection=ssh ansible_ssh_user=root" > inventory
            ansible-playbook -i inventory /home/steve/ansible/playbook.yml
            EOF
  }
}
