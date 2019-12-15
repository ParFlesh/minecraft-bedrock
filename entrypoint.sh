#!/bin/bash
set -e

# if worlds folder does not exist, create it
if [ ! -d "${DATA_DIR}/worlds" ]
then
 mkdir -p "${DATA_DIR}/worlds"
fi

if [ ! "$(ls -A ${SERVER_DIR}/worlds)" ]
then
  ln -s ${DATA_DIR}/worlds ${SERVER_DIR}/worlds
fi

# If server.properties file doesnt exist generate it
if [ ! -f "${SERVER_DIR}/server.properties" ]
then
  echo "Generating server configuration:"
  touch ${SERVER_DIR}/server.properties
  # Parse all environment variables beginning with MCPROP to generate server.properties
  # For each matching line
  #  - Get property name from beggining to first = sign
  #    - Remove MCPROP_ from beginning
  #    - Switch to lowercase
  #    - Convert _ to -
  #  - Get property value from everything after first = sign
  # Examples
  #  - MCPROP_ALLOW_CHEATS=true
  #    allow-cheats=true
  for P in `printenv | grep '^MCPROP_'`
  do
    PROP_NAME=${P%%=*}
    PROP_VALUE=${P##${PROP_NAME}=}
    PROP_NAME=${PROP_NAME#*_}
    PROP_NAME=`echo ${PROP_NAME} | tr '[:upper:]' '[:lower:]'`
    PROP_NAME=`echo ${PROP_NAME} | tr "_" "-"`
    echo -e "\t${PROP_NAME}=${PROP_VALUE}"
    echo "${PROP_NAME}=${PROP_VALUE}" >> ${SERVER_DIR}/server.properties
  done
fi

while read -r line
do
  PROP_NAME=${line%%=*}
  PROP_VALUE=${line##${PROP_NAME}=}
  PROP_NAME=`echo ${PROP_NAME} | tr '[:lower:]' '[:upper:]'`
  PROP_NAME=`echo ${PROP_NAME} | tr "-" "_"`
  eval "${PROP_NAME}=${PROP_VALUE}"
done < "${SERVER_DIR}/server.properties"

LEVEL_NAME=${LEVEL_NAME:-"level"}

if [ ! -d "${DATA_DIR}/worlds/${LEVEL_NAME}" ]
then
  mkdir -p ${DATA_DIR}/worlds/${LEVEL_NAME}
fi

# Link permission and whilelist
for f in permissions.json whitelist.json
do
	if [ ! -f "${SERVER_DIR}/${f}" ]
	then
	  if [ ! -f "${DATA_DIR}/worlds/${LEVEL_NAME}/${f}" ];
	  then
  		cp "${SERVER_DIR}/default/${f}" "${DATA_DIR}/worlds/${LEVEL_NAME}/${f}"
  	fi
  	ln -s "${DATA_DIR}/worlds/${LEVEL_NAME}/${f}" "${SERVER_DIR}/"
	fi
done

# Create Debug_Log
if [ ! -f "${SERVER_DIR}/Debug_Log.txt" ]
then
  touch "${SERVER_DIR}/Debug_Log.txt"
fi

# Create valid_known_packs
if [ ! -f "${SERVER_DIR}/valid_known_packs.json" ]
then
  if [ ! -f "${DATA_DIR}/worlds/${LEVEL_NAME}/valid_known_packs.json" ];
  then
    touch "${DATA_DIR}/worlds/${LEVEL_NAME}/valid_known_packs.json"
  fi
  ln -s "${DATA_DIR}/worlds/${LEVEL_NAME}/valid_known_packs.json" "${SERVER_DIR}/"
fi

# Link directories with defaults
for f in behavior_packs resource_packs
do
  # if directory doesn't exist create from minecraft default
	if [ ! -d "${SERVER_DIR}/${f}" ]
	then
	  if [ ! -d "${DATA_DIR}/${f}" ]
	  then
		  cp -a ${SERVER_DIR}/default/${f} ${DATA_DIR}/${f}
		fi
	  ln -s ${DATA_DIR}/${f} ${SERVER_DIR}/${f}
	fi
done

exec "$@"