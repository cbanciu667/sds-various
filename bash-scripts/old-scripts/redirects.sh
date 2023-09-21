#!/bin/bash

echo
for domain in $@; do
echo --------------------
echo $domain
echo --------------------
curl -sILk $domain | egrep 'HTTPS|Loc' | sed 's/Loc/ -> Loc/g'
echo
done
