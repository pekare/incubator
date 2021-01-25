Kudos: https://alexskra.com/blog/ubuntu-20-04-with-software-raid1-and-uefi/

Reformat both drives if they’re not empty. 
Mark both drives as a boot device. Doing so will create an ESP(EFI system partition) on both drives.
Add an unformatted GPT partition to both drives. They need to have the same size. We’re going to use those partitions for the RAID that contains the OS.
Create a software RAID(md) by selecting the two partitions you just created for the OS.
Congratulations, you now have a new RAID device. Let’s add at least one GPT partition to it.
Optional: If you want the ability to swap, create a swap partition on the RAID device. Set the size to the same as your RAM, or half if you have 64 GB or more RAM.
Create a partition for Ubuntu on the RAID device. You can use the remaining space if you want to. Format it as ext4 and mount it at /.


Remove btrfs-progs to speed up the boot process in case of a drive failure:
$ sudo apt purge btrfs-progs

Change the source to the existing drive and dest to the new one:
$ source=/dev/sda
$ dest=/dev/sdb
Create a backup in case you mix it up:
$ sudo sgdisk --backup=backup-$(basename $source).sgdisk $source
$ sudo sgdisk --backup=backup-$(basename $dest).sgdisk $dest
Create a replica of the source partition table and then grenerate new UUIDs for the new drive:
$ sudo sgdisk --replicate=$dest $source
$ sudo sgdisk -G $dest
Start syncing the raid, replace the X with the correct partition(it’s 2 for me):
$ sudo mdadm --manage /dev/md0 -a $(echo "$dest"X)
Now, copy over the ESP(replace X with the correct partition, it’s 1 for me):
$ sudo dd if=$(echo "$source"X) of=$(echo "$dest"X)
Then list the current drive UUIDs:
$ ls -la /dev/disk/by-partuuid/
Then show the boot-list:
$ efibootmgr -v
Take note of the BootOrder in case you want to change it.
If any of the ubuntu entries points to a UUID that currently don’t exist, delete it(replace XXXX with the ID form the boot-list):
$ sudo efibootmgr -B -b XXXX
If any of the current UUIDs for partition 1 on the drives don’t exist in the boot-list, add it(replace the X with the drive that is missing):
$ sudo efibootmgr --create --disk /dev/sdX --part 1 --label "ubuntu" --loader "\EFI\ubuntu\shimx64.efi"
Verify that it’s correct:
$ efibootmgr -v
