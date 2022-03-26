# Домашнее задание к занятию "3.3. Операционные системы, лекция 1"

1. Какой системный вызов делает команда `cd`? В прошлом ДЗ мы выяснили, что `cd` не является самостоятельной  программой, это `shell builtin`, поэтому запустить `strace` непосредственно на `cd` не получится. Тем не менее, вы можете запустить `strace` на `/bin/bash -c 'cd /tmp'`. В этом случае вы увидите полный список системных вызовов, которые делает сам `bash` при старте. Вам нужно найти тот единственный, который относится именно к `cd`.

`chdir("/tmp")  `

2. Попробуйте использовать команду `file` на объекты разных типов на файловой системе. Например:
    ```bash
    vagrant@netology1:~$ file /dev/tty
    /dev/tty: character special (5/0)
    vagrant@netology1:~$ file /dev/sda
    /dev/sda: block special (8/0)
    vagrant@netology1:~$ file /bin/bash
    /bin/bash: ELF 64-bit LSB shared object, x86-64
    ```
    Используя `strace` выясните, где находится база данных `file` на основании которой она делает свои догадки.

База данных находится в файле /usr/share/misc/magic.mgc

По выводу strace это:

`openat(AT_FDCWD, "/usr/share/misc/magic.mgc", O_RDONLY) = 3`

Также попытки поиска предпринимала по таким путям:

