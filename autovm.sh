#!/bin/bash

# Verificación de argumentos
if [ "$#" -ne 6 ]; then
  echo "Uso: $0 <nombre_vm> <tipo_so> <num_cpus> <memoria_gb> <vram_mb> <tamanio_disco_gb>"
  exit 1
fi

# Variables
VM_NAME=$1
OS_TYPE=$2
CORES_2_USE=$3
MEMORIA_GB=$4
VRAM_MB=$5
DISK_SIZE=$6
SATA_CONTROLLER="SATAController"
IDE_CONTROLLER="IDEController"

echo _1: Crear VM
VBoxManage createvm --name "$VM_NAME" --ostype "$OS_TYPE" --register

echo _2: Configurar VM
VBoxManage modifyvm "$VM_NAME" --cpus "$CORES_2_USE"
VBoxManage modifyvm "$VM_NAME" --memory "$MEMORIA_GB"GB
VBoxManage modifyvm "$VM_NAME" --vram "$VRAM_MB"MB

echo _3: Crear disco duro virtual
VBoxManage createmedium disk --filename "$VM_NAME/$VM_NAME.vdi" --size "$DISK_SIZE"GB --format VDI

echo _4: Crear y asociar controlador SATA
VBoxManage storagectl "$VM_NAME" --name "$SATA_CONTROLLER" --add sata
VBoxManage storageattach "$VM_NAME" --storagectl "$SATA_CONTROLLER" --port 0 --device 0 --type hdd --medium "$VM_NAME/$VM_NAME.vdi"

echo _5: Crear y asociar controlador IDE
VBoxManage storagectl "$VM_NAME" --name "$IDE_CONTROLLER" --add ide
VBoxManage storageattach "$VM_NAME" --storagectl "$IDE_CONTROLLER" --port 0 --device 0 --type dvddrive --medium emptydrive

echo _6: Imprimir configuración
echo "Configuración de la Máquina Virtual:"
VBoxManage showvminfo "$VM_NAME"

echo "Configuración del Disco Duro Virtual:"
VBoxManage showmediuminfo disk "$VM_NAME/$VM_NAME.vdi"

echo "Configuración del Controlador SATA:"
VBoxManage storagectl "$VM_NAME" --name "$SATA_CONTROLLER" --portcount 1 --remove

echo "Configuración del Controlador IDE:"
VBoxManage storagectl "$VM_NAME" --name "$IDE_CONTROLLER" --portcount 1 --remove
