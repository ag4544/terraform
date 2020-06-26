variable "hcloud_token" {
  type = string
}

provider "hcloud" {
  token = var.hcloud_token
}

data "hcloud_ssh_key" "rebrain" {
  name = "REBRAIN.SSH.PUB.KEY"
}

resource "hcloud_ssh_key" "default" {
  name       = "TF_key"
  public_key = file("/home/ag4544/terraform_tasks/terraform_task2/tf_rsa.pub")
}

resource "hcloud_server" "terraform_task6" {
  image       = "debian-10"
  name        = "ag4544-terraform-task6"
  location    = "hel1"
  server_type = "cx11"
  ssh_keys = [
    data.hcloud_ssh_key.rebrain.id,
    hcloud_ssh_key.default.id
  ]
  labels = {
    module = "devops"
    email  = "ag4544_at_yandex_ru"
  }
}

output "public_address" {
  value = hcloud_server.terraform_task6.ipv4_address
}
