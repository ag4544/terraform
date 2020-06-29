variable "hcloud_token" {
  type = string
}

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

variable "hcloud_server_count" {
  type = number
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

resource "hcloud_server" "terraform_task8" {
  count       = var.hcloud_server_count
  image       = "debian-10"
  name        = "ag4544-terraform-task8-${count.index + 1}"
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

provider "aws" {
  region     = "eu-north-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

data "aws_route53_zone" "rebrain" {
  name         = "devops.rebrain.srwx.net."
  private_zone = false
}

resource "aws_route53_record" "task8" {
  count   = var.hcloud_server_count
  zone_id = data.aws_route53_zone.rebrain.zone_id
  name    = "ag4544_at_yandex_ru-${count.index + 1}.${data.aws_route53_zone.rebrain.name}"
  type    = "A"
  ttl     = "300"
  records = [hcloud_server.terraform_task8[count.index].ipv4_address]
}
