FROM ubuntu:rolling as artifact

RUN apt update && \
    apt install -y unzip curl

ARG VERSION="1.14.1.4"
ARG ARCHIVE_FILENAME="bedrock-server-"
ARG ARCHIVE_EXTENSION=".zip"
ARG BASE_URL="https://minecraft.azureedge.net/bin-linux/"

WORKDIR "/tmp"

ENV ARCHIVE_DIR="/tmp/bedrock_server"
RUN if [ "$VERSION" = "latest" ];then VERSION=`curl -v --silent  https://www.minecraft.net/en-us/download/server/bedrock/ 2>&1 | grep 'https://minecraft.azureedge.net/bin-linux/bedrock-server-.*\.zip' | awk -F'bedrock-server-' '{print $2}' | awk -F'.zip' '{print $1}'`;fi && \
    curl -O ${BASE_URL}${ARCHIVE_FILENAME}${VERSION}${ARCHIVE_EXTENSION} && \
    unzip ${ARCHIVE_FILENAME}${VERSION}${ARCHIVE_EXTENSION} -d ${ARCHIVE_DIR} && \
    mkdir ${ARCHIVE_DIR}/default && \
    rm ${ARCHIVE_DIR}/server.properties && \
    for i in permissions.json whitelist.json behavior_packs resource_packs;do mv ${ARCHIVE_DIR}/$i ${ARCHIVE_DIR}/default/$i;done && \
    chmod -R g=u ${ARCHIVE_DIR}

FROM ubuntu:rolling

ENV SERVER_DIR="/opt/minecraft_bedrock" \
    DATA_DIR="/data" \
    PATH=$PATH:/opt/minecraft_bedrock

COPY --chown=1001:0 --from=artifact /tmp/bedrock_server ${SERVER_DIR}

RUN apt update && \
    apt install --no-install-recommends -y libcurl4  && \
    apt clean autoclean && \
    rm -Rf /var/lib/apt/lists/*

RUN mkdir ${DATA_DIR} && \
    chown 1001:0 ${DATA_DIR} && \
    chmod ug+w ${DATA_DIR} && \
    chmod ug+w ${SERVER_DIR}

ADD *.sh ${SERVER_DIR}/

USER 1001:0

VOLUME "${DATA_DIR}"

EXPOSE "19132/udp"
EXPOSE "19133/udp"
EXPOSE "60977/udp"
EXPOSE "36964/udp"

WORKDIR "${SERVER_DIR}"

ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "startup.sh" ]
