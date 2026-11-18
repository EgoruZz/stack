# Stack

Персональный набор инструментов для macOS: MCP-серверы, AI-скиллы, CLI-инструменты и скрипты для полноценной AI-разработки через OpenCode.

## Быстрый старт

```bash
git clone https://github.com/EgoruZz/stack.git ~/stack
cd ~/stack
bash setup.sh
```

## Что устанавливается (обзор)

| Компонент | Источник | Описание |
|-----------|----------|----------|
| Python 3.12, Node.js, Julia, gh, ffmpeg | Homebrew | Системные рантаймы |
| Manim + ManimGL, JupyterLab | pip (venv) | Анимации, ноутбуки |
| Firecrawl CLI, tldraw CLI | npm (global) | Веб-исследования, экспорт диаграмм |
| Playwright Chromium, Puppeteer Chrome | npx | Headless-рендер (render-visual, tldraw export) |
| 5 MCP-серверов | git clone | Wolfram, Julia, Manim, ParaView, tldraw |
| 6 расширений VS Code | code CLI | Просмотр файлов стека (.tldr, .ipynb, .tex, .wl, .jl, .py) |
| 51 скилл OpenCode | npm + git + local | AI-навыки для агента |
| LSP-серверы | встроены в OpenCode | Диагностика кода для агента |

---

## Терминальные и CLI-инструменты

Всё перечисленное ниже устанавливается `setup.sh` и обновляется `update-all.sh`.

### Homebrew (обновляются в шаге 2)

| Пакет | Зачем в стеке |
|-------|---------------|
| `node` | Рантайм для tldraw MCP и npm-инструментов |
| `python@3.12` | Рантайм для всех Python venv (Manim, Jupyter, MCP) |
| `gh` | GitHub CLI (работа с репозиториями, PR) |
| `ffmpeg` | Кодирование видео для Manim |
| `anomalyco/tap/opencode` | Сам OpenCode (AI-агент) |

Обновляются **только эти пакеты** (не всё подряд в brew) — мусорные формулы не затрагиваются.

### npm global (шаг 6)

| Пакет | Зачем |
|-------|-------|
| `firecrawl-cli` | Веб-поиск, скрапинг, research (ставит 28 скиллов firecrawl) |
| `@kitschpatrol/tldraw-cli` | Экспорт `.tldr` → PNG/SVG |

### Python venv (шаг 5)

| venv | Пакеты |
|------|--------|
| `manim-env` | `manim` (community — для MCP/headless), `manimgl` (3b1b — интерактивный GUI) |
| `jupyter-env` | `jupyterlab`, `numpy`, `matplotlib`, `pandas`, `sympy`, `plotly`, `ipywidgets`, `openpyxl`, `markitdown` |
| `paraview-mcp-env` | `mcp[cli]`, `httpx` (по requirements.txt ParaView MCP) |
| `julia-mcp-env` | `mcp[cli]` |

> **Manim vs ManimGL:** `manim` (community) — основной движок, его использует MCP-сервер для headless-рендера в видео. `manimgl` (3Blue1Brown) — отдельный интерактивный инструмент со своим GUI-окном, **не используется** ни одним MCP. `manim` для автоматизации, `manimgl` — для интерактивной разработки и живого просмотра.

### Браузеры (шаг 6 setup, шаг 6 update)

| Браузер | Зачем |
|---------|-------|
| Playwright Chromium | render-visual: HTML/SVG → PNG/PDF |
| Puppeteer Chrome | tldraw export: `.tldr` → PNG/SVG |

Версия Chrome **автоопределяется** из пина установленного tldraw-cli (`chrome-version.sh`) — хардкода нет.

### Julia (шаг 9 update)

`juliaup` + 21 пакет: Plots, DifferentialEquations, StaticArrays, Optim, JuMP, IJulia, Flux, Turing, DataFrames, CSV, ForwardDiff, SymPy, SpecialFunctions, StatsBase, Distributions, Polynomials, FFTW, IterativeSolvers, LinearAlgebra, SparseArrays, **LanguageServer** (для LSP).

При смене минорной версии Julia скрипт сам мигрирует пакеты в новое окружение.

### Wolfram (шаг 10 update)

Paclet `Wolfram/AgentTools` (MCP-интеграция Wolfram). Требует активной лицензии: `bash check-wolfram-license.sh`.

### Внешние git-репозитории (шаг 3 update)

