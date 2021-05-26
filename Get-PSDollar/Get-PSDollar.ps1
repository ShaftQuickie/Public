<#
#### requires ps-version 3.0 ####
<#
.SYNOPSIS
This script will search for all the DollarUsers(local admin), that are in Norway.
.DESCRIPTION
Get-PSDollar will first query all the users in Admin Users OU for their name and expirydate. Since they dont have the correct email-adresses,
the script will build a "Namefilter" based on their name -admin, then collect the emailadresses, from their regular accounts.
Use verbose parameter to get Verbose output
.NOTES
   Version:        0.1
   Author:         Daniel Olsson
   Creation Date:  Wednesday, September 25th 2019, 8:18:33 am
   File: Get-PSdollar.ps1
   Copyright (c) 2019 Strålfors
HISTORY:
Date      	          By	Comments
----------	          ---	----------------------------------------------------------

.COMPONENT
 Required Modules: ActiveDirectory
.EXAMPLE
Get-PSDollar
#>


function Get-PSdollar {
    [CmdletBinding()]
    PARAM (

    [Parameter(ValueFromPipeline=$true,
    Mandatory=$false)]
    [String]$Logpath
        
    ) #PARAM
    
    BEGIN {

        If ( ! (Get-module ActiveDirectory )) {
            Import-Module ActiveDirectory
          }

        $DollarSearch_Param=@{
            SearchBase = "OU=Norway,OU=AdminAccounts,OU=Base,DC=stralfors,DC=se"
            Filter = {enabled -eq $true -and passwordneverexpires -eq $false}
            Properties = "*"
        } #DollarSearch

        $DollarUsers = get-aduser @DollarSearch_Param |
        select name,  @{n="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}
        
    } #BEGIN
    
    PROCESS {

        #SEARCHFILTER
        Write-Verbose "Creating a filter used for searching the correct AD users"
        $NamesFilter = foreach ($usr in $DollarUsers) {
  
        $Name = $usr.name.TrimEnd("Admin")
        $Name.Trim()
  
      } #NAMESFILTER

      #COLLECTING MAILADRESSES
      Write-Verbose "Collecting the mailaccounts"
      $Mail = foreach ($n in $namesFilter) {
      Get-ADUser -filter "name -eq '$n'" -Properties userprincipalname, displayname | 
      Select-Object @{n='Mail';E={$_.userprincipalname}}, displayname

  } #MAIL

      $Mail += [PSCustomObject]@{
      'Mail' = "Ridwan.Seid@stralfors.no";
      'Displayname' = "Ridwan Seid"

  } #MAIL

    } #PROCESS
    
    END {
        
        #Output
        Write-Verbose "Creating an output with Name, ExpiryDate and mailadress"
        $Result = foreach ($User in $Mail) {
            $filter = $user.displayname + " Admin"
            Get-ADUser -SearchBase $DollarSearch_Param.SearchBase -Filter {displayname -like $filter -and Enabled -eq $True -and PasswordNeverExpires -eq $False} -Properties 'DisplayName', 'Mail', 'msDS-UserPasswordExpiryTimeComputed' |
            Select-Object -Property  @{n='Name';E={$_.DisplayName.replace('Admin',"")}},
                                     @{n='ExpiryDate';Expression={[datetime]::FromFileTime($_.'msDS-UserPasswordExpiryTimeComputed')}},
                                     @{n='Mail';E={$User.mail}}
                                    
            } #RESULT
            
        $Result

    } #END
} #FUNCTION


