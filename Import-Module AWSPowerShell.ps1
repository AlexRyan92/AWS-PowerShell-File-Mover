#Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

Import-Module AWSPowerShell

#---Define Credentials---#
$userName = 'admin'
$pwdTxt = Get-Content 'C:\Source\SecureCredentials.txt'

#---Convert to secure string---#
$securePwd = $pwdTxt | ConvertTo-SecureString 

#---Create credential object---#
$credObject = New-Object System.Management.Automation.PSCredential -ArgumentList $userName, $securePwd

#---Define current date---#
$Current = Get-Date

#---Define number of days---#
$Days = 90

#---Define source folders---#
$ScanSources = @("C:\Temp","D:\Source","E:\Source","F:\Source","G:\Source","H:\Source","I:\Source","J:\Source","K:\Source","L:\Source","M:\Source","N:\Source")
foreach ($Source in $ScanSources) 
{ 
    #---Define destination folder---#
    $CopyTo = ‘S3://alextestscriptbucket’

    #---Define extension---#
    $LastAccess = ($Current).AddDays(-$Days)

    
    #---Define files to copy from source folder that are older than specified days--- # 
    $Files = Get-ChildItem $Source  -Recurse | Where-Object { $_.LastAccessTime -le "$LastAccess"}

    #---Define number of files copied/not copied---#
    $FilesCopied = 0
    $FilesNotCopied = 0

    #---Copy each file---#
    foreach ($File in $Files)
    {

        #---Define file exists---#
        $FileExists = Test-Path -Path $CopyTo/$File

        #---Determine if the file is not null and does not already exist---#
        if (($File -ne $NULL) -and ($FileExists -eq $False))
        {
    
        #---Copy the file to the destination folder---#
        aws s3 cp $File.FullName $CopyTo

        
        #---Alternate option: Copy-Item $File.FullName $CopyTo---#

        #---Add to number of files copied---#
        $FilesCopied += 1
        }

        else
        {

        #---Add to number of files not copied---#
        $FilesNotCopied += 1

        }
    }
}

#---Display the number of files copied/not copied---#
Write-Host “Files copied:” $FilesCopied -ForegroundColor Green

Write-Host “Files not copied:” $FilesNotCopied -ForegroundColor Red

#Have a text file left behind with a message stating file has been archived and to contact Ben