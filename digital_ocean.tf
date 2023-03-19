
terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}
# Configure the DigitalOcean provider
provider "digitalocean" {
  token = "dop_v1_eb1497af434d3cb3315ec2f5e2a70c2f7a17abb6c427497f83adeacb2981b43f"
}

# Create a new Droplet
resource "digitalocean_droplet" "visieserver" {
  name       = "visieserver"
  region     = "sgp1"
  size       = "s-1vcpu-1gb"
  image      = "ubuntu-20-04-x64"
  ssh_keys   = []
  monitoring = true

  # Set the root user's password
  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      "echo 'root:${var.root_password}' | chpasswd"
    ]
  }

  connection {
      type        = "ssh"
      user        = "root"
      password    = "${var.root_password}"
      host        = digitalocean_droplet.visieserver.ipv4_address
      timeout     = "5m"
      agent       = false
    }
}

# Define the root password variable
variable "root_password" {
  type        = string
  description = "The root password for the Droplet"
}
