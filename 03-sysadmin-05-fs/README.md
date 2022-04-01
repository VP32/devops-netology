# Домашнее задание к занятию "3.5. Файловые системы"

1. Узнайте о [sparse](https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D0%B7%D1%80%D0%B5%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D1%84%D0%B0%D0%B9%D0%BB) (разряженных) файлах.

Разреженный файл - это файл, последовательность нулевых байтов в котором заменена на информацию об этой последовательности. Иными словами, файл занимает меньше дискового пространства за счет того, что нулевые байты фактически не пишутся на диск. Это один из способов сжатия данных на уровне файловой системы. Разреженные файлы используются для хранения контейнеров, образов виртуальных машин, резервных копий. Также удобны для торрентов. 

2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?

Не могут, поскольку это фактически один и тот же объект в пределах данной файловой системы, у них одинаковый inode:

```bash
vagrant@vagrant:~/hl/test_hardlink$ touch file.file
vagrant@vagrant:~/hl/test_hardlink$ ln file.file file.hardlink
vagrant@vagrant:~/hl/test_hardlink$ ls -l
total 0
-rw-rw-r-- 2 vagrant vagrant 0 Apr  1 14:00 file.file
-rw-rw-r-- 2 vagrant vagrant 0 Apr  1 14:00 file.hardlink
vagrant@vagrant:~/hl/test_hardlink$ chmod o+w file.file 
vagrant@vagrant:~/hl/test_hardlink$ ls -l
total 0
-rw-rw-rw- 2 vagrant vagrant 0 Apr  1 14:00 file.file
-rw-rw-rw- 2 vagrant vagrant 0 Apr  1 14:00 file.hardlink
vagrant@vagrant:~/hl/test_hardlink$ sudo chown root file.file 
vagrant@vagrant:~/hl/test_hardlink$ ls -l
total 0
-rw-rw-rw- 2 root vagrant 0 Apr  1 14:00 file.file
-rw-rw-rw- 2 root vagrant 0 Apr  1 14:00 file.hardlink
vagrant@vagrant:~/hl/test_hardlink$ stat file.file 
  File: file.file
  Size: 0         	Blocks: 0          IO Block: 4096   regular empty file
Device: fd00h/64768d	Inode: 1054715     Links: 2
Access: (0666/-rw-rw-rw-)  Uid: (    0/    root)   Gid: ( 1000/ vagrant)
Access: 2022-04-01 14:00:45.933318793 +0000
Modify: 2022-04-01 14:00:45.933318793 +0000
Change: 2022-04-01 14:01:45.597321044 +0000
 Birth: -
vagrant@vagrant:~/hl/test_hardlink$ stat file.hardlink 
  File: file.hardlink
  Size: 0         	Blocks: 0          IO Block: 4096   regular empty file
Device: fd00h/64768d	Inode: 1054715     Links: 2
Access: (0666/-rw-rw-rw-)  Uid: (    0/    root)   Gid: ( 1000/ vagrant)
Access: 2022-04-01 14:00:45.933318793 +0000
Modify: 2022-04-01 14:00:45.933318793 +0000
Change: 2022-04-01 14:01:45.597321044 +0000
 Birth: -
```

При изменении прав и владельца у одного объекта они меняются и у другого.

3. Сделайте `vagrant destroy` на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим:

    ```bash
    Vagrant.configure("2") do |config|
      config.vm.box = "bento/ubuntu-20.04"
      config.vm.provider :virtualbox do |vb|
        lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"
        lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"
        vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
        vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
      end
    end
    ```

    Данная конфигурация создаст новую виртуальную машину с двумя дополнительными неразмеченными дисками по 2.5 Гб.

Сделано:

```bash
vagrant@vagrant:~$ lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
loop0                       7:0    0 70.3M  1 loop /snap/lxd/21029
loop1                       7:1    0 55.4M  1 loop /snap/core18/2128
loop2                       7:2    0 32.3M  1 loop /snap/snapd/12704
sda                         8:0    0   64G  0 disk 
├─sda1                      8:1    0    1M  0 part 
├─sda2                      8:2    0    1G  0 part /boot
└─sda3                      8:3    0   63G  0 part 
  └─ubuntu--vg-ubuntu--lv 253:0    0 31.5G  0 lvm  /
sdb                         8:16   0  2.5G  0 disk 
sdc                         8:32   0  2.5G  0 disk 
```


4. Используя `fdisk`, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.

Сделано:

