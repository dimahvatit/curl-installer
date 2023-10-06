#!/bin/bash

# Проверяем, было ли передано два аргумента
if [ "$#" -ne 2 ]; then
  echo "Ошибка: Необходимо передать два аргумента - текущую и новую версию curl"
  exit 1
fi

CURL_DIR="$HOME/bin/curl"
CURRENT_VERSION="$1"
LATEST_VERSION="$2"
EXISTING_IMAGE="curl:$CURRENT_VERSION"

# Проверяем, содержит ли $PATH директорию $CURL_DIR
if [[ ":$PATH:" == *":$CURL_DIR:"* ]]; then
  echo "Директория $CURL_DIR уже содержится в PATH"
else
  # Если директория отсутствует, добавляем ее к $PATH
  echo 'export PATH="$HOME/bin/curl:$PATH"' >> ~/.bashrc
  echo "Директория $CURL_DIR добавлена к PATH"
fi

# Удаляем старый образ Docker, если он существует
if [[ "$(docker images -q $EXISTING_IMAGE 2> /dev/null)" == "" ]]; then
  echo "Старый образ $EXISTING_IMAGE не найден"
else
  echo "Удаляем старый образ $EXISTING_IMAGE..."
  docker rmi $EXISTING_IMAGE
fi

echo "Собираем образ curl:$LATEST_VERSION..."
docker build . -t curl:$LATEST_VERSION

echo "Запускаем контейнер curl:$LATEST_VERSION..."
TEMP_CONTAINER_ID=$(docker create curl:$LATEST_VERSION)

echo "Копируем curl из контейнера"
rm -rf ~/bin/curl
docker cp $TEMP_CONTAINER_ID:/var/lib/app/curl/src/ ~/bin/curl

echo "Удаляем контейнер"
docker rm $TEMP_CONTAINER_ID