```
stat("/home/vagrant/.magic.mgc", 0x7ffd7bd2e0a0) = -1 ENOENT (No such file or directory)
stat("/home/vagrant/.magic", 0x7ffd7bd2e0a0) = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/etc/magic.mgc", O_RDONLY) = -1 ENOENT (No such file or directory)
stat("/etc/magic", {st_mode=S_IFREG|0644, st_size=111, ...}) = 0
openat(AT_FDCWD, "/etc/magic", O_RDONLY) = 3`
```

3. Предположим, приложение пишет лог в текстовый файл. Этот файл оказался удален (deleted в lsof), однако возможности сигналом сказать приложению переоткрыть файлы или просто перезапустить приложение – нет. Так как приложение продолжает писать в удаленный файл, место на диске постепенно заканчивается. Основываясь на знаниях о перенаправлении потоков предложите способ обнуления открытого удаленного файла (чтобы освободить место на файловой системе).

Удалось воспроизвести на временном файле редактора vi. Удалил его. Затем обнулил с помощью команды `echo ''>/proc/16473/fd/3`:

```
vagrant@vagrant:~/testdel$ ps au | grep 'vi test'
vagrant    16473  0.0  0.4  21880  9704 pts/0    S+   15:07   0:00 vi testfile
vagrant    16511  0.0  0.0   6432   736 pts/1    S+   15:15   0:00 grep --color=auto vi test
vagrant@vagrant:~/testdel$ lsof -p 16473
COMMAND   PID    USER   FD   TYPE DEVICE SIZE/OFF    NODE NAME
vi      16473 vagrant  cwd    DIR  253,0     4096 1048615 /home/vagrant/testdel
vi      16473 vagrant  rtd    DIR  253,0     4096       2 /
vi      16473 vagrant  txt    REG  253,0  2906824 1840947 /usr/bin/vim.basic
vi      16473 vagrant  mem    REG  253,0    51832 1841607 /usr/lib/x86_64-linux-gnu/libnss_files-2.31.so
vi      16473 vagrant  mem    REG  253,0  3035952 1835290 /usr/lib/locale/locale-archive
vi      16473 vagrant  mem    REG  253,0    47064 1841615 /usr/lib/x86_64-linux-gnu/libogg.so.0.8.4
vi      16473 vagrant  mem    REG  253,0   182344 1841710 /usr/lib/x86_64-linux-gnu/libvorbis.so.0.4.8
vi      16473 vagrant  mem    REG  253,0    14848 1841706 /usr/lib/x86_64-linux-gnu/libutil-2.31.so
vi      16473 vagrant  mem    REG  253,0   108936 1841721 /usr/lib/x86_64-linux-gnu/libz.so.1.2.11
vi      16473 vagrant  mem    REG  253,0   182560 1841498 /usr/lib/x86_64-linux-gnu/libexpat.so.1.6.11
vi      16473 vagrant  mem    REG  253,0    39368 1841574 /usr/lib/x86_64-linux-gnu/libltdl.so.7.3.1
vi      16473 vagrant  mem    REG  253,0   100520 1838075 /usr/lib/x86_64-linux-gnu/libtdb.so.1.4.3
vi      16473 vagrant  mem    REG  253,0    38904 1841711 /usr/lib/x86_64-linux-gnu/libvorbisfile.so.3.3.7
vi      16473 vagrant  mem    REG  253,0   584392 1841629 /usr/lib/x86_64-linux-gnu/libpcre2-8.so.0.9.0
vi      16473 vagrant  mem    REG  253,0  2029224 1841468 /usr/lib/x86_64-linux-gnu/libc-2.31.so
vi      16473 vagrant  mem    REG  253,0   157224 1841646 /usr/lib/x86_64-linux-gnu/libpthread-2.31.so
vi      16473 vagrant  mem    REG  253,0  5449112 1835103 /usr/lib/x86_64-linux-gnu/libpython3.8.so.1.0
vi      16473 vagrant  mem    REG  253,0    18816 1841486 /usr/lib/x86_64-linux-gnu/libdl-2.31.so
vi      16473 vagrant  mem    REG  253,0    22456 1841527 /usr/lib/x86_64-linux-gnu/libgpm.so.2
vi      16473 vagrant  mem    REG  253,0    39088 1841437 /usr/lib/x86_64-linux-gnu/libacl.so.1.1.2253
vi      16473 vagrant  mem    REG  253,0    71680 1841469 /usr/lib/x86_64-linux-gnu/libcanberra.so.0.2.5
vi      16473 vagrant  mem    REG  253,0   163200 1841656 /usr/lib/x86_64-linux-gnu/libselinux.so.1
vi      16473 vagrant  mem    REG  253,0   192032 1841679 /usr/lib/x86_64-linux-gnu/libtinfo.so.6.2
vi      16473 vagrant  mem    REG  253,0  1369352 1841579 /usr/lib/x86_64-linux-gnu/libm-2.31.so
vi      16473 vagrant  mem    REG  253,0   191472 1841428 /usr/lib/x86_64-linux-gnu/ld-2.31.so
vi      16473 vagrant    0u   CHR  136,0      0t0       3 /dev/pts/0
vi      16473 vagrant    1u   CHR  136,0      0t0       3 /dev/pts/0
vi      16473 vagrant    2u   CHR  136,0      0t0       3 /dev/pts/0
vi      16473 vagrant    3u   REG  253,0     4096 1048616 /home/vagrant/testdel/.testfile.swp (deleted)
vagrant@vagrant:~/testdel$ echo ''>/proc/16473/fd/3
vagrant@vagrant:~/testdel$ lsof -p 16473 | grep .testfile.swp
vi      16473 vagrant    3u   REG  253,0        1 1048616 /home/vagrant/testdel/.testfile.swp (deleted)
```

4. Занимают ли зомби-процессы какие-то ресурсы в ОС (CPU, RAM, IO)?

Зомби-процессы не занимают ресурсы ОС, они освобождают ресурсы при переходе в это состояние (в отличие от "сирот"), но блокируют записи в таблице процессов, размер которой ограничен.

5. В iovisor BCC есть утилита `opensnoop`:
    ```bash
    root@vagrant:~# dpkg -L bpfcc-tools | grep sbin/opensnoop
    /usr/sbin/opensnoop-bpfcc
    ```
    На какие файлы вы увидели вызовы группы `open` за первую секунду работы утилиты? Воспользуйтесь пакетом `bpfcc-tools` для Ubuntu 20.04. Дополнительные [сведения по установке](https://github.com/iovisor/bcc/blob/master/INSTALL.md).

Запустить утилиту после установки удалось под суперпользователем. В первую секунду были обращения к файлам /var/run/utmp, /usr/local/share/dbus-1/system-services, /usr/share/dbus-1/system-services и далее:

```
vagrant@vagrant:~/testdel$ dpkg -L bpfcc-tools | grep sbin/opensnoop
/usr/sbin/opensnoop-bpfcc
vagrant@vagrant:~/testdel$ opensnoop-bpfcc
bpf: Failed to load program: Operation not permitted

Traceback (most recent call last):
  File "/usr/sbin/opensnoop-bpfcc", line 181, in <module>
    b.attach_kprobe(event="do_sys_open", fn_name="trace_entry")
  File "/usr/lib/python3/dist-packages/bcc/__init__.py", line 654, in attach_kprobe
    fn = self.load_func(fn_name, BPF.KPROBE)
  File "/usr/lib/python3/dist-packages/bcc/__init__.py", line 391, in load_func
    raise Exception("Need super-user privileges to run")
