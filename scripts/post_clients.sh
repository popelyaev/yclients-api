#!/bin/bash

for ((i = 1; i <= 2; i++)); do
	curl -X POST "https://api.yclients.com/api/v1/company/$COMPANY_ID/clients/search" \
		-H "Accept: application/vnd.yclients.v2+json" \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $YCLIENTS_PARTNER_TOKEN, $YCLIENTS_USER_TOKEN" \
		-d "{
          \"page\": $i,
          \"page_size\": 200,
          \"fields\": [
                         \"name\",
                         \"patronymic\",
                         \"surname\",
                         \"phone\",
                         \"last_visit_date\"
                      ],
          \"order_by\": \"last_visit_date\",
          \"order_by_direction\": \"desc\",
          \"operation\": \"AND\",
          \"filters\": []
    }" |
        # TODO: изменить логику добавления объектов из последующих листов в первый
		if [[ $i -eq 1 ]]; then
			jq > data/post_clients.json
		else
			jq -s '.[0].data += .[1].data | .[0]' data/post_clients.json - > tmp.json
			cat tmp.json > data/post_clients.json
			rm tmp.json
		fi

done
