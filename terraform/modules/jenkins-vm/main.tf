resource "google_compute_firewall" "jenkins_firewall" {
  name    = "jenkins-allow-8080"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["jenkins-server"]
}

resource "google_compute_instance" "jenkins_vm" {
  name         = var.vm_name
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {
      # Public IP for Jenkins access
    }
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  tags = ["jenkins-server"]

  metadata_startup_script = <<-EOT
    #!/bin/bash
    sudo apt-get update
    
    # Install Docker and its dependencies
    sudo apt-get install -y ca-certificates curl gnupg lsb-release
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg >/dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    # Run the Jenkins container
    sudo docker run \
      --name jenkins \
      --detach \
      --restart=on-failure \
      --publish 8080:8080 \
      --volume jenkins_home:/var/jenkins_home \
      jenkins/jenkins:lts
  EOT
}