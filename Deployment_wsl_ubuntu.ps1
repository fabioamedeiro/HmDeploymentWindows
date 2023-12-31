function ex{exit}
New-Alias ^D ex

$HomeVirtualboxExecutable = "$HOME\Downloads\VirtualBox-7.0.10-158379-Win.exe"
$HomeVirtualbox = "C:\Program Files\Oracle\VirtualBox"
$HomeOpenVpnExecutable = "$HOME\Downloads\openvpn-connect-3.3.7.2979_signed.msi"
$HomeOpenVpn = "C:\Program Files\OpenVpn Connect\OpenVPNConnect.exe"
$OpenVpnConfig = "$HOME\Downloads\DublinOpenVpn.ovpn"
$HomePuttyExecutable = "$HOME\Downloads\putty-64bit-0.78-installer.msi"
$HomeVisualCExecutable = "$HOME\Downloads\vc_redist.x64.exe"

$HomeTortoiseSVNExecutable = "$HOME\Downloads\TortoiseSVN-1.14.5.29465-x64-svn-1.14.2.msi"

$URL = "https://cfhcable.dl.sourceforge.net/project/tortoisesvn/1.14.5/Application/TortoiseSVN-1.14.5.29465-x64-svn-1.14.2.msi"

if (!([System.IO.File]::Exists($HomeTortoiseSVNExecutable )))
{
    echo "Downloading TortoiseSVN"
    Invoke-WebRequest -Uri $URL -OutFile $HomeTortoiseSVNExecutable

    echo "Installing TortoiseSVN"
    msiexec.exe /i $HomeTortoiseSVNExecutable /quiet ADDLOCAL="ALL"
}


$URL = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
if (!([System.IO.File]::Exists($HomeVisualCExecutable )))
{
    echo "Downloading Visual C++"
    Invoke-WebRequest -Uri $URL -OutFile $HomeVisualCExecutable
}

if (!(Test-Path -Path HKLM:SOFTWARE\Microsoft\DevDiv\VC\Servicing\14.0\RuntimeMinimum))
{
    echo "Installing Visual C++"
    & $HomeVisualCExecutable /q /norestart
    Start-Sleep -Seconds 10
}


$URL = "https://raw.githubusercontent.com/fabioamedeiro/HmDeploymentWindows/main/Dublin_OpenVPN.ovpn"

if (!([System.IO.File]::Exists($OpenVpnConfig )))
{
    echo "Downloading OpenVPN Config"
    Invoke-WebRequest -Uri $URL -OutFile $OpenVpnConfig

}


$URL = "https://swupdate.openvpn.net/downloads/connect/openvpn-connect-3.3.7.2979_signed.msi"

if (!([System.IO.File]::Exists($HomeOpenVpnExecutable )))
{
    echo "Downloading OpenVPN"
    Invoke-WebRequest -Uri $URL -OutFile $HomeOpenVpnExecutable
}


if (!(Test-Path -Path $HomeOpenVpn))
{
    echo "Installing OpenVPN"
    msiexec.exe /i $HomeOpenVpnExecutable /quiet
	Start-Sleep -Seconds 10
	
	echo "Importing OpenVPN Config"
	& C:\"Program Files"\"OpenVpn Connect"\OpenVPNConnect.exe --accept-gdpr --skip-startup-dialogs --import-profile=$OpenVpnConfig
}

$URL = "https://download.virtualbox.org/virtualbox/7.0.10/VirtualBox-7.0.10-158379-Win.exe"
if (!([System.IO.File]::Exists($HomeVirtualboxExecutable )))
{
    echo "Downloading VirtualBox  7.0.10"
    Invoke-WebRequest -Uri $URL -OutFile $HomeVirtualboxExecutable
}

if (!(Test-Path -Path $HomeVirtualbox))
{
    echo "Installing Virtulbox 7.0.10"
    start-process ($HomeVirtualboxExecutable)  --silent
}

echo "Preparing windows to enable some feature"
C:\Windows\System32\OptionalFeatures.exe

echo "Checking if Microsoft-Windows-Subsystem-Linux feature is enabled"

if((Get-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online).State -eq "Disabled")
{
    echo "Enabling WSL"
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all 
}

echo "Checking if VirtualMachinePlatform feature is enabled"

if ((Get-WindowsOptionalFeature -FeatureName VirtualMachinePlatform  -Online).State -eq "Disabled")
{
    echo "Enable Virtual Machine feature"
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all  
}

echo "Checking if Microsoft-Hyper-V feature is enabled"

if ((Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V  -Online).State -eq "Enabled")
{
    echo "Deactivating hyper-V"
    dism.exe /online /disable-feature /featurename:Microsoft-Hyper-V 
 
}

echo "Deploying the Windows terminal"

 winget install --silent --accept-package-agreements --accept-source-agreements --id=9N0DX20HK701 --source=msstore

echo "WSL updating"
wsl --update

echo "Set WSL 2 as your default version"
wsl --set-default-version 2

echo "Install WSL command"

wsl --install -d Ubuntu-22.04
