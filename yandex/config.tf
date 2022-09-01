terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.77.0"
    }
  }
}

provider "yandex" {
  token     = "Past your token"
  cloud_id  = "b1g9jbanlh938aqasluv"
  folder_id = "b1gdbn18620nta0brqdr"
  zone      = "ru-central1-b"
}

resource "yandex_iam_service_account" "sa" {
  folder_id =  "b1gdbn18620nta0brqdr"
  name      = "tf-test-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = "b1gdbn18620nta0brqdr"
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

resource "yandex_storage_bucket" "artifactory" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = "tf-war-bucket"
}

resource "yandex_compute_instance" "build" {
  name = "build"
  platform_id = "standard-v3"
  zone = "ru-central1-b"

    
 resources {
   cores  = 4
   memory = 4
 }
  
 boot_disk {
   initialize_params {
     image_id = "fd8uoiksr520scs811jl"
     size = "15"
   }
 }
  
 network_interface {
   subnet_id = "e2lihk5ttnbs7l3fu5ds"
   nat = true
 }  

 metadata = {
    user-data = "${file("./cloud-config.txt")}"
 }
 
}

resource "yandex_compute_instance" "web" {
  name = "web"
  platform_id = "standard-v3"
  zone = "ru-central1-b"


 resources {
   cores  = 4
   memory = 4
 }

 boot_disk {
   initialize_params {
     image_id = "fd8uoiksr520scs811jl"
     size = "15"
   }
}

 network_interface {
   subnet_id = "e2lihk5ttnbs7l3fu5ds"
   nat = true
 }

 metadata = {
    user-data = "${file("./cloud-config2.txt")}"
 }

}