```bash
vagrant@vagrant:~$ sudo fdisk /dev/sdb

Welcome to fdisk (util-linux 2.34).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): m

Help:

  DOS (MBR)
   a   toggle a bootable flag
   b   edit nested BSD disklabel
   c   toggle the dos compatibility flag

  Generic
   d   delete a partition
   F   list free unpartitioned space
   l   list known partition types
   n   add a new partition
   p   print the partition table
   t   change a partition type
   v   verify the partition table
   i   print information about a partition

  Misc
   m   print this menu
   u   change display/entry units
   x   extra functionality (experts only)

  Script
   I   load disk layout from sfdisk script file
   O   dump disk layout to sfdisk script file

  Save & Exit
   w   write table to disk and exit
   q   quit without saving changes

  Create a new label
   g   create a new empty GPT partition table
   G   create a new empty SGI (IRIX) partition table
   o   create a new empty DOS partition table
   s   create a new empty Sun partition table


Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1): 
First sector (2048-5242879, default 2048): 
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-5242879, default 5242879): +2G

Created a new partition 1 of type 'Linux' and of size 2 GiB.

Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (2-4, default 2): 
First sector (4196352-5242879, default 4196352): 
Last sector, +/-sectors or +/-size{K,M,G,T,P} (4196352-5242879, default 5242879): 

Created a new partition 2 of type 'Linux' and of size 511 MiB.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.

vagrant@vagrant:~$ lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
loop0                       7:0    0 70.3M  1 loop /snap/lxd/21029
loop1                       7:1    0 55.4M  1 loop /snap/core18/2128
loop3                       7:3    0 55.5M  1 loop /snap/core18/2344
loop4                       7:4    0 43.6M  1 loop /snap/snapd/15177
loop5                       7:5    0 61.9M  1 loop /snap/core20/1405
loop6                       7:6    0 67.8M  1 loop /snap/lxd/22753
sda                         8:0    0   64G  0 disk 
├─sda1                      8:1    0    1M  0 part 
├─sda2                      8:2    0    1G  0 part /boot
└─sda3                      8:3    0   63G  0 part 
  └─ubuntu--vg-ubuntu--lv 253:0    0 31.5G  0 lvm  /
sdb                         8:16   0  2.5G  0 disk 
├─sdb1                      8:17   0    2G  0 part 
└─sdb2                      8:18   0  511M  0 part 
sdc                         8:32   0  2.5G  0 disk
```

5. Используя `sfdisk`, перенесите данную таблицу разделов на второй диск.

Сделано:

```bash
vagrant@vagrant:~$ sudo sfdisk -d /dev/sdb | sudo sfdisk /dev/sdc
Checking that no-one is using this disk right now ... OK

Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.

>>> Created a new DOS disklabel with disk identifier 0xf6730e88.
/dev/sdc1: Created a new partition 1 of type 'Linux' and of size 2 GiB.
/dev/sdc2: Created a new partition 2 of type 'Linux' and of size 511 MiB.
/dev/sdc3: Done.

New situation:
Disklabel type: dos
Disk identifier: 0xf6730e88

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdc1          2048 4196351 4194304    2G 83 Linux
/dev/sdc2       4196352 5242879 1046528  511M 83 Linux

The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
vagrant@vagrant:~$ 
vagrant@vagrant:~$ lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
loop0                       7:0    0 70.3M  1 loop /snap/lxd/21029
loop1                       7:1    0 55.4M  1 loop /snap/core18/2128
loop3                       7:3    0 55.5M  1 loop /snap/core18/2344
loop4                       7:4    0 43.6M  1 loop /snap/snapd/15177
loop5                       7:5    0 61.9M  1 loop /snap/core20/1405
loop6                       7:6    0 67.8M  1 loop /snap/lxd/22753
sda                         8:0    0   64G  0 disk 
├─sda1                      8:1    0    1M  0 part 
├─sda2                      8:2    0    1G  0 part /boot
└─sda3                      8:3    0   63G  0 part 
  └─ubuntu--vg-ubuntu--lv 253:0    0 31.5G  0 lvm  /
sdb                         8:16   0  2.5G  0 disk 
├─sdb1                      8:17   0    2G  0 part 
└─sdb2                      8:18   0  511M  0 part 
sdc                         8:32   0  2.5G  0 disk 
├─sdc1                      8:33   0    2G  0 part 
└─sdc2                      8:34   0  511M  0 part 
```

6. Соберите `mdadm` RAID1 на паре разделов 2 Гб.

Сделано:

