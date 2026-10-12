# AceMagic S1 Home Server Dashboard

[English version](README.md)

Тема «домашний сервер» для переднего LCD-экрана AceMagic S1, сделанная для
[s1panel](https://github.com/tjaworski/AceMagic-S1-LED-TFT-Linux).
Одна тема с двумя раскладками — горизонтальной (320×170) и вертикальной (170×320, показатели в колонку).
Ориентация переключается в веб-интерфейсе (`http://<хост>:8686` → Orientation), раскладка подставляется автоматически.

Сделано для домашнего сервера `firebat` (Proxmox VE 9).

## Скриншоты

| Горизонтальная | Вертикальная |
|---|---|
| ![Горизонтальная](screenshots/landscape.png) | ![Вертикальная](screenshots/portrait.png) |

Показывает: время и дату, загрузку CPU, температуру CPU, занятость RAM, заполнение корневого диска и IP-адрес `vmbr0`.

## Содержимое

| Файл | Что это |
|---|---|
| `install.sh` | Установка на другое устройство (делает резервные копии `*.bak-<дата>`) |
| `themes/homeserver/landscape_dashboard.json` | Сама тема: `widgets` — активная раскладка, `widgets_landscape` / `widgets_portrait` — вторая |
| `icons/mdi/*.svg` | Иконки локально (без обращения к api.iconify.design) |
| `patches/s1panel-dual-layout-local-icons.patch` | Изменения кода s1panel (`api.js`, `widgets/iconify.js`) |
| `patched/` | Уже изменённые `api.js` и `widgets/iconify.js` (запасной вариант, если патч не накладывается) |
| `config.example.json` | Полный `config.json` с исходного сервера — для справки |
| `portrait_dashboard.gen.py` | Скрипт, которым сгенерирована вертикальная раскладка (координаты, шрифты, цвета) |
| `screenshots/` | Скриншоты для README |

## Установка

На целевом устройстве должен быть установлен s1panel (по умолчанию `/opt/acemagic/s1panel`).

```sh
git clone https://github.com/<user>/acemagic-s1-homeserver-theme.git /tmp/s1theme
sh /tmp/s1theme/install.sh
# другой путь установки: sh install.sh /path/to/s1panel
```

Скрипт:
1. делает резервные копии `api.js`, `widgets/iconify.js`, `config.json` и темы;
2. накладывает патч (если не накладывается — копирует файлы из `patched/`);
3. копирует тему и иконки;
4. делает тему активной в `config.json` и добавляет датчики `network` (vmbr0) и `space` (root), если их нет;
5. перезапускает `s1panel`.

Повторный запуск безопасен.

## Что изменено в коде s1panel

- **`api.js` → `set_orientation`**: при смене ориентации текущие виджеты сохраняются в `widgets_<старая>`,
  а из `widgets_<новая>` подставляются в `widgets`. Если второй раскладки нет — поведение как в оригинале.
- **`widgets/iconify.js`**: иконка сначала ищется в `icons/<набор>/<имя>.svg`; если её нет — скачивается
  с api.iconify.design и сохраняется туда же.

## Замечания

- После смены ориентации в веб-интерфейсе обновите страницу (F5) перед редактированием виджетов —
  редактор не перечитывает список виджетов сам.
- Сетевой интерфейс в теме — `vmbr0`. На устройстве с другим именем поменяйте `network_vmbr0`
  в теме и `interface` в `config.json`.
- Обновление s1panel из репозитория перезапишет `api.js` и `iconify.js` — после обновления запустите `install.sh` снова.

## Лицензия

GPL-3.0, как и у [s1panel](https://github.com/tjaworski/AceMagic-S1-LED-TFT-Linux),
на основе которого сделаны изменённые файлы `api.js` и `widgets/iconify.js` (© Tomasz Jaworski).
Иконки — [Material Design Icons](https://pictogrammers.com/library/mdi/) (Apache-2.0).
