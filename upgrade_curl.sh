#!/bin/bash

download_src() {
  echo "Загрузка исходников"
  rm -rf ./src/*
  cd ./src
  wget $1
  local TAR_NAME=$(ls)
  tar -xzf $TAR_NAME --strip 1 && rm $TAR_NAME
  cd ../
}

remove_image () {
  # Удаляем образ Docker, если он существует
  if [[ "$(docker images -q $1 2> /dev/null)" == "" ]]; then
    echo "Образ $1 не найден"
  else
    echo "Удаляем образ $1..."
    docker rmi $1
  fi
}

update_path () {
  # Проверяем, содержит ли $PATH директорию $CURL_DIR
  if grep -q "export PATH=\$HOME/bin/curl:\$PATH" ~/.bashrc; then
    echo "Директория $1 уже содержится в PATH"
  else
    echo 'export PATH=$HOME/bin/curl:$PATH' >> ~/.bashrc
    echo "Директория $1 добавлена к PATH"
    echo "Требуется релогин"
  fi
}

main () {
  local CURL_DIR="$HOME/bin/curl"
  local CURRENT_VERSION="$1"
  local LATEST_VERSION="$2"
  local TAR_URL="$3"
  local EXISTING_IMAGE="curl:$CURRENT_VERSION"

  # download_src $TAR_URL
  remove_image $EXISTING_IMAGE

  echo "Собираем образ curl:$LATEST_VERSION..."
  docker build --build-arg TAR_URL=$TAR_URL . -t curl:$LATEST_VERSION

  echo "Запускаем контейнер curl:$LATEST_VERSION..."
  TEMP_CONTAINER_ID=$(docker create curl:$LATEST_VERSION)

  echo "Копируем curl из контейнера"
  rm -rf ~/bin/curl
  docker cp $TEMP_CONTAINER_ID:/usr/bin/app/curl/src/ ~/bin/curl

  echo "Удаляем контейнер"
  docker rm $TEMP_CONTAINER_ID

  echo "Удаляем созданный образ"
  remove_image curl:$LATEST_VERSION

  update_path $CURL_DIR
}

# Проверяем, было ли передано три аргумента
if [ "$#" -ne 3 ]; then
  echo "Ошибка: Необходимо передать 3 аргумента - текущую, новую версию curl и url src"
  exit 1
fi

main $1 $2 $3 
