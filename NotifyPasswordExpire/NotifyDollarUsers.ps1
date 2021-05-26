<#
#### requires ps-version 3.0 ####
<#
.SYNOPSIS
Send out mail if Admin Password has less then 7 days to expire
.DESCRIPTION
Send out mail if Admin Password has less then 7 days to expire, and log the notifications to D:\Get-PSDollar\log.log
.NOTES
   Version:        0.1
   Author:         Daniel Olsson
   Creation Date:  Thursday, September 12th 2019, 1:23:17 pm
   File: NotifyDollarUsers.ps1
   Copyright (c) 2019 
HISTORY:
Date      	          By	Comments
----------	          ---	----------------------------------------------------------

.COMPONENT
 Get-PSDollar 
#>




$Today = (Get-Date).ToString("dd/MM/yyyy")
$PSDollar = Get-PSdollar | Where-Object {$_.mail -ne 'xxxx' -and $_.mail -ne 'xxxx' -and $_.mail -ne 'xxxx'}

foreach ($User in $PSDollar)  {

    $Name = $User.Name
    $To = $User.Mail
    $ExpiryDate = $User.ExpiryDate
    $DateDiff = New-TimeSpan -Start $Today -End $ExpiryDate

    
    If ($DateDiff.Days -le 7 -and $DateDiff.Days -ge 0){
        
        #HTML Props
        $Body = "
        <html>
        <head>
        <style type='text/css'>
        h1 {
        color: #01A0D7;
        font-family: verdana;
        font-size: 20px;
        }
     
        h2 {
        color: ##002933;
        font-family: verdana;
        font-size: 15px;
        }
     
        body {
        color: #002933;
        font-family: verdana;
        font-size: 13px;
        }
        </style>
        </head>
        <h1>Your AdminAccount password will soon expire!</h1>
        <body>
        Dear $Name<br/><br/>
        Your password to your $dollaruser user account will expire in <b>$($DateDiff.Days)</b> days (<b>$ExpiryDate</b>).<br/><br/>
        To change the password to your Admin account, just sign in to the computer using that particular account, then press CTRL+ALT+DELETE and choose 'Change a password'.<br/><br/>
        
        </body>
        </html>
        "
        #Override to for testing purposes
        #$To = "daniel.olsson@stralfors.no"

        #Email Settings
        $MailProp = @{ 
    
        From = 'xxxx';
        Subject = 'Your DollarUser password will expire soon!';
        Smtpserver = 'xxxx'
        To = $to
        Body = $Body
        } #MAILPROPS
        
        #Send the mail message
         Send-MailMessage @MailProp -bcc 'xxxx' -BodyAsHtml -Encoding Unicode

         $Log= ($Timestamp + " Notified $To")
         $Log | Out-File D:\Get-PSdollar\Log.log
    } #IF

} #FOREACH

        
    
    





