# Домашнее задание к занятию «Б
езопасность в облачных провайдерах»  


---
## Задание 1. Yandex Cloud   

1. С помощью ключа в KMS необходимо зашифровать содержимое бакета:

 - создать ключ в KMS;
 - с помощью ключа зашифровать содержимое бакета, созданного ранее.

**Решение**

Код для Terraform находится в подпапке [src/terraform](./src/terraform).

Итоговый план Terraform:

```terraform
provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_region
}

# Сервисный аккаунт для управления бакетом
resource "yandex_iam_service_account" "bucket-sa" {
  name        = "bucket-sa"
  description = "сервисный аккаунт для управления s3-бакетом"
}

# Выдаем роли сервисному аккаунту:
# Запись в хранилище
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.yc_folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.bucket-sa.id}"
}
# Шифрование-расшифрование данных ключами KMS
resource "yandex_resourcemanager_folder_iam_member" "sa-editor-encrypter-decrypter" {
  folder_id = var.yc_folder_id
  role      = "kms.keys.encrypterDecrypter"
  member    = "serviceAccount:${yandex_iam_service_account.bucket-sa.id}"
}

# Создаем ключи доступа для сервисного аккаунта
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.bucket-sa.id
  description        = "static access key for object storage"
}

# Ключ для шифрования бакета
resource "yandex_kms_symmetric_key" "key-1" {
  name              = "key-1"
  description       = "ключ для шифрования бакета"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" // 1 год
}

# Создаем бакет с указанными ключами доступа и шифрованием выбранным ключом
resource "yandex_storage_bucket" "vp-bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "vp-netology-test-bucket"

  max_size = 1073741824 # 1 Gb

  anonymous_access_flags {
    read = true
    list = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.key-1.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

# Загрузка картинки в бакет
resource "yandex_storage_object" "my-picture" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = yandex_storage_bucket.vp-bucket.id
  key        = "my-picture.jpg"
  source     = var.my_picture
}

###############################################################################################################
# Выводим полученные данные
output "pic-url" {
  value       = "https://${yandex_storage_bucket.vp-bucket.bucket_domain_name}/${yandex_storage_object.my-picture.key}"
  description = "Адрес загруженной в бакет картинки"
}
```

Взял часть кода из прошлого ДЗ, где нужно было создавать бакет и класть в него картинку. Добавил создание ключа в KMS, роль kms.keys.encrypterDecrypter для используемого сервисного аккаунта и добавил шифрование ключом в бакет.

Применяю манифест. Все успешно создается:

![1.png](img%2F1.png)

![2.png](img%2F2.png)

Так как в бакете используется шифрование объектов, несмотря на включенный публичный доступ к объектам бакета, картинка не открывается в браузере. Насколько я понял, для доступа необходимо авторизовывать запрос с указанием ключа для расшифровки:

![3.png](img%2F3.png)

2. (Выполняется не в Terraform)* Создать статический сайт в Object Storage c собственным публичным адресом и сделать доступным по HTTPS:

 - создать сертификат;
 - создать статическую страницу в Object Storage и применить сертификат HTTPS;
 - в качестве результата предоставить скриншот на страницу с сертификатом в заголовке (замочек).

**Решение**

Для статического сайта использовал свой домен nostalgic.gallery. Завожу статический сайт с доменом третьего уровня, как сказано в документации.

В кабинете регистратора доменов прописал делегирование домена на NS-серверы Яндекс-облака:

![1.png](img%2Ftask2%2F1.png)

Создаю бакет test.nostalgic.gallery, включаю в нем публичный доступ на чтение объектов:

![2.png](img%2Ftask2%2F2.png)

Размещаю в нем тестовую страничку для статического сайта с помощью формы загрузки объектов в бакет:

![3.png](img%2Ftask2%2F3.png)

Включаю режим хостинга для веб-сайта:

![4.png](img%2Ftask2%2F4.png)


Создаю в Cloud DNS публичную зону для домена:

![5.png](img%2Ftask2%2F5.png)

![6.png](img%2Ftask2%2F6.png)

Создаю CNAME-запись в публичной зоне для домена test.nostalgic.gallery, указываю в значении адрес бакета:

![7.png](img%2Ftask2%2F7.png)

![8.png](img%2Ftask2%2F8.png)

Выпускаю Let's Encrypt сертификат для домена test.nostalgic.gallery в Certificate Manager:

![9.png](img%2Ftask2%2F9.png)

Перехожу в созданный сертификат и создаю CNAME-зону для валидации домена по DNS:

![10.png](img%2Ftask2%2F10.png)

![11.png](img%2Ftask2%2F11.png)


Спустя некоторое время сертификат валидируется и выпускается:

![12.png](img%2Ftask2%2F12.png)

Включаю HTTPS-доступ к бакету, выбираю полученный сертификат:

![13.png](img%2Ftask2%2F13.png)

![14.png](img%2Ftask2%2F14.png)

Через некоторое время сайт корректно работает по https с Let's encrypt-сертификатом:

![15.png](img%2Ftask2%2F15.png)

![16.png](img%2Ftask2%2F16.png)

![17.png](img%2Ftask2%2F17.png)