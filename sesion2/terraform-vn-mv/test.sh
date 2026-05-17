#!/bin/bash

# Grupo de recursos para pruebas
RESOURCE_GROUP="test-policy-rg"

# Crear grupo de recursos si no existe
az group create --name $RESOURCE_GROUP --location eastus >/dev/null

# Obtener todas las regiones disponibles de Azure
REGIONS=$(az account list-locations --query "[].name" -o tsv)

echo "Probando despliegue de recursos en todas las regiones disponibles..."

for REGION in $REGIONS; do
    STORAGE_NAME="testpolicystorage$RANDOM"
    echo -n "Probando $REGION... "

    # Intentar crear un Storage Account temporal
    az storage account create \
        --name $STORAGE_NAME \
        --resource-group $RESOURCE_GROUP \
        --location $REGION \
        --sku Standard_LRS \
        --kind StorageV2 \
        --only-show-errors >/dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "✅ Permitido"
        # Borrar el recurso de prueba
        az storage account delete --name $STORAGE_NAME --resource-group $RESOURCE_GROUP --yes >/dev/null
    else
        echo "❌ Bloqueado"
    fi
done

echo "Prueba completada."


