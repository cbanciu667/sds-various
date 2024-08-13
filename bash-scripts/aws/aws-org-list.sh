#!/bin/bash

function list_ou_and_accounts() {
    local PARENT_ID=$1
    local INDENT=$2

    # List Organizational Units (OUs)
    aws organizations list-organizational-units-for-parent --parent-id $PARENT_ID --query 'OrganizationalUnits[*].[Id, Name]' --output text | while read OU_ID OU_NAME; do
        echo "${INDENT}OU: ${OU_NAME} (${OU_ID})"
        list_ou_and_accounts $OU_ID "$INDENT  "
    done

    # List Accounts in the current OU
    aws organizations list-accounts-for-parent --parent-id $PARENT_ID --query 'Accounts[*].[Id, Name]' --output text | while read ACCOUNT_ID ACCOUNT_NAME; do
        echo "${INDENT}Account: ${ACCOUNT_NAME} (${ACCOUNT_ID})"
    done
}

# Start from the root organization unit
ROOT_ID=$(aws organizations list-roots --query 'Roots[0].Id' --output text)
echo "Root: (${ROOT_ID})"
list_ou_and_accounts $ROOT_ID "  "
