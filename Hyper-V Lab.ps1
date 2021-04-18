
<#
.SYNOPSIS
    create Hyper-V VMs based on the input from user.
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>

# Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart
Import-Module Hyper-V
if (!(Get-Module -Name Hyper-V)) {
    # Testing if Hyper-V Powershell modules are installed
    Write-Host "Install Hyper-V Powershell module" 
}  
else {
    
    [int]$NoOfVMs = $null       # Getting the no. of VM to create
    $NameOfVMs = $null       
    $NameOfVMs = @()            # Getting the names of VM to create
    $VMlocation = "H:\Hyper-V VMs"  # The location to VM files
    $VHDXsize = 20GB                # vDisk Size
    $WS_2016_ISO_loc = "G:\WSIM\WS2016\version 3\WS2016_DC_Eval_no_prompt_autounattend_xml.iso"   # The location of installation media (ISO)
    $vSwitchName = "ExternalSwitch" # Virtual Switch name
    $vSwitchPhyAdater = (Get-NetAdapter | Select-Object -ExpandProperty InterfaceAlias) # Physical adapter (uplink) for the virtual switch
    $MinMem = 512MB
    $MaxMem = 2048MB
    do {                
        try {
            $NoOfVMs = Read-Host "Enter the no. of VMs to create"   # Getting the no. of VMs to be created via user prompt
            $cond = $true   # a flag variable
            if (($cond) -and ($NoOfVMs -gt 0)) {
                while ($NoOfVMs -gt 0) {
                    $tempName = Read-Host "Enter the name for VM(s)" # Getting the names of VMs to be created via user prompt
                    if (Test-Path -Path "$VMlocation\$tempName") {
                        # checking whether any VM files already exists with same name
                        Write-Host "VM files with same name already exists! Please enter a different name..."
                    }
                    else {
                        $NameOfVMs += $tempName 
                        $NoOfVMs--
                    }
                }
            }
            else {
                Write-Host "Please enter a numeric value greater than 0"
                $cond = $false
            }
        }
        catch {
            Write-Host "Please enter a number!"
            $cond = $false
        }
    } while (!($cond))
    try {
        if (!(Get-VMSwitch -SwitchName $vSwitchName -ErrorAction SilentlyContinue)) {
            # Checking whether a external virtual switch with name in $vSwitchName variable exists
            New-VMSwitch -Name $vSwitchName -AllowManagementOS $true -NetAdapterName $vSwitchPhyAdater  # if not, create a new switch with name in $vSwitchName variable
        }
        else {
            $NameOfVMs | ForEach-Object { 
                if (Get-VM -Name $_ -ErrorAction SilentlyContinue) {
                    Write-Host "VM named" """$_""" "already exists"
                }
                else {
                    Write-Host "Creating VM" """$_""" "..."         #optional; to organise the displayed output
                    New-VM -Name $_ -Path $VMlocation -MemoryStartupBytes 800MB -NewVHDPath $_".vhdx" -Generation 2 -NewVHDSizeBytes $VHDXsize -SwitchName $vSwitchName 
                    # Write-Host "Finished creating VM" """$_"""    #optional; to organise the displayed output
                    start-sleep 1                                   #optional; to organise the displayed output
                    Add-VMDvdDrive -VMName $_ -Path $WS_2016_ISO_loc -ErrorAction SilentlyContinue   # Mounting the Windows installation media (ISO)
                    Set-VMFirmware -VMName $_ -FirstBootDevice (Get-VMDvdDrive -VMName $_)
                    Set-VM -Name $_ -DynamicMemory -MemoryMinimumBytes $MinMem -MemoryMaximumBytes $MaxMem
                    Start-VM -Name $_ -ErrorAction SilentlyContinue #starting the VM and guest OS installation (EUFI)
                }
            }  
        }
        
    }
    catch {
        Write-Warning "VM creation failed!"  $errormsg
    }
}

# function VirtualSwitch ($VirSwitch = (Get-VMSwitch -SwitchType External -ErrorAction SilentlyContinue)) {
#     if ($VirSwitch) {
#         New-VMSwitch -Name ExternalSwitch -NetAdapterName -AllowManagementOS $true
#     } 
#     else {
#         Write-Host "An EXTERNAL Virtual Switch already exists..."
#     }
# }
    
# $NewVMs = @{
 
#     Name               = $_
#     Generation         = '2'
#     MemoryStartupBytes = 2GB
#     NewVHDPath         = $_ + ".vhdx"
#     NewVHDSizeBytes    = 20GB
#     path               = "H:\Hyper-V VMs"
# }
# $ModifyVMs = @{
# DynamicMemory = $true
# MemoryMinimumBytes = 512MB
# MemoryMaximumBytes = 2GB

# }

# New-VM -Name ($VMname=Read-Host "Enter a name for VM") -Path "H:\Hyper-V VMs" -MemoryStartupBytes 512MB -NewVHDPath $VMname".vhdx" -NewVHDSizeBytes 20GB | Set-VM -DynamicMemory -MemoryMinimumBytes 512MB -MemoryMaximumBytes 2GB -Verbose
# New-VM @vms