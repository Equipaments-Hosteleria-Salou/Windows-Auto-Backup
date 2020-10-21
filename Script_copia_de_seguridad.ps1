
# Destination folder
$BackupFolder = "C:\COPIA_SEGURETAT"
$tgData = "\\servidornou\dades\TGProfesional"
$Destination = "$BackupFolder\COPIA_SEGURETAT_$(Get-Date -f dd_MM_yyyy).zip"

echo "LA COPIA DE SEGURIDAD AUTOMATICA VA A EMPEZAR. NO CIERRES ESTA VENTANA"

# Checks if the backup folder exists
if (Test-Path -Path 'C:\COPIA_SEGURETAT' -PathType Container)
{
    # Obtain the names of the last backup
    $backupList = Get-ChildItem -Path C:\COPIA_SEGURETAT 
    Copy-Item -Recurse -Path $tgData -Destination $Destination
    foreach ($backupfolder in $backupList) 
    {
        $backupfolderPath = $backupfolder.fullname
        # Remove old backup
	    Remove-Item –path $backupfolderPath -Recurse
    }
}
else  # If the backup folder does not exist
{
    # Create backup folder
	New-Item -Path "c:\" -Name "COPIA_SEGURETAT" -ItemType "directory"
    # Copy TG data to the backup folder
	Copy-Item -Recurse -Path $tgData -Destination $Destination
}

echo "COPIA FINALIZADA"
echo "PULSA CUALQUIER TECLA PARA SALIR"

[Console]::ReadKey()

