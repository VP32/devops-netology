# devops-netology

## Файл .gitignore

За счет добавления файла .gitignore пока ничего не будет исключено, так как он пустой.

## Файл terraform/.gitignore - исключение файлов внутри подпапки terraform

* `**/.terraform/*` - исключит все подпапки .terraform со всеми файлами во всех подпапках
* `*.tfstate`, `*.tfstate.*` - исключит все файлы с расширением tfstate, а также файлы с любым расширением, имя которых заканчивается на .tfstate, рекурсивно в папке terraform и во всех подпапках
* `crash.log`, `crash.*.log` - исключит все файлы crash.log и файлы, имя которых начинается на crash., и с раширением .log рекурсивно в папке terraform и во всех подпапках
* `*.tfvars`, `*.tfvars.json` - исключит все файлы с расширением tfvars, а также с .tfvars.json рекурсивно в папке terraform и во всех подпапках
* `override.tf`, `override.tf.json` - исключит все файлы override.tf и override.tf.json рекурсивно в папке terraform и во всех подпапках
* `*_override.tf`, `*_override.tf.json` - исключит все файлы, имя которых оканчивается на _override.tf и _override.tf.json рекурсивно в папке terraform и во всех подпапках
* `.terraformrc`, `terraform.rc` - исключит все файлы с расширением terraformrc и имя которых оканчивается на terraform.rc рекурсивно в папке terraform и во всех подпапках

## Обновлено 25.02.2022

## Обновлено 25.02.2022 номер 2


