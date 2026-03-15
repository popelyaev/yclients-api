#!/bin/bash

curl -X GET "https://api.yclients.com/api/v1/reports/z_report/$COMPANY_ID?start_date=2026-03-13" \
	-H "Accept: application/vnd.yclients.v2+json" \
	-H "Content-Type: application/json" \
	-H "Authorization: Bearer $YCLIENTS_PARTNER_TOKEN, $YCLIENTS_USER_TOKEN" | \
	jq > data/get_z_report.json


