# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
- подключения к БД
- вывода списка таблиц
- вывода описания содержимого таблиц
- выхода из psql

**Решение**

Для поднятия инстанса использовал docker-compose. Привожу манифест:

```
version: '3.1'

networks:
  postgresnet:
    driver: bridge

volumes:
  database_data: {}
  backups_data: {}

services:
  postgres:
    image: postgres:13
    container_name: postgresvp32
    volumes:
      - database_data:/var/lib/postgresql/data
      - ../test_data:/backups
    ports:
      - "5432:5432"
    networks:
      - postgresnet
    restart: always
    user: postgres
    environment:
      - POSTGRES_PASSWORD=secret
      - POSTGRES_USER=postgres
```


управляющие команды для:
- вывода списка БД

команда `\l`

- подключения к БД

команда `\c` :

`\c[onnect] {[DBNAME|- USER|- HOST|- PORT|-] | conninfo}`


- вывода списка таблиц

команда `\d `:

`\d[S+]                 list tables, views, and sequences`

- вывода описания содержимого таблиц

Команда `\d NAME`, где NAME - имя таблицы, представления, индекса

`\d[S+]  NAME           describe table, view, sequence, or index`

- выхода из psql

команда `\q`

## Задача 2

Используя `psql` создайте БД `test_database`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

**Решение**

Используя `psql` создайте БД `test_database`.

```vladimir@linuxstage:~/learndevops/devops-netology/06-db-04-postgresql/pgsql$ docker exec -it postgresvp32 /bin/bash
postgres@a6352a78c42a:/$ psql --command="create database test_database"
CREATE DATABASE
postgres@a6352a78c42a:/$ psql --command="\l"
                                   List of databases
     Name      |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
---------------+----------+----------+------------+------------+-----------------------
 postgres      | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0     | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
               |          |          |            |            | postgres=CTc/postgres
 template1     | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
               |          |          |            |            | postgres=CTc/postgres
 test_database | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
(4 rows)
```

Восстановите бэкап БД в `test_database`.

```
postgres@a6352a78c42a:/$ psql test_database < /backups/test_dump.sql 
SET
SET
SET
SET
SET
 set_config 
------------
 
(1 row)

SET
SET
SET
SET
SET
SET
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
ALTER TABLE
COPY 8
 setval 
--------
      8
(1 row)

ALTER TABLE
```

Перейдите в управляющую консоль psql внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.
```
postgres@a6352a78c42a:/$ psql
psql (13.7 (Debian 13.7-1.pgdg110+1))
Type "help" for help.

postgres=# \c test_database 
You are now connected to database "test_database" as user "postgres".
test_database=# ANALYZE orders;
ANALYZE
test_database=# ANALYZE VERBOSE orders;
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
ANALYZE
```

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

Это столбец title:

```
test_database=# select attname, max(avg_width) as maxlen from pg_stats where tablename = 'orders' group by attname order by maxlen desc limit 1;
 attname | maxlen 
---------+--------
 title   |     16
(1 row)
```



## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

**Решение**

```
begin;
alter table orders rename to orders_not_secioned;

create table orders
(
    id    serial,
    title varchar(80) not null,
    price integer default 0
) partition by range (price);

create table orders_le_499 partition of orders
for values from (0) to (500);

create table orders_g_499 partition of orders
for values from (500) to (2147483647);

insert into orders(id, title, price) select id, title, price from orders_not_secioned;

commit;
```

Можно было бы исключить ручное разбиение, если изначально создавать таблицу как секционированную.


## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

**Решение**

```
postgres@c1d0f4515eda:/$ pg_dump -d test_database > ~/new_test_database.sql
```

Для обеспечения уникальности title без секционирования можно было бы использовать уникальный индекс. 

```
create unique index orderss_title_unique on orders_not_secioned(title);
```

С секционированием, согласно документации, невозможно создать уникальный индекс для поля title для всей таблицы. Такой индекс должен включать в себя также все поля из ключа секционирования. В нашем случае это поле price. Таким образом, можно создать отдельные уникальные индексы по полю title внутри каждой секции, и можно создать уникальный индекс по полям title и price для всей таблицы:

```
alter table orders_le_499 add unique (title);
alter table orders_g_499 add unique (title);

ALTER TABLE orders ADD CONSTRAINT orders_title_unique UNIQUE (title, price);
```

Что это даст? Останется возможность ввести дублирующие значения title с уникальными price из разных секций. Внутри каждой секции мы не сможем создать дубли по title, а глобально по всей таблице - не сможем ввести дважды одно и то же сочетание title и price.



