Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "RDP Quick Connect"
$form.Size = New-Object System.Drawing.Size(350, 260)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

$labelIP = New-Object System.Windows.Forms.Label
$labelIP.Text = "IP Address / Hostname:"
$labelIP.Location = New-Object System.Drawing.Point(20, 20)
$labelIP.Size = New-Object System.Drawing.Size(280, 20)
$form.Controls.Add($labelIP)

$textIP = New-Object System.Windows.Forms.TextBox
$textIP.Location = New-Object System.Drawing.Point(20, 45)
$textIP.Size = New-Object System.Drawing.Size(290, 20)
$form.Controls.Add($textIP)

$labelUser = New-Object System.Windows.Forms.Label
$labelUser.Text = "Username:"
$labelUser.Location = New-Object System.Drawing.Point(20, 80)
$labelUser.Size = New-Object System.Drawing.Size(280, 20)
$form.Controls.Add($labelUser)

$textUser = New-Object System.Windows.Forms.TextBox
$textUser.Location = New-Object System.Drawing.Point(20, 105)
$textUser.Size = New-Object System.Drawing.Size(290, 20)
$form.Controls.Add($textUser)

$labelPass = New-Object System.Windows.Forms.Label
$labelPass.Text = "Password:"
$labelPass.Location = New-Object System.Drawing.Point(20, 140)
$labelPass.Size = New-Object System.Drawing.Size(280, 20)
$form.Controls.Add($labelPass)

$textPass = New-Object System.Windows.Forms.TextBox
$textPass.Location = New-Object System.Drawing.Point(20, 165)
$textPass.Size = New-Object System.Drawing.Size(290, 20)
$textPass.UseSystemPasswordChar = $true
$form.Controls.Add($textPass)

$buttonConnect = New-Object System.Windows.Forms.Button
$buttonConnect.Text = "Connect"
$buttonConnect.Location = New-Object System.Drawing.Point(20, 195)
$buttonConnect.Size = New-Object System.Drawing.Size(140, 30)
$form.Controls.Add($buttonConnect)

$buttonCancel = New-Object System.Windows.Forms.Button
$buttonCancel.Text = "Cancel"
$buttonCancel.Location = New-Object System.Drawing.Point(170, 195)
$buttonCancel.Size = New-Object System.Drawing.Size(140, 30)
$form.Controls.Add($buttonCancel)

$buttonConnect.Add_Click({
    $ip = $textIP.Text.Trim()
    $user = $textUser.Text.Trim()
    $pass = $textPass.Text

    if ([string]::IsNullOrWhiteSpace($ip) -or [string]::IsNullOrWhiteSpace($user)) {
        [System.Windows.Forms.MessageBox]::Show("IP dan Username tidak boleh kosong.", "Error", "OK", "Error")
        return
    }

    cmdkey /generic:TERMSRV/$ip /user:$user /pass:$pass | Out-Null

    Start-Process "mstsc.exe" -ArgumentList "/v:$ip"

    $form.Close()
})

$buttonCancel.Add_Click({
    $form.Close()
})

[void]$form.ShowDialog()
