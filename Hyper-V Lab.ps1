
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

[CmdletBinding()]
param (
    [Parameter(HelpMessage = "Enter the no of VM to create.")]
    [int]
    $NoOfVMs = 0,

    # Parameter help description
    [Parameter(Mandatory = $false, HelpMessage = "Enter the names of VM to create.")]
    [string[]]
    $NameOfVMs = $null,

    # Parameter help description
    [Parameter()]
    [string]
    $VMlocation = "H:\Hyper-V VMs",

    # Parameter help description
    [Parameter()]
    [string]
    $VHDXsize = 20GB,

    # Parameter help description
    [Parameter()]
    [string]
    $vSwitchName = "ExternalSwitch",

    # Parameter help description
    [Parameter()]
    [string]
    $MinMem = 512MB,

    # Parameter help description
    [Parameter()]
    [string]
    $MaxMem = 2048MB,

    # Parameter help description
    [Parameter()]
    [string]
    $ISO = ""
)
function Get-ISO {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $temp1
    )
    $temp1 = Read-Host "Select the OS to install
    1 - WS2016
    2 - WS2012R
    3 - W10
    4 - W8.1
    5 - CentOS 7
    Please choose Project Type"

    Switch ($temp1) {
        1 { $OS = "D:\Softwares\~ WINDOWS OS's\Windows Server 2016 (x64)\Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO" }
        2 { $OS = "D:\Softwares\~ WINDOWS OS's\WINDOWS SERVER 2012 R2 Update1\9600.17050.Microsoft Windows Server 2012 R2 Update1 (x64) EVAL.ISO" }
        3 { $OS = "D:\Softwares\~ WINDOWS OS's\WINDOWS 10\Win10_20H2_English_x64.iso" }
        4 { $OS = "D:\Softwares\~ WINDOWS OS's\WINDOWS 8.1 Update1\Windows_8.1_Single_Language_x64.iso" }
        5 { $OS = "G:\CentOS-7-x86_64-DVD-2009.iso" }
    }
    return $OS
}

## $WS_2016_ISO_loc = "G:\WSIM\WS2016\version 3\WS2016_DC_Eval_no_prompt_autounattend_xml.iso"   # The location of installation media (ISO)
$vSwitchPhyAdater = (Get-NetAdapter | Select-Object -ExpandProperty InterfaceAlias) # Physical adapter (uplink) for the virtual switch
try {
    Get-Module -Name Hyper-V
    # createVM()
}
catch {
    Write-Host "Install Hyper-V Powershell module" 
}

# function createVM {
#     param (
#         # OptionalParameters
#     )
#     $NoOfVMs = Read-Host -Prompt "Enter the no. of VMs to create"   # Getting the no. of VMs to be created via user prompt
#     [string[]]$tempName = Read-Host -Prompt "Enter the name for VM(s)" # Getting the names of VMs to be created via user prompt
# }

# Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart
Import-Module Hyper-V
if (!(Get-Module -Name Hyper-V)) {
    # Testing if Hyper-V Powershell modules are installed
    Write-Host "Install Hyper-V Powershell module" 
}  
else {
    do {
        try {
            [Int32][ValidateRange(1, 10)]$NoOfVMs = Read-Host "Enter the no. of VMs to create"   # Getting the no. of VMs to be created via user prompt
            $cond = $true   # a flag variable
            $tempName = $null
            if (($NoOfVMs -gt 0) -and ($cond)) {
                while ($NoOfVMs -gt 0) {
                    $tempName = Read-Host "Enter the name for VM(s)" # Getting the names of VMs to be created via user prompt
                    if (!$tempName) {
                        Write-Host "Please enter a valid name for VM"
                    }
                    elseif (Test-Path -Path "$VMlocation\$tempName") {                        
                        Write-Host "VM files with same name already exists! Please enter a different name..." # checking whether any VM files already exists with same name
                    }
                    else {
                        $NameOfVMs += , $tempName 
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
            Write-Host $Error[0]
            $cond = $false
        }
        
    }while (!($cond))

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
                    $ISO = Get-ISO # OSselection is a function
                    Write-Host "Creating VM" """$_""" "..."         #optional; to organise the displayed output
                    New-VM -Name $_ -Path $VMlocation -MemoryStartupBytes 800MB -NewVHDPath $_".vhdx" -Generation 2 -NewVHDSizeBytes $VHDXsize -SwitchName $vSwitchName 
                    # Write-Host "Finished creating VM" """$_"""    #optional; to organise the displayed output
                    start-sleep 1                                   #optional; to organise the displayed output
                    Add-VMDvdDrive -VMName $_ -Path $ISO -ErrorAction SilentlyContinue   # Mounting the Windows installation media (ISO)
                    Set-VMFirmware -VMName $_ -FirstBootDevice (Get-VMDvdDrive -VMName $_)
                    Set-VM -Name $_ -DynamicMemory -MemoryMinimumBytes $MinMem -MemoryMaximumBytes $MaxMem
                    Start-VM -Name $_ -ErrorAction SilentlyContinue #starting the VM and guest OS installation (EUFI)
                }
            }  
        }
        
    }
    catch {
        Write-Warning $Error[0]
    }
    # foreach ($VM in $NameOfVMs) {
    #     Enter-PSSession -VMName $VM
    #     Invoke-Command -VMName $VM -ScriptBlock{Rename-Computer -NewName $VM}
    # }
    
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