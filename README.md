<div align="center">

# Stack

**Персональная AI-разработка среда для macOS: человек + ИИ-ассистент в OpenCode.**
MCP-серверы, скиллы, CLI-инструменты и офисные приложения — всё подключается к проекту одной командой и обновляется одной командой.

![платформа](https://img.shields.io/badge/платформа-macOS-black)
![агент](https://img.shields.io/badge/агент-OpenCode_v2-1F6FEB)
![MCP](https://img.shields.io/badge/MCP--серверы-10-2EA043)
![скиллы](https://img.shields.io/badge/скиллы-60-E16F24)
![Craft_Apps](https://img.shields.io/badge/Craft_Apps-5-EA4AAA)
![CLI](https://img.shields.io/badge/CLI--инструменты-12-0969DA)

[![AGENTS.md](https://img.shields.io/badge/🤖_агенту_начать_отсюда-AGENTS.md-1F6FEB)](AGENTS.md)
[![STACK.md](https://img.shields.io/badge/📖_полная_документация-STACK.md-1F6FEB)](STACK.md)
[![workflow.txt](https://img.shields.io/badge/🔀_git--workflow-workflow.txt-1F6FEB)](workflow.txt)

</div>

---

## Зачем

Research и разработка требуют вычислений (Wolfram, Julia), визуализации (ParaView, Manim), веб-исследований (Firecrawl), документов-деливераблов (Word/Excel/PowerPoint/PDF) и интерфейсных мокапов (FigCraft) — **в одном месте и под управлением ИИ-агента**. Стек собирает официальные open-source инструменты и подключает их к OpenCode всеми возможными каналами: **MCP-серверы** (интерактивные вычисления и редактирование), **скиллы** (пошаговые workflow для агента), **headless-CLI** (скриптовое применение команд без окна) и **CLI-скрипты контроля** (проверки, обновления, срок-контроль) — и делает всё это доступным **только в проектах, где он явно включён**: глобальный конфиг OpenCode остаётся пустым, вне проектов агент их не видит.

| Принцип | Что значит |
|---------|-----------|
| **Проектность** | Стек поднимается только в проектах, где подключён |
| **Один источник** | Шаблон конфига, списки скиллов, карта репозитория правятся в одном месте и расходятся скриптами |
| **Свежесть** | `update-all.sh` обновляет всё: brew → репо → venv → скиллы → Julia → Wolfram → Craft Apps, и следит за сроками лицензий/подписок |
| **Переносимость** | Пути в конфигах через `{env:HOME}`; свежая машина = `git clone` + `setup.sh` |
| **Маршрутизация** | Локальный трафик стека — всегда напрямую; внешний web — через Singapore ISP-прокси (`proxy.sh`) |

## Оглавление

- [Структура репозитория](#структура-репозитория)
- [Ручные шаги (до setup.sh)](#ручные-шаги-выполни-до-setupsh)
- [Быстрый старт](#быстрый-старт)
- [Что внутри](#что-внутри)
- [Стек в проекте](#стек-в-проекте)
- [Файлы: человек vs ИИ-агент](#файлы-человек-vs-ии-агент)
- [Использование](#использование)
- [Документация](#документация)

## Структура репозитория

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
├── proxy.sh                     # Сеть: env-прокси + CLI (status/expiry/git/test)
├── chrome-version.sh            # Версия Chrome под пин tldraw
├── check-wolfram-license.sh     # Срок лицензии Wolfram
│
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

## Ручные шаги (выполни до setup.sh)

Что CLI **не** ставят — по независимым причинам (лицензии, GUI-приложения):

| Компонент | Как установить |
|-----------|---------------|
| **OpenCode** | [opencode.ai](https://opencode.ai) |
| **Wolfram Engine** | `brew install --cask wolfram-engine`, затем `wolframscript` — активация лицензии (продлевать каждые ~40 дней: [проверка](#использование)) |
| **ParaView** | [paraview.org/download](https://www.paraview.org/download/) |
| **MacTeX** | `brew install --cask mactex` (~4 GB) |
| **Firecrawl auth** | `firecrawl login --browser` — без него работает бесплатный tier |

Всё остальное ставится автоматически. Секреты (прокси, ключи) живут в `~/.zshrc` и `~/.stack-secrets.sh` — **не** в репозитории.

> Наличие ручных компонентов проверяет `check-all.sh` (Wolfram, ParaView, MacTeX/LaTeX, OpenCode, VS Code — с ✅/❌). Единственное исключение — Firecrawl auth: проверяй вручную `firecrawl --status`.

## Быстрый старт

```bash
git clone https://github.com/EgoruZz/stack.git ~/stack
cd ~/stack
bash setup.sh        # 12 шагов: brew, репозитории, venv, CLI, скиллы, конфиги
```

- Пароль спрашивается только там, где его требует система
- В конце запускается автопроверка — все компоненты должны быть ✅
- Проекты подключаются после: `~/stack/new-project.sh <путь>`

## Что внутри

### Терминальные и CLI-инструменты

Всё ставится автоматически `setup.sh`:

| Что | Как ставится |
|-----|--------------|
| Python 3.12 · Node.js · gh · ffmpeg · juliaup | `brew install` |
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
| **figcraft** | UI-дизайн: frames, auto-layout, прототипы; формат .figcraft (.fig — best-effort), экспорт PNG/JPEG/WebP/SVG/PDF |

### Craft Apps (5)

Нативные macOS-приложения [ArtCraft](https://getartcraft.com) (open source, pure Rust) — у каждого есть headless-CLI и MCP. GUI ставится/обновляется скриптом в *своём* терминале:

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

## Стек в проекте

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

## Файлы: человек vs ИИ-агент

Ты — в VS Code (с LSP), агент — в OpenCode (через MCP/CLI и запуск линтеров):

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

## Использование

| Задача | Команда |
|--------|---------|
| **Обновить весь стек** | `cd ~/stack && bash update-all.sh` — 13 шагов, затем `/reload` или перезапуск OpenCode |
| **Проверить работоспособность** | `bash ~/stack/check-all.sh` |
| **Подключить проект** | `~/stack/new-project.sh <путь>` |
| **Синхронизировать проекты** | `bash ~/stack/sync-agents.sh` |
| **Установить/обновить Craft Apps** | `bash ~/stack/craft-install.sh` (в своём терминале) |
| **Сеть: статус / тест / git** | `bash ~/stack/proxy.sh status` · `test` · `git on\|off` |
| **Сроки: прокси / Wolfram** | `bash ~/stack/proxy.sh expiry` · `bash ~/stack/check-wolfram-license.sh` |
| **Кредиты Firecrawl** | `firecrawl credits` |
| **Версия Chrome под tldraw** | `bash ~/stack/chrome-version.sh` |

> Конфиги OpenCode v2 перечитываются на лету (`/reload`); после обновления самих компонентов (бинарники MCP, venv, скиллы) надёжнее перезапустить OpenCode.

## Документация

| Файл | Для кого | О чём |
|------|----------|-------|
| [`AGENTS.md`](AGENTS.md) | Агент | Карта репозитория, MCP-инструменты, конвенции |
| [`STACK.md`](STACK.md) | Человек | Хоткеи, примеры кода, ссылки по каждому инструменту |
| [`workflow.txt`](workflow.txt) | Оба | Git-workflow: ветка → коммит → PR → merge |
