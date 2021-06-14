# Disk setup
## Disk 1
### / 50GB on install
### /var/lib/libvirt 100%FREE

# HPE drivers
sudo vi /etc/apt/sources.list.d/mcp.list
## Management Component Pack
deb http://sudo vi /etc/fstab
mount -adownloads.linux.hpe.com/SDR/repo/mcp focal/current non-free
sudo -i
curl https://downloads.linux.hpe.com/SDR/hpPublicKey2048.pub | apt-key add -
curl https://downloads.linux.hpe.com/SDR/hpPublicKey2048_key1.pub | apt-key add -
curl https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key1.pub | apt-key add -
exit
sudo apt update && sudo apt install amsd -y

# KVM

## Storage 
# 2nd disk
# luks + lvm
# /var/lib/libvirt/images-large 100%FREE

# create luks partition parted /dev/sdX1
parted /dev/sdX
(parted) mklabel gpt
(parted) mkpart primary ext4 0% 100%
# setup luks
cryptsetup luksFormat /dev/sdX1
cryptsetup luksOpen /dev/sdX1 large
pvcreate /dev/mapper/large
vgcreate large-vg /dev/mapper/large
lvcreate -l 100%FREE large-vg -n images-large
sudo mkfs -t ext4 /dev/large-vg/images-large
sudo mkdir /var/lib/libvirt/images-large
# echo "/dev/disk/by-id/$(ls -la /dev/disk/by-id/ | grep dm-1 | grep uuid | awk '{print $9}') /opt/isos ext4 defaults 0 0"
sudo vi /etc/fstab
mount -a


# Fix luks for boot disks
# https://unix.stackexchange.com/questions/392284/using-a-single-passphrase-to-unlock-multiple-encrypted-disks-at-boot/392286#392286

sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst libosinfo-bin virt-top
#sudo lvcreate -L 50G -n kvm-isos ubuntu-vg
#sudo lvcreate -l 100%FREE -n kvm-vms ubuntu-vg
#sudo mkfs -t ext4 /dev/ubuntu-vg/kvm-isos
#sudo mkfs -t ext4 /dev/ubuntu-vg/kvm-vms

sudo usermod -aG libvirt $USER
sudo usermod -aG kvm $USER

virsh pool-define-as --name large --type dir --target /var/lib/libvirt/images-large
virsh pool-autostart large
virsh pool-start large

#sudo lvcreate -L 50G -n kvm-isos vg0
#sudo lvcreate -l 100%FREE -n kvm-vms vg0
#sudo mkfs -t ext4 /dev/vg0/kvm-isos
#sudo mkfs -t ext4 /dev/vg0/kvm-vms
#sudo mkdir /opt/isos
#sudo mkdir /opt/vms
# check dm-X
#echo "/dev/disk/by-id/$(ls -la /dev/disk/by-id/ | grep dm-1 | grep uuid | awk '{print $9}') /opt/isos ext4 defaults 0 0 
#/dev/disk/by-id/$(ls -la /dev/disk/by-id/ | grep dm-2 | grep uuid | awk '{print $9}') /opt/vms ext4 defaults 0 0" 
#sudo vi /etc/fstab
#mount -a

sudo wget https://opnsense.c0urier.net/releases/21.1/OPNsense-21.1-OpenSSL-dvd-amd64.iso.bz2 -O /opt/isos/OPNsense-21.1-OpenSSL-dvd-amd64.iso.bz2

