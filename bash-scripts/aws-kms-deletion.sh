#!/bin/bash

aws kms schedule-key-deletion --key-id $1 --pending-window-in-days 0