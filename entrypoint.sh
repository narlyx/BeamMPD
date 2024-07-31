#!/bin/sh
chmod 777 -R /beammp/ 2> /dev/null
/data/beammp-server --config=./Configuration/ServerConfig.toml
