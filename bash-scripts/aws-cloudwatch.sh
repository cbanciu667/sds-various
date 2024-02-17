#!/bin/bash

# Cognito logs search in group aws-controltower/CloudTrailLogs:
fields @timestamp, eventName, eventSource, awsRegion, requestParameters, responseElements, additionalEventData, userIdentity, requestID
| filter eventSource like /cognito-idp.amazonaws.com/
| filter additionalEventData.requestParameters.client_id.0 = '489bf5be-9567-461a-9afd-0167a594ed24'
| filter userIdentity.principalId like /EMAIL_ADDRESS/
| filter sourceIPAddress = 'INTERNET_IP'
| filter @message like '1bb80850-0fd6-4469-b16d-d75e034cef47'
| filter eventName like 'Error_GET'