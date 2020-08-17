https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/user-guide/nested-virtualization

# Disable dynamic memory
```
Set-VM -StaticMemory $VMName
```

# Enable nested virtualization
```
Set-VMProcessor -VMName $VMName -ExposeVirtualizationExtensions $true
```

# Enable mac address spoofing
```
Get-VMNetworkAdapter -VMName $VMName | Set-VMNetworkAdapter -MacAddressSpoofing On
```
