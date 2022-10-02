data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}

# Creates a GCP VM Instance.  Metadata Startup script install the Nginx webserver.
resource "google_compute_instance" "vm" {
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["http-server","foo", "web"]
  #source_tags  = ["foo"]
  #target_tags  = ["web"]
  labels       = var.labels

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }

  metadata_startup_script = data.template_file.nginx.rendered
}

data "template_file" "nginx" {
  template = file("${path.module}/template/install_nginx.tpl")

  vars = {
    ufw_allow_nginx = "Nginx HTTP"
  }
}

resource "google_compute_firewall" "rules" {
  network     = "default"
  description = "Creates firewall rule targeting tagged instances"

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000"]
  }

  source_tags = ["foo"]
  target_tags = ["web"]
}