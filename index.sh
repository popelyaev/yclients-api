#!/bin/bash

# Нужен для прерывания всего цикла с помощью ctrl + c
trap "exit 1" INT

# Подключение api функций
source ./scripts/api_request.sh

# ---
# Получаем все услуги
all_services=$(api_get_services)

# Получаем все категории услуг
all_service_catigories=$(api_get_service_categories)

# Делаем запос api на получение клиентов и записываем ответ в переменную 
clients=$(api_post_clients)

# Инициация массива, в котором будут храниться все полученные объекты по api
array_object_clients='[]'
# ---

# Получаем id всех наших клиентов
client_id=$(echo $clients | jq '[.[].id]')

# Получаем ФИО клиентов
client_name=$(echo $clients | jq '[.[] | .name + " " + .patronymic + " " + .surname]')


# Количество id
# total=$(echo $clients | jq '. | length')
total=3

for ((i = 0; i < $total; i++)); do

	arg=$(jq -r ".[$i]" <<<"$client_id")
	name=$(jq -r ".[$i]" <<<"$client_name")

	# Пимер загрузки
    printf "\r%d / $total" "$(($i + 1))" 

    each_object=$(api_post_history_client "$arg" | jq --arg id "$arg" --arg name "$name" '{client_id: $id, client_name: $name} + .')
    array_object_clients=$(jq --argjson obj "$each_object" '. + [$obj]' <<<"$array_object_clients")

done

# del
echo $array_object_clients | jq > data/all_object_clients.json

# Фильтрация полученных объектов и создание на их основе нового JSON
filter_object_clients=$(echo $array_object_clients | jq -f ./filter.jq)

add_category_id=$(jq -s '.[0] as $x | .[1].data as $y | select($x[].service_id == $y[].id) | .' <(echo "$filter_object_clients") <(echo "$all_services"))

echo $add_category_id | jq -s 'length'

# del Запись фильтрованоого JSON в файл
echo $filter_object_clients | jq > data/clients_history.json

