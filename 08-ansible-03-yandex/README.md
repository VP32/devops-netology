# Домашнее задание к занятию "08.03 Использование Yandex Cloud"

## Подготовка к выполнению

1. Подготовьте в Yandex Cloud три хоста: для `clickhouse`, для `vector` и для `lighthouse`.

Ссылка на репозиторий LightHouse: https://github.com/VKCOM/lighthouse

## Основная часть

1. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает lighthouse.
2. При создании tasks рекомендую использовать модули: `get_url`, `template`, `yum`, `apt`.
3. Tasks должны: скачать статику lighthouse, установить nginx или любой другой webserver, настроить его конфиг для открытия lighthouse, запустить webserver.
4. Приготовьте свой собственный inventory файл `prod.yml`.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.
10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-03-yandex` на фиксирующий коммит, в ответ предоставьте ссылку на него.

**Решение:**

Разворачивал хосты в Yandex Cloud с помощью Terraform. План для Terraform находится в папке terraform репозитория с заданием. После выполнения будут выведены ip-адреса созданных хостов:

```
vladimir@vp-learndevops:~/learndevops/learnansible2/terraform$ terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_compute_instance.vp_netology_learnansible[0] will be created
  + resource "yandex_compute_instance" "vp_netology_learnansible" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                centos:ssh-rsa AAAA...xGNbG7 vladimir@vp-learndevops
            EOT
        }
      + name                      = "test-0"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd88d14a6790do254kj7"
              + name        = (known after apply)
              + size        = (known after apply)
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_compute_instance.vp_netology_learnansible[1] will be created
  + resource "yandex_compute_instance" "vp_netology_learnansible" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                centos:ssh-rsa AAA...xGNbG7 vladimir@vp-learndevops
            EOT
        }
      + name                      = "test-1"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd88d14a6790do254kj7"
              + name        = (known after apply)
              + size        = (known after apply)
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_compute_instance.vp_netology_learnansible[2] will be created
  + resource "yandex_compute_instance" "vp_netology_learnansible" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                centos:ssh-rsa AAAA...GNbG7 vladimir@vp-learndevops
            EOT
        }
      + name                      = "test-2"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd88d14a6790do254kj7"
              + name        = (known after apply)
              + size        = (known after apply)
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_vpc_network.network-1 will be created
  + resource "yandex_vpc_network" "network-1" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "network1"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.subnet-1 will be created
  + resource "yandex_vpc_subnet" "subnet-1" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnet1"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.0.0/16",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

Plan: 5 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + instance_ip = {
      + "0" = (known after apply)
      + "1" = (known after apply)
      + "2" = (known after apply)
    }
yandex_vpc_network.network-1: Creating...
yandex_vpc_network.network-1: Creation complete after 1s [id=enpjomsj553uadv4sck9]
yandex_vpc_subnet.subnet-1: Creating...
yandex_vpc_subnet.subnet-1: Creation complete after 1s [id=e9bq0di92bmc24uetg0g]
yandex_compute_instance.vp_netology_learnansible[2]: Creating...
yandex_compute_instance.vp_netology_learnansible[0]: Creating...
yandex_compute_instance.vp_netology_learnansible[1]: Creating...
yandex_compute_instance.vp_netology_learnansible[2]: Still creating... [10s elapsed]
yandex_compute_instance.vp_netology_learnansible[0]: Still creating... [10s elapsed]
yandex_compute_instance.vp_netology_learnansible[1]: Still creating... [10s elapsed]
yandex_compute_instance.vp_netology_learnansible[0]: Still creating... [20s elapsed]
yandex_compute_instance.vp_netology_learnansible[2]: Still creating... [20s elapsed]
yandex_compute_instance.vp_netology_learnansible[1]: Still creating... [20s elapsed]
yandex_compute_instance.vp_netology_learnansible[2]: Creation complete after 25s [id=fhm0f5m4s0kfanm4gv1v]
yandex_compute_instance.vp_netology_learnansible[1]: Still creating... [30s elapsed]
yandex_compute_instance.vp_netology_learnansible[0]: Still creating... [30s elapsed]
yandex_compute_instance.vp_netology_learnansible[0]: Creation complete after 31s [id=fhmua2ka290vh2cd11dt]
yandex_compute_instance.vp_netology_learnansible[1]: Creation complete after 34s [id=fhm67lq6ap0liem6lm7r]

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

instance_ip = {
  "0" = "51.250.93.73"
  "1" = "62.84.124.253"
  "2" = "51.250.0.152"
}
```


Эти адреса используем в inventory для Ansible.

1. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает lighthouse.
2. При создании tasks рекомендую использовать модули: `get_url`, `template`, `yum`, `apt`.
3. Tasks должны: скачать статику lighthouse, установить nginx или любой другой webserver, настроить его конфиг для открытия lighthouse, запустить webserver.
4. Приготовьте свой собственный inventory файл `prod.yml`.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.

Ошибок не найдено:

```
vladimir@vp-learndevops:~/learndevops/learnansible2$ ansible-lint site.yml 
WARNING: PATH altered to include /usr/bin
WARNING  Overriding detected file kind 'yaml' with 'playbook' for given positional argument: site.yml
vladimir@vp-learndevops:~/learndevops/learnansible2$ 
```

6. Попробуйте запустить playbook на этом окружении с флагом `--check`.

Падает таск Install clickhouse packages из-за невозможности найти файл для установки, который в check-режиме не был скачен.

```
vladimir@vp-learndevops:~/learndevops/learnansible2$ ansible-playbook -i inventory/prod.yml site.yml   --check

