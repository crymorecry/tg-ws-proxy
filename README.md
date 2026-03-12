# TG WS Proxy

Локальный SOCKS5-прокси для Telegram Desktop, который перенаправляет трафик через WebSocket-соединения к указанным серверам, помогая частично ускорить работу Telegram.  
  
**Ожидаемый результат аналогичен прокидыванию hosts для Web Telegram**: ускорение загрузки и скачивания файлов, загрузки сообщений и части медиа.

<img width="529" height="487" alt="image" src="https://github.com/user-attachments/assets/6a4cf683-0df8-43af-86c1-0e8f08682b62" />

## Как это работает

```
Telegram Desktop → SOCKS5 (127.0.0.1:1080) → TG WS Proxy → WSS (kws*.web.telegram.org) → Telegram DC
```

1. Приложение поднимает локальный SOCKS5-прокси на `127.0.0.1:1080`
2. Перехватывает подключения к IP-адресам Telegram
3. Извлекает DC ID из MTProto obfuscation init-пакета
4. Устанавливает WebSocket (TLS) соединение к соответствующему DC через домены `kws{N}.web.telegram.org`
5. Если WS недоступен (302 redirect) — автоматически переключается на прямое TCP-соединение

## 🚀 Быстрый старт

### Windows
Перейдите на [страницу релизов](https://github.com/Flowseal/tg-ws-proxy/releases) и скачайте **`TgWsProxy.exe`**. Он собирается автоматически через [Github Actions](https://github.com/Flowseal/tg-ws-proxy/actions) из открытого исходного кода.

При первом запуске откроется окно с инструкцией по подключению Telegram Desktop. Приложение сворачивается в системный трей.

**Меню трея:**
- **Открыть в Telegram** — автоматически настроить прокси через `tg://socks` ссылку
- **Перезапустить прокси** — перезапуск без выхода из приложения
- **Настройки...** — GUI-редактор конфигурации
- **Открыть логи** — открыть файл логов
- **Выход** — остановить прокси и закрыть приложение

## Установка из исходников

```bash
pip install -r requirements.txt
```

## Docker / Coolify

В репозитории есть готовые `Dockerfile` и `docker-compose.yml`.

### Локальный запуск через Docker Compose

```bash
cp .env.example .env
docker compose up -d --build
```

Прокси будет доступен на `127.0.0.1:${PORT}` (по умолчанию `1080`).

### Запуск в Coolify

1. Создайте сервис из этого репозитория (Docker Compose).
2. Убедитесь, что проброшен порт `1080` (или ваш `PORT`).
3. При необходимости задайте переменные окружения:
   - `PORT` (по умолчанию `1080`)
   - `DC_IP_1` (по умолчанию `2:149.154.167.220`)
   - `DC_IP_2` (по умолчанию `4:149.154.167.220`)
   - `VERBOSE` (любое непустое значение включает DEBUG-логи)
4. Деплойте — контейнер стартует автоматически командой:
   `python proxy/tg_ws_proxy.py --host 0.0.0.0 ...`

### Windows (Tray-приложение)

```bash
python windows.py
```

### Консольный режим

```bash
python proxy/tg_ws_proxy.py [--port PORT] [--dc-ip DC:IP ...] [-v]
```

**Аргументы:**

| Аргумент | По умолчанию | Описание |
|---|---|---|
| `--port` | `1080` | Порт SOCKS5-прокси |
| `--dc-ip` | `2:149.154.167.220`, `4:149.154.167.220` | Целевой IP для DC (можно указать несколько раз) |
| `-v`, `--verbose` | выкл. | Подробное логирование (DEBUG) |

**Примеры:**

```bash
# Стандартный запуск
python proxy/tg_ws_proxy.py

# Другой порт и дополнительные DC
python proxy/tg_ws_proxy.py --port 9050 --dc-ip 1:149.154.175.205 --dc-ip 2:149.154.167.220

# С подробным логированием
python proxy/tg_ws_proxy.py -v
```

## Настройка Telegram Desktop

### Автоматически

ПКМ по иконке в трее → **«Открыть в Telegram»**

### Вручную

1. Telegram → **Настройки** → **Продвинутые настройки** → **Тип подключения** → **Прокси**
2. Добавить прокси:
   - **Тип:** SOCKS5
   - **Сервер:** `127.0.0.1`
   - **Порт:** `1080`
   - **Логин/Пароль:** оставить пустыми

## Конфигурация

Tray-приложение хранит данные в `%APPDATA%/TgWsProxy`:

```json
{
  "port": 1080,
  "dc_ip": [
    "2:149.154.167.220",
    "4:149.154.167.220"
  ],
  "verbose": false
}
```

## Автоматическая сборка

Проект содержит спецификацию PyInstaller ([`windows.spec`](packaging/windows.spec)) и GitHub Actions workflow ([`.github/workflows/build.yml`](.github/workflows/build.yml)) для автоматической сборки.

```bash
pip install pyinstaller
pyinstaller packaging/windows.spec
```

## Лицензия

[MIT License](LICENSE)
