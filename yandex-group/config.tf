terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.77.0"
    }
  }
}

provider "yandex" {
  token     = "past your token"
  cloud_id  = "b1g9jbanlh938aqasluv"
  folder_id = "b1gdbn18620nta0brqdr"
  zone      = "ru-central1-b"
}

resource "yandex_iam_service_account" "admin" {
  name        = "admin"
  description = "service account to manage IG"
}

resource "yandex_resourcemanager_folder_iam_binding" "editor" {
  folder_id = "b1gdbn18620nta0brqdr"
  role      = "editor"
  members   = [
    "serviceAccount:${yandex_iam_service_account.admin.id}",
  ]
  depends_on = [
    yandex_iam_service_account.admin,
  ]
}

resource "yandex_compute_instance_group" "ig-2" {
  name               = "fixed-ig"
  folder_id          = "b1gdbn18620nta0brqdr"
  service_account_id = "${yandex_iam_service_account.admin.id}"
  depends_on          = [yandex_resourcemanager_folder_iam_binding.editor]
  instance_template {
    platform_id = "standard-v3"
    resources {
      memory = 4
      cores  = 4
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = "fd8uoiksr520scs811jl"
        size = "15"
      }
    }

    network_interface {
      network_id = "enprf76s45t4vetotjtm"
      nat = true 
    }  
  
   metadata = {
    user-data = "${file("./cloud-config.txt")}"
    }
  }

  scale_policy {
    fixed_scale {
      size = 2
    }
  }

  allocation_policy {
    zones = ["ru-central1-b"]
  }

  deploy_policy {
    max_unavailable = 2
    max_expansion = 0
  }
}

