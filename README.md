# Minecraft Bedrock Server
[![Docker Repository on Quay](https://quay.io/repository/parflesh/minecraft-bedrock/status "Docker Repository on Quay")](https://quay.io/repository/parflesh/minecraft-bedrock)

## Quickstart

Docker
```shell script
docker run -Pd quay.io/parflesh/minecraft-bedrock
```

Podman
```shell script
podman run -Pd quay.io/parflesh/minecraft-bedrock
```

Kubernetes
```shell script
kubectl create deployment minecraft-bedrock --image quay.io/parflesh/minecraft-bedrock
kubectl expose deployment minecraft-bedrock --type=NodePort --port 19132 --protocol UDP 
```

Openshift
```shell script
oc new-app quay.io/parflesh/minecraft-bedrock --name minecraft-bedrock
oc expose dc/minecraft-bedrock --type=NodePort --port 19132 --protocol=UDP
```

## Environment Variables

DATA_DIR (optional; Default: /data): Location to store configuration files and worlds data    
    
MCPROP_* (optional): Parsed to generate server.properties   
Note: Available options can be retrieved from minecract bedrock server how to file in [Bedrock Server Download](https://www.minecraft.net/en-us/download/server/bedrock/) 
* Logic:
  - Strip MCPROP_
  - change to lowercase
  - convert _ to -
* Examples:
  - MCPROP_LEVEL_NAME=myworld  
    level-name=myworld
  - MCPROP_DIFFICULTY=3  
    difficulty=3

## Persisting Data

Mount $DATA_DIR to volume

## Overrides config files
Note: mount any/all of the following files into /opt/minecraft_bedrock

* server.properties
* whitelist.json
* permissions.json

## Adding resource and behavior packs
Note: mount any/all as directory into /opt/minecraft_bedrock or store in DATA_DIR

* behavior_packs
* resource_packs