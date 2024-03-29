# Домашнее задание к занятию "10.04. ELK"

## Дополнительные ссылки

При выполнении задания пользуйтесь вспомогательными ресурсами:

- [поднимаем elk в докер](https://www.elastic.co/guide/en/elastic-stack-get-started/current/get-started-docker.html)
- [поднимаем elk в докер с filebeat и докер логами](https://www.sarulabs.com/post/5/2019-08-12/sending-docker-logs-to-elasticsearch-and-kibana-with-filebeat.html)
- [конфигурируем logstash](https://www.elastic.co/guide/en/logstash/current/configuration.html)
- [плагины filter для logstash](https://www.elastic.co/guide/en/logstash/current/filter-plugins.html)
- [конфигурируем filebeat](https://www.elastic.co/guide/en/beats/libbeat/5.3/config-file-format.html)
- [привязываем индексы из elastic в kibana](https://www.elastic.co/guide/en/kibana/current/index-patterns.html)
- [как просматривать логи в kibana](https://www.elastic.co/guide/en/kibana/current/discover.html)
- [решение ошибки increase vm.max_map_count elasticsearch](https://stackoverflow.com/questions/42889241/how-to-increase-vm-max-map-count)

В процессе выполнения задания могут возникнуть также не указанные тут проблемы в зависимости от системы.

Используйте output stdout filebeat/kibana и api elasticsearch для изучения корня проблемы и ее устранения.

## Задание повышенной сложности

Не используйте директорию [help](./help) при выполнении домашнего задания.

## Задание 1

Вам необходимо поднять в докере:
- elasticsearch(hot и warm ноды)
- logstash
- kibana
- filebeat

и связать их между собой.

Logstash следует сконфигурировать для приёма по tcp json сообщений.

Filebeat следует сконфигурировать для отправки логов docker вашей системы в logstash.

В директории [help](./help) находится манифест docker-compose и конфигурации filebeat/logstash для быстрого 
выполнения данного задания.

Результатом выполнения данного задания должны быть:
- скриншот `docker ps` через 5 минут после старта всех контейнеров (их должно быть 5)
- скриншот интерфейса kibana
- docker-compose манифест (если вы не использовали директорию help)
- ваши yml конфигурации для стека (если вы не использовали директорию help)

**Решение:**

Поднял из готового манифеста по директории help. Потребовалось включить vpn - иначе образ для Elasticsearch не скачивался.

Потребовалось внести изменения на хост-машине, как описано в одном из материалов, иначе падали контейнеры с Elastic:

`sysctl -w vm.max_map_count=262144`

И внести эту настройку в `/etc/sysctl.conf`.

При запуске падает контейнер с Filebeat с ошибкой:

`Exiting: error loading config file: config file ("filebeat.yml") must be owned by the user identifier (uid=0) or root`

На хост-машине переопределил права к конфигу filebeat:

```
chown root ./configs/filebeat.yml
chmod go-w ./configs/filebeat.yml
```

Далее потребовался ряд исправлений:

 - Дополнил [docker-compose.yml](./help/docker-compose.yml) по части конфигурации logstash, добавил filebeat в сеть elastic
 - исправил программу [run.py](./help/pinger/run.py), чтобы логировала в json-формате
 - исправил конфиг [logstash.conf](./help/configs/logstash.conf) для корректной обработки данных, иначе прокидывались крякозябры и не долетало до Эластика - вместо tcp указал input beats, подправил output по части названия индекса в Эластике.


Скриншот `docker ps` через 5 минут после старта всех контейнеров:

![](img/ps.png)

Скриншот интерфейса kibana:

![](img/k1.png)


## Задание 2

Перейдите в меню [создания index-patterns  в kibana](http://localhost:5601/app/management/kibana/indexPatterns/create)
и создайте несколько index-patterns из имеющихся.

Перейдите в меню просмотра логов в kibana (Discover) и самостоятельно изучите как отображаются логи и как производить 
поиск по логам.

В манифесте директории help также приведенно dummy приложение, которое генерирует рандомные события в stdout контейнера.
Данные логи должны порождать индекс logstash-* в elasticsearch. Если данного индекса нет - воспользуйтесь советами 
и источниками из раздела "Дополнительные ссылки" данного ДЗ.
 
**Решение:**

Индексы из приложения добавились в меню создания index-patterns:

![](img/k3.png)

Создал несколько индекс-паттернов:

![](img/k4.png)

Логи в Discover:

![](img/k5.png)


![](img/k6.png)