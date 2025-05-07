#!/bin/sh

# look for a file name foundryvtt-.....zip or FoundryVTT...zip, copy it to 
# /opt/foundryvtt, unzip and remove it. Then start the foundry app

cd /opt/foundryvtt || exit
echo "Copying zip file..."
find /host -type f -name '[f,F]oundry[vtt,VTT]*.zip' -exec cp '{}' . ';'

echo "Unzipping..."
unzip -o ./*.zip -d unpacked && rm ./*.zip

echo "Moving to mapped directory"
mv unpacked/* resources/app/

echo "Starting node"
cd resources/app
node main.mjs --dataPath=/data/foundryvtt