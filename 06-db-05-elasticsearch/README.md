# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [elasticsearch:7](https://hub.docker.com/_/elasticsearch) как базовый:

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib` 
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Подсказки:
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения
- обратите внимание на настройки безопасности такие как `xpack.security.enabled` 
- если докер образ не запускается и падает с ошибкой 137 в этом случае может помочь настройка `-e ES_HEAP_SIZE`
- при настройке `path` возможно потребуется настройка прав доступа на директорию

Далее мы будем работать с данным экземпляром elasticsearch.

**Решение**

Составил следующий Dockerfile:

```
FROM elasticsearch:7.17.5

RUN mkdir /var/lib/elasticsearch/ && \
        chown -R elasticsearch:elasticsearch /var/lib/elasticsearch/  && \
        mkdir /usr/share/elasticsearch/snapshots/ && \
        chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/snapshots/

COPY ./config/elasticsearch.yml /usr/share/elasticsearch/config/

EXPOSE 9200

CMD ["bin/elasticsearch"]
```

Использовал следующий конфиг: [elasticsearch.yml](./elastic/config/elasticsearch.yml)

Запускал через docker-compose, манифест docker-compose.yml:

```
version: '3.1'

services:
  elastic:
    build: .
    restart: always
    ports:
      - "9200:9200"
```

Ссылка на Docker Hub: [https://hub.docker.com/repository/docker/vlpol32/elastic_netology](https://hub.docker.com/repository/docker/vlpol32/elastic_netology)

Вывод /:
```
{
  "name" : "netology_test",
  "cluster_name" : "vp32_netology",
  "cluster_uuid" : "6jRPAOheQcWRj5kusBucwA",
  "version" : {
    "number" : "7.17.5",
    "build_flavor" : "default",
    "build_type" : "docker",
    "build_hash" : "8d61b4f7ddf931f219e3745f295ed2bbc50c8e84",
    "build_date" : "2022-06-23T21:57:28.736740635Z",
    "build_snapshot" : false,
    "lucene_version" : "8.11.1",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

Получите состояние кластера `elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Удалите все индексы.

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

**Решение:**

Создание индексов:

```
curl --location --request PUT 'localhost:9200/ind-1' \
--header 'Content-Type: application/json' \
--data-raw '{
    "settings": {
        "number_of_replicas": 0,
        "number_of_shards": 1
    }
}'
```

```
curl --location --request PUT 'localhost:9200/ind-2' \
--header 'Content-Type: application/json' \
--data-raw '{
    "settings": {
        "number_of_replicas": 1,
        "number_of_shards": 2
    }
}'
```

```
curl --location --request PUT 'localhost:9200/ind-3' \
--header 'Content-Type: application/json' \
--data-raw '{
    "settings": {
        "number_of_replicas": 2,
        "number_of_shards": 4
    }
}'
```

Список индексов:

`curl --location --request GET 'localhost:9200/_cat/indices?v=true'`

```
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases 6XM4flNKRlSmBOoaJxdqOQ   1   0         40            0     37.7mb         37.7mb
green  open   ind-1            2reKrIFSQ1yoD2jd6XAzqA   1   0          0            0       226b           226b
yellow open   ind-3            43PnzEUUSZqaFFBhT7GVxQ   4   2          0            0       904b           904b
yellow open   ind-2            21odU14BSki4v43VZk_Qpg   2   1          0            0       452b           452b
```

Состояние кластера:

`curl --location --request GET 'localhost:9200/_cluster/health'`

```
{
    "cluster_name": "vp32_netology",
    "status": "yellow",
    "timed_out": false,
    "number_of_nodes": 1,
    "number_of_data_nodes": 1,
    "active_primary_shards": 10,
    "active_shards": 10,
    "relocating_shards": 0,
    "initializing_shards": 0,
    "unassigned_shards": 10,
    "delayed_unassigned_shards": 0,
    "number_of_pending_tasks": 0,
    "number_of_in_flight_fetch": 0,
    "task_max_waiting_in_queue_millis": 0,
    "active_shards_percent_as_number": 50.0
}
```

Часть индексов и кластер находятся в состоянии yellow, так как недостаточно нод для распределения по ним имеющихся шардов у этих индексов. У нас только одна нода, а у индексов 2 и 3 указаны реплики.

Удаление индексов:

curl --location --request DELETE 'localhost:9200/ind-1'
curl --location --request DELETE 'localhost:9200/ind-2'
curl --location --request DELETE 'localhost:9200/ind-3'

Индексы удалены:

`curl --location --request GET 'localhost:9200/_cat/indices?v=true'`

```
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases 6XM4flNKRlSmBOoaJxdqOQ   1   0         40            0     37.7mb         37.7mb`
```



## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

**Решение:**

Папку `/usr/share/elasticsearch/snapshots/` создал через Dockerfile и указал ее в директиве `path.repo` в `elasticsearch.yml`.

Регистрация репозитория:

```
curl --location --request PUT 'localhost:9200/_snapshot/netology_backup' \
--header 'Content-Type: application/json' \
--data-raw '{
  "type": "fs",
  "settings": {
    "location": "/usr/share/elasticsearch/snapshots"
  }
}'
```

Результат:
```
{
    "acknowledged": true
}
```

Создание индекса test:
```
curl --location --request PUT 'localhost:9200/test' \
--header 'Content-Type: application/json' \
--data-raw '{
  "settings": {
    "index": {
      "number_of_shards": 1,  
      "number_of_replicas": 0 
    }
  }
}'
```

Список индексов:

```
curl --location --request GET 'localhost:9200/_cat/indices?v=true'
```

```
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases rhKlTSQvSyGlw4blAyzPJQ   1   0         40            0     37.7mb         37.7mb
green  open   test             u-QA_eSlQrilBTAax6kF0g   1   0          0            0       226b           226b
```

Создание снэпшота:
```
curl --location --request PUT 'localhost:9200/_snapshot/netology_backup/my_snapshot'
```

```
{
    "accepted": true
}
```

Список файлов директории `/usr/share/elasticsearch/snapshots` :
```
root@9b27ecefa71f:/usr/share/elasticsearch# ls /usr/share/elasticsearch/snapshots/ -lah
total 60K
drwxr-xr-x 1 elasticsearch elasticsearch 4.0K Jul 21 13:41 .
drwxrwxr-x 1 root          root          4.0K Jul 21 13:25 ..
-rw-rw-r-- 1 elasticsearch root          1.4K Jul 21 13:41 index-0
-rw-rw-r-- 1 elasticsearch root             8 Jul 21 13:41 index.latest
drwxrwxr-x 6 elasticsearch root          4.0K Jul 21 13:41 indices
-rw-rw-r-- 1 elasticsearch root           29K Jul 21 13:41 meta-HAvQ_DULS-uGWMlw_KRLOg.dat
-rw-rw-r-- 1 elasticsearch root           710 Jul 21 13:41 snap-HAvQ_DULS-uGWMlw_KRLOg.dat
```

Результирующий список индексов после удаления test и создания test-2:

```
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2           nQar2LSRSxe0nS5ouqM-Rg   1   0          0            0       226b           226b
green  open   .geoip_databases rhKlTSQvSyGlw4blAyzPJQ   1   0         40            0     37.7mb         37.7mb
```


Восстановление из снэпшота. Пришлось явно указать индекс test для восстановления, так как восстановление без аргументов приводило к ошибке из-за того, что дефолтный индекс .geoip_databases уже существовал: 

```
curl --location --request POST 'localhost:9200/_snapshot/netology_backup/my_snapshot/_restore' \
--header 'Content-Type: application/json' \
--data-raw '{
    "indices": "test"
}'
```

Список индексов после восстановления:

```
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2           nQar2LSRSxe0nS5ouqM-Rg   1   0          0            0       226b           226b
green  open   .geoip_databases rhKlTSQvSyGlw4blAyzPJQ   1   0         40            0     37.7mb         37.7mb
green  open   test             jF4and62RQ-ynTBIn1K1Uw   1   0          0            0       226b           226b
```