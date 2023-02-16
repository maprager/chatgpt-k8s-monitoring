#!/bin/bash 

url="127.0.0.1:5000"
args="$*"
encoded_string=$(printf "%s" "$args" | sed -e 's/%/%25/g' -e 's/ /%20/g' -e 's/!/%21/g' -e 's/"/%22/g' -e 's/#/%23/g' -e 's/\&/%26/g' -e "s/'/%27/g" -e 's/(/%28/g' -e 's/)/%29/g' -e 's/\*/%2a/g')
curl -s "{$url}/${encoded_string}"