| Репозиторий | Назначение |
|-------------|-----------|
| `paraview-mcp/` | MCP-сервер ParaView (TCP-мост) |
| `manim-mcp/` | MCP-сервер Manim |
| `julia-mcp/` | MCP-сервер Julia (persistent REPL) |
| `tldraw-mcp/` | MCP-сервер tldraw (30+ инструментов) |
| `aris-research-repo/` | ARIS research pipeline (14 скиллов из него) |
| `WolframLanguageForJupyter/` | Jupyter kernel для Wolfram Language |

---

## MCP-серверы (5)

Прописываются в `~/.config/opencode/opencode.jsonc` (генерируется `setup.sh`).

| Сервер | Что делает |
|--------|-----------|
| **Wolfram** | Вычисления на Wolfram Language (через AgentTools) |
| **julia** | Persistent Julia REPL-сессии |
| **manim** | Headless-рендер анимаций в видео |
| **ParaView** | 3D-визуализация данных (через TCP-мост) |
| **tldraw** | Whiteboard-холст, 30+ инструментов |

## Расширения VS Code (6)

Устанавливаются `setup.sh` (шаг 7) и проверяются `check-all.sh`. Нужны для просмотра файлов стека прямо в редакторе.

| Расширение | Файлы / назначение |
|------------|--------------------|
| `tldraw-org.tldraw-vscode` | `.tldr` — просмотр и редактирование whiteboard-диаграмм |
| `ms-python.python` | `.py` — Python (автодополнение, отладка) |
| `ms-toolsai.jupyter` | `.ipynb` — Jupyter-ноутбуки |
| `julialang.language-julia` | `.jl` — Julia |
| `wolframresearch.wolfram` | `.wl`, `.wls` — Wolfram Language |
| `james-yu.latex-workshop` | `.tex` — LaTeX (компиляция, превью) |

Ручная установка одного расширения: `code --install-extension <id>`.

---

## Скиллы OpenCode (51)

Хранятся глобально в `~/.config/opencode/skills/` — доступны из любого проекта.

| Группа | Кол-во | Источник | Назначение |
|--------|--------|----------|-----------|
| **Firecrawl** | 28 | `firecrawl-cli init` (npm) | Веб-поиск, скрапинг, SEO, lead gen, market research, мониторинг |
| **ARIS** | 14 | `aris-research-repo` через `sync-aris.sh` | Research pipeline, написание статей, планирование экспериментов |
| **tldraw-skill** | 1 | GitHub (`Agents365-ai/tldraw-skill`) | Генерация `.tldr`-диаграмм из текста |
| **Standalone** | 8 | `skills/` этого репозитория | См. ниже |

### Standalone-скиллы (8, хранятся в репозитории)

| Скилл | Назначение |
|-------|-----------|
| `render-visual` | Полированные PNG/SVG/PDF, слайды, схемы, GIF (headless Chromium) |
| `data-analysis` | EDA, визуализация данных, отчёты, гипотезы |
| `xlsx` | Работа с Excel/CSV/TSV: формулы, проверка, конвертация |
| `deep-mind` | Глубокое критическое мышление, first-principles анализ |
| `epistemic-rigor` | Anti-sycophancy, честная оценка гипотез и решений |
| `grill-me` | Стресс-тест планов и дизайн-решений |
| `dag-hallucination-detector` | Проверка цитат, URL, статистики на галлюцинации |
| `aris-research-pipeline` | Полный research-pipeline ARIS (local-only режим) |

Список ARIS-скиллов: `aris-skills.txt` (единый источник правды, читается `sync-aris.sh`).

---

## Конфигурация OpenCode и LSP

### Глобальный конфиг

`~/.config/opencode/opencode.jsonc` **генерируется `setup.sh`** (шаг 10) и содержит:

- `plugin: ["opencode-firecrawl"]` — интеграция firecrawl
- `lsp: true` — включённые LSP-серверы (см. ниже)
- `mcp` — 5 MCP-серверов стека

Конфиг обновляется повторным запуском `bash setup.sh`.

### LSP (Language Server Protocol)

**Что это:** протокол «умного» редактора — даёт диагностику (ошибки/предупреждения), автодополнение, переход к определению. В VS Code это Pylance для Python и т.п.; в OpenCode — встроенные LSP-серверы.

**Статус:** включён (`"lsp": true`). Когда агент открывает файл, OpenCode поднимает соответствующий LSP-сервер и получает диагностику обратно в цикл — агент видит ошибки сразу, не дожидаясь запуска.

