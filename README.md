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
| ~61 скилл OpenCode | npm + git + local | AI-навыки для агента (проектные, через skills-store) |
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
| `firecrawl-cli` | Веб-поиск, скрапинг, research (ставит ~37 скиллов firecrawl) |
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

Прописываются в `.opencode/opencode.json` каждого проекта (генерируется `gen-opencode-config.sh`). **Глобально стек не поднимается** — MCP запускается только в проектах из реестра `projects.txt` и в самом `~/stack`.

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

## Просмотр и контроль файлов: пользователь vs ИИ-агент

Стек даёт **двойной контроль** над файлами: ты работаешь с ними в VS Code, агент — в OpenCode. Это не конфликтует: LSP VS Code и LSP OpenCode — независимые процессы (Pylance у тебя в редакторе, pyright у агента), они не делят состояние и не мешают друг другу.

### Как контролирует пользователь (VS Code)

Ты открываешь файл во вкладке — расширение даёт визуальный редактор и живую диагностику:

| Формат | Расширение | Что даёт тебе |
|--------|-----------|---------------|
| `.tldr` | tldraw | Полноценный белый холст прямо во вкладке: рисуешь, сохраняешь |
| `.py` | Python + Pylance | Автодополнение, ошибки подчёркиваются прямо в коде |
| `.sh` | (встроенное) | Подсветка; запуск и ошибки — в терминале ``Cmd+` `` |
| `.jl` | Julia | Автодополнение, переходы к определениям (LanguageServer.jl) |
| `.ts` | встроенный TS | Типы, автодополнение для tldraw-mcp |
| `.ipynb` | Jupyter | Запуск ячеек, графики, превью ноутбука |
| `.tex` | LaTeX Workshop | Компиляция + PDF-превью рядом с кодом |
| `.wl` | Wolfram | Подсветка, интеграция с wolframscript |

Плюс терминал VS Code: запускаешь `manim`, `julia`, `pdflatex` сам и видишь вывод.

### Как контролирует ИИ-агент (OpenCode)

Агент работает с теми же файлами тремя слоями:

1. **Чтение как текст** (`read`/`grep`/`glob`) — любой формат, включая `.tldr` (JSON) и `.ipynb` (JSON ячеек)
2. **LSP-диагностика** — серверы запускаются автоматически при открытии файла и присылают ошибки в цикл агента (см. раздел LSP ниже)
3. **Запуск инструментов** — агент сам выполняет компиляторы и линтеры через терминал и видит реальный вывод

### Сводная таблица: кто как видит каждый формат

| Формат | Пользователь (VS Code) | ИИ-агент (OpenCode) |
|--------|------------------------|----------------------|
| `.tldr` | Рисуешь на холсте визуально | Читает JSON; создаёт/правит через tldraw MCP; рендерит через `tldraw export` |
| `.py` | Pylance: ошибки в редакторе | pyright LSP + запуск `python` |
| `.sh` | Терминал: `bash -n`, запуск | bash-language-server + `bash -n` + запуск |
| `.jl` | Julia LS: автодополнение | julials LSP + запуск `julia` |
| `.ts` | Встроенный TypeScript | typescript-language-server + `npm run build` |
| `.ipynb` | Запуск ячеек в GUI | Читает JSON; запускает через `jupyter` |
| `.tex` | Компиляция + PDF превью | Пишет `.tex`, запускает `pdflatex`, читает лог ошибок |
| `.wl` | Подсветка + wolframscript | Проверяет код через `wolframscript` |

> Для `.tex` и `.wl` агент намеренно полагается на **компиляторы**, а не на LSP: `pdflatex` и `wolframscript` дают честные ошибки сборки.

---

## Скиллы OpenCode (~61)

**Как и MCP — проектные:** скиллы собраны в хранилище `~/stack/skills-store/` и подключаются к проекту через `skills.paths` в `.opencode/opencode.json`. Вне проектов агент видит только 1 встроенный скилл OpenCode. Глобальные каталоги (`~/.config/opencode/skills`, `~/.claude/skills`, `~/.agents/skills`) опустошаются `consolidate-skills.sh` — OpenCode сканирует их всегда, отключить сканирование нельзя, поэтому скиллы физически не должны там жить.

Сборка хранилища (`consolidate-skills.sh`, входит в setup и update-all):

| Группа | Кол-во | Источник |
|--------|--------|----------|
| **Firecrawl** | ~37 | `firecrawl setup skills/build/workflows` → перенос в хранилище |
| **ARIS** | 14 | `aris-research-repo` через `sync-aris.sh` |
| **tldraw-skill** | 1 | GitHub (`Agents365-ai/tldraw-skill`) |
| **tldraw-offline** | 1 | ставится приложением tldraw Desktop (агент-скилл его локального API) |
| **Standalone** | 8 | `skills/` этого репозитория |

Количество firecrawl-скиллов меняется с версиями CLI — точное число: `ls ~/stack/skills-store | wc -l`.

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

### Проектный конфиг (стек живёт в проектах)

Стек **намеренно не прописан в глобальном** `~/.config/opencode/opencode.jsonc` — там могут быть только твои личные настройки. Конфиг стека генерируется в каждую папку, где стек указан:

| Файл | Кто создаёт | Что содержит |
|------|-------------|--------------|
| `<проект>/.opencode/opencode.json` | `sync-agents.sh` и `new-project.sh` | `plugin`, `lsp`, 5 `mcp`-серверов |
| `~/stack/.opencode/opencode.json` | `setup.sh` (шаг 10) | то же — для сессий в самом стеке |

Один источник шаблона — `gen-opencode-config.sh [директория]`:

```bash
bash ~/stack/gen-opencode-config.sh ~/work/my-project   # вручную для любой папки
```

Пути внутри записаны через `{env:HOME}` — OpenCode подставляет переменные окружения при чтении, поэтому файл переносим между машинами и его можно коммитить.

**Что получает зарегистрированный проект** (при `new-project.sh` или `sync-agents.sh`):

- `AGENTS.md` — инструкции для агента (stack-секция между маркерами)
- `.opencode/opencode.json` — MCP-серверы, LSP, плагин, подключение skills-store

**Вне проектов** (`opencode` в случайной папке): ни MCP, ни LSP стека не запускаются.

> Скиллы подключаются так же, как MCP: через `skills.paths` в проектном конфиге. Единственное глобальное — 2 встроенных скилла самого OpenCode (`customize-opencode`, `report`), они есть всегда.

Обновление конфигов всех проектов: `bash ~/stack/sync-agents.sh` (входит в `update-all.sh`, шаг 12).

### LSP (Language Server Protocol)

**Что это:** протокол «умного» редактора — даёт диагностику (ошибки/предупреждения), автодополнение, переход к определению. В VS Code это Pylance для Python и т.п.; в OpenCode — встроенные LSP-серверы.

**Статус:** включён (`"lsp": true`). Когда агент открывает файл, OpenCode поднимает соответствующий LSP-сервер и получает диагностику обратно в цикл — агент видит ошибки сразу, не дожидаясь запуска.

| LSP | Файлы | Что даёт стеку |
|-----|-------|----------------|
| `pyright` | `.py` | Диагностика Python-кода MCP-серверов и проектов |
| `bash-language-server` | `.sh` | Диагностика 8 bash-скриптов стека |
| `julials` | `.jl` | Диагностика Julia (нужен пакет `LanguageServer.jl` — ставится setup.sh) |
| + встроенные (typescript, clangd и др.) | по расширениям | Для остальных языков проектов |

Отключить: удалить поле `"lsp"` из `.opencode/opencode.json` (и перегенерировать через `sync-agents.sh`). LSP-серверы также можно проверить из CLI: `opencode debug lsp diagnostics <файл>`. Подробности: https://opencode.ai/docs/lsp

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
├── consolidate-skills.sh        # Сборка skills-store + очистка глобальных каталогов
├── new-project.sh               # Создание/регистрация проекта
├── gen-opencode-config.sh       # Генератор .opencode/opencode.json (MCP/LSP)
├── chrome-version.sh            # Определение версии Chrome под tldraw
├── check-wolfram-license.sh     # Проверка лицензии Wolfram
├── projects.txt                 # Реестр проектов (по одному пути на строку)
├── aris-skills.txt              # Список ARIS-скиллов (14)
├── skills/                      # 8 standalone-скиллов (источник)
└── WolframLanguage/             # Пользовательские Wolfram-пакеты
```

