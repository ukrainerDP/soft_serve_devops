#!/bin/bash

# Форматування часу у хвилини та секунди
format_time() {
  local T=$1
  local M=$((T / 60))
  local S=$((T % 60))
  local result=""

  if (( M > 0 )); then
    result="${M} хвилин"
    (( M == 1 )) && result="${M} хвилина"
  fi

  if (( S > 0 )); then
    [[ -n "$result" ]] && result+=" "
    result+="${S} секунд"
    (( S == 1 )) && result="${result/% секунд/ секунда}"
  fi

  echo "$result"
}

# --- Налаштування ---
PROJECT_DIR="/home/vagrant/example-app-nodejs-backend-react-frontend"
cd "$PROJECT_DIR" || { echo "Не вдалося перейти в каталог проєкту"; exit 1; }

# --- Тест: yarn ---
START_YARN=$(date +%s)

# Очищення попередніх залежностей
[ -d node_modules ] && rm -rf node_modules

# Очищення кешу yarn (може бути не підтримано у деяких версіях)
yarn cache clean >/dev/null 2>&1

# Встановлення залежностей та збірка
yarn install
yarn build

END_YARN=$(date +%s)
ELAPSED_YARN=$((END_YARN - START_YARN))
echo "[yarn] Готово за $(format_time $ELAPSED_YARN)"

# --- Тест: npm ---
START_NPM=$(date +%s)

# Очищення node_modules перед npm
[ -d node_modules ] && rm -rf node_modules

# Примусове очищення кешу npm
npm cache clean --force >/dev/null

# Встановлення залежностей та збірка
npm install
npm run build

END_NPM=$(date +%s)
ELAPSED_NPM=$((END_NPM - START_NPM))
echo "[npm] Готово за $(format_time $ELAPSED_NPM)"

# --- Порівняння продуктивності ---
if (( ELAPSED_YARN < ELAPSED_NPM )); then
  echo "yarn був швидшим на $(format_time $((ELAPSED_NPM - ELAPSED_YARN)))"
elif (( ELAPSED_NPM < ELAPSED_YARN )); then
  echo "npm був швидшим на $(format_time $((ELAPSED_YARN - ELAPSED_NPM)))"
else
  echo "yarn і npm виконались за однаковий час: $(format_time $ELAPSED_NPM)"
fi

# --- Запуск обох частин проєкту ---
# Запуск бекенду на порту 5000
PORT=5000 npm start &
SERVER_PID=$!

# Запуск фронтенду на порту 3000
PORT=3000 npm start &
CLIENT_PID=$!

# Обробка зупинки через Ctrl+C
trap "kill $SERVER_PID $CLIENT_PID; exit" SIGINT

# Очікування завершення обох процесів
wait $SERVER_PID $CLIENT_PID
