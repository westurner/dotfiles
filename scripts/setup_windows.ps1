
## setup_windows.ps1
# - author: @westurner

function setup_windows__print_usage() {
    Get-Help -Full setup_windows

    #Write-Output (Get-PSCallStack | Select-Object -Last 1)
    $_this = (Get-PSCallStack | Select-Object -Last 1)."ScriptName"
    Write-Output @"

## Usage    
```sh
powershell.exe -executionpolicy unrestricted -file ./setup_windows.ps1 -h  # --help
powershell.exe -executionpolicy unrestricted -file $($_this) -h
powershell.exe -executionpolicy unrestricted -file ./setup_windows.ps1 -Report # [-ReportDir ./reports/_datetime]
powershell.exe -executionpolicy unrestricted -file ./setup_windows.ps1 -Report -ReportDir ./data/xyz

powershell.exe -executionpolicy unrestricted -file ./setup_windows.ps1 -InstallOpenSSHServerAndClient
powershell.exe -executionpolicy unrestricted -file ./setup_windows.ps1 -StartOpenSSHServer
powershell.exe -executionpolicy unrestricted -file ./setup_windows.ps1 -StartOpenSSHServer

powershell.exe -executionpolicy unrestricted -file ./setup_windows.ps1 -EnableTerminalServices
powershell.exe -executionpolicy unrestricted -file ./setup_windows.ps1 -DisableTerminalServices
powershell.exe -executionpolicy unrestricted -file ./setup_windows.ps1 -StatusTerminalServices

powershell.exe -executionpolicy unrestricted -file ./setup_windows.ps1 -InstallPSWindowsUpdate
powershell.exe -executionpolicy unrestricted -file ./setup_windows.ps1 -UpdateWindows
powershell.exe -executionpolicy unrestricted -file ./setup_windows.ps1 -InstallWSL
powershell.exe -executionpolicy unrestricted -file ./setup_windows.ps1 -InstallChoco
powershell.exe -executionpolicy unrestricted -file ./setup_windows.ps1 -InstallChocoPackages

powershell.exe -executionpolicy unrestricted -file ./setup_windows.ps1 -UpdateWindows
powershell.exe -executionpolicy unrestricted -file ./setup_windows.ps1 -UpdateChocoPackages
```
"@
}


function generate_programs_installed_table() {
    wmic product get * | select *
}


function generate_programs_installed_csv() {
    Write-Debug "INFO: generate_programs_installed_csv ..."
    wmic product get * /format:csv
}

function write_programs_installed_csv ($path) {
    Write-Debug "INFO: write_programs_installed_csv: Writing to $path ..."
    generate_programs_installed_csv > $path
}

function generate_programs_installed_csv-Choco ($path) {
    Write-Output "INFO: generate_programs_installed_csv-Choco: Writing to $path ..."
    choco list --include-programs
}

function write_programs_installed_csv-Choco ($path) {
    Write-Output "INFO: write_programs_installed_csv-Choco: Writing to $path ..."
    generate_programs_installed_csv-Choco > $path
}


function generate_process_table () {
    ## Generate a list of running processes in a table
    Get-Process | Format-Table *
    Get-CimInstance Win32_Process | Select-Object * | Format-Table
}

function write_process_csv ($path) {
    ## Generate a list of running processes in a CSV
    Write-Output "INFO: write_process_csv: Writing to $path and $path.win32process.csv ..."
    Get-Process | Select-Object * | Export-Csv -Path $path -NoTypeInformation
    Get-CimInstance Win32_Process | Select-Object * | Export-Csv -Path "$path.win32process.csv" -NoTypeInformation

    ## Note: To Get the CommandLine values (which aren't present in GetProcess Process object in PS<7 ?)
    #  Get-CimInstance Win32_Process -Filter 'Name = "svchost.exe"' | Select-Object ProcessId, Name, CommandLine
}


function generate_firewall_status () {
    netsh firewall show
    netsh advfirewall firewall dump
}

function write_firewall_status_txt ($path) {

}


function list_all_interactive() {
    generate_programs_installed_csv
    generate_process_table
}

function write_report ($path) {

    Write-Output "INFO: Writing a write_report report to: $path"
    mkdir -Force $path
    write_programs_installed_csv $(Join-Path $path apps_installed.wmic_product_get_star.csv)
    write_process_csv $(Join-Path $path apps_running.csv)
    write_windows_license_key_txt $(Join-Path $path os_windows_license_key.csv)

    write_programs_installed_csv-Choco $(Join-Path $path apps_installed.chocolatey.txt)

    # TODO: ccleaner \?ListInstalledPrograms > $(Join-Path $path apps_installed.ccleaner.txt)
}

