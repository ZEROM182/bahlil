function Test-IsElevated {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal(
        [Security.Principal.WindowsIdentity]::GetCurrent()
    )
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Ensure-Admin {
    if (Test-IsElevated) {
        return
    }

    $scriptPath = $MyInvocation.PSCommandPath
    if (-not $scriptPath) {
        $scriptPath = $PSCommandPath
    }

    try {
        $argList = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$scriptPath`"")
        Start-Process -FilePath "powershell.exe" -ArgumentList $argList -Verb RunAs
        exit
    }
    catch {
        exit 1
    }
}

Ensure-Admin

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Setup RDP Baru"
$form.Size = New-Object System.Drawing.Size(350, 260)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

$labelUser = New-Object System.Windows.Forms.Label
$labelUser.Text = "Username baru:"
$labelUser.Location = New-Object System.Drawing.Point(20, 20)
$labelUser.Size = New-Object System.Drawing.Size(280, 20)
$form.Controls.Add($labelUser)

$textUser = New-Object System.Windows.Forms.TextBox
$textUser.Location = New-Object System.Drawing.Point(20, 45)
$textUser.Size = New-Object System.Drawing.Size(290, 20)
$form.Controls.Add($textUser)

$labelPass = New-Object System.Windows.Forms.Label
$labelPass.Text = "Password:"
$labelPass.Location = New-Object System.Drawing.Point(20, 80)
$labelPass.Size = New-Object System.Drawing.Size(280, 20)
$form.Controls.Add($labelPass)

$textPass = New-Object System.Windows.Forms.TextBox
$textPass.Location = New-Object System.Drawing.Point(20, 105)
$textPass.Size = New-Object System.Drawing.Size(290, 20)
$textPass.UseSystemPasswordChar = $true
$form.Controls.Add($textPass)

$labelInfo = New-Object System.Windows.Forms.Label
$labelInfo.Text = "User ini akan dibuat & diberi akses Remote Desktop di komputer ini."
$labelInfo.Location = New-Object System.Drawing.Point(20, 140)
$labelInfo.Size = New-Object System.Drawing.Size(290, 40)
$form.Controls.Add($labelInfo)

$buttonCreate = New-Object System.Windows.Forms.Button
$buttonCreate.Text = "Buat & Aktifkan RDP"
$buttonCreate.Location = New-Object System.Drawing.Point(20, 185)
$buttonCreate.Size = New-Object System.Drawing.Size(150, 30)
$form.Controls.Add($buttonCreate)

$buttonCancel = New-Object System.Windows.Forms.Button
$buttonCancel.Text = "Cancel"
$buttonCancel.Location = New-Object System.Drawing.Point(180, 185)
$buttonCancel.Size = New-Object System.Drawing.Size(130, 30)
$form.Controls.Add($buttonCancel)

$buttonCreate.Add_Click({
    $user = $textUser.Text.Trim()
    $pass = $textPass.Text

    if ([string]::IsNullOrWhiteSpace($user) -or [string]::IsNullOrWhiteSpace($pass)) {
        [System.Windows.Forms.MessageBox]::Show("Username dan Password tidak boleh kosong.", "Error", "OK", "Error")
        return
    }

    try {
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0

        Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

        $securePass = ConvertTo-SecureString $pass -AsPlainText -Force
        New-LocalUser -Name $user -Password $securePass -PasswordNeverExpires -ErrorAction Stop

        Add-LocalGroupMember -Group "Remote Desktop Users" -Member $user

        $ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" } | Select-Object -First 1).IPAddress

        [System.Windows.Forms.MessageBox]::Show(
            "RDP berhasil diaktifkan.`n`nIP: $ip`nUsername: $user`nPassword: $pass",
            "Sukses", "OK", "Information"
        )

        $form.Close()
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Gagal: $($_.Exception.Message)", "Error", "OK", "Error")
    }
})

$buttonCancel.Add_Click({
    $form.Close()
})

[void]$form.ShowDialog()