| LSP | Файлы | Что даёт стеку |
|-----|-------|----------------|
| `pyright` | `.py` | Диагностика Python-кода MCP-серверов и проектов |
| `bash-language-server` | `.sh` | Диагностика 8 bash-скриптов стека |
| `julials` | `.jl` | Диагностика Julia (нужен пакет `LanguageServer.jl` — ставится setup.sh) |
| + встроенные (typescript, clangd и др.) | по расширениям | Для остальных языков проектов |

Отключить: удалить поле `"lsp"` из `opencode.jsonc`. Подробности: https://opencode.ai/docs/lsp

---

## Ручные шаги

Что **не** ставится автоматически:

| Компонент | Как установить |
|-----------|---------------|
| **OpenCode** | https://opencode.ai (сам AI-инструмент) |
| **Wolfram Engine** | `brew install --cask wolfram-engine`, затем `wolframscript` (активация лицензии) |
| **ParaView** | https://www.paraview.org/download/ (RC-версии нет в brew) |
| **MacTeX** | `brew install --cask mactex` (pdflatex, ~4 GB) |
| **Firecrawl auth** | `firecrawl login --browser` (без него работает бесплатный tier) |

Если `setup.sh` не смог поставить браузеры:

```bash
npx playwright install chromium
VER=$(bash ~/stack/chrome-version.sh)   # версия Chrome под tldraw
npx puppeteer browsers install "chrome@$VER"
```

---

## Структура репозитория

```
~/stack/
├── README.md                    # Этот файл
├── AGENTS.md                    # Инструкции для AI-агента
├── STACK.md                     # Полная документация (хоткеи, примеры, ссылки)
├── workflow.txt                 # Правила git-workflow
├── setup.sh                     # Установка (12 шагов)
├── update-all.sh                # Обновление всего (13 шагов)
├── check-all.sh                 # Проверка работоспособности
├── sync-agents.sh               # Синхронизация AGENTS.md в проекты
├── sync-aris.sh                 # Синхронизация ARIS-скиллов
├── new-project.sh               # Создание/регистрация проекта
├── chrome-version.sh            # Определение версии Chrome под tldraw
├── check-wolfram-license.sh     # Проверка лицензии Wolfram
├── projects.txt                 # Реестр проектов (по одному пути на строку)
├── aris-skills.txt              # Список ARIS-скиллов (14)
├── skills/                      # 8 standalone-скиллов
└── WolframLanguage/             # Пользовательские Wolfram-пакеты
```

После установки рядом появляются внешние репозитории: `paraview-mcp/`, `manim-mcp/`, `julia-mcp/`, `tldraw-mcp/`, `aris-research-repo/`, `WolframLanguageForJupyter/`.

---

## Использование

### Обновление всего стека (одна команда)

```bash
cd ~/stack && bash update-all.sh
```

13 шагов: git-репозиторий → brew → внешние репо → сборка tldraw-mcp → Python venv → npm CLI + Chrome → ARIS-скиллы → standalone-скиллы → Julia (с миграцией окружения) → Wolfram → проверка → синхронизация AGENTS.md → напоминание о перезапуске.

> **После обновления перезапусти OpenCode** — MCP-серверы и скиллы подхватятся только при старте сессии.

### Проверка работоспособности

```bash
bash ~/stack/check-all.sh
```

### Создание проекта

```bash
~/stack/new-project.sh ~/projects/my-project    # создать новый
~/stack/new-project.sh ~/work/analysis          # где угодно
~/stack/new-project.sh ~/learn                  # зарегистрировать существующий
```

Создаёт папку (если нужно), копирует `AGENTS.md`, регистрирует в `projects.txt`.

### Синхронизация AGENTS.md во все проекты

```bash
bash ~/stack/sync-agents.sh
```

Читает `projects.txt`, заменяет stack-секцию между маркерами `STACK:START`/`STACK:END`. Проект-специфичный контент (вне маркеров) сохраняется.

### Алиасы

| Алиас | Команда |
|-------|---------|
| `stack` | `cd ~/stack` |
| `manim-activate` | Активация manim-env |
| `jupyter-jlab` | Запуск JupyterLab |
| `jupyter-wolfram` | Jupyter с Wolfram kernel |
| `new-project` | Создание проекта |

---

## Workflow

См. `workflow.txt`: ветка → коммит → PR → merge.

## Документация

- `AGENTS.md` — инструкции для AI-агента (MCP-инструменты, конвенции)
- `STACK.md` — полная документация: хоткеи, примеры кода, ссылки
- `workflow.txt` — правила git-workflow
