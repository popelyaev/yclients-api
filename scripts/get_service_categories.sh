#!/bin/bash

# Можно в конце запроса (после /service_categories/) указать id услуши что бы получить конкретную категорию 
curl -X GET "https://api.yclients.com/api/v1/company/$COMPANY_ID/service_categories/" \
	-H "Accept: application/vnd.yclients.v2+json" \
	-H "Content-Type: application/json" \
	-H "Authorization: Bearer $YCLIENTS_PARTNER_TOKEN, $YCLIENTS_USER_TOKEN" | \
	jq > data/get_service_categories.json
