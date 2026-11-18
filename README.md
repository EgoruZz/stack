<div align="center">

# 🧰 Stack

![платформа](https://img.shields.io/badge/платформа-macOS-black)
![агент](https://img.shields.io/badge/AI--агент-OpenCode-1F6FEB)
![MCP](https://img.shields.io/badge/MCP--серверы-5-2EA043)
![скиллы](https://img.shields.io/badge/скиллы-~61-E16F24)
![VS_Code](https://img.shields.io/badge/расширения_VS_Code-6-8250DF)
![обновление](https://img.shields.io/badge/обновление-update--all.sh-D29922)

[![AGENTS.md](https://img.shields.io/badge/🤖_карта_и_конвенции-AGENTS.md-1F6FEB)](AGENTS.md)
[![STACK.md](https://img.shields.io/badge/📖_полная_дока-STACK.md-1F6FEB)](STACK.md)
[![workflow.txt](https://img.shields.io/badge/🔀_git--workflow-workflow.txt-1F6FEB)](workflow.txt)

</div>

**Персональный набор инструментов для macOS** — MCP-серверы, AI-скиллы, CLI-утилиты и скрипты для полноценной AI-разработки через [OpenCode](https://opencode.ai).

🤖 *ИИ-агент? Начни с [`AGENTS.md`](AGENTS.md) — карта репозитория и конвенции.*

---

## 💡 Суть

| Принцип | Что значит |
|---------|-----------|
| 🏠 **Проектность** | Стек поднимается **только в проектах, где он подключён** — глобальный конфиг OpenCode остаётся пустым |
| 1️⃣ **Один источник** | Шаблон конфига, список ARIS-скиллов, карта репозитория — правятся в одном месте, расходятся скриптами |
| 🔄 **Свежесть** | `bash update-all.sh` обновляет всё одной командой — от brew до скиллов |
| ♻️ **Переносимость** | Пути в конфигах через `{env:HOME}`; свежая машина = `git clone` + `setup.sh` |

## 🗺 Оглавление

- [🚀 Быстрый старт](#-быстрый-старт)
- [📦 Что внутри](#-что-внутри)
- [🖐 Ручные шаги](#-ручные-шаги)
- [⚡ Стек в проекте](#-стек-в-проекте)
- [👀 Файлы: пользователь vs ИИ-агент](#-файлы-пользователь-vs-ии-агент)
- [🛠 Использование](#-использование)
- [📁 Структура репозитория](#-структура-репозитория)
- [📚 Документация](#-документация)

## 🚀 Быстрый старт

```bash
git clone https://github.com/EgoruZz/stack.git ~/stack
cd ~/stack
bash setup.sh        # 12 шагов: brew, репозитории, venv, CLI, скиллы, конфиги
```

- 12 шагов: brew · репозитории · venv · CLI · браузеры · скиллы · конфиги
- Пароль спрашивается только там, где его требует система
- В конце запускается автопроверка — все компоненты должны быть ✅

## 📦 Что внутри

### 🖥 Терминальные и CLI-инструменты

| Что | Как ставится | Обновляется |
|-----|--------------|-------------|
| Python 3.12 · Node.js · gh · ffmpeg · OpenCode | `brew install` | `update-all.sh`, шаг 2 |
| `firecrawl-cli` · `tldraw-cli` | `npm install -g` | шаг 6 |
| `manim-env` — Manim + ManimGL | pip venv | шаг 5 |
| `jupyter-env` — JupyterLab, numpy, pandas, sympy, plotly… | pip venv | шаг 5 |
| `paraview-mcp-env`, `julia-mcp-env` — MCP SDK | pip venv | шаг 5 |
| Playwright Chromium · Puppeteer Chrome *(headless, версия авто)* | `npx … install` | шаг 6 |
| Julia + 21 пакет *(вкл. LanguageServer для LSP)* | `juliaup` + `Pkg.add` | шаг 9 |
| Wolfram AgentTools (paclet) | `PacletInstall` | шаг 10 |
| 6 внешних репозиториев MCP | `git clone --depth 1` | шаг 3 |
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

### 🎯 Скиллы OpenCode (~61)

Собираются в хранилище `~/stack/skills-store/` и подключаются к проектам через `skills.paths` — **вне проектов агент видит только 1 встроенный скилл**.

| Группа | ~Кол-во | Источник |
|--------|---------|----------|
| Firecrawl — веб-research, скрапинг, SEO | 37 | `firecrawl setup skills/build/workflows` |
| ARIS — research pipeline, статьи, эксперименты | 14 | клон ARIS → `sync-aris.sh` |
| `tldraw-skill` — генерация `.tldr` из текста | 1 | GitHub |
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

Что скрипты **не** ставят — по независимым причинам (лицензии, GUI-приложения):

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
| `.opencode/opencode.json` | `mcp` ×5 · `lsp: true` · `skills.paths` → skills-store |

| Факт | Детали |
|------|--------|
| 🔌 **Переносимость** | Пути в конфиге через `{env:HOME}` — файл переносим между машинами и коммитобезопасен |
| 📋 **Реестр проектов** | `~/stack/projects.txt` — по одному пути на строку |
| 🔁 **Синхронизация** | `bash ~/stack/sync-agents.sh` перегенерирует AGENTS.md + конфиги во всех проектах (входит в `update-all.sh`, шаг 12); проект-специфичный контент AGENTS.md **вне маркеров** `<!-- STACK:START -->…<!-- STACK:END -->` сохраняется |
| 🧠 **LSP включён** | При открытии файла OpenCode поднимает языковой сервер и получает ошибки в свой цикл: `pyright` (`.py`), `bash-language-server` (`.sh`), `julials` (`.jl`), typescript и др. Отключение: убрать поле `lsp` · Проверка: `opencode debug lsp diagnostics <файл>` · [docs](https://opencode.ai/docs/lsp) |
| 🚫 **Вне проектов** | Ни MCP, ни скиллов, ни LSP. Глобальный каталог `~/.config/opencode/` пуст (OpenCode сам создаёт там лишь 2 файла-стаба) |
| 🚫 **Без поля `plugin`** | Пакет `opencode-firecrawl` не существует на npm (404); раньше его строка разворачивала ~62 МБ зависимостей в глобальном каталоге. Понадобится плагинный уровень — есть сторонний `opencode-firecrawl-ng` |

## 👀 Файлы: пользователь vs ИИ-агент

Стек даёт **двойной контроль** над файлами, и эти два мира не конфликтуют: LSP VS Code (Pylance) и LSP OpenCode (pyright) — независимые процессы для разных потребителей.

| Файл | 👤 Ты — в VS Code | 🤖 Агент — в OpenCode |
|------|-------------------|------------------------|
| `.tldr` | Рисуешь на холсте во вкладке | Читает JSON; создаёт через tldraw MCP; рендерит `tldraw export` |
| `.py` | Pylance: ошибки и автодополнение | pyright LSP + запуск кода |
| `.sh` | Терминал: `bash -n` | bash-language-server + `bash -n` |
| `.jl` | Julia LS | julials LSP + запуск `julia` |
| `.ts` | Встроенный TypeScript | typescript LSP + `npm run build` |
| `.ipynb` | Запуск ячеек в GUI | Читает JSON ячеек; запускает `jupyter` |
| `.tex` | Компиляция + PDF-превью | Пишет `.tex`, запускает `pdflatex`, читает лог |
| `.wl` | Подсветка + wolframscript | Проверяет через `wolframscript` |

> 💡 Для `.tex` и `.wl` агент намеренно использует **компиляторы**, а не LSP — `pdflatex` и `wolframscript` дают честные ошибки сборки.

## 🛠 Использование

| Задача | Команда |
|--------|---------|
| 🔄 **Обновить весь стек** | `cd ~/stack && bash update-all.sh` — 13 шагов, затем перезапусти OpenCode |
| ✅ **Проверить работоспособность** | `bash ~/stack/check-all.sh` |
| ➕ **Подключить проект** | `~/stack/new-project.sh <путь>` |
| 🔁 **Синхронизировать все проекты** | `bash ~/stack/sync-agents.sh` |
| 📄 **Срок лицензии Wolfram** | `bash ~/stack/check-wolfram-license.sh` |
| 🧩 **Версия Chrome под tldraw** | `bash ~/stack/chrome-version.sh` |

**Алиасы** (добавляются в `.zshrc`):

| Алиас | Действие |
|-------|---------|
| `stack` | перейти в `~/stack` |
| `manim-activate` | активировать manim-env |
| `jupyter-jlab` | запустить JupyterLab |
| `jupyter-wolfram` | Jupyter с Wolfram kernel |
| `new-project` | подключить проект |

> ⚠️ После любого обновления **перезапусти OpenCode** — MCP, скиллы и конфиги читаются только при старте сессии.

## 📁 Структура репозитория

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
├── skills-store/                # 🗃 Собранные ~61 скилл (gitignored)
├── WolframLanguage/             # 🐺 Пользовательские Wolfram-пакеты
│
└── paraview-mcp/ · manim-mcp/ · julia-mcp/ · tldraw-mcp/ ·      # 🌐 клонированные
    aris-research-repo/ · WolframLanguageForJupyter/             #    репозитории
```

## 📚 Документация

| Файл | Для кого | О чём |
|------|----------|-------|
| [`AGENTS.md`](AGENTS.md) | 🤖 Агент | Карта репозитория, MCP-инструменты, конвенции |
| [`STACK.md`](STACK.md) | 👤 Человек | Хоткеи, примеры кода, ссылки по каждому инструменту |
| [`workflow.txt`](workflow.txt) | 👤🤖 | Git-workflow: ветка → коммит → PR → merge |

---

<div align="center">

**Stack** · macOS · [OpenCode](https://opencode.ai) · обновляется одной командой 🔄

</div>
