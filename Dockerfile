#### Builder ####
FROM docker.io/ubuntu:22.04 AS builder

# Creating working directory
RUN mkdir /work
WORKDIR /work

# Installing curl
RUN apt update && apt upgrade -y && apt install -y curl

# Downloading latest version of beammp server
RUN export LATEST_VERSION=$(curl -s https://api.github.com/repos/BeamMP/BeamMP-Server/releases/latest | grep "tag_name" | cut -d '"' -f 4) && \
    export CURRENT_ARCH=$(uname -m | sed s/aarch64/arm64/g) && \
    export CURRENT_OS="ubuntu.22.04" && \
    export DOWNLOAD_URL="https://github.com/BeamMP/BeamMP-Server/releases/download/$LATEST_VERSION/BeamMP-Server.$CURRENT_OS.$CURRENT_ARCH" && \
    echo "Downloading server from $DOWNLOAD_URL" && \
    curl -L -o BeamMP-Server $DOWNLOAD_URL && \
    chmod +x BeamMP-Server

#### Runner ####
FROM docker.io/ubuntu:22.04
LABEL maintainer="shout@narlyx.dev"

# Installing dependancies
RUN apt update &&  \
    apt upgrade -y && \
    apt install -y liblua5.3-0 tzdata && \
    apt-get clean && rm -rf /var/lib/apt/lists/

# Creating wokring directory
RUN mkdir -p /data/Resources/Server /data/Resources/Client /data/Configuration
VOLUME /data/Resources
VOLUME /data/Configuration
WORKDIR /data

# Copying previously downloaded beammp server to current working directory
COPY --from=builder /work/BeamMP-Server ./beammp-server

# Starting the server
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
ENTRYPOINT ["/data/entrypoint.sh"]