После установки рядом появляются:
- внешние репозитории: `paraview-mcp/`, `manim-mcp/`, `julia-mcp/`, `tldraw-mcp/`, `aris-research-repo/`, `WolframLanguageForJupyter/`
- `.opencode/opencode.json` в самом `~/stack` и в каждом зарегистрированном проекте (генерируется, в `.gitignore`)

---

## Использование

### Обновление всего стека (одна команда)

```bash
cd ~/stack && bash update-all.sh
```

13 шагов: git-репозиторий → brew → внешние репо → сборка tldraw-mcp → Python venv → npm CLI + Chrome → ARIS-скиллы → консолидация скиллов (skills-store) → Julia (с миграцией окружения) → Wolfram → проверка → синхронизация AGENTS.md **и конфигов OpenCode** во все проекты → напоминание о перезапуске.

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

Создаёт папку (если нужно), копирует `AGENTS.md`, генерирует `.opencode/opencode.json`, регистрирует в `projects.txt`.

### Синхронизация AGENTS.md и конфигов во все проекты

```bash
bash ~/stack/sync-agents.sh
```

Читает `projects.txt` и для каждого проекта:
- заменяет stack-секцию в `AGENTS.md` между маркерами `STACK:START`/`STACK:END` (проект-специфичный контент сохраняется);
- перегенерирует `.opencode/opencode.json` (MCP/LSP стека).

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
