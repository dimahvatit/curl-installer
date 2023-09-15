#!/bin/bash

# Проверяем, было ли передано два аргумента
if [ "$#" -ne 2 ]; then
  echo "Ошибка: Необходимо передать два аргумента - текущую и новую версию curl"
  exit 1
fi

CURL_DIR="/home/dimahvatit/curl/src"
CURRENT_VERSION="$1"
LATEST_VERSION="$2"

# Проверяем, содержит ли $PATH директорию CURL_DIR
if [[ ":$PATH:" == *":$CURL_DIR:"* ]]; then
  echo "Директория $CURL_DIR уже содержится в PATH"
else
  # Если директория отсутствует, добавляем ее к $PATH
  echo 'export PATH="$CURL_DIR:$PATH"' >> /home/$USER/.bashrc
  echo "Директория $CURL_DIR добавлена к PATH"
fi

# Удаляем старый образ Docker, если он существует
EXISTING_IMAGE="curl:$CURRENT_VERSION"
if [[ "$(docker images -q $EXISTING_IMAGE 2> /dev/null)" == "" ]]; then
  echo "Старый образ $EXISTING_IMAGE не найден"
else
  echo "Удаляем старый образ $EXISTING_IMAGE..."
  docker rmi $EXISTING_IMAGE
fi

# Сборка образа Docker
echo "Собираем образ curl:$LATEST_VERSION..."
docker build . -t curl:$LATEST_VERSION

# Запуск временного контейнера
echo "Запускаем контейнер curl:$LATEST_VERSION..."
TEMP_CONTAINER_ID=$(docker create curl:$LATEST_VERSION)

# Копирование curl из контейнера
echo "Копируем curl из контейнера"
rm -rf /home/dimahvatit/curl
docker cp $TEMP_CONTAINER_ID:/home/dimahvatit/curl /home/dimahvatit/curl

# Удаление временного контейнера
echo "Удаляем контейнер"
docker rm $TEMP_CONTAINER_ID