function install_wsl () {
    # TODO: setup_wsl
    Write-Output "https://learn.microsoft.com/en-us/windows/wsl/install"
    Write-Output "https://learn.microsoft.com/en-us/windows/wsl/install-manual"

    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    # Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux,VirtualMachinePlatform -All

    wsl --set-default-version 2
    wsl --update
    wsl install --help
}

function install_choco () {
    # TODO: 
}

function install_choco_packages () {
    choco install git.install --params "'/GitAndUnixToolsOnPath /WindowsTerminal"
    choco install -y 7zip ccleaner ctags curl Firefox git GoogleChrome notepadplusplus putty rsync sysinternals unetbootin vagrant vim virtualbox vlc winscp minishift kubernetes-cli docker-engine docker-cli docker-desktop docker-compose
    # docker depends upon `wsl --update` having been run
}

function update_all_choco_packages () {
    choco upgrade -y 'all'
}

function install_pswindowsupdate () {
    Install-Module PSWindowsUpdate
    # Set-ExecutionPolicy Bypass -Scope Process
}

function update_windows_PSWindowsUpdate () {
    # Write-Debug "NOTE: You must install_pswindowsupdate first"
    Get-WindowsUpdate
    #Get-WindowsUpdate -AcceptAll -Install #-AutoReboot
    Install-WindowsUpdate -AcceptAll -Install #-AutoReboot
}

function check_is_admin () {
    (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function _PATH_get_user() {
    echo $env:Path
}

# TODO: PATH_get_user

function PATH_get_machine ($expandvars) {
    $key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment', $true)
    if ($expandvars) {
        $path = $key.GetValue('Path', $null, $null)
    } else {
        $path = $key.GetValue('Path', $null, 'DoNotExpandEnvironmentNames')
    }
    return $path;
}

function PATH_set($pathstr) {
    $key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment', $true)
    $path = $key.GetValue('Path', $null, 'DoNotExpandEnvironmentNames')
    $key.SetValue('Path', $pathstr, 'ExpandString')
    $key.Dispose()
}

function PATH_prepend($path) {
    # TODO
    #[System.Environment]::SetEnvironmentVariable('PATH', $path,[System.EnvironmentVariableTarget]::Machine) 
    $key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment', $true)
    $_path = $key.GetValue('Path',$null,'DoNotExpandEnvironmentNames')
    #$path
    $key.SetValue('Path', $path + ';' + $_path, 'ExpandString')
    $key.Dispose()
}

function PATH_append($path) {
    $key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment', $true)
    $_path = $key.GetValue('Path',$null,'DoNotExpandEnvironmentNames')
    $key.SetValue('Path', $_path + ';' + $path, 'ExpandString')
    $key.Dispose()
}

function PATH_remove($path) {
    # TODO
    #[System.Environment]::SetEnvironmentVariable('PATH', $path,[System.EnvironmentVariableTarget]::Machine) 
}


function get_current_firewall_profile () {
    Get-NetFirewallProfile 
}

function get_firewall_status () {
    Get-NetFirewallProfile -All
}

function print_firewall_log () {
    cat "%systemroot%\system32\LogFiles\Firewall\pfirewall.log"
}


function is_openssh_installed () {
    Get-WindowsCapability -Online | ? Name -like 'OpenSSH*'
}

function install_openssh () {
    param (
        [Parameter(HelpMessage="Install OpenSSH Server (sshd)")]
        #[Alias('Server')]
        [switch]$server,

        [Parameter(HelpMessage="Install OpenSSH Client (ssh)")]
        #[Alias('Client')]
        [switch]$client,

        [Parameter(HelpMessage="Start OpenSSH Server after installation")]
        [Alias('Start-Server')]
        [switch]$start_server
    )
    is_openssh_installed
    #Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
    if ($server) {
        cat_sshd_config
        Add-WindowsCapability -Online -Name OpenSSH.Server
        cat_sshd_config
    }
    if ($client) {
        Add-WindowsCapability -Online -Name OpenSSH.Client
    }
    if ($start_server) {
        start_sshd
    }
}

function start_sshd () {
    Start-Service sshd
}

function stop_sshd () {
    Stop-Service sshd
}

function restart_sshd () {
    Restart-Service sshd
}

function status_sshd () {
    Get-Service -Name sshd
    #cat_sshd_status
    #cat_sshd_logs
}

function cat_sshd_config () {
    cat C:\ProgramData\ssh\sshd_config
}

function cat_sshd_logs () {
    cat C:\ProgramData\ssh\logs\sshd.logs
    # TODO [WMI?] Event Logs (isntead or also?)
    # how to open the logs .msc?
}

function enable_terminal_services () {
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -name "fDenyTSConnections" -value 0
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
}

function disable_terminal_services () {
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -name "fDenyTSConnections" -value 1
    Disable-NetFirewallRule -DisplayGroup "Remote Desktop"
}

# function reenable_terminal_services () {
#     disable_terminal_services
#     enable_terminal_services
# }

function status_terminal_services () {
    Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -name "fDenyTSConnections"
    Get-NetFirewallRule -DisplayGroup "Remote Desktop"
}


function get_windows_license_key () {
    wmic path SoftwareLicensingService get OA3xOriginalProductKey 
}

function write_windows_license_key_txt ($path) {
    Write-Output '# wmic path SoftwareLicensingService get 0A3xOriginalProductKey' > $path
    get_windows_license_key > $path
}

function setup_other_things () {
    install_wsl
}

function setup_windows () {
    param(
        [Parameter(HelpMessage="Generate a Report (and store the output in -ReportDir)")]
        [switch]$Report,

        [Parameter(HelpMessage="Directory in which to store output data")]
        [Alias('OutputDir')]
        [Alias('o')]
        [System.IO.DirectoryInfo]$ReportDir='.\data\',


        [Parameter(HelpMessage="Install All")]
        [Alias('Install')]
        [switch]$InstallAll,

        [Parameter(HelpMessage="Update All")]
        [Alias('Update')]
        [switch]$UpdateAll,


        [Parameter(HelpMessage="Install PSWindowsUpdate")]
        [switch]$InstallPSWindowsUpdate,

        [Parameter(HelpMessage="Update Windows with PSWindowsUpdate")]
        [Alias('WindowsUpdate_')]
        [switch]$UpdateWindows,


        [Parameter(HelpMessage="Install Chocolatey (choco)")]
        [switch]$InstallChoco,

        [Parameter(HelpMessage="Install Chocolatey packages")]
        [switch]$InstallChocoPackages,

        [Parameter(HelpMessage="Update all Chocolatey packages")]
        [switch]$UpdateChocoPackages,


        [Parameter(HelpMessage="Install WSL")]
        [switch]$InstallWSL,


        [Parameter(HelpMessage="Install OpenSSH Server and Client")]
        [Alias('ssh-install-server')]
        [Alias('sshd-install')]
        [switch]$InstallOpenSSHServerAndClient,

        [Parameter(HelpMessage="Install OpenSSH Client")]
        [alias('ssh-install-client')]
        [switch]$InstallOpenSSHClient,

        [Parameter(HelpMessage="Start OpenSSH Server (sshd)")]
        [alias('sshd-start')]
        [switch]$StartOpenSSHServer,
        
        [Parameter(HelpMessage="Stop OpenSSH Server (sshd)")]
        [Alias('sshd-stop')]
        [switch]$StopOpenSSHServer,  

        [Parameter(HelpMessage="Restart OpenSSH Server (sshd)")]
        [Alias('sshd-restart')]
        [switch]$RestartOpenSSHServer,

        [Parameter(HelpMessage="Print OpenSSH Server (sshd) status")]
        [Alias('sshd-status')]
        [switch]$StatusOpenSSHServer,
        
        [Parameter(HelpMessage="Show OpenSSH Server logs (ProgramData\ssh\logs\sshd.log TODO Event Logs)")]
        [Alias('sshd-logs')]
        [switch]$CatLogsOpenSSHServer,

        [Parameter(HelpMessage="Show OpenSSH Server config (ProgramData\ssh\sshd_config)")]
        [Alias('sshd-config')]
        [switch]$CatConfigOpenSSHServer,


        [Parameter(HelpMessage="Enable MS Terminal Services")]
        [alias('terminal-services-enable')]
        [alias('terminal-services-start')]
        [alias('StartTerminalServices')]
        [switch]$EnableTerminalServices,
        
        [Parameter(HelpMessage="Stop MS Terminal Services")]
        [Alias('terminal-services-stop')]
        [Alias('terminal-services-disable')]
        [Alias('StopTerminalServices')]
        [switch]$DisableTerminalServices,  

        [Parameter(HelpMessage="Restart MS Terminal Services")]
        [Alias('terminal-services-restart')]
        [switch]$RestartTerminalServices, 

        [Parameter(HelpMessage="Print status of MS Terminal Services")]
        [Alias('terminal-services-status')]
        [switch]$StatusTerminalServices, 

        [Parameter(HelpMessage="List installed programs")]
        [switch]$ListProgramsInstalled,

        [Parameter(HelpMessage="Get current firewall profile")]
        [switch]$GetCurrentFirewallProfile,

        [Parameter(HelpMessage="Get current firewall rules")]
        [switch]$GetCurrentFirewallRules,

        [Parameter(HelpMessage="Print firewall log")]
        [switch]$PrintFirewallLog,


        [Parameter(HelpMessage="Print help (-h, --help, -help)")]
        [switch]$help
    )

    if ($help) {
        setup_windows__print_usage
    }

    # TODO: create params for each individual file to save:
    #   write_programs_installed_csv wmic_product_get_star.csv
    #   write_process_csv
    #   write_windows_license_key_txt wmic_get_productkey.txt
    if ($Report) {
        write_report $ReportDir
    }
    if ($ListProgramsInstalled) {
        list_all_interactive
    }

    function _tee($output_subpath) {
        $OutputPath=(Join-Path $ReportDir $output_subpath)
        $OutputDir=([System.io.FileInfo]$OutputPath).Directory
        Write-Output "OutputDir: $OutputDir"
        Write-Output "OutputPath: $OutputPath"
        if (!(Test-Path $OutputDir )) {
            mkdir -Force $OutputDir
        }
        return Tee-Object -FilePath $OutputPath
    }

    function _reportpath($subpath) {
        $OutputPath=(Join-Path $ReportDir $subpath)
        return $OutputPath
    }

    if ($GetCurrentFirewallProfile) {
        get_current_firewall_profile | Tee-Object -FilePath (_reportpath("firewallcfg.log.txt"))
    }

    if ($GetCurrentFirewallRules) {
        foreach ($profile in Get-NetFirewallProfile | ForEach-Object Name) {
            Write-Output "## GetNetFirewallProfile -Name $profile | Get-NetFirewallRule" | Tee-Object -FilePath (_reportpath("firewallprofile.$profile.log.txt"))
            Get-NetFirewallProfile -Name $profile | Get-NetFirewallRule | Tee-Object -Append -FilePath (_reportpath("firewallprofile.$profile.log.txt"))
        }
    }

    if ($PrintFirewallLog) {
        print_firewall_log | Tee-Object -FilePath (_reportpath("pfirewall.log.txt"))
    }

    if ($InstallOpenSSHClient) {
        install_openssh -client | Tee-Object -FilePath (_reportpath("install_openssh.client.log.txt"))
    }

    if ($InstallOpenSSHServerAndClient) {
        install_openssh -server -client | Tee-Object -FilePath (_reportpath("install_openssh.server.log.txt"))
    }

    if ($StartOpenSSHServer) {
        start_sshd
        status_sshd
    }

    if ($StopOpenSSHServer) {
        stop_sshd
        status_sshd
    }

    if ($RestartOpenSSHServer) {
        status_sshd
        restart_sshd
        status_sshd
    }

    if ($StatusOpenSSHServer) {
        status_sshd
    }

    if ($CatConfigOpenSSHServer) {
        cat_sshd_config
    }

    if ($CatLogsOpenSSHServer) {
        cat_sshd_logs
    }

    
    if ($StatusTerminalServices) {
        status_terminal_services
    }

    if ($EnableTerminalServices) {
        $is_admin = check_is_admin
        if (!$is_admin) {
            Write-Error "You must be an admin to run this command."
            return
        }
        enable_terminal_services
        status_terminal_services
    }

    if ($DisableTerminalServices) {
        $is_admin = check_is_admin
        if (!$is_admin) {
            Write-Error "You must be an admin to run this command."
            return
        }
        disable_terminal_services
        status_terminal_services
    }

    if ($RestartTerminalServices) {
        $is_admin = check_is_admin
        if (!$is_admin) {
            Write-Error "You must be an admin to run this command."
            return
        }
        disable_terminal_services
        status_terminal_services
        enable_terminal_services
        status_terminal_services
    }


    if ($InstallPSWindowsUpdate -or $InstallAll) {
        install_pswindowsupdate | Tee-Object -FilePath (_reportpath("install_pswindowsupdate.log.txt"))
    }

    if ($InstallWSL -or $InstallAll) {
        install_wsl | Tee-Object -FilePath (_reportpath("install_wsl.log.txt"))
    }

    if ($InstallChocolatey -or $InstallAll) {
        install_choco | Tee-Object -FilePath (_reportpath("install_choco.log.txt"))
    }

    if ($InstallChocoPackages -or $InstallAll) {
        install_choco_packages | Tee-Object -FilePath (_reportpath("install_choco_packages.log.txt"))
    }

    if ($UpdateChocoPackages -or $UpdateAll) {
        update_all_choco_packages | Tee-Object -FilePath (_reportpath("update_choco_packages.log.txt"))
    }


    if ($UpdateWindows -or $InstallAll -or $UpdateAll) {
        update_windows_PSWindowsUpdate | Tee-Object -FilePath (_reportpath("update_windows.log.txt"))
    }
}

Write-output "# Args:"
Write-output $args
if (($args.IndexOf("-h") -ne -1) -or ($args.IndexOf("--help") -ne -1) -or ($args.IndexOf("-Help") -ne -1) ) {
    setup_windows__print_usage
} else {
    setup_windows @args
}