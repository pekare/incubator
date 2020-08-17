https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/user-guide/nested-virtualization

# Disable dynamic memory

# Enable nested virtualization
```
Set-VMProcessor -VMName <VMName> -ExposeVirtualizationExtensions $true
```

# Enable mac address spoofing
```
Get-VMNetworkAdapter -VMName <VMName> | Set-VMNetworkAdapter -MacAddressSpoofing On
```
