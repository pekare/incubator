# 2 external USB drives, first setup
sudo wipefs -a /dev/sdc
sudo cryptsetup luksFormat /dev/sdc
sudo cryptsetup luksOpen /dev/sdc backup
sudo mkfs.ext4 /dev/mapper/backup -L backup
sudo mkdir /backup
sudo mount /dev/mapper/backup /backup

# daily mount
sudo cryptsetup luksOpen /dev/sdc backup
sudo mount /dev/mapper/backup /backup
# daily umount
sudo umount /backup
sudo cryptsetup luksClose backup



# cronjob as root
#!/usr/bin/env python3

import datetime
import subprocess
from shutil import copy
import os

datestamp = datetime.date.today()

backup_targets = {
  'infra': ['/var/lib/libvirt/images/infra.qcow2'],
  'media': ['/var/lib/libvirt/images/media.qcow2'],
  'opnsense': ['/var/lib/libvirt/images/opnsense.qcow2']
}

backup_destination = "/backup"

for target in backup_targets:
  # shutdown vm: virsh shutdown --domain $ACTIVEVM
  result = subprocess.run(["virsh", "shutdown", target], capture_output=True, text=True)
  if result.stdout =! 'Domain infra is being shutdown':
    print('error shutdown')
  # wait for it to be shutdown
  running = True
  while running:
    result = subprocess.run(["virsh", "dominfo", target], capture_output=True, text=True)
    if 'shut off' in result.stdout:
      running = False
    else:
      sleep(10)
  # copy disk to backup
  for source in backup_targets[target]:
    filename = os.path.basename(source)
    backup_filename = os.path.splitext(base)[0] + date + '.' + os.path.splitext(base)[1]
    destination = os.path.join(backup_destination, backup_filename)
    copy(source, destination)

# dump config: virsh dumpxml $ACTIVEVM > $BACKUP_DIR/$ACTIVEVM-$TIMESTAMP.xml

# start vm
#virsh start infra
#Domain infra started
  result = subprocess.run(["virsh", "start", target], capture_output=True, text=True)
  if result.stdout =! 'Domain infra started':
    print('error starting')
