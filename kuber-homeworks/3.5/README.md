# Домашнее задание к занятию "Troubleshooting"


### Задание. При деплое приложение web-consumer не может подключиться к auth-db. Необходимо это исправить.

1. Установить приложение по команде:
```shell
kubectl apply -f https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml
```
2. Выявить проблему и описать.
3. Исправить проблему, описать, что сделано.
4. Продемонстрировать, что проблема решена.



**Решение:**

У меня сразу же не запустилось по команде, ругается на то, что нет неймспейсов web и data в моем кластере:

![1.png](img%2F1.png)

Если создать неймпсейсы, то манифест применяется:

![2.png](img%2F2.png)

Все запускается, смотрим логи одного из подов web-consumer. Видно, что не видит хост auth-db:

![3.png](img%2F3.png)

Проблема в том, что сервис auth-db находится в неймспейсе data, в то время как web-consumer обращается к нему в своем неймспейсе web.

Пробую исправить адрес в команде для web-consumer-а, вместо auth-db в команде пробую указать вместе с неймспейсом адрес сервиса auth-db.data.
Исправляю деплоймент с помощью команды `kubectl edit -n web deployments.apps web-consumer`:

![5.png](img%2F5.png)

![4.png](img%2F4.png)

Изменения применятся, поды пересоздадутся. Смотрим логи одного из подов web-consumer, видим, что curl успешно отрабатывает:

![6.png](img%2F6.png)

Смотрим логи второго пода, там тоже curl отрабатывает:

![7.png](img%2F7.png)

Проблема решена.



