#!/bin/bash

# bash best practices
set -o errexit
set -o nounset
set -o pipefail

function getdescription () {
  local readme="../../ansible/roles/$1/readme.md"
  local rline=""
  local descLine=""
  local firstline="true"

  [[ ! -f $readme ]] && { echo "readme template added to role"; cp ../../docs/role.readme.template.md "$readme"; return; } || true

  while IFS= read -r rline || [[ -n "$rline" ]]; do

    # stop at first set of dashes
    grep -q '\-\-' <<< "$rline" && break 
    # skip over first set of equals
    grep -q '==' <<< "$rline" && continue
    [[ $firstline == "true" ]] && firstline="false" || descLine="$descLine<br> $rline"

  done < "$readme"
  echo -e "$descLine"

}

function build_playbook_links () {
  local string=$1

  echo "$string"

}

baseRoleURL="https://github.com/IBM/community-automation/tree/master/ansible"

roletable="/tmp/roletable.html"
rolenamesfile="/tmp/rolenamefile"
ls ../../ansible/roles | xargs -I {}  basename {} > $rolenamesfile

echo -e "<html><table border=1>" > $roletable
echo -e "<th>Role</th><th>Example Plays</th><th>Description</th>" >> $roletable
while IFS= read -r line || [[ -n "$line" ]]; do
  # add role name
  echo -e  "<tr><td><a href=$baseRoleURL/roles/$line>$line</a></td>" >> $roletable

  # add playbooks
  echo -e "<td>" >> $roletable

  # capture playbook details
  grep -E -rl "$line" ../../ansible | grep -vi -E "jenkins|roles|readme|inventory|example" | awk '{printf " "$1 "<br>"}' >> $roletable || true
  echo -e "</td><td>" >> $roletable

  # add description
  getdescription "$line" >> $roletable || true

  echo -e "</td></tr>" >> $roletable

done < $rolenamesfile

echo -e "</table></html>" >> $roletable