```bash
vagrant@vagrant:~$ sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
vagrant@vagrant:~$ lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
loop0                       7:0    0 70.3M  1 loop  /snap/lxd/21029
loop1                       7:1    0 55.4M  1 loop  /snap/core18/2128
loop3                       7:3    0 55.5M  1 loop  /snap/core18/2344
loop4                       7:4    0 43.6M  1 loop  /snap/snapd/15177
loop5                       7:5    0 61.9M  1 loop  /snap/core20/1405
loop6                       7:6    0 67.8M  1 loop  /snap/lxd/22753
sda                         8:0    0   64G  0 disk  
├─sda1                      8:1    0    1M  0 part  
├─sda2                      8:2    0    1G  0 part  /boot
└─sda3                      8:3    0   63G  0 part  
  └─ubuntu--vg-ubuntu--lv 253:0    0 31.5G  0 lvm   /
sdb                         8:16   0  2.5G  0 disk  
├─sdb1                      8:17   0    2G  0 part  
│ └─md0                     9:0    0    2G  0 raid1 
└─sdb2                      8:18   0  511M  0 part  
sdc                         8:32   0  2.5G  0 disk  
├─sdc1                      8:33   0    2G  0 part  
│ └─md0                     9:0    0    2G  0 raid1 
└─sdc2                      8:34   0  511M  0 part  
vagrant@vagrant:~$ cat /proc/mdstat
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md0 : active raid1 sdc1[1] sdb1[0]
      2094080 blocks super 1.2 [2/2] [UU]
```

7. Соберите `mdadm` RAID0 на второй паре маленьких разделов.

Сделано:

```bash
vagrant@vagrant:~$ sudo mdadm --create /dev/md1 --level=0 --raid-devices=2 /dev/sdb2 /dev/sdc2
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md1 started.
vagrant@vagrant:~$ lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
loop0                       7:0    0 70.3M  1 loop  /snap/lxd/21029
loop1                       7:1    0 55.4M  1 loop  /snap/core18/2128
loop3                       7:3    0 55.5M  1 loop  /snap/core18/2344
loop4                       7:4    0 43.6M  1 loop  /snap/snapd/15177
loop5                       7:5    0 61.9M  1 loop  /snap/core20/1405
loop6                       7:6    0 67.8M  1 loop  /snap/lxd/22753
sda                         8:0    0   64G  0 disk  
├─sda1                      8:1    0    1M  0 part  
├─sda2                      8:2    0    1G  0 part  /boot
└─sda3                      8:3    0   63G  0 part  
  └─ubuntu--vg-ubuntu--lv 253:0    0 31.5G  0 lvm   /
sdb                         8:16   0  2.5G  0 disk  
├─sdb1                      8:17   0    2G  0 part  
│ └─md0                     9:0    0    2G  0 raid1 
└─sdb2                      8:18   0  511M  0 part  
  └─md1                     9:1    0 1018M  0 raid0 
sdc                         8:32   0  2.5G  0 disk  
├─sdc1                      8:33   0    2G  0 part  
│ └─md0                     9:0    0    2G  0 raid1 
└─sdc2                      8:34   0  511M  0 part  
  └─md1                     9:1    0 1018M  0 raid0 
vagrant@vagrant:~$ cat /proc/mdstat
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md1 : active raid0 sdc2[1] sdb2[0]
      1042432 blocks super 1.2 512k chunks
      
md0 : active raid1 sdc1[1] sdb1[0]
      2094080 blocks super 1.2 [2/2] [UU]
      
unused devices: <none>
```

8. Создайте 2 независимых PV на получившихся md-устройствах.

Сделано:

```bash
vagrant@vagrant:~$ sudo pvcreate /dev/md0 /dev/md1
  Physical volume "/dev/md0" successfully created.
  Physical volume "/dev/md1" successfully created.
vagrant@vagrant:~$ sudo pvs
  PV         VG        Fmt  Attr PSize    PFree   
  /dev/md0             lvm2 ---    <2.00g   <2.00g
  /dev/md1             lvm2 ---  1018.00m 1018.00m
  /dev/sda3  ubuntu-vg lvm2 a--   <63.00g  <31.50g
```


9. Создайте общую volume-group на этих двух PV.

Сделано:

```bash
vagrant@vagrant:~$ sudo vgcreate vg0 /dev/md0 /dev/md1
  Volume group "vg0" successfully created
vagrant@vagrant:~$ sudo vgs
  VG        #PV #LV #SN Attr   VSize   VFree  
  ubuntu-vg   1   1   0 wz--n- <63.00g <31.50g
  vg0         2   0   0 wz--n-  <2.99g  <2.99g
```


10. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.

```bash
vagrant@vagrant:~$ sudo lvcreate -L100 -nlv0 vg0 /dev/md1
  Logical volume "lv0" created.
vagrant@vagrant:~$ sudo lvs
  LV        VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  ubuntu-lv ubuntu-vg -wi-ao----  31.50g                                                    
  lv0       vg0       -wi-a----- 100.00m    
vagrant@vagrant:~$ sudo lvdisplay
  --- Logical volume ---
  LV Path                /dev/ubuntu-vg/ubuntu-lv
  LV Name                ubuntu-lv
  VG Name                ubuntu-vg
  LV UUID                ftN15m-3lML-YH5x-R5P2-kLCd-kzW3-32dlqO
  LV Write Access        read/write
  LV Creation host, time ubuntu-server, 2021-12-19 19:37:44 +0000
  LV Status              available
  # open                 1
  LV Size                31.50 GiB
  Current LE             8064
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0
   
  --- Logical volume ---
  LV Path                /dev/vg0/lv0
  LV Name                lv0
  VG Name                vg0
  LV UUID                pyPXj9-Ezqy-Vycm-xybN-h5Sj-9qQX-1AY6AF
  LV Write Access        read/write
  LV Creation host, time vagrant, 2022-04-04 09:42:00 +0000
  LV Status              available
  # open                 0
  LV Size                100.00 MiB
  Current LE             25
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     4096
  Block device           253:1
```


11. Создайте `mkfs.ext4` ФС на получившемся LV.

Сделано:

```bash
vagrant@vagrant:~$ sudo mkfs.ext4 /dev/vg0/lv0
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 25600 4k blocks and 25600 inodes

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (1024 blocks): done
Writing superblocks and filesystem accounting information: done
```


12. Смонтируйте этот раздел в любую директорию, например, `/tmp/new`.

Сделано:

```bash
vagrant@vagrant:~$ mkdir /tmp/new
vagrant@vagrant:~$ sudo mount /dev/vg0/lv0 /tmp/new
vagrant@vagrant:~$ ls -l /tmp/new
total 16
drwx------ 2 root root 16384 Apr  4 09:49 lost+found
```

13. Поместите туда тестовый файл, например `wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz`.

Сделано:

```bash
vagrant@vagrant:~$ sudo wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz
--2022-04-04 10:00:55--  https://mirror.yandex.ru/ubuntu/ls-lR.gz
Resolving mirror.yandex.ru (mirror.yandex.ru)... 213.180.204.183, 2a02:6b8::183
Connecting to mirror.yandex.ru (mirror.yandex.ru)|213.180.204.183|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 22297379 (21M) [application/octet-stream]
Saving to: ‘/tmp/new/test.gz’

/tmp/new/test.gz                                   100%[===============================================================================================================>]  21.26M  5.78MB/s    in 3.7s    

2022-04-04 10:01:00 (5.78 MB/s) - ‘/tmp/new/test.gz’ saved [22297379/22297379]

vagrant@vagrant:~$ ls -l /tmp/new
total 21792
drwx------ 2 root root    16384 Apr  4 09:49 lost+found
-rw-r--r-- 1 root root 22297379 Apr  4 08:58 test.gz
```

14. Прикрепите вывод `lsblk`.

```bash
vagrant@vagrant:~$ lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
loop0                       7:0    0 55.4M  1 loop  /snap/core18/2128
loop2                       7:2    0 70.3M  1 loop  /snap/lxd/21029
loop3                       7:3    0 55.5M  1 loop  /snap/core18/2344
loop4                       7:4    0 43.6M  1 loop  /snap/snapd/15177
loop5                       7:5    0 61.9M  1 loop  /snap/core20/1405
loop6                       7:6    0 67.8M  1 loop  /snap/lxd/22753
sda                         8:0    0   64G  0 disk  
├─sda1                      8:1    0    1M  0 part  
├─sda2                      8:2    0    1G  0 part  /boot
└─sda3                      8:3    0   63G  0 part  
  └─ubuntu--vg-ubuntu--lv 253:0    0 31.5G  0 lvm   /
sdb                         8:16   0  2.5G  0 disk  
├─sdb1                      8:17   0    2G  0 part  
│ └─md0                     9:0    0    2G  0 raid1 
└─sdb2                      8:18   0  511M  0 part  
  └─md1                     9:1    0 1018M  0 raid0 
    └─vg0-lv0             253:1    0  100M  0 lvm   /tmp/new
sdc                         8:32   0  2.5G  0 disk  
├─sdc1                      8:33   0    2G  0 part  
│ └─md0                     9:0    0    2G  0 raid1 
└─sdc2                      8:34   0  511M  0 part  
  └─md1                     9:1    0 1018M  0 raid0 
    └─vg0-lv0             253:1    0  100M  0 lvm   /tmp/new
```

