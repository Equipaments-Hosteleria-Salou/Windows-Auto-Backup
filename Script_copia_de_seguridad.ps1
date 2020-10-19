
# Destination folder
$Destination = "C:\COPIA_SEGURETAT\COPIA_SEGURETAT_$(Get-Date -f dd_MM_yyyy)"
echo "LA COPIA DE SEGURIDAD AUTOMATICA VA A EMPEZAR. NO CIERRES ESTA VENTANA"

# Checks if the backup folder exists
if (Test-Path -Path 'C:\COPIA_SEGURETAT' -PathType Container)
{
    # Obtain the name of the last backup
	$oldcopyname = "$(dir c:\COPIA_SEGURETAT)"
    # Copy TG data to the backup folder
	Copy-Item -Recurse -Path \\servidornou\dades\TGProfesional -Destination $Destination
    # Remove old backup
	Remove-Item –path c:\COPIA_SEGURETAT\$oldcopyname
}
else  # If the backup folder does not exist
{
    # Create backup folder
	New-Item -Path "c:\" -Name "COPIA_SEGURETAT" -ItemType "directory"
    # Copy TG data to the backup folder
	Copy-Item -Recurse -Path \\servidornou\dades\TGProfesional -Destination $Destination
}
echo "COPIA FINALIZADA"
echo "PULSA CUALQUIER TECLA PARA SALIR"

[Console]::ReadKey()