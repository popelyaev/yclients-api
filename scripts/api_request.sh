#!/bin/bash

# Подключаем переменные окружения
set -a
source .env
set +a

# Получение списка клиентов
api_post_clients() {

	for ((i = 1; i <= 2; i++)); do

		response=$(

			curl -s -X POST "https://api.yclients.com/api/v1/company/$COMPANY_ID/clients/search" \
				-H "Accept: application/vnd.yclients.v2+json" \
				-H "Content-Type: application/json" \
				-H "Authorization: Bearer $YCLIENTS_PARTNER_TOKEN, $YCLIENTS_USER_TOKEN" \
				-d "{
                    \"page\": $i,
                    \"page_size\": 200,
                    \"fields\": [
                                   \"id\",
                                   \"name\",
                                   \"patronymic\",
                                   \"surname\",
                                   \"phone\",
                                   \"email\",
                                   \"discount\",
                                   \"first_visit_date\",
                                   \"last_visit_date\",
                                   \"sold_amount\",
                                   \"visits_count\"
                                ],
                    \"order_by\": \"last_visit_date\",
                    \"order_by_direction\": \"desc\",
                    \"operation\": \"AND\",
                    \"filters\": []
                }"

		)

		if [[ $i -eq 1 ]]; then
			count=$(jq '.meta.total_count' <<<$response)
			api_result=$(jq '[.data[]]' <<<$response)
		else
			api_result_new=$(jq '[.data[]]' <<<$response)
			api_result=$(jq -s '.[0] + .[1]' <(echo $api_result) <(echo $api_result_new))
		fi
	done

	echo $api_result | jq

}

# Получение всех посещений клиентом
api_post_history_client() {

	curl -s -X POST "https://api.yclients.com/api/v1/company/$COMPANY_ID/clients/visits/search" \
		-H "Accept: application/vnd.yclients.v2+json" \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $YCLIENTS_PARTNER_TOKEN, $YCLIENTS_USER_TOKEN" \
		-d "{
          \"client_id\": $1,
          \"client_phone\": null,
          \"from\": \"2020-01-01\",
          \"to\": \"2026-12-31\",
          \"payment_statuses\": [],
          \"attendance\": null 
        }"

}

# Получение всех услуг
api_get_services() {

	# Можно в конце запроса (после /services/) указать id услуши что бы получить конкретную услугу
	curl -s -X GET "https://api.yclients.com/api/v1/company/$COMPANY_ID/services/" \
		-H "Accept: application/vnd.yclients.v2+json" \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $YCLIENTS_PARTNER_TOKEN, $YCLIENTS_USER_TOKEN"

}

# Получение всех категорий услуг
api_get_service_categories() {

	# Можно в конце запроса (после /service_categories/) указать id услуши что бы получить конкретную категорию
	curl -s -X GET "https://api.yclients.com/api/v1/company/$COMPANY_ID/service_categories/" \
		-H "Accept: application/vnd.yclients.v2+json" \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $YCLIENTS_PARTNER_TOKEN, $YCLIENTS_USER_TOKEN"

}
