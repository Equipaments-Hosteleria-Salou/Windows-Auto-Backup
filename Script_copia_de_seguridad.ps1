
#
# ============================================================================================================
# | Purpose:           Copies and then compresses program data from TGProfessional served in the local area  |
# |                    network filesystem by the server SERVIDORNOU, pointed by the variable                 | 
# |                    $TGProfessionalData. Stores the compressed folder in the backup folder of the local   |
# |                    filesystem, pointed by the variable $BackupFolder.                                    |
# | Parameters:        Hardcoded in the variable definition, which can be changed editing this script.       |
# | Permissions:       - Does need to write in the local C: drive in order to create the backup folder       |
# |                    which will be created if does not exist.                                              |
# |                    - Does need to access network filesystem to copy TGProfessional data. This filesystem |
# |                    is served by SERVIDORNOU. We use PowerShell instead of Windows cmd because the last   |
# |                    cannot access network filesystems, which is a requirement.                            | 
# |                    - Of course, Windows script policy needs to be configured adequately in order to      | 
# |                    allow the execution of this script.                                                   |
# |                    - Argument 1 of the script indicates that the computer does not need to shut down     |
# |                    when the copy has finished.                                                           |
# | Called From:       Windows Programmed tasks once per day / Manual execution for explicit backups.        |
# | Author:            Aleix Mariné-Tena (aleixaretra@gmail.com)                                             |
# | Notes:             All destinations and paths are hard-coded at the beginning of the script.             |
# |                    This script is expected to be executed from programmed tasks of Windows but can be    |
# |                    executed manually for an inmediate unatended backup copy. A information message is    |
# |                    shown after the backup is performed to let the user know.                             |
# | Revision:          Last change: 14/12/20                                                                 |
# | Copyright:         This script has been developed as a tool for Equipaments Hosteleria Salou, so this    |
# |                    tool cannot be used for comercial benefit of third-parties. All rights reserved.      |  
# ============================================================================================================
#


# Parameters and data declaration
$BackupFolder = "C:\__COPIES_SEGURETAT"
$TGProfessionalData = "\\servidornou\dades\TGProfesional"

# Parameter reading
$shutdown = $args[0]

Clear-Host  # Clean screen
echo "LA COPIA DE SEGURIDAD AUTOMATICA VA A EMPEZAR. NO CIERRES ESTA VENTANA NI APAGUES EL EQUIPO."

# Generate backup name
$currentBackup = "COPIA_SEGURETAT_$(Get-Date -f dd_MM_yyyy).zip"
if (Test-Path -Path $BackupFolder -PathType Container)  # If the backups folder already exists
{
    # Obtain the names of the last backup for future removal after the backup is done
    $backupList = Get-ChildItem -Path $BackupFolder

    # Perform backup. Use Copy-Item as starting command instead of directly use Compress-Archive because 
    # Compress-Archive cannot access a file that is already open, but Copy-item can.
    Copy-Item -LiteralPath $TGProfessionalData -Destination $BackupFolder -Recurse -Force -Verbose -Exclude @('thumbs.bd','desktop.ini') -ErrorAction Continue 

    # Compress the just generated copied backup folder
    Compress-Archive -Force -LiteralPath $( $BackupFolder + "\TGProfesional") -DestinationPath $BackupFolder\$currentBackup -CompressionLevel Fastest -ErrorAction Continue

    # Remove old back-ups and temporals after we have performed the current one
    foreach ($backup in $backupList) 
    {
	    Remove-Item -Recurse -LiteralPath $backup.fullname 
    }
}
else  # If the backup folder does not exist it is the first backup copy...
{
    # Create backup folder
    New-Item -ItemType Directory -Force -Path $BackupFolder

    # Perform backup. Use Copy-Item as starting command instead of directly use Compress-Archive because 
    # Compress-Archive cannot access a file that is already open, but Copy-item can.
    Copy-Item -LiteralPath $TGProfessionalData -Destination $BackupFolder -Recurse -Force -Verbose -Exclude @('thumbs.bd','desktop.ini') -ErrorAction Continue 

    # Compress the just generated copied backup folder
    Compress-Archive -Force -LiteralPath $( $BackupFolder + "\TGProfesional") -DestinationPath $BackupFolder\$currentBackup -CompressionLevel Fastest -ErrorAction Continue
}
# Remove backup folder
Remove-Item -Recurse -Force -LiteralPath $( $BackupFolder + "\TGProfesional") -ErrorAction SilentlyContinue

if ($shutdown -eq $null)
{
    #Stop-Computer -ComputerName "localhost" -Force
    Read-Host
}
else
{
    # Special line for one of the scripts, to have a copy in the desktop
    Copy-Item -LiteralPath $BackupFolder\$currentBackup -Destination "C:\Users\Jordi\Desktop" -Force -ErrorAction Continue 
    Read-Host
}

