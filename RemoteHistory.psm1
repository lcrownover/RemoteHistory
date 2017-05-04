<#
.SYNOPSIS
    Powershell wrapper for nirsoft's BrowsingHistoryView by Lucas Crownover.
    URL: https://github.com/lcrownover/RemoteHistory
#>
#requires -Version 3.0
#region Setup

Function Get-RemoteHistory {
    param (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$True)]
        [string]$ComputerName,
    [Parameter()]
        [string]$TargetUser,
    [Parameter()]
        [int]$DaysBack
    )

    ###  Local variables  ###
    $InitConfig = "$PSScriptRoot\bhv\init.cfg"
    $WorkingConfig = "$PSScriptRoot\bhv\work.cfg"
    $FinalConfig = "$PSScriptRoot\bhv\bhv.cfg"
    $LocalComputerName = $Env:COMPUTERNAME
    $LocalUserName = $Env:USERNAME
    $CurrentDateTime = (Get-Date).ToString("d-M-yyy H:MM:ss")

    ###  Test host  ###
    if (!(Test-Connection -Count 1 -ComputerName $ComputerName)) {
        throw "Can't connect to $ComputerName"
    }

    ###  Processing arguments into config  ###
    $WorkingConfig = Get-Content $InitConfig
    if ($TargetUser) {
        $WorkingConfig = $WorkingConfig.Replace("HistorySource=", "HistorySource=4")
        $WorkingConfig = $WorkingConfig.Replace("HistorySourceFolder=", `
                                                "HistorySourceFolder=C:\Users\$TargetUser")
    } else {
        $WorkingConfig = $WorkingConfig.Replace("HistorySource=", "HistorySource=1")
        $TargetUser = "AllUsers"
    }

    if ($DaysBack) {
        $EndDate = (Get-Date).AddDays(-$DaysBack).ToString("d-M-yyy H:MM:ss")
        $WorkingConfig = $WorkingConfig.Replace('previousday', $EndDate)
        $WorkingConfig = $WorkingConfig.Replace('currentday', $CurrentDateTime)
    } else {
        $DaysBack = 365
        $EndDate = (Get-Date).AddDays(-365).ToString("d-M-yyy H:MM:ss")
        $WorkingConfig = $WorkingConfig.Replace('previousday', $EndDate)
        $WorkingConfig = $WorkingConfig.Replace('currentday', $CurrentDateTime)
    }
    $WorkingConfig | Out-File $FinalConfig

    ###  Debug Data  ###
    Write-Debug "`$CurrentDateTime = $CurrentDateTime"
    Write-Debug "`$EndDate = $EndDate"
    Write-Debug "$(Get-Content $FinalConfig)"

    ###  Remote paths  ###
    $Destination = "\\$ComputerName\c$\temp\bhv"
    $Desktop = "C:\Users\$LocalUserName\Desktop"
    $Results = "${ComputerName}_${TargetUser}_${DaysBack}days.csv"
    $bhv = "C:\temp\bhv\browsinghistoryview.exe"
    $arguments = "/cfg C:\temp\bhv\bhv.cfg /scomma $Results"
    
    ###  Copy files, execute script, grab data, delete files  ###
    Copy-Item -Path "$PSScriptRoot\bhv" -Destination $Destination -Recurse -Force
    Invoke-Command -ComputerName $ComputerName -ScriptBlock {
        Set-Location C:\temp\bhv
        Start-Process $Using:bhv $Using:arguments -Wait
    }
    Copy-Item -Path "$Destination\$Results" -Destination $Desktop
    Remove-Item -Path $Destination -Recurse -Force
    Remove-Item $FinalConfig

    Write-Output "`n'$Results' saved to your desktop`n"
}

Export-ModuleMember -Function Get-RemoteHistory