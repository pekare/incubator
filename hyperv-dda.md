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

## Dismount device from host (append -force flag if it fails)
```
Dismount-VMHostAssignableDevice -LocationPath $LocationPath
```

Disable dynamic memory for VM.

Assigning the Device to the Guest VM
Add-VMAssignableDevice -LocationPath $locationPath -VMName VMName

# Disable
Remove-VMAssignableDevice -LocationPath $LocationPath -VMName VMName
Mount-VMHostAssignableDevice -LocationPath $LocationPath