sudo mv /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.orig
sudo vi /etc/netplan/00-br-vlans-bond.yaml
network:
  renderer: networkd
  version: 2
  bonds:
    bond0:
      dhcp4: false
      dhcp6: false
      interfaces:
      - eno1
      - eno2
      - eno3
      - eno4
      link-local: []
      parameters:
        lacp-rate: fast
        mii-monitor-interval: 100
        min-links: 2
        mode: 802.3ad
  bridges:
    br10:
      dhcp4: false
      dhcp6: false
      interfaces:
      - vlan10
      link-local: []
    br11:
      addresses:
      - 10.0.11.4/24
      dhcp4: false
      dhcp6: false
      gateway4: 10.0.11.254
      interfaces:
      - vlan11
      link-local: []
      nameservers:
        addresses:
        - 10.0.11.254
    br12:
      dhcp4: false
      dhcp6: false
      interfaces:
      - vlan12
      link-local: []
    br13:
      dhcp4: false
      dhcp6: false
      interfaces:
      - vlan13
      link-local: []
    br14:
      dhcp4: false
      dhcp6: false
      interfaces:
      - vlan14
      link-local: []
    br15:
      dhcp4: false
      dhcp6: false
      interfaces:
      - vlan15
      link-local: []
  ethernets:
    eno1:
      dhcp4: false
      dhcp6: false
    eno2:
      dhcp4: false
      dhcp6: false
    eno3:
      dhcp4: false
      dhcp6: false
      optional: true
    eno4:
      dhcp4: false
      dhcp6: false
      optional: true
  vlans:
    vlan10:
      dhcp4: false
      dhcp6: false
      id: 10
      link: bond0
    vlan11:
      dhcp4: false
      dhcp6: false
      id: 11
      link: bond0
    vlan12:
      dhcp4: false
      dhcp6: false
      id: 12
      link: bond0
    vlan13:
      dhcp4: false
      dhcp6: false
      id: 13
      link: bond0
    vlan14:
      dhcp4: false
      dhcp6: false
      id: 14
      link: bond0
    vlan15:
      dhcp4: false
      dhcp6: false
      id: 15
      link: bond0

# Destroy default kvm networks
sudo virsh net-destroy default
sudo virsh net-undefine default

# Apply networking configuration
# sudo netplan generate 
# sudo netplan --debug apply
reboot

cat <<EOF > br10.xml
<network>
  <name>br10</name>
  <forward mode="bridge"/>
  <bridge name="br10"/>
</network>
EOF
cat <<EOF > br11.xml
<network>
  <name>br11</name>
  <forward mode="bridge"/>
  <bridge name="br11"/>
</network>
EOF
cat <<EOF > br12.xml
<network>
  <name>br12</name>
  <forward mode="bridge"/>
  <bridge name="br12"/>
</network>
EOF
cat <<EOF > br13.xml
<network>
  <name>br13</name>
  <forward mode="bridge"/>
  <bridge name="br13"/>
</network>
EOF
cat <<EOF > br14.xml
<network>
  <name>br14</name>
  <forward mode="bridge"/>
  <bridge name="br14"/>
</network>
EOF
cat <<EOF > br15.xml
<network>
  <name>br15</name>
  <forward mode="bridge"/>
  <bridge name="br15"/>
</network>
EOF

# create libvirt network using existing host bridge
virsh net-define br10.xml
virsh net-start br10
virsh net-autostart br10
virsh net-define br11.xml
virsh net-start br11
virsh net-autostart br11
virsh net-define br12.xml
virsh net-start br12
virsh net-autostart br12
virsh net-define br13.xml
virsh net-start br13
virsh net-autostart br13
virsh net-define br14.xml
virsh net-start br14
virsh net-autostart br14
virsh net-define br15.xml
virsh net-start br15
virsh net-autostart br15

# state should be active, autostart, and persistent
virsh net-list --all

rm br1*

sudo ufw enable
sudo ufw allow ssh





sudo bzip2 -d /opt/isos/OPNsense-20.7-OpenSSL-dvd-amd64.iso.bz2
sudo mkdir /opt/vms/opnsense
sudo qemu-img create -f qcow2 /opt/vms/opnsense/disk0.qcow2 20G

virt-install \
--name opnsense \
--vcpus 2 \
--memory 1024 \
--noautoconsole \
--graphics vnc,listen=0.0.0.0 \
--disk /opt/vms/opnsense/disk0.qcow2,size=20,format=qcow2 \
--autostart \
--os-variant freebsd12.0 \
--cdrom /opt/isos/OPNsense-20.7-OpenSSL-dvd-amd64.iso \
--network bridge=br10,model=virtio \
--network bridge=br11,model=virtio \
--network bridge=br12,model=virtio \
--network bridge=br13,model=virtio \
--network bridge=br14,model=virtio \
--network bridge=br15,model=virtio \
--debug


sudo ufw enable
sudo ufw allow ssh




