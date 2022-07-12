# Домашнее задание к занятию "6.2. SQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

**Результат**

Использовал docker-compose, привожу docker-compose.yaml:

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
    image: postgres:12
    container_name: postgresvp32
    volumes:
      - database_data:/var/lib/postgresql/data
      - backups_data:/var/lib/postgresql
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

## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user  
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,
- описание таблиц (describe)
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
- список пользователей с правами над таблицами test_db

**Результат:**

- итоговый список БД после выполнения пунктов выше
```
vladimir@linuxstage:~/learndevops/devops-netology/06-db-02-sql/src$ docker exec -it  postgresvp32 psql
psql (12.11 (Debian 12.11-1.pgdg110+1))
Type "help" for help.

postgres=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
(4 rows)

```

- описание таблиц (describe)
```
postgres=# \c test_db;
You are now connected to database "test_db" as user "postgres".
test_db=# \d clients
                                     Table "public.clients"
  Column  |          Type          | Collation | Nullable |               Default               
----------+------------------------+-----------+----------+-------------------------------------
 id       | integer                |           | not null | nextval('clients_id_seq'::regclass)
 name     | character varying(255) |           |          | 
 country  | character varying(255) |           |          | 
 order_id | integer                |           |          | 
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
    "clients_country_idx" btree (country)
Foreign-key constraints:
    "clients_order_id_fkey" FOREIGN KEY (order_id) REFERENCES orders(id)
test_db=# \d orders
                                    Table "public.orders"
 Column |          Type          | Collation | Nullable |              Default               
--------+------------------------+-----------+----------+------------------------------------
 id     | integer                |           | not null | nextval('orders_id_seq'::regclass)
 name   | character varying(255) |           |          | 
 price  | integer                |           |          | 
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_order_id_fkey" FOREIGN KEY (order_id) REFERENCES orders(id)

```

- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db

```
SELECT * FROM information_schema.table_privileges WHERE table_catalog = 'test_db' AND table_schema='public' ORDER BY grantee;
```
- список пользователей с правами над таблицами test_db

```
test_db=# SELECT * FROM information_schema.table_privileges WHERE table_catalog = 'test_db' AND table_schema='public' ORDER BY grantee;
 grantor  |     grantee      | table_catalog | table_schema | table_name | privilege_type | is_grantabl
e | with_hierarchy 
----------+------------------+---------------+--------------+------------+----------------+------------
--+----------------
 postgres | postgres         | test_db       | public       | orders     | INSERT         | YES        
  | NO
 postgres | postgres         | test_db       | public       | orders     | SELECT         | YES        
  | YES
 postgres | postgres         | test_db       | public       | orders     | UPDATE         | YES        
  | NO
 postgres | postgres         | test_db       | public       | orders     | DELETE         | YES        
  | NO
 postgres | postgres         | test_db       | public       | orders     | TRUNCATE       | YES        
  | NO
 postgres | postgres         | test_db       | public       | orders     | REFERENCES     | YES        
  | NO
 postgres | postgres         | test_db       | public       | orders     | TRIGGER        | YES        
  | NO
 postgres | postgres         | test_db       | public       | clients    | INSERT         | YES        
  | NO
 postgres | postgres         | test_db       | public       | clients    | SELECT         | YES        
  | YES
 postgres | postgres         | test_db       | public       | clients    | UPDATE         | YES        
  | NO
 postgres | postgres         | test_db       | public       | clients    | DELETE         | YES        
  | NO
 postgres | postgres         | test_db       | public       | clients    | TRUNCATE       | YES        
  | NO
 postgres | postgres         | test_db       | public       | clients    | REFERENCES     | YES        
  | NO
 postgres | postgres         | test_db       | public       | clients    | TRIGGER        | YES        
  | NO
 postgres | test-admin-user  | test_db       | public       | orders     | TRIGGER        | NO         
  | NO
 postgres | test-admin-user  | test_db       | public       | clients    | UPDATE         | NO         
  | NO
 postgres | test-admin-user  | test_db       | public       | clients    | DELETE         | NO         
  | NO
 postgres | test-admin-user  | test_db       | public       | orders     | INSERT         | NO         
  | NO
 postgres | test-admin-user  | test_db       | public       | orders     | SELECT         | NO         
  | YES
 postgres | test-admin-user  | test_db       | public       | orders     | UPDATE         | NO         
  | NO
 postgres | test-admin-user  | test_db       | public       | orders     | DELETE         | NO         
  | NO

...skipping 1 line
 postgres | test-admin-user  | test_db       | public       | orders     | REFERENCES     | NO         
  | NO
 postgres | test-admin-user  | test_db       | public       | clients    | TRUNCATE       | NO         
  | NO
 postgres | test-admin-user  | test_db       | public       | clients    | REFERENCES     | NO         
  | NO
 postgres | test-admin-user  | test_db       | public       | clients    | TRIGGER        | NO         
  | NO
 postgres | test-admin-user  | test_db       | public       | clients    | INSERT         | NO         
  | NO
 postgres | test-admin-user  | test_db       | public       | clients    | SELECT         | NO         
  | YES
 postgres | test-simple-user | test_db       | public       | orders     | SELECT         | NO         
  | YES
 postgres | test-simple-user | test_db       | public       | orders     | UPDATE         | NO         
  | NO
 postgres | test-simple-user | test_db       | public       | orders     | DELETE         | NO         
  | NO
 postgres | test-simple-user | test_db       | public       | clients    | UPDATE         | NO         
  | NO
 postgres | test-simple-user | test_db       | public       | clients    | DELETE         | NO         
  | NO
 postgres | test-simple-user | test_db       | public       | orders     | INSERT         | NO         
  | NO
 postgres | test-simple-user | test_db       | public       | clients    | INSERT         | NO         
  | NO
 postgres | test-simple-user | test_db       | public       | clients    | SELECT         | NO         
  | YES
(36 rows)

```

## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.

**Результат**

_Запросы на вставку:_

```
INSERT INTO orders (name, price)
VALUES ('Шоколад', 10),
       ('Принтер', 3000),
       ('Книга', 500),
       ('Монитор', 7000),
       ('Гитара', 4000);

INSERT INTO clients (name, country)
VALUES ('Иванов Иван Иванович', 'USA'),
       ('Петров Петр Петрович', 'Canada'),
       ('Иоганн Себастьян Бах', 'Japan'),
       ('Ронни Джеймс Дио', 'Russia'),
       ('Ritchie Blackmore', 'Russia');
```

_Запросы на расчет количества записей и результаты их выполнения:_

```
test_db=# SELECT count(*) FROM clients;
 count 
-------
     5
(1 row)

test_db=# SELECT count(*) FROM orders;
 count 
-------
     5
(1 row)
```


## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
 
Подсказк - используйте директиву `UPDATE`.

**Результат**

_Запросы на обновление данных (простановку заказов пользователям):_

```
UPDATE clients SET order_id = (SELECT id FROM orders WHERE name='Книга') WHERE name = 'Иванов Иван Иванович';
UPDATE clients SET order_id = (SELECT id FROM orders WHERE name='Монитор') WHERE name = 'Петров Петр Петрович';
UPDATE clients SET order_id = (SELECT id FROM orders WHERE name='Гитара') WHERE name = 'Иоганн Себастьян Бах';
```

_Варианты запроса на поиск пользователей, совершивших заказы:_

Через соединение с таблицей orders, при этом будут показаны только те пользователи, по которым есть записи в таблице orders:

```
test_db=# SELECT cl.* FROM clients as cl
INNER JOIN orders o on o.id = cl.order_id;
 id |         name         | country | order_id 
----+----------------------+---------+----------
  1 | Иванов Иван Иванович | USA     |        3
  2 | Петров Петр Петрович | Canada  |        4
  3 | Иоганн Себастьян Бах | Japan   |        5
(3 rows)

```

Более простой вариант, через поиск пользователей, у которых заполнено поле order_id: 

```
test_db=# SELECT * FROM clients WHERE clients.order_id IS NOT NULL;
 id |         name         | country | order_id 
----+----------------------+---------+----------
  1 | Иванов Иван Иванович | USA     |        3
  2 | Петров Петр Петрович | Canada  |        4
  3 | Иоганн Себастьян Бах | Japan   |        5
(3 rows)
```



## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

```
test_db=# EXPLAIN SELECT cl.* FROM clients as cl
INNER JOIN orders o on o.id = cl.order_id;
                                QUERY PLAN                                 
---------------------------------------------------------------------------
 Hash Join  (cost=11.57..24.20 rows=70 width=1040)
   Hash Cond: (o.id = cl.order_id)
   ->  Seq Scan on orders o  (cost=0.00..11.40 rows=140 width=4)
   ->  Hash  (cost=10.70..10.70 rows=70 width=1040)
         ->  Seq Scan on clients cl  (cost=0.00..10.70 rows=70 width=1040)
(5 rows)

test_db=# EXPLAIN SELECT * FROM clients WHERE clients.order_id IS NOT NULL;
                         QUERY PLAN                         
------------------------------------------------------------
 Seq Scan on clients  (cost=0.00..10.70 rows=70 width=1040)
   Filter: (order_id IS NOT NULL)
(2 rows)
```

