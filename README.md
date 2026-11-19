<div align="center">

![платформа](https://img.shields.io/badge/платформа-macOS-black)
![агент](https://img.shields.io/badge/AI--агент-OpenCode_v2-1F6FEB)
![MCP](https://img.shields.io/badge/MCP--серверы-5-2EA043)
![скиллы](https://img.shields.io/badge/скиллы-60-E16F24)
![VS_Code](https://img.shields.io/badge/расширения_VS_Code-6-8250DF)
![CLI](https://img.shields.io/badge/CLI--инструменты-10-0969DA)

[![AGENTS.md](https://img.shields.io/badge/🤖_карта_и_конвенции-AGENTS.md-1F6FEB)](AGENTS.md)
[![STACK.md](https://img.shields.io/badge/📖_полная_дока-STACK.md-1F6FEB)](STACK.md)
[![workflow.txt](https://img.shields.io/badge/🔀_git--workflow-workflow.txt-1F6FEB)](workflow.txt)

</div>

**Персональный набор инструментов для macOS** — MCP-серверы, AI-скиллы, 10 CLI-инструментов и расширения VS Code для полноценной AI-разработки через [OpenCode](https://opencode.ai).

🤖 *ИИ-агент? Начни с [`AGENTS.md`](AGENTS.md) — карта репозитория и конвенции.*

---

## 💡 Суть

| Принцип | Что значит |
|---------|-----------|
| 🏠 **Проектность** | Стек поднимается **только в проектах, где он подключён** — глобальный конфиг OpenCode остаётся пустым |
| 1️⃣ **Один источник** | Шаблон конфига, список ARIS-скиллов, карта репозитория — правятся в одном месте, расходятся CLI-скриптами |
| 🔄 **Свежесть** | `bash update-all.sh` обновляет всё одной командой — от brew до скиллов |
| ♻️ **Переносимость** | Пути в конфигах через `{env:HOME}`; свежая машина = `git clone` + `setup.sh` |

## 🗺 Оглавление

- [📁 Структура репозитория](#-структура-репозитория)
- [🚀 Быстрый старт](#-быстрый-старт)
- [📦 Что внутри](#-что-внутри)
- [🖐 Ручные шаги](#-ручные-шаги)
- [⚡ Стек в проекте](#-стек-в-проекте)
- [👀 Файлы: пользователь vs ИИ-агент](#-файлы-пользователь-vs-ии-агент)
- [🛠 Использование](#-использование)
- [📚 Документация](#-документация)

## 📁 Структура репозитория

Все `*.sh` — **CLI-инструменты** (запуск: `bash ~/stack/<имя>.sh`):

```
~/stack/
├── README.md                    # 📘 Этот файл
├── AGENTS.md                    # 🤖 Инструкции агента (с картой репозитория)
├── STACK.md                     # 📖 Полная документация: хоткеи, примеры
├── workflow.txt                 # 🔀 Правила git-workflow
│
├── setup.sh                     # 🚀 Установка (12 шагов)
├── update-all.sh                # 🔄 Обновление всего (13 шагов)
├── check-all.sh                 # ✅ Проверка работоспособности
│
├── new-project.sh               # ➕ Подключить проект
├── sync-agents.sh               # 🔁 AGENTS.md + конфиги → все проекты
├── gen-opencode-config.sh       # ⚙️ Генератор .opencode/opencode.json
├── sync-aris.sh                 # 📚 ARIS-скиллы → skills-store
├── consolidate-skills.sh        # 🎯 Сборка skills-store + чистка глобальных
├── chrome-version.sh            # 🧩 Версия Chrome под пин tldraw
├── check-wolfram-license.sh     # 📄 Срок лицензии Wolfram
│
├── projects.txt                 # 📋 Реестр проектов
├── aris-skills.txt              # 📚 Список 14 ARIS-скиллов
├── skills/                      # 🎯 8 standalone-скиллов (источник)
├── skills-store/                # 🗃 Собранные 60 скиллов (gitignored)
├── WolframLanguage/             # 🐺 Пользовательские Wolfram-пакеты
│
└── paraview-mcp/ · manim-mcp/ · julia-mcp/ · tldraw-mcp/ ·      # 🌐 клонированные
    aris-research-repo/ · WolframLanguageForJupyter/             #    репозитории
```

## 🚀 Быстрый старт

```bash
git clone https://github.com/EgoruZz/stack.git ~/stack
cd ~/stack
bash setup.sh        # 12 шагов: brew, репозитории, venv, CLI, скиллы, конфиги
```

- Пароль спрашивается только там, где его требует система
- В конце запускается автопроверка — все компоненты должны быть ✅

## 📦 Что внутри

### 🖥 Терминальные и CLI-инструменты

| Что | Как ставится | Обновляется |
|-----|--------------|-------------|
| Python 3.12 · Node.js · gh · ffmpeg | `brew install` | `update-all.sh`, шаг 2 |
| OpenCode | вручную ([opencode.ai](https://opencode.ai)) | `update-all.sh`, шаг 2 |
| `firecrawl-cli` · `tldraw-cli` | `npm install -g` | шаг 6 |
| `manim-env` — Manim + ManimGL | pip venv | шаг 5 |
| `jupyter-env` — JupyterLab, numpy, pandas, sympy, plotly… | pip venv | шаг 5 |
| `paraview-mcp-env`, `julia-mcp-env` — MCP SDK | pip venv | шаг 5 |
| Playwright Chromium · Puppeteer Chrome *(headless, версия авто)* | `npx … install` | шаг 6 |
| Julia + 20 пакетов | `juliaup` + `Pkg.add` | шаг 9 |
| Wolfram AgentTools (paclet) | `PacletInstall` | шаг 10 |
| 6 внешних репозиториев | `git clone --depth 1` | шаг 3 |
| сборка `tldraw-mcp` | `npm install && npm run build` | шаг 4 |

> 💡 **Manim vs ManimGL:** `manim` (community) — рендерит headless, его использует MCP-сервер. `manimgl` (3Blue1Brown) — интерактивный GUI-инструмент для тебя, ни один MCP его не использует.

### 🔌 MCP-серверы (5)

| Сервер | Что делает |
|--------|-----------|
| **Wolfram** | Вычисления на Wolfram Language (через AgentTools) |
| **julia** | Persistent Julia REPL-сессии |
| **manim** | Headless-рендер анимаций в видео |
| **ParaView** | 3D-визуализация данных (через TCP-мост) |
| **tldraw** | Whiteboard-холст, 30+ инструментов |

### 🧩 Расширения VS Code (6)

| Расширение | Для файлов |
|------------|-----------|
| `tldraw-org.tldraw-vscode` | `.tldr` — холст прямо во вкладке |
| `ms-python.python` | `.py` |
| `ms-toolsai.jupyter` | `.ipynb` |
| `julialang.language-julia` | `.jl` |
| `wolframresearch.wolfram` | `.wl` |
| `james-yu.latex-workshop` | `.tex` — компиляция + PDF-превью |

### 🎯 Скиллы OpenCode (60)

Собираются в хранилище `~/stack/skills-store/` и подключаются к проектам через `skills` в конфиге — **вне проектов агент видит только встроенные скиллы самого OpenCode** (`customize-opencode` — учит агента безопасно править его конфигурацию; начиная с v2 — также `report` для репортов багов).

| Группа | ~Кол-во | Источник |
|--------|---------|----------|
| Firecrawl — веб-research, скрапинг, SEO | 37 | `firecrawl setup skills/build/workflows` |
| ARIS — research pipeline, статьи, эксперименты | 14 | клон ARIS → `sync-aris.sh` |
| `tldraw-offline` — управление открытым tldraw Desktop | 1 | ставит само приложение |
| Standalone — см. `skills/` репозитория | 8 | этот репозиторий |

<details>
<summary><b>8 standalone-скиллов поимённо</b></summary>

| Скилл | Назначение |
|-------|-----------|
| `render-visual` | Полированные PNG/SVG/PDF, слайды, схемы, GIF |
| `data-analysis` | EDA, визуализация данных, отчёты, гипотезы |
| `xlsx` | Excel/CSV/TSV: формулы, проверка, конвертация |
| `deep-mind` | Глубокое критическое мышление |
| `epistemic-rigor` | Anti-sycophancy, честная оценка гипотез |
| `grill-me` | Стресс-тест планов и решений |
| `dag-hallucination-detector` | Проверка цитат и фактов |
| `aris-research-pipeline` | Полный research pipeline (local-only) |

</details>

## 🖐 Ручные шаги

Что CLI **не** ставят — по независимым причинам (лицензии, GUI-приложения):

| Компонент | Как установить |
|-----------|---------------|
| **OpenCode** | [opencode.ai](https://opencode.ai) |
| **Wolfram Engine** | `brew install --cask wolfram-engine`, затем `wolframscript` — активация лицензии (продлевать каждые ~40 дней, проверка: `bash check-wolfram-license.sh`) |
| **ParaView** | [paraview.org/download](https://www.paraview.org/download/) |
| **MacTeX** | `brew install --cask mactex` (~4 GB) |
| **Firecrawl auth** | `firecrawl login --browser` — без него работает бесплатный tier |

## ⚡ Стек в проекте

Подключение стека к папке — одна команда:

```bash
~/stack/new-project.sh ~/work/my-project    # создать новый / зарегистрировать существующий
```

Проект получает **два файла**:

| Файл | Содержимое |
|------|-----------|
| `AGENTS.md` | Инструкции агента: карта стека, MCP-инструменты, конвенции |
| `.opencode/opencode.json` | `mcp` ×5 · `skills` → skills-store |

| Факт | Детали |
|------|--------|
| 🔌 **Переносимость** | Пути в конфиге через `{env:HOME}` — файл переносим между машинами и коммитобезопасен |
| 📋 **Реестр проектов** | `~/stack/projects.txt` — по одному пути на строку |
| 🔁 **Синхронизация** | `bash ~/stack/sync-agents.sh` перегенерирует AGENTS.md + конфиги во всех проектах (входит в `update-all.sh`, шаг 12); проект-специфичный контент AGENTS.md **вне маркеров** `<!-- STACK:START -->…<!-- STACK:END -->` сохраняется |
| ⚠️ **Конфиг — без маркеров** | `.opencode/opencode.json` перегенерируется **целиком** при каждом `sync-agents.sh` / `new-project.sh`: ручные правки конфига в проекте будут затёрты. Правь шаблон в `~/stack/gen-opencode-config.sh` — он единый источник для стека и всех проектов |
| 🧠 **Диагностика — через запуск** | OpenCode v2 не имеет LSP: агент получает ошибки кода, запуская линтеры/компиляторы/тесты напрямую (`bash -n`, `python`, `npm run build`, `pdflatex`) — честные ошибки сборки |
| 🚫 **Вне проектов** | Ни MCP, ни скиллов. В `~/.config/opencode/` нет конфига стека — только клиентские настройки (`cli.json`) |
| 🔌 **Расширения — без плагинов** | OpenCode v2 умеет подключать плагины (код, расширяющий tools/команды/TUI: поле `plugins` в конфиге или `.opencode/plugins/`). Стек их сознательно не использует: все расширения идут через MCP-серверы (внешние процессы) и скиллы (промпты) — конфиг стека не содержит поля `plugins` |

## 👀 Файлы: пользователь vs ИИ-агент

Стек даёт **двойной контроль** над файлами. Ты — через расширения VS Code (с их LSP: Pylance и др.), агент — через чтение файлов и запуск инструментов.

| Файл | 👤 Ты — в VS Code | 🤖 Агент — в OpenCode |
|------|-------------------|------------------------|
| `.tldr` | Рисуешь на холсте во вкладке | Читает JSON; создаёт через tldraw MCP; рендерит `tldraw export` |
| `.py` | Pylance: ошибки и автодополнение | Запуск кода; диагностика через линтеры |
| `.sh` | Терминал: `bash -n` | `bash -n` + запуск |
| `.jl` | Julia LS | Запуск `julia` |
| `.ts` | Встроенный TypeScript | `npm run build` |
| `.ipynb` | Запуск ячеек в GUI | Читает JSON ячеек; запускает `jupyter` |
| `.tex` | Компиляция + PDF-превью | Пишет `.tex`, запускает `pdflatex`, читает лог |
| `.wl` | Подсветка + wolframscript | Проверяет через `wolframscript` |

> 💡 Агент проверяет правки **компиляторами и линтерами** — они дают честные ошибки сборки.

## 🛠 Использование

| Задача | Команда |
|--------|---------|
| 🔄 **Обновить весь стек** | `cd ~/stack && bash update-all.sh` — 13 шагов, затем `/reload` или перезапуск OpenCode |
| ✅ **Проверить работоспособность** | `bash ~/stack/check-all.sh` |
| ➕ **Подключить проект** | `~/stack/new-project.sh <путь>` |
| 🔁 **Синхронизировать все проекты** | `bash ~/stack/sync-agents.sh` |
| 📄 **Срок лицензии Wolfram** | `bash ~/stack/check-wolfram-license.sh` |
| 🧩 **Версия Chrome под tldraw** | `bash ~/stack/chrome-version.sh` |

> ⚠️ Конфиги OpenCode v2 перечитываются на лету (`/reload`); после обновления самих компонентов (MCP-бинарники, venv, скиллы) надёжнее перезапустить OpenCode.

## 📚 Документация

| Файл | Для кого | О чём |
|------|----------|-------|
| [`AGENTS.md`](AGENTS.md) | 🤖 Агент | Карта репозитория, MCP-инструменты, конвенции |
| [`STACK.md`](STACK.md) | 👤 Человек | Хоткеи, примеры кода, ссылки по каждому инструменту |
| [`workflow.txt`](workflow.txt) | 👤🤖 | Git-workflow: ветка → коммит → PR → merge |
