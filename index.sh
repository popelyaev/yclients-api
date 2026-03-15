#!/bin/bash

# Пути до директорий
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Если где то будет ошибка, то скрипт сразу же завершится
set -e

# Подключаем переменные окружения
set -a
source .env
set +a

# Проверяет существует ли директория data для json, и если не существует, то создаст ее для записи файлов json
mkdir -p data

# Response в директорию data для дальнейшей обработки данных взятых из этих json
$SOURCE_DIR/scripts/get_service_categories.sh
$SOURCE_DIR/scripts/get_services.sh
$SOURCE_DIR/scripts/post_clients.sh
$SOURCE_DIR/scripts/post_history_clients.sh
