#!/bin/bash

#install extensions via terminal

# fill the array with the needed extensions 
# key=["extension_name"] value="extension_ID"

declare -A EXTlist=(
    ["selenium-ide"]="mooikfkahbdckldjjndioackbalphokd"
)
mkdir -p /opt/google/chrome/extensions
for i in "${!EXTlist[@]}"; do
    echo '{"external_update_url": "https://clients2.google.com/service/update2/crx"}' > /opt/google/chrome/extensions/${EXTlist[$i]}.json
    echo "Installed $i"
done
