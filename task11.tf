provider "hcloud" {
  token = var.hcloud_token
}

data "hcloud_ssh_key" "rebrain" {
  name = "REBRAIN.SSH.PUB.KEY"
}

resource "hcloud_ssh_key" "default" {
  name       = "TF_key2"
  public_key = file("/home/ag4544n2/.ssh/terraform_rsa.pub")
}

resource "random_password" "password" {
  count            = length(var.devs)
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "hcloud_server" "terraform_task11" {
  count       = length(var.devs)
  image       = "debian-10"
  name        = var.devs[count.index]
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

  provisioner "remote-exec" {
    inline = ["echo 'root:${random_password.password[count.index].result}' | chpasswd"]
  }


  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("/home/ag4544n2/.ssh/terraform_rsa")
    host        = self.ipv4_address
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

resource "aws_route53_record" "task11" {
  count   = length(var.devs)
  zone_id = data.aws_route53_zone.rebrain.zone_id
  name    = "${var.devs[count.index]}.${data.aws_route53_zone.rebrain.name}"
  type    = "A"
  ttl     = "300"
  records = [hcloud_server.terraform_task11[count.index].ipv4_address]
}

output "VPS_summary" {
  value = [hcloud_server.terraform_task11.*.ipv4_address, aws_route53_record.task11.*.name, random_password.password.*.result]
}

resource "local_file" "VPS_summary" {
  content  = join("\n", hcloud_server.terraform_task11.*.ipv4_address, aws_route53_record.task11.*.name, random_password.password.*.result)
  filename = "${path.module}/vps.txt"
}
