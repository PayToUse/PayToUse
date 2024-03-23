#!/bin/bash
# Credits to @fearocanity in GitHub

date="$(( $(date +%s) + 18000 ))"

while [[ "${date}" -gt "$(date +%s)" ]]; do
    curl -sLf -H "Authorization: Bearer ${1}" \
      -H "Accept: application/vnd.github.v3+json" \
      -X POST \
      -d '{"ref":"'"${3}"'","inputs":{}}' "https://api.github.com/repos/fearocanity/fearocanity/actions/workflows/${2}/dispatches" \
      -o /dev/null && { : "$((i+=1))" ; printf '%s\n' "Completed Runs: ${i:=0}" ;}
    sleep 210
done
