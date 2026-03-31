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


# Фильтрация полученных объектов и создание на их основе нового JSON
filter_object_clients=$(echo $array_object_clients | jq -f ./filter.jq)

# Добавляем id категории услуги для дальнейшего получения названия категории услуги, а также добавляем продолжительность услуги
add_category_id=$(jq -s '
  .[0] as $clients |
  .[1].data as $services |

  $clients
  | map(
      . as $item
      | ($services | map(select(.id == $item.service_id))[0]) as $match
      | if $match then
          $item + {
            category_id: $match.category_id,
            duration: ($match.duration / 60)
          }
        else
          $item
        end
    )
' <(echo "$filter_object_clients") <(echo "$all_services"))

# Добавляем название категорий услуги
add_category_title=$(jq -s '
  .[0] as $clients |
  .[1].data as $category_title |

  $clients
  | map(
      . as $item
      | ($category_title | map(select(.id == $item.category_id))[0]) as $match
      | if $match then
          $item + {category_title: $match.title}
        else
          $item
        end
    )
' <(echo "$add_category_id") <(echo "$all_service_catigories"))

# Создаем csv файл для импорта в google sheets или excel
echo $add_category_title | jq -r '
([
    "ФИО","attendance","Дата","Месяц","Год","Время", "Категория услуги",
    "Услуга","Цена","Себестоимость","Продолжительность (мин)",
    "staff_id","staff_name",
    "category_id","service_id"
  ] | @csv),

  (.[] | [
    .name,
    .attendance,
    .date,
    .mounth,
    .year,
    .time,
    .category_title,
    .title,
    .price,
    .cost_price,
    .duration,
    .staff.id,
    .staff.name,
    .category_id,
    .service_id
  ] | @csv)
' > data.csv


