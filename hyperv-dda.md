# Enable
## Verify DDA
https://github.com/MicrosoftDocs/Virtualization-Documentation/blob/live/hyperv-tools/DiscreteDeviceAssignment/SurveyDDA.ps1

## Find PCI address
### Find device classes
```
Get-PnpDevice
```

### Get device instanceid
```
$Devices = Get-PnpDevice | Where-Object {$_.Class -eq "SCSIAdapter"}
$Devices | ft -AutoSize 
$InstanceID = "???"
```

### Get locationpath for device
```
$DeviceToDismount = Get-PnpDeviceProperty DEVPKEY_Device_LocationPaths -InstanceId $InstanceID
$LocationPath = ($DeviceToDismount).data[0]
$LocationPath
```

## Disable the device with device manager
```
Disable-PnpDevice -InstanceId $InstanceID
```

## Configure the “Automatic Stop Action” of a VM to TurnOff by executing
```
$VMName = "???"
Set-VM -Name $VMName -AutomaticStopAction TurnOff
```

## Enable Write-Combining on the CPU
```
Set-VM -GuestControlledCacheTypes $true -VMName $VMName
```

## Dismount device from host (be careful of -force, it might affect host system)
```
Dismount-VMHostAssignableDevice -LocationPath $LocationPath -force
```

## Disable dynamic memory for VM
```
Set-VMMemory -VMName $VMName -DynamicMemoryEnabled 0
```

## Assigning the Device to the Guest VM
```
Add-VMAssignableDevice -LocationPath $LocationPath -VMName $VMName
```

# Disable
```
Remove-VMAssignableDevice -LocationPath $LocationPath -VMName VMName
Mount-VMHostAssignableDevice -LocationPath $LocationPath
Enable-PnpDevice -InstanceId $InstanceID
```
