
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


# Hard-coded parameters and data declaration
$backupFolder = "C:\__COPIES_SEGURETAT"
$TGProfessionalFolder = "TGProfesional"
$TGProfessionalData = "\\servidornou\dades"
$MAX_BACKUPS = 10

Clear-Host  # Clean screen
echo "INICIANT LA TASCA DE LA COPIA DE SEGURETAT."

# Generate current backup name
$currentBackup = "COPIA_SEGURETAT_$(Get-Date -f mm_HH_dd_MM_yyyy).zip"

if (Test-Path -Path $backupFolder -PathType Container)  # If the backups folder already exists
{
    # Perform backup. Use Copy-Item as starting command instead of directly use Compress-Archive because 
    # Compress-Archive cannot access a file that is already open, but Copy-item can.
    Copy-Item -LiteralPath "$TGProfessionalData\$TGProfessionalFolder" -Destination $backupFolder -Recurse -Force -Verbose -Exclude @('thumbs.bd','desktop.ini') -ErrorAction Continue 

    # Compress the result of the copied backup folder
    Compress-Archive -Force -LiteralPath "$backupFolder\$TGProfessionalFolder" -DestinationPath "$backupFolder\$currentBackup" -CompressionLevel Fastest -ErrorAction Continue

    echo "LA COPIA DE SEGURETAT HA ACABAT. "

    # If there are more than $MAX_BACKUPS backups remove the older ones
    $currentNumBackups = ( Get-ChildItem -Path $backupFolder -filter "*.zip" -Attributes !Directory | Measure-Object ).Count
    if ( $currentNumBackups -gt $MAX_BACKUPS )
    {
        echo "ARRIBAT AL MAXIM NOMBRE DE COPIES DE SEGURETAT. ES BORRARAN UNA O MES COPIES ANTIGUES."
        $backupList = Get-ChildItem -Path $backupFolder -filter "*.zip" -Attributes !Directory | sort LastWriteTime -Descending | select name
        while ( $currentNumBackups -gt $MAX_BACKUPS )
        {
            $currentNumBackups = $currentNumBackups - 1
            Remove-Item  "$backupFolder\$backupList[$currentNumBackups]"
            echo "COPIA $backupList[$currentNumBackups] ELIMINADA."
        }
    }
}
else  # If the backup folder does not exist it is the first backup copy...
{
    # Create backup folder
    New-Item -ItemType Directory -Force -Path $backupFolder

    # Perform backup. Use Copy-Item as starting command instead of directly use Compress-Archive because 
    # Compress-Archive cannot access a file that is already open, but Copy-item can.
    Copy-Item -LiteralPath "$TGProfessionalData\$TGProfesionalFolder" -Destination $backupFolder -Recurse -Force -Verbose -Exclude @('thumbs.bd','desktop.ini') -ErrorAction Continue 

    # Compress the just generated copied backup folder
    Compress-Archive -Force -LiteralPath "$backupFolder\$TGProfessionalFolder" -DestinationPath "$backupFolder\$currentBackup" -CompressionLevel Fastest -ErrorAction Continue
}

# Shutdown and make a local copy in the desktop in Jordi's desktop
if (Test-Path "C:\Users\Jordi\Desktop")
{
    Copy-Item -LiteralPath "$BackupFolder\$currentBackup" -Destination "C:\Users\Jordi\Desktop" -Force -ErrorAction Continue 
    Read-Host
}

echo "AQUI EL PC ES PODRIA CONFIGURAR PER APAGARSE. APRETA QUALSEVOL TECLA PER SORTIR."
Stop-Computer -ComputerName "localhost" -Force
