# Домашнее задание к занятию "08.02 Работа с Playbook"

## Подготовка к выполнению

1. (Необязательно) Изучите, что такое [clickhouse](https://www.youtube.com/watch?v=fjTNS2zkeBs) и [vector](https://www.youtube.com/watch?v=CgEhyffisLY)
2. Создайте свой собственный (или используйте старый) публичный репозиторий на github с произвольным именем.
3. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.
4. Подготовьте хосты в соответствии с группами из предподготовленного playbook.

**Решение**

С помощью Terraform подготовил виртуальную машину в Яндекс-облаке. Проект для Terraform доступен в репозитории с заданием в подпапке terraform:

После применения плана мы получаем в выводе ip-адрес созданной машины. Его занесем в inventory-файл в дальнейших шагах:

```
vladimir@vp-learndevops:~/learndevops/learnansible2/terraform$ terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_compute_instance.vp_netology_learnansible will be created
  + resource "yandex_compute_instance" "vp_netology_learnansible" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                centos:ssh-rsa AA...7 vladimir@vp-learndevops
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

Plan: 3 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + instance_ip = (known after apply)
yandex_vpc_network.network-1: Creating...
yandex_vpc_network.network-1: Creation complete after 1s [id=enpsmjjc1eor0vdcpou3]
yandex_vpc_subnet.subnet-1: Creating...
yandex_vpc_subnet.subnet-1: Creation complete after 1s [id=e9bqt0n08597tklgsigl]
yandex_compute_instance.vp_netology_learnansible: Creating...
yandex_compute_instance.vp_netology_learnansible: Still creating... [10s elapsed]
yandex_compute_instance.vp_netology_learnansible: Still creating... [20s elapsed]
yandex_compute_instance.vp_netology_learnansible: Still creating... [30s elapsed]
yandex_compute_instance.vp_netology_learnansible: Creation complete after 30s [id=fhmc4ti52co06ka1ktiv]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

instance_ip = "51.250.64.182"
```

## Основная часть

1. Приготовьте свой собственный inventory файл `prod.yml`.

**Решение**

Подготовил, включил туда ip-адрес машины, созданной в Яндекс-облаке.

```yaml
---
clickhouse:
  hosts:
    clickhouse-01:
      ansible_host: 51.250.64.182
vector:
  hosts:
    vector-01:
      ansible_host: 51.250.64.182
```

2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает [vector](https://vector.dev).
3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
4. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, установить vector.

**Решение**

В исходный плей добавил параметр `remote_user: centos`, так как для этого образа в Яндекс Облаке рекомендуется его использовать.

Добавил теги.

Также добавил туда таск Flush handlers после Install clickhouse packages, чтобы стартовать Clickhouse перед попыткой создать в нем БД (как показали на лекции): 

```yaml
    - name: Flush handlers
      meta: flush_handlers
```

Добавил следующий play:

```yaml
- name: Install Vector
  hosts: vector
  remote_user: centos
  tags: vector
  tasks:
    - name: Get vector distrib
      tags: get_distrib
      ansible.builtin.get_url:
        url: "https://packages.timber.io/vector/{{ vector_version }}/vector-{{ vector_version }}-{{ vector_minor_version }}.{{ ansible_architecture }}.rpm"
        dest: "./vector-{{ vector_version }}.rpm"
    - name: Install vector distrib
      become: true
      tags: install_distrib
      ansible.builtin.yum:
        name:
          - vector-{{ vector_version }}.rpm
    - name: Check vector works correctly
      ansible.builtin.command: "vector --version"
      tags: check
      register: vector_checked
      failed_when: vector_checked.rc != 0
      changed_when: vector_checked == 0
```

5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.

**Решение**

Запустил, ошибок не обнаружено:

```
vladimir@vp-learndevops:~/learndevops/learnansible2$ ansible-lint site.yml
WARNING: PATH altered to include /usr/bin
WARNING  Overriding detected file kind 'yaml' with 'playbook' for given positional argument: site.yml
vladimir@vp-learndevops:~/learndevops/learnansible2$ 
```

6. Попробуйте запустить playbook на этом окружении с флагом `--check`.

**Решение**

Падает таск Install clickhouse packages из-за невозможности найти файл для установки, который в check-режиме не был скачен.

```
vladimir@vp-learndevops:~/learndevops/learnansible2$ ansible-playbook -i inventory/prod.yml site.yml --check

PLAY [Install Clickhouse] ***************************************************************************

TASK [Gathering Facts] ******************************************************************************
The authenticity of host '51.250.64.182 (51.250.64.182)' can't be established.
ED25519 key fingerprint is SHA256:eJUH2JqAPckFpVHLYMPBNT37UW/C/dps+ehlwgKLGPs.
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

**Решение**

Запустил, плеи и таски отработали:

```
vladimir@vp-learndevops:~/learndevops/learnansible2$ ansible-playbook -i inventory/prod.yml site.yml --diff

PLAY [Install Clickhouse] ***************************************************************************

TASK [Gathering Facts] ******************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] ***********************************************************************
changed: [clickhouse-01] => (item=clickhouse-client)
changed: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "item": "clickhouse-common-static", "msg": "Request failed", "response": "HTTP Error 404: Not Found", "status_code": 404, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Get clickhouse distrib] ***********************************************************************
changed: [clickhouse-01]

TASK [Install clickhouse packages] ******************************************************************
changed: [clickhouse-01]

TASK [Flush handlers] *******************************************************************************

RUNNING HANDLER [Start clickhouse service] **********************************************************
changed: [clickhouse-01]

TASK [Create database] ******************************************************************************
changed: [clickhouse-01]

PLAY [Install Vector] *******************************************************************************

TASK [Gathering Facts] ******************************************************************************
ok: [vector-01]

TASK [Get vector distrib] ***************************************************************************
changed: [vector-01]

TASK [Install vector distrib] ***********************************************************************
changed: [vector-01]

TASK [Check vector works correctly] *****************************************************************
ok: [vector-01]

PLAY RECAP ******************************************************************************************
clickhouse-01              : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0   
vector-01                  : ok=4    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

vladimir@vp-learndevops:~/learndevops/learnansible2$ 
```


8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.

**Решение**

Запустил, все в статусе ОК:

```
vladimir@vp-learndevops:~/learndevops/learnansible2$ ansible-playbook -i inventory/prod.yml site.yml --diff

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

TASK [Get vector distrib] ***************************************************************************
ok: [vector-01]

TASK [Install vector distrib] ***********************************************************************
ok: [vector-01]

TASK [Check vector works correctly] *****************************************************************
ok: [vector-01]

PLAY RECAP ******************************************************************************************
clickhouse-01              : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0   
vector-01                  : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

vladimir@vp-learndevops:~/learndevops/learnansible2$ 
```

9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.
10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-02-playbook` на фиксирующий коммит, в ответ предоставьте ссылку на него.

**Решение**

Ссылка на репозиторий: [https://github.com/VP32/learnansible2](https://github.com/VP32/learnansible2)