#!/bin/bash
# Exit if any of the intermediate steps fail
set -e
eval "$(jq -r '@sh "LOCATION=\(.location)"')"
DATACENTER_LOCATION="${LOCATION:-europewest}"
# https://stackoverflow.com/a/53939113
MICROSOFT_IP_RANGES_URL="https://www.microsoft.com/en-us/download/confirmation.aspx?id=41653"
IP_RANGES_URL=$(curl -Lfs "${MICROSOFT_IP_RANGES_URL}" | grep -Eoi '<a [^>]+>' | grep -Eo 'href="[^\"]+"' | grep "download.microsoft.com/download/" | grep -m 1 -Eo '(http|https)://[^"]+')
IP_RANGES=$(curl $IP_RANGES_URL -s)  
# https://stackoverflow.com/a/15471368
pip install --quiet --user lxml
echo $IP_RANGES | python -c "from lxml.etree import parse; from sys import stdin; print('{\"ips\":\"' + ','.join(parse(stdin).xpath('//AzurePublicIpAddresses/Region[@Name=\\'"$DATACENTER_LOCATION"\\']/IpRange/@Subnet')) + '\"}')" 