# Домашнее задание к занятию "7.6. Написание собственных провайдеров для Terraform."

Бывает, что 
* общедоступная документация по терраформ ресурсам не всегда достоверна,
* в документации не хватает каких-нибудь правил валидации или неточно описаны параметры,
* понадобиться использовать провайдер без официальной документации,
* может возникнуть необходимость написать свой провайдер для системы используемой в ваших проектах.   

## Задача 1. 
Давайте потренируемся читать исходный код AWS провайдера, который можно склонировать от сюда: 
[https://github.com/hashicorp/terraform-provider-aws.git](https://github.com/hashicorp/terraform-provider-aws.git).
Просто найдите нужные ресурсы в исходном коде и ответы на вопросы станут понятны.  


1. Найдите, где перечислены все доступные `resource` и `data_source`, приложите ссылку на эти строки в коде на 
гитхабе.   

**Решение:**

* все `data_source` перечислены тут: [Github](https://github.com/hashicorp/terraform-provider-aws/blob/71d1fa399fd77b60db8f64c94e89a8020742cb1b/internal/provider/provider.go#L414)

* все `resource` перечислены тут: [Github](https://github.com/hashicorp/terraform-provider-aws/blob/71d1fa399fd77b60db8f64c94e89a8020742cb1b/internal/provider/provider.go#L923)

2. Для создания очереди сообщений SQS используется ресурс `aws_sqs_queue` у которого есть параметр `name`. 
    * С каким другим параметром конфликтует `name`? Приложите строчку кода, в которой это указано.
    * Какая максимальная длина имени? 
    * Какому регулярному выражению должно подчиняться имя? 

**Решение:**

   * конфликтует с параметром `name_prefix`, указано тут: [Github](https://github.com/hashicorp/terraform-provider-aws/blob/71d1fa399fd77b60db8f64c94e89a8020742cb1b/internal/service/sqs/queue.go#L87)
   * Максимальная длина имени равна 80 символам. Имя может состоять из комбинации  name_prefix и name, к которым в случае, если атрибут fifo_queue = true, может быть добавлен суффикс ".fifo": [Github](https://github.com/hashicorp/terraform-provider-aws/blob/71d1fa399fd77b60db8f64c94e89a8020742cb1b/internal/service/sqs/queue.go#L424)
   * В случае, если атрибут fifo_queue = true, регулярное выражение `^[a-zA-Z0-9_-]{1,75}\.fifo$`. Иначе - `^[a-zA-Z0-9_-]{1,80}$`: [Github](https://github.com/hashicorp/terraform-provider-aws/blob/71d1fa399fd77b60db8f64c94e89a8020742cb1b/internal/service/sqs/queue.go#L424)
    