Exception: Need super-user privileges to run
vagrant@vagrant:~/testdel$ sudo opensnoop-bpfcc
PID    COMM               FD ERR PATH
977    vminfo              5   0 /var/run/utmp
651    dbus-daemon        -1   2 /usr/local/share/dbus-1/system-services
651    dbus-daemon        21   0 /usr/share/dbus-1/system-services
651    dbus-daemon        -1   2 /lib/dbus-1/system-services
651    dbus-daemon        21   0 /var/lib/snapd/dbus-1/system-services/
657    irqbalance          6   0 /proc/interrupts
657    irqbalance          6   0 /proc/stat
657    irqbalance          6   0 /proc/irq/20/smp_affinity
657    irqbalance          6   0 /proc/irq/0/smp_affinity
657    irqbalance          6   0 /proc/irq/1/smp_affinity
657    irqbalance          6   0 /proc/irq/8/smp_affinity
657    irqbalance          6   0 /proc/irq/12/smp_affinity
657    irqbalance          6   0 /proc/irq/14/smp_affinity
657    irqbalance          6   0 /proc/irq/15/smp_affinity
977    vminfo              5   0 /var/run/utmp
651    dbus-daemon        -1   2 /usr/local/share/dbus-1/system-services
651    dbus-daemon        21   0 /usr/share/dbus-1/system-services
651    dbus-daemon        -1   2 /lib/dbus-1/system-services
651    dbus-daemon        21   0 /var/lib/snapd/dbus-1/system-services/
```


6. Какой системный вызов использует `uname -a`? Приведите цитату из man по этому системному вызову, где описывается альтернативное местоположение в `/proc`, где можно узнать версию ядра и релиз ОС.

uname:

`execve("/usr/bin/uname", ["uname", "-a"], 0x7ffff1a92d98 /* 24 vars */) = 0`

Цитата:

Part  of  the  utsname information is also accessible via /proc/sys/kernel/{ostype, hostname, osre‐
       lease, version, domainname}.



7. Чем отличается последовательность команд через `;` и через `&&` в bash? Например:
    ```bash
    root@netology1:~# test -d /tmp/some_dir; echo Hi
    Hi
    root@netology1:~# test -d /tmp/some_dir && echo Hi
    root@netology1:~#
    ```
    Есть ли смысл использовать в bash `&&`, если применить `set -e`?

 - ; - разделитель последовательных команд
 - && - логический оператор И

В первом случае выполнятся все команды. Во втором - если успешно выполнится проверка, что существует каталог /tmp/some_dir, то выполнится и команда echo Hi

`set -e` немедленно прекращает выполнение и сессию, если команда вернула ненулевой статус. Так как параметр влияет на всю текущую сессию, в ряде случаев целесообразнее использовать &&. Если нам не нужно прерывать сессию в случае ненулевого статуса команды, то надо использовать &&. Например, если в скрипте предусмотрена какая-то дальнейшая логика.

8. Из каких опций состоит режим bash `set -euxo pipefail` и почему его хорошо было бы использовать в сценариях?

 - e немедленно прекращает выполнение и сессию, если команда вернула ненулевой статус

 - u если переменная не установлена или не задана, то будет ошибка при обращении к такой переменной с выводом в stdout и прекращением работы сценария

 - x печать команд и их аргументов при их выполнении

 - o pipefail - набор команд вернет статус последней команды с ненулевым статусом, либо 0, если ни одна команда набора не вернула ненулевой статус.

Повышает удобство отладки сценария: обеспечивает логирование ошибок, завершит сценарий при наличии ошибок.

9. Используя `-o stat` для `ps`, определите, какой наиболее часто встречающийся статус у процессов в системе. В `man ps` ознакомьтесь (`/PROCESS STATE CODES`) что значат дополнительные к основной заглавной буквы статуса процессов. Его можно не учитывать при расчете (считать S, Ss или Ssl равнозначными).

Самые частые статусы:

- S interruptible sleep (waiting for an event to complete) процессы, ожидающие завершения событий

- R running or runnable (on run queue) работающие процессы

Дополнительные символы - это дополнительные характеристики: приоритет, наличие многопоточности, заблокированных страниц в памяти, процесс в фоновой группе и пр.
