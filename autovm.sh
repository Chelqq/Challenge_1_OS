#!/bin/bash

# Verificación de argumentos
if [ "$#" -ne 6 ]; then
  echo "Uso: $0 <nombre_vm> <tipo_so> <num_cpus> <memoria_gb> <vram_mb> <tamanio_disco_gb>"
  exit 1
fi

# Variables
NOMBRE_VM=$1
TIPO_SO=$2
NUM_CPUS=$3
MEMORIA_GB=$4
VRAM_MB=$5
TAMANIO_DISCO_GB=$6
CONTROLADOR_SATA="SATAController"
CONTROLADOR_IDE="IDEController"

# Paso 1: Crear VM
VBoxManage createvm --name "$NOMBRE_VM" --ostype "$TIPO_SO" --register

# Paso 2: Configurar VM
VBoxManage modifyvm "$NOMBRE_VM" --cpus "$NUM_CPUS"
VBoxManage modifyvm "$NOMBRE_VM" --memory "$MEMORIA_GB"GB
VBoxManage modifyvm "$NOMBRE_VM" --vram "$VRAM_MB"MB

# Paso 3: Crear disco duro virtual
VBoxManage createmedium disk --filename "$NOMBRE_VM/$NOMBRE_VM.vdi" --size "$TAMANIO_DISCO_GB"GB --format VDI

# Paso 4: Crear y asociar controlador SATA
VBoxManage storagectl "$NOMBRE_VM" --name "$CONTROLADOR_SATA" --add sata
VBoxManage storageattach "$NOMBRE_VM" --storagectl "$CONTROLADOR_SATA" --port 0 --device 0 --type hdd --medium "$NOMBRE_VM/$NOMBRE_VM.vdi"

# Paso 5: Crear y asociar controlador IDE
VBoxManage storagectl "$NOMBRE_VM" --name "$CONTROLADOR_IDE" --add ide
VBoxManage storageattach "$NOMBRE_VM" --storagectl "$CONTROLADOR_IDE" --port 0 --device 0 --type dvddrive --medium emptydrive

# Paso 6: Imprimir configuración
echo "Configuración de la Máquina Virtual:"
VBoxManage showvminfo "$NOMBRE_VM"

echo "Configuración del Disco Duro Virtual:"
VBoxManage showmediuminfo disk "$NOMBRE_VM/$NOMBRE_VM.vdi"

echo "Configuración del Controlador SATA:"
VBoxManage storagectl "$NOMBRE_VM" --name "$CONTROLADOR_SATA" --portcount 1 --remove

echo "Configuración del Controlador IDE:"
VBoxManage storagectl "$NOMBRE_VM" --name "$CONTROLADOR_IDE" --portcount 1 --remove
