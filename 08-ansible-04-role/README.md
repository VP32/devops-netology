# Домашнее задание к занятию "8.4 Работа с Roles"

## Подготовка к выполнению
1. Создайте два пустых публичных репозитория в любом своём проекте: vector-role и lighthouse-role.
2. Добавьте публичную часть своего ключа к своему профилю в github.

## Основная часть

Наша основная цель - разбить наш playbook на отдельные roles. Задача: сделать roles для clickhouse, vector и lighthouse и написать playbook для использования этих ролей. Ожидаемый результат: существуют три ваших репозитория: два с roles и один с playbook.

1. Создать в старой версии playbook файл `requirements.yml` и заполнить его следующим содержимым:

   ```yaml
   ---
     - src: git@github.com:AlexeySetevoi/ansible-clickhouse.git
       scm: git
       version: "1.11.0"
       name: clickhouse 
   ```

2. При помощи `ansible-galaxy` скачать себе эту роль.
3. Создать новый каталог с ролью при помощи `ansible-galaxy role init vector-role`.
4. На основе tasks из старого playbook заполните новую role. Разнесите переменные между `vars` и `default`. 
5. Перенести нужные шаблоны конфигов в `templates`.
6. Описать в `README.md` обе роли и их параметры.
7. Повторите шаги 3-6 для lighthouse. Помните, что одна роль должна настраивать один продукт.
8. Выложите все roles в репозитории. Проставьте тэги, используя семантическую нумерацию Добавьте roles в `requirements.yml` в playbook.
9. Переработайте playbook на использование roles. Не забудьте про зависимости lighthouse и возможности совмещения `roles` с `tasks`.
10. Выложите playbook в репозиторий.
11. В ответ приведите ссылки на оба репозитория с roles и одну ссылку на репозиторий с playbook.

---

Решение:
------

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
                centos:ssh-rsa AAAAB3Nza...xGNbG7 vladimir@vp-learndevops
            EOT
        }
      + name                      = "test-0"
      + network_acceleration_type = "standard"
      
  ...
  
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

instance_ip = {
  "0" = "178.154.201.235"
  "1" = "178.154.203.228"
  "2" = "178.154.201.16"
}

```



Выполняю скачивание ролей для использования их плейбуком:

```
vladimir@vp-learndevops:~/learndevops/learnansible2$ ansible-galaxy install -r requirements.yml --force
Starting galaxy role install process
- changing role clickhouse from 1.11.0 to 1.11.0
- extracting clickhouse to /home/vladimir/.ansible/roles/clickhouse
- clickhouse (1.11.0) was installed successfully
- changing role vector from 1.0.1 to 1.0.2
- extracting vector to /home/vladimir/.ansible/roles/vector
- vector (1.0.2) was installed successfully
- changing role nginx from 1.0.1 to 1.0.2
- extracting nginx to /home/vladimir/.ansible/roles/nginx
- nginx (1.0.2) was installed successfully
- changing role lighthouse from 1.0.1 to 1.0.2
- extracting lighthouse to /home/vladimir/.ansible/roles/lighthouse
- lighthouse (1.0.2) was installed successfully
vladimir@vp-learndevops:~/learndevops/learnansible2$ 
```

Выполняю плейбук:

```
vladimir@vp-learndevops:~/learndevops/learnansible2$ ansible-playbook -i inventory/prod.yml site.yml --diff

PLAY [Install Clickhouse] ***************************************************************************

TASK [Gathering Facts] ******************************************************************************
ok: [clickhouse-01]

TASK [clickhouse : Include OS Family Specific Variables] ********************************************
ok: [clickhouse-01]

...

>f++++++.?? lighthouse-master/js/bootstrap.min.js
changed: [lighthouse-01]

PLAY RECAP ******************************************************************************************
clickhouse-01              : ok=24   changed=0    unreachable=0    failed=0    skipped=10   rescued=0    ignored=0   
lighthouse-01              : ok=10   changed=9    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
vector-01                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

Повторно выполняю плейбук, проверяю идемпотентность:

```
vladimir@vp-learndevops:~/learndevops/learnansible2$ ansible-playbook -i inventory/prod.yml site.yml --diff

PLAY [Install Clickhouse] ***************************************************************************

TASK [Gathering Facts] ******************************************************************************
ok: [clickhouse-01]

TASK [clickhouse : Include OS Family Specific Variables] ********************************************
ok: [clickhouse-01]

...

TASK [lighthouse : Download Lighthouse ZIP] *********************************************************
ok: [lighthouse-01]

TASK [lighthouse : Extract Lighthouse ZIP] **********************************************************
ok: [lighthouse-01]

PLAY RECAP ******************************************************************************************
clickhouse-01              : ok=24   changed=0    unreachable=0    failed=0    skipped=10   rescued=0    ignored=0   
lighthouse-01              : ok=9    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
vector-01                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```


### Ссылки на репозитории:

Плейбук, использующий роли:

 - https://github.com/VP32/learnansible2, ссылка на релиз: https://github.com/VP32/learnansible2/releases/tag/08-ansible-04-role

Роли:
 - для установки Vector: https://github.com/VP32/vector-role
 - для установки Nginx: https://github.com/VP32/nginx-role
 - для установки Lighthouse: https://github.com/VP32/lighthouse-role
