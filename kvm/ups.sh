sudo apt install nut -y

sudo vim /etc/nut/nut.conf
# mode standalone

sudo vim /etc/nut/ups.conf
[myups]
    driver = nutdrv_qx
    port = auto
