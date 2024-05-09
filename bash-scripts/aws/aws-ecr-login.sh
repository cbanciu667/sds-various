#!/bin/bash

eval $(aws ecr get-login --no-include-email --profile $1 --region ${2}| sed 's;https://;;g')