#!/bin/bash

echo "STARTING BEDROCKSERVER"

mkfifo ${SERVER_DIR}/mc-input
MC_INPUT_PID=$!

########### SIG handler ############
function _int() {
   echo "Stopping container."
   echo "SIGINT received, shutting down server!"
   echo -e "stop\n" > ${SERVER_DIR}/mc-input
   while grep ^bedrock_server /proc/*/cmdline > /dev/null 2>&1
   do
     sleep 1
   done
   exit 0
}

# Set SIGINT handler
trap _int SIGINT

# Set SIGTERM handler
trap _int SIGTERM

# cd to bin folder and exec to bedrock_server
LD_LIBRARY_PATH=. tail -f ${SERVER_DIR}/mc-input | bedrock_server &

childPID=$!
while read -r line
do
  echo "$line" > ${SERVER_DIR}/mc-input
done < /dev/stdin &
wait $childPID