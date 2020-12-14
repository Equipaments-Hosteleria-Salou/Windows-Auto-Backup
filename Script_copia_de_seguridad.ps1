
#
# =========================================================================================================
# = Purpose:           Compresses data from TGProfessional from server SERVIDORNOU and stores it in the
# =                    backup folder of the local filesystem.
# = Parameters:        None.
# = Permissions:       Does need to write in the local C: drive, concretely in the backups folder, which 
# =                    will be created if does not exist. Does need to access network filesystem to copy 
# =                    TGProfessional data. This filesystem is served by SERVIDORNOU. We use PowerShell 
# =                    instead of Windows cmd because the last cannot access network filesystems, which is 
# =                    a requirement.
# =                    Of course, Windows script policy needs to be configured adequately in order to allow 
# =                    the execution of this script.
# = Called From:       Windows Programmed tasks once per day / Manual execution for explicit backups.
# = Author:            Aleix Mariné-Tena (aleixaretra@gmail.com)
# = Notes:             All destinations and paths are hard-coded at the beginning of the script. 
# =                    This script is expected to be executed from programmed tasks of Windows but can be
# =                    executed manually for an inmediate unatended backup copy. A information message is
# =                    shown after the backup is performed to let the user know.
# = Revision:          Last change: 14/12/20 
# = Copyright:         This script has been developed as a tool for Equipaments Hosteleria Salou, so this 
# =                    tool cannot be used for comercial benefit of third-parties. All rights reserved.
# =========================================================================================================
#

# Destination folder
$BackupFolder = "C:\__COPIES_SEGURETAT"
$TGProfessionalData = "\\servidornou\dades\TGProfesional"
$currentBackup = "COPIA_SEGURETAT_$(Get-Date -f dd_MM_yyyy).zip"

Clear-Host

echo "LA COPIA DE SEGURIDAD AUTOMATICA VA A EMPEZAR. NO CIERRES ESTA VENTANA NI APAGUES EL EQUIPO."

if (Test-Path -Path $BackupFolder -PathType Container)  # If the backups folder already exists
{
    # Obtain the names of the last backup for future removal after the backup is done
    $backupList = Get-ChildItem -Path $BackupFolder

    # Perform backup. Use Copy-Item as starting command instead of directly use Compress-Archive because Compress-Archive cannot access a file that is already open, but Copy-item can.
    Copy-Item -Path $TGProfessionalData -Recurse -Force -PassThru -Verbose -Exclude "Thumbs.db" -ErrorAction Continue | Get-ChildItem | Compress-Archive -DestinationPath $BackupFolder\$currentBackup -CompressionLevel Fastest -ErrorAction Continue

    # Remove old back-ups after we have performed the current one
    foreach ($backup in $backupList) 
    {
	    Remove-Item -Path $backup.fullname
    }
}
else  # If the backup folder does not exist it is the first backup copy...
{
    # Create backup folder
    New-Item -ItemType Directory -Force -Path $BackupFolder

    # Perform backup
    Copy-Item -Path $TGProfessionalData -Recurse -Force -PassThru -Verbose -Exclude "Thumbs.db" -ErrorAction Continue | Get-ChildItem | Compress-Archive -DestinationPath $BackupFolder\$currentBackup -CompressionLevel Fastest -ErrorAction Continue
}

# Remove tmp files to generate the backup
Remove-Item –path TGProfesional –recurse

echo ""
echo ""
echo ""
echo "COPIA FINALIZADA"
echo ""
echo "NO OLVIDES GUARDAR LA COPIA CREADA EN UN LUGAR SEGURO SEPARADO EN EL ESPACIO DE LOS DATOS ORIGINALES PARA OBTENER UNA VERDADERA COPIA DE SEGURIDAD"
echo ""
echo "PULSA CUALQUIER TECLA O CIERRA ESTA VENTANA PARA SALIR"

Read-Host

