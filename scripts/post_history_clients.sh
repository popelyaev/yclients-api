#!/bin/bash

curl -X POST "https://api.yclients.com/api/v1/company/$COMPANY_ID/clients/visits/search" \
	-H "Accept: application/vnd.yclients.v2+json" \
	-H "Content-Type: application/json" \
	-H "Authorization: Bearer $YCLIENTS_PARTNER_TOKEN, $YCLIENTS_USER_TOKEN" \
	-d "{
          \"client_id\": 227043375,
          \"client_phone\": null,
          \"from\": \"2020-01-01\",
          \"to\": \"2026-12-31\",
          \"payment_statuses\": [],
          \"attendance\": null 
        }" |
	jq > data/post_history_clients.json
