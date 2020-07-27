#!/bin/sh

cd /opt/foundryvtt
cp /host/foundryvtt*.zip .
unzip -o foundryvtt*.zip
rm foundryvtt*.zip
node resources/app/main.js --dataPath=/data/foundryvtt
