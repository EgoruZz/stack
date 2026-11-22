<div align="center">

<img src="assets/banner.png" alt="Stack — personal AI dev environment" width="100%">

# Stack

**Персональная AI-разработка среда для macOS: человек + ИИ-ассистент в OpenCode.**
MCP-серверы, скиллы, CLI-инструменты и офисные приложения — всё подключается к проекту одной командой и обновляется одной командой.

![macOS](https://img.shields.io/badge/macOS-000000?logo=apple&logoColor=white&style=for-the-badge)
![OpenCode v2](https://img.shields.io/badge/OpenCode_v2-1F6FEB?style=for-the-badge)

![MCP--серверы](https://img.shields.io/badge/MCP--серверы-10-2EA043?style=for-the-badge)
![Скиллы](https://img.shields.io/badge/Скиллы-60-E16F24?style=for-the-badge)
![Craft_Apps](https://img.shields.io/badge/Craft_Apps-5-EA4AAA?style=for-the-badge)
![CLI--инструменты](https://img.shields.io/badge/CLI--инструменты-13-0969DA?style=for-the-badge)
![Версия](https://img.shields.io/badge/версия-v1.0.0-8250DF?style=for-the-badge)

> [!NOTE]
> 🤖 **ИИ-агенту:** начать с [`AGENTS.md`](AGENTS.md) — карта репозитория и конвенции.
>
> 👤 **Человеку:** [`STACK.md`](STACK.md) — полная документация: хоткеи, примеры, ссылки.
>
> 🤝 **ИИ + человеку:** [`workflow.txt`](workflow.txt) — правила git-workflow (ветка → PR → merge).

</div>

---

<h2 align="center">🧭 Зачем</h2>

Research и разработка требуют вычислений (Wolfram, Julia), визуализации (ParaView, Manim), веб-исследований (Firecrawl), документов-деливераблов (Word/Excel/PowerPoint/PDF) и интерфейсных мокапов (FigCraft) — **в одном месте и под управлением ИИ-агента**. Стек собирает официальные open-source инструменты и подключает их к OpenCode всеми возможными каналами: **MCP-серверы** (интерактивные вычисления и редактирование), **скиллы** (пошаговые workflow для агента), **headless-CLI** (скриптовое применение команд без окна) и **CLI-скрипты контроля** (проверки, обновления, срок-контроль) — и делает всё это доступным **только в проектах, где он явно включён**: глобальный конфиг OpenCode остаётся пустым, вне проектов агент их не видит.

| Принцип | Что значит |
|---------|-----------|
| **Проектность** | Стек поднимается только в проектах, где подключён |
| **Один источник** | Шаблон конфига, списки скиллов, карта репозитория правятся в одном месте и расходятся скриптами |
| **Свежесть** | `update-all.sh` обновляет всё: brew → репо → venv → скиллы → Julia → Wolfram → Craft Apps, и следит за сроками лицензий/подписок |
| **Переносимость** | Пути в конфигах через `{env:HOME}`; свежая машина = `git clone` + `setup.sh` |
| **Маршрутизация** | Локальный трафик стека — всегда напрямую; внешний web — через Singapore ISP-прокси (`proxy.sh`) |

## Оглавление

- [Структура репозитория](#-структура-репозитория)
- [Ручные шаги](#-ручные-шаги)
- [Быстрый старт](#-быстрый-старт)
- [Что внутри](#-что-внутри)
- [Стек в проекте](#-стек-в-проекте)
- [Файлы: человек vs ИИ-агент](#-файлы-человек-vs-ии-агент)
- [Использование](#-использование)

<h2 align="center">📁 Структура репозитория</h2>

Все `*.sh` — CLI-инструменты (запуск: `bash ~/stack/<имя>.sh`):

```
~/stack/
├── README.md                    # Этот файл
├── AGENTS.md                    # Инструкции агента (с картой репозитория)
├── STACK.md                     # Полная документация: хоткеи, примеры
├── workflow.txt                 # Правила git-workflow
│
├── setup.sh                     # Установка на чистую macOS (12 шагов)
├── update-all.sh                # Обновление всего (13 шагов) + срок-контроль
├── check-all.sh                 # Проверка работоспособности
│
├── new-project.sh               # Подключить проект
├── sync-agents.sh               # AGENTS.md + конфиги → все проекты
├── gen-opencode-config.sh       # Генератор .opencode/opencode.json (10 MCP)
├── sync-aris.sh                 # ARIS-скиллы → skills-store
├── consolidate-skills.sh        # Сборка skills-store + чистка глобальных
├── craft-install.sh             # Установка/обновление Craft Apps (GUI)
├── apply-first-start.sh         # Форма первого старта → личные конфиги
├── proxy.sh                     # Сеть: env-прокси + CLI (status/expiry/git/test)
├── chrome-version.sh            # Версия Chrome под пин tldraw
├── check-wolfram-license.sh     # Срок лицензии Wolfram
│
├── first-start.template.txt     # Шаблон формы первого старта
├── projects.txt                 # Реестр проектов
├── aris-skills.txt              # Список 14 ARIS-скиллов
├── skills/                      # 8 standalone-скиллов (источник)
├── skills-store/                # Собранные 60 скиллов (gitignored)
├── craft-cli/                   # Headless-CLI Craft Apps (gitignored)
├── craft-downloads/             # Кэш DMG установщиков (gitignored)
├── WolframLanguage/             # Пользовательские Wolfram-пакеты
│
└── paraview-mcp/ · manim-mcp/ · julia-mcp/ · tldraw-mcp/ ·      # клонированные
    aris-research-repo/ · WolframLanguageForJupyter/             # репозитории
```

<h2 align="center">🖐 Ручные шаги</h2>

brew-каски ставят почти всё автоматически — включая то, что раньше было ручным (OpenCode, Wolfram Engine, ParaView, MacTeX, tldraw Desktop). Руками остаётся только:

| Шаг | Зачем | Как |
|-----|-------|-----|
| **Форма первого старта** | прокси, Wolfram ID, git identity | `cp ~/stack/first-start.template.txt ~/stack/first-start.txt` → заполнить → `bash ~/stack/apply-first-start.sh` |
| **Активация Wolfram** | лицензия MCP (продлевать каждые ~40 дней) | `wolframscript` — войти с Wolfram ID; проверка: `bash ~/stack/check-wolfram-license.sh` |
| **Firecrawl auth** *(опционально)* | полный тариф вместо free | `firecrawl login --browser`; проверка: `firecrawl --status` |

> Наличие компонентов проверяет `check-all.sh` — по каждому ✅ или ❌.

<h2 align="center">🚀 Быстрый старт</h2>

```bash
git clone https://github.com/EgoruZz/stack.git ~/stack
cd ~/stack
bash setup.sh        # 12 шагов: brew+каски, репозитории, venv, CLI, скиллы, конфиги
```

- Пароль спрашивается только там, где его требует система
- В конце запускается автопроверка — все компоненты должны быть ✅
- Форма первого старта применяется автоматически, если `first-start.txt` заполнен
- Проекты подключаются: `~/stack/new-project.sh <путь>`

<h2 align="center">📦 Что внутри</h2>

### Терминальные и CLI-инструменты

Всё ставится автоматически `setup.sh`:

| Что | Как ставится |
|-----|--------------|
| Python 3.12 · Node.js · gh · ffmpeg · juliaup | `brew install` |
| Wolfram Engine · ParaView · MacTeX · tldraw Desktop | `brew install --cask` |
| OpenCode | `brew install anomalyco/tap/opencode-v2` |
| `firecrawl-cli` · `tldraw-cli` | `npm install -g` |
| `manim-env` — Manim + ManimGL | pip venv |
| `jupyter-env` — JupyterLab, numpy, pandas, sympy, plotly… | pip venv |
| `paraview-mcp-env`, `julia-mcp-env` — MCP SDK | pip venv |
| Playwright Chromium · Puppeteer Chrome *(headless, версия авто)* | `npx … install` |
| Julia + 20 пакетов | `juliaup` + `Pkg.add` |
| Wolfram AgentTools (paclet) | `PacletInstall` — если Wolfram Engine уже установлен, иначе при первом `update-all.sh` |
| 6 внешних репозиториев | `git clone --depth 1` |
| сборка `tldraw-mcp` | `npm install && npm run build` |
| Headless-CLI Craft Apps ×5 | GitHub releases → `~/stack/craft-cli/` |

> **Manim vs ManimGL:** `manim` (community) — рендерит headless, его использует MCP-сервер. `manimgl` (3Blue1Brown) — интерактивный GUI-инструмент, ни один MCP его не использует.

### MCP-серверы (10)

Конфиги генерируются автоматически (`gen-opencode-config.sh`); для ParaView запусти GUI + pvserver по workflow из `STACK.md`:

| Сервер | Что делает |
|--------|-----------|
| **Wolfram** | Вычисления на Wolfram Language (AgentTools) |
| **julia** | Persistent Julia REPL-сессии |
| **manim** | Headless-рендер анимаций в видео |
| **ParaView** | 3D-визуализация данных (через TCP-мост) |
| **tldraw** | Whiteboard-холст, 30+ инструментов |
| **wordcraft** | Word-документы: .docx, цитирования APA/MLA/Chicago/IEEE, Zotero |
| **gridcraft** | Excel: .xlsx, 500+ функций, PivotTables, графики |
| **deckcraft** | PowerPoint: .pptx, темы, Morph, экспорт PDF/GIF |
| **pdfcraft** | PDF: объединение, разделение, защита, комментарии |
| **figcraft** | UI-дизайн: frames, auto-layout, прототипы |

### Craft Apps (5)

Нативные macOS-приложения [ArtCraft](https://getartcraft.com) (open source, pure Rust) — у каждого есть headless-CLI и MCP. GUI ставится/обновляется скриптом:

```bash
bash ~/stack/craft-install.sh
```

| Приложение | Статус (официально) |
|---|---|
| WordCraft · GridCraft · DeckCraft | In development |
| PdfCraft · FigCraft | Early alpha |

> ⚠️ Все приложения — предрелизные: сложные файлы из MS Office и .fig-файлы открываются best-effort и могут отображаться не идеально — **храни копии важных документов**.

### Расширения VS Code (6)

Ставятся автоматически `setup.sh`, если установлен VS Code CLI (`code`): `tldraw-org.tldraw-vscode` (.tldr), `ms-python.python` (.py), `ms-toolsai.jupyter` (.ipynb), `julialang.language-julia` (.jl), `wolframresearch.wolfram` (.wl), `james-yu.latex-workshop` (.tex).

### Скиллы OpenCode (60)

Собираются автоматически (`consolidate-skills.sh`) в `~/stack/skills-store/` и подключаются к проектам через `skills` в конфиге — **вне проектов агент видит только встроенные скиллы OpenCode**.

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
| `craft-office` | Office-деливераблы: Word/Excel/PowerPoint/PDF через Craft Apps |
| `deep-mind` | Глубокое критическое мышление |
| `epistemic-rigor` | Anti-sycophancy, честная оценка гипотез |
| `grill-me` | Стресс-тест планов и решений |
| `dag-hallucination-detector` | Проверка цитат и фактов |
| `aris-research-pipeline` | Полный research pipeline (local-only) |

</details>

<h2 align="center">⚡ Стек в проекте</h2>

```bash
~/stack/new-project.sh ~/work/my-project    # создать новый / зарегистрировать существующий
```

Проект получает **два файла**:

| Файл | Содержимое |
|------|-----------|
| `AGENTS.md` | Инструкции агента: карта стека, MCP-инструменты, конвенции |
| `.opencode/opencode.json` | `mcp` ×10 · `skills` → skills-store |

| Факт | Детали |
|------|--------|
| **Переносимость** | Пути в конфиге через `{env:HOME}` — переносим между машинами |
| **Реестр проектов** | `~/stack/projects.txt` — по одному пути на строку |
| **Синхронизация** | `bash ~/stack/sync-agents.sh` перегенерирует AGENTS.md + конфиги во всех проектах; контент AGENTS.md вне маркеров `<!-- STACK:START/END -->` сохраняется |
| **Конфиг — без маркеров** | `.opencode/opencode.json` перегенерируется **целиком**: правь шаблон в `gen-opencode-config.sh`, не конфиги проектов |
| **Диагностика — через запуск** | OpenCode v2 не имеет LSP: агент получает ошибки, запуская линтеры/компиляторы/тесты напрямую |
| **Вне проектов** | Ни MCP, ни скиллов; в `~/.config/opencode/` только клиентские настройки |
| **Расширения — без плагинов** | Все расширения через MCP (внешние процессы) и скиллы (промпты); конфиг не содержит поля `plugins` |

<h2 align="center">🤝 Файлы: человек vs ИИ-агент</h2>

Ты — в VS Code (расширения стека дают языковые серверы: автодополнение и ошибки при печати), агент — в OpenCode (через MCP/CLI и запуск компиляторов/линтеров напрямую):

| Файл | Человек — в VS Code | Агент — в OpenCode |
|------|---------------------|--------------------|
| `.tldr` | Рисуешь на холсте | tldraw MCP; рендер `tldraw export` |
| `.py` | Pylance | Запуск кода; линтеры |
| `.sh` | Терминал: `bash -n` | `bash -n` + запуск |
| `.jl` | Julia LS | Запуск `julia` |
| `.ts` | Встроенный TS | `npm run build` |
| `.ipynb` | Ячейки в GUI | `jupyter` |
| `.tex` | Компиляция + PDF | `pdflatex` + чтение лога |
| `.wl` | Подсветка + wolframscript | wolframscript |
| `.docx` `.xlsx` `.pptx` `.pdf` | Craft Apps GUI | Craft Apps MCP/CLI (headless или live-режим) |
| `.figcraft` | FigCraft | FigCraft MCP/CLI: frames, прототипы, экспорт PNG/SVG/PDF |

<h2 align="center">🛠 Использование</h2>

| Задача | Команда |
|--------|---------|
| **Обновить весь стек** | `cd ~/stack && bash update-all.sh` — 13 шагов, затем `/reload` или перезапуск OpenCode |
| **Проверить работоспособность** | `bash ~/stack/check-all.sh` |
| **Подключить проект** | `~/stack/new-project.sh <путь>` |
| **Синхронизировать проекты** | `bash ~/stack/sync-agents.sh` |
| **Установить/обновить Craft Apps** | `bash ~/stack/craft-install.sh` |
| **Сеть: статус / тест / git** | `bash ~/stack/proxy.sh status` · `test` · `git on\|off` |
| **Сроки: прокси / Wolfram** | `bash ~/stack/proxy.sh expiry` · `bash ~/stack/check-wolfram-license.sh` |
| **Кредиты Firecrawl** | `firecrawl credits` |
| **Версия Chrome под tldraw** | `bash ~/stack/chrome-version.sh` |

> Конфиги OpenCode v2 перечитываются на лету (`/reload`); после обновления самих компонентов (бинарники MCP, venv, скиллы) надёжнее перезапустить OpenCode.