Для первого варианта показывает стоимость (нагрузку) запроса. Показывает связь таблиц, ее условие, шаги и сканирование таблиц после связи для сбора данных. 

Для второго варианта аналогично показывает стоимость запроса. Показывает фильтрацию данных по полю order_id по условию IS NOT NULL для выборки данных.

По стоимости запроса (значению cost) второй вариант более оптимальный, т.к. стоимость меньше 0.00..10.70 - против 11.57..24.20 у первого варианта.

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

**Результат**


Создаем бэкап:

```
vladimir@linuxstage:~/learndevops/devops-netology/06-db-02-sql/src$ docker exec -it postgresvp32 /bin/bash
postgres@2d3f967af057:/$ pg_dumpall > /var/lib/postgresql/backup
```

Останавливаем контейнер:

```
vladimir@linuxstage:~/learndevops/devops-netology/06-db-02-sql/src$ docker-compose down
Stopping postgresvp32 ... done
Removing postgresvp32 ... done
Removing network src_postgresnet
```

Если не удалить вольюм с данными database_data, то при старте контейнера у нас появится наша база с данными. Удалим вольюм database_data:

```
vladimir@linuxstage:~/learndevops/devops-netology/06-db-02-sql/src$ docker volume rm src_database_data 
src_database_data
```

Стартуем контейнер:
```
vladimir@linuxstage:~/learndevops/devops-netology/06-db-02-sql/src$ docker-compose up -d
Creating network "src_postgresnet" with driver "bridge"
Creating volume "src_database_data" with default driver
Creating postgresvp32 ... done
```
Проваливаемся в контейнер, и видим, что файл бэкапа есть, но базы test_db нет:
```
vladimir@linuxstage:~/learndevops/devops-netology/06-db-02-sql/src$ docker exec -it postgresvp32 /bin/bash
postgres@ae58b63dd7de:/$ ls /var/lib/postgresql/ -lah | grep backup
-rw-r--r--  1 postgres postgres 6.8K Jul 12 18:10 backup
postgres@ae58b63dd7de:/$ psql
psql (12.11 (Debian 12.11-1.pgdg110+1))
Type "help" for help.

postgres=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(3 rows)
postgres=# \q

```



Поднимаем базу из бэкапа в контейнере:

```
postgres@ae58b63dd7de:/$ psql -f /var/lib/postgresql/backup 
SET
SET
SET
psql:/var/lib/postgresql/backup:14: ERROR:  role "postgres" already exists
ALTER ROLE
CREATE ROLE
ALTER ROLE
CREATE ROLE
ALTER ROLE
You are now connected to database "template1" as user "postgres".
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
You are now connected to database "postgres" as user "postgres".
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
CREATE DATABASE
ALTER DATABASE
You are now connected to database "test_db" as user "postgres".
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
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
ALTER TABLE
ALTER TABLE
COPY 5
COPY 5
 setval 
--------
      5
(1 row)

 setval 
--------
      5
(1 row)

ALTER TABLE
ALTER TABLE
CREATE INDEX
ALTER TABLE
GRANT
GRANT
GRANT
GRANT


```

Проверим, что БД успешно восстановлена:
```
postgres@ae58b63dd7de:/$ psql
psql (12.11 (Debian 12.11-1.pgdg110+1))
Type "help" for help.

postgres=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
(4 rows)

postgres=# \c test_db
You are now connected to database "test_db" as user "postgres".
test_db=# \dt
          List of relations
 Schema |  Name   | Type  |  Owner   
--------+---------+-------+----------
 public | clients | table | postgres
 public | orders  | table | postgres
(2 rows)

test_db=# select * from orders;
 id |  name   | price 
----+---------+-------
  1 | Шоколад |    10
  2 | Принтер |  3000
  3 | Книга   |   500
  4 | Монитор |  7000
  5 | Гитара  |  4000
(5 rows)

test_db=# select * from clients;
 id |         name         | country | order_id 
----+----------------------+---------+----------
  4 | Ронни Джеймс Дио     | Russia  |         
  5 | Ritchie Blackmore    | Russia  |         
  1 | Иванов Иван Иванович | USA     |        3
  2 | Петров Петр Петрович | Canada  |        4
  3 | Иоганн Себастьян Бах | Japan   |        5
(5 rows)

```