15. Протестируйте целостность файла:

     ```bash
     root@vagrant:~# gzip -t /tmp/new/test.gz
     root@vagrant:~# echo $?
     0
     ```

Сделано:

```bash
vagrant@vagrant:~$ sudo gzip -t /tmp/new/test.gz
vagrant@vagrant:~$ echo $?
0
```


16. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.

Сделано:

```bash
vagrant@vagrant:~$ sudo pvmove /dev/md1 /dev/md0
  /dev/md1: Moved: 20.00%
  /dev/md1: Moved: 100.00%
vagrant@vagrant:~$ lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
loop0                       7:0    0 55.4M  1 loop  /snap/core18/2128
loop2                       7:2    0 70.3M  1 loop  /snap/lxd/21029
loop3                       7:3    0 55.5M  1 loop  /snap/core18/2344
loop4                       7:4    0 43.6M  1 loop  /snap/snapd/15177
loop5                       7:5    0 61.9M  1 loop  /snap/core20/1405
loop6                       7:6    0 67.8M  1 loop  /snap/lxd/22753
sda                         8:0    0   64G  0 disk  
├─sda1                      8:1    0    1M  0 part  
├─sda2                      8:2    0    1G  0 part  /boot
└─sda3                      8:3    0   63G  0 part  
  └─ubuntu--vg-ubuntu--lv 253:0    0 31.5G  0 lvm   /
sdb                         8:16   0  2.5G  0 disk  
├─sdb1                      8:17   0    2G  0 part  
│ └─md0                     9:0    0    2G  0 raid1 
│   └─vg0-lv0             253:1    0  100M  0 lvm   /tmp/new
└─sdb2                      8:18   0  511M  0 part  
  └─md1                     9:1    0 1018M  0 raid0 
sdc                         8:32   0  2.5G  0 disk  
├─sdc1                      8:33   0    2G  0 part  
│ └─md0                     9:0    0    2G  0 raid1 
│   └─vg0-lv0             253:1    0  100M  0 lvm   /tmp/new
└─sdc2                      8:34   0  511M  0 part  
  └─md1                     9:1    0 1018M  0 raid0 
```

17. Сделайте `--fail` на устройство в вашем RAID1 md.

Сделано:

```bash
vagrant@vagrant:~$ sudo mdadm --fail /dev/md0 /dev/sdb1
mdadm: set /dev/sdb1 faulty in /dev/md0
vagrant@vagrant:~$ cat /proc/mdstat
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md1 : active raid0 sdc2[1] sdb2[0]
      1042432 blocks super 1.2 512k chunks
      
md0 : active raid1 sdc1[1] sdb1[0](F)
      2094080 blocks super 1.2 [2/1] [_U]
      
unused devices: <none>
```


18. Подтвердите выводом `dmesg`, что RAID1 работает в деградированном состоянии.

```bash
vagrant@vagrant:~$ dmesg -T
...
[Mon Apr  4 10:17:24 2022] md/raid1:md0: Disk failure on sdb1, disabling device.
                           md/raid1:md0: Operation continuing on 1 devices.
```

19. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:

     ```bash
     root@vagrant:~# gzip -t /tmp/new/test.gz
     root@vagrant:~# echo $?
     0
     ```

Сделано:
```bash
vagrant@vagrant:~$ sudo gzip -t /tmp/new/test.gz 
vagrant@vagrant:~$ echo $?
0
```

20. Погасите тестовый хост, `vagrant destroy`.

 Сделано:

```bash
vagrant@vagrant:~$ exit
logout
Connection to 127.0.0.1 closed.
vladimir@linuxstage:~/learndevops/devops-netology/vagrant$ vagrant destroy
    default: Are you sure you want to destroy the 'default' VM? [y/N] y
==> default: Forcing shutdown of VM...
==> default: Destroying VM and associated drives...
vladimir@linuxstage:~/learndevops/devops-netology/vagrant$ 
```
