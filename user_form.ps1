$xaml = @"
<Window x:Class="ADUserApp.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:ADUserApp"
        mc:Ignorable="d"
        Title="MainWindow" Height="548.668" Width="562.09">
    <Grid>
        <Label x:Name="fn_lbl" Content="First Name:" HorizontalAlignment="Left" Margin="120,123,0,0" VerticalAlignment="Top"/>
        <Label x:Name="mi_lbl" Content="MI:" HorizontalAlignment="Left" Margin="245,123,0,0" VerticalAlignment="Top"/>
        <Label x:Name="ln_lbl" Content="Last Name:" HorizontalAlignment="Left" Margin="290,123,0,0" VerticalAlignment="Top"/>
        <TextBox x:Name="fn_txt" HorizontalAlignment="Left" Height="23" Margin="120,154,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="120"/>
        <TextBox x:Name="mi_txt" HorizontalAlignment="Left" Height="23" Margin="245,154,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="40"/>
        <TextBox x:Name="ln_txt" HorizontalAlignment="Left" Height="23" Margin="290,154,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="120"/>
        <Label x:Name="un_lbl" Content="User Name:" HorizontalAlignment="Left" Margin="120,182,0,0" VerticalAlignment="Top"/>
        <TextBox x:Name="un_txt" HorizontalAlignment="Left" Height="23" Margin="120,208,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="120"/>
        <Label x:Name="dp_lbl" Content="Display Name:" HorizontalAlignment="Left" Margin="247,182,0,0" VerticalAlignment="Top"/>
        <TextBox x:Name="dp_txt" HorizontalAlignment="Left" Height="23" Margin="247,208,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="163"/>
        <Image x:Name="image" HorizontalAlignment="Left" Height="73" Margin="133,39,0,0" VerticalAlignment="Top" Width="71" Source="C:\Users\luper\GitRepo\ADUserCreationTool\ps.png"/>
        <Label x:Name="main_lbl" Content="User Creation Form" HorizontalAlignment="Left" Margin="222,61,0,0" VerticalAlignment="Top" FontWeight="Bold" FontSize="14"/>
        <Button x:Name="cu_bttn" Content="Create User Account" HorizontalAlignment="Left" Margin="290,319,0,0" VerticalAlignment="Top" Width="120" Height="28"/>
        <Label x:Name="cn_lbl" Content="CN/Common Name:" HorizontalAlignment="Left" Margin="120,236,0,0" VerticalAlignment="Top"/>
        <Label x:Name="em_lbl" Content="Email:" HorizontalAlignment="Left" Margin="247,236,0,0" VerticalAlignment="Top"/>
        <TextBox x:Name="cn_txt" HorizontalAlignment="Left" Height="23" Margin="120,267,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="120"/>
        <TextBox x:Name="em_txt" HorizontalAlignment="Left" Height="23" Margin="247,267,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="163"/>
        <Button x:Name="ck_bttn" Content="Generate Fields" HorizontalAlignment="Left" Margin="120,319,0,0" VerticalAlignment="Top" Width="99" Height="28"/>


    </Grid>
</Window>
"@

$xml = $xaml -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$xaml = $xml

# Read formatted XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$form = [Windows.Markup.XamlReader]::Load($reader)


#=========================================
# Load XAML Objects In PowerShell
#=========================================
$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    #"trying item $($_.Name)";
    try {
        Set-Variable -Name "WPF$($_.Name)" -Value $form.FindName($_.Name) -ErrorAction Stop
    }
    catch {
        throw
    }
}

#=====================================
# Show when debugging
#=====================================
<#
Function Get-FormVariables{
    if ($global:ReadmeDisplay -ne $true){
        Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow
        $global:ReadmeDisplay=$true
    }
    write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
    get-variable WPF*
}
Get-FormVariables
#>


#=====================================
# Form Logic
#=====================================

#$WPFem_txt.Text = '@lco.net'
# Function Sets the display name as the user enters their first name, middle initial and last name
# Middle initial is only displayed if data exists
function Set-DisplayName {
    if ($WPFmi_txt.Text) {
        $WPFdp_txt.Text = $WPFln_txt.Text + ", " + $WPFfn_txt.Text + " " + $WPFmi_txt.Text + "."
    }
    else {
        $WPFdp_txt.Text = $WPFln_txt.Text + ", " + $WPFfn_txt.Text
    }
}
$WPFfn_txt.add_textchanged( { Set-DisplayName $WPFfn_txt $_ })
$WPFmi_txt.add_textchanged( { Set-DisplayName $WPFmi_txt $_ })
$WPFln_txt.add_textchanged( { Set-DisplayName $WPFln_txt $_ })

# Function runs when the create user account button is clicked
# The function sets a username based on the data already entered
# once the username is generated, it is checked against active directory to ensure username doesn't already exist

# Button functionality to auto-generate missing fields
$WPFck_bttn.add_click( {

        # Check if middle initial was provided
        if ($WPFmi_txt.Text) {
        
            # Check if last name is less than 5 characters long
            if ($WPFln_txt.Text.Length -lt 5) {
                $WPFun_txt.Text = $WPFln_txt.Text.tolower() + $WPFfn_txt.Text.substring(0, 1).tolower() + $WPFmi_txt.Text.tolower() + "1"
            }
            else {
                $WPFun_txt.Text = $WPFln_txt.Text.substring(0, 5).tolower() + $WPFfn_txt.Text.substring(0, 1).tolower() + $WPFmi_txt.Text.tolower() + "1"
            }

        }
        else {

            if ($WPFln_txt.Text.Length -lt 5) {
                $WPFun_txt.Text = $WPFln_txt.Text.tolower() + $WPFfn_txt.Text.substring(0, 1).tolower() + $WPFmi_txt.Text.tolower() + "1"
            }
            else {
                $WPFun_txt.Text = $WPFln_txt.Text.substring(0, 5).tolower() + $WPFfn_txt.Text.substring(0, 1).tolower() + "1"
            }
        }

        # Generate common name and email address
        $WPFcn_txt.Text = $WPFdp_txt.Text
        $WPFem_txt.Text = $WPFun_txt.Text + '@lco.net'
    })

# Button functionality to check account for duplicates and create the account
$WPFcu_bttn.add_click( {
        $username = $WPFun_txt.Text
        try {
            $account = Get-ADUser -Identity $username -Credential $adm -ErrorAction SilentlyContinue
        }
        catch {
            Write-Output "no user"
        }
    
        # Check if account exists
        if ($account) {
            [System.Windows.MessageBox]::Show("Account <$username> already exists!`nTry a different username.")
        }
        else {
            $default_password = ConvertTo-SecureString -String 'B33b0p@!' -AsPlainText -Force
            $params = @{
                Givenname         = $WPFfn_txt.Text
                Surname           = $WPFln_txt.Text
                Name              = $WPFcn_txt.Text
                DisplayName       = $WPFdp_txt.Text
                SamAccountName    = $WPFun_txt.Text
                UserPrincipalName = $WPFem_txt.Text
                Enabled           = $true
                AccountPassword   = $default_password
            }
            New-ADUser @params -Credential $adm
            [System.Windows.MessageBox]::Show("Account <$username> has been created")
        }
    })


#=====================================
# Display Form
#=====================================
$form.WindowStartupLocation = 'CenterScreen'
$form.Top = $true
$form.ShowDialog() | Out-Null