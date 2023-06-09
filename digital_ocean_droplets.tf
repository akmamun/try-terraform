
# define packages 
terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Create API token from DigitalOcean and Configure API Token
provider "digitalocean" {
  token = "digitalocean_token"
}

# Network firewall define, allow necessary port
resource "digitalocean_firewall" "visie-server-firewall" {
  name = "visie-server-firewall"

  droplet_ids = [digitalocean_droplet.visie-server.id]
  tags   = [digitalocean_tag.visie-tag.id]

 inbound_rule {
    protocol = "tcp"
    port_range = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }


  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

   inbound_rule {
    protocol         = "tcp"
    port_range       = "5000"
    source_addresses = ["0.0.0.0/0"]
  }


}

# Add ssh key for future ssh access 
resource "digitalocean_ssh_key" "my_ssh_key" {
  name = "new_ssh_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Create a new Droplet Configuration
resource "digitalocean_droplet" "visie-server" {
  name       = "visie-server"
  region     = "sgp1"
  size       = "s-1vcpu-1gb"
  image      = "ubuntu-20-04-x64"
  ssh_keys   = [digitalocean_ssh_key.my_ssh_key.id]
  monitoring = false
  tags   = [digitalocean_tag.visie-tag.id]

}

# create tags 
resource "digitalocean_tag" "visie-tag" {
  name = "visie-tag"
}

# assined ip 
output "droplet_ip_address" {
  value = digitalocean_droplet.visie-server.ipv4_address
}

# create reserved ip 
resource "digitalocean_reserved_ip" "visie-reserved-ip" {
  region = "sgp1"
} 

# assinded reserved ip to droplet
resource "digitalocean_reserved_ip_assignment" "assigned-ip" {
  ip_address = digitalocean_reserved_ip.visie-reserved-ip.ip_address
  droplet_id = digitalocean_droplet.visie-server.id
}