PLAY [Install Clickhouse] ***************************************************************************

TASK [Gathering Facts] ******************************************************************************
The authenticity of host '51.250.93.73 (51.250.93.73)' can't be established.
ED25519 key fingerprint is SHA256:gNQdbK/NZKiQ3bJCa7ca/yjRC9V5QnkhFBYD6K1Fbes.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
ok: [clickhouse-01]

TASK [Get clickhouse distrib] ***********************************************************************
changed: [clickhouse-01] => (item=clickhouse-client)
changed: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "item": "clickhouse-common-static", "msg": "Request failed", "response": "HTTP Error 404: Not Found", "status_code": 404, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Get clickhouse distrib] ***********************************************************************
changed: [clickhouse-01]

TASK [Install clickhouse packages] ******************************************************************
fatal: [clickhouse-01]: FAILED! => {"changed": false, "msg": "No RPM file matching 'clickhouse-common-static-22.3.3.44.rpm' found on system", "rc": 127, "results": ["No RPM file matching 'clickhouse-common-static-22.3.3.44.rpm' found on system"]}

PLAY RECAP ******************************************************************************************
clickhouse-01              : ok=2    changed=1    unreachable=0    failed=1    skipped=0    rescued=1    ignored=0   

vladimir@vp-learndevops:~/learndevops/learnansible2$ 
```


7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.

```
vladimir@vp-learndevops:~/learndevops/learnansible2$ ansible-playbook -i inventory/prod.yml site.yml   --diff

PLAY [Install Clickhouse] ***************************************************************************

TASK [Gathering Facts] ******************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] ***********************************************************************
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "gid": 1000, "group": "centos", "item": "clickhouse-common-static", "mode": "0664", "msg": "Request failed", "owner": "centos", "response": "HTTP Error 429: Too Many Requests", "secontext": "unconfined_u:object_r:user_home_t:s0", "size": 246310036, "state": "file", "status_code": 429, "uid": 1000, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

...

-#        error_page 500 502 503 504 /50x.html;
-#            location = /50x.html {
-#        }
-#    }
-
-}
-
+}
\ No newline at end of file


TASK [Start Nginx service] ************************************************************************** 
changed: [lighthouse-01]

PLAY RECAP ****************************************************************************************** 
clickhouse-01              : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0   
lighthouse-01              : ok=9    changed=6    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
vector-01                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```



8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.

```
vladimir@vp-learndevops:~/learndevops/learnansible2$ ansible-playbook -i inventory/prod.yml site.yml  --diff

PLAY [Install Clickhouse] ***************************************************************************

TASK [Gathering Facts] ******************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] ***********************************************************************
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "gid": 1000, "group": "centos", "item": "clickhouse-common-static", "mode": "0664", "msg": "Request failed", "owner": "centos", "response": "HTTP Error 404: Not Found", "secontext": "unconfined_u:object_r:user_home_t:s0", "size": 246310036, "state": "file", "status_code": 404, "uid": 1000, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Get clickhouse distrib] ***********************************************************************
ok: [clickhouse-01]

TASK [Install clickhouse packages] ******************************************************************
ok: [clickhouse-01]

TASK [Flush handlers] *******************************************************************************

TASK [Create database] ******************************************************************************
ok: [clickhouse-01]

PLAY [Install Vector] *******************************************************************************

TASK [Gathering Facts] ******************************************************************************
ok: [vector-01]

TASK [Install vector distrib] ***********************************************************************
ok: [vector-01]

TASK [Check vector works correctly] *****************************************************************
ok: [vector-01]

PLAY [Install Lighthouse] ***************************************************************************

TASK [Gathering Facts] ******************************************************************************
ok: [lighthouse-01]

TASK [Install unzip] ********************************************************************************
ok: [lighthouse-01]

TASK [Install EPEL repo] ****************************************************************************
ok: [lighthouse-01]

TASK [Install Nginx] ********************************************************************************
ok: [lighthouse-01]

TASK [Download Lighthouse ZIP] **********************************************************************
ok: [lighthouse-01]

TASK [Extract Lighthouse ZIP] ***********************************************************************
ok: [lighthouse-01]

TASK [Allow connections on 80 port] *****************************************************************
ok: [lighthouse-01]

TASK [Copy Nginx config] ****************************************************************************
ok: [lighthouse-01]

TASK [Start Nginx service] **************************************************************************
ok: [lighthouse-01]

PLAY RECAP ******************************************************************************************
clickhouse-01              : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0   
lighthouse-01              : ok=9    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
vector-01                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

vladimir@vp-learndevops:~/learndevops/learnansible2$ 

```


9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.
10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-03-yandex` на фиксирующий коммит, в ответ предоставьте ссылку на него.

Репозиторий с заданием: https://github.com/VP32/learnansible2

Ссылка на релиз по тегу: https://github.com/VP32/learnansible2/releases/tag/08-ansible-03-yandex