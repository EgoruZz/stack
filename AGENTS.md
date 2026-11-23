# AGENTS.md

<!-- STACK:START -->
## Установленный стэк

Весь стэк находится в ~/stack/
Запускай OpenCode отсюда: `cd ~/stack && opencode`

### Карта репозитория ~/stack

| Файл / папка | Назначение |
|:---:|:---:|
| `AGENTS.md` | Инструкции агента (этот файл — источник для проектов) |
| `README.md` | Документация для людей (обзор, оглавление) |
| `STACK.md` | Полная документация: хоткеи, примеры, ссылки |
| `workflow.txt` | Правила git-workflow (ветка → PR → merge) |
| `setup.sh` | Установка на чистую macOS (12 шагов) |
| `update-all.sh` | Полное обновление стека (13 шагов) |
| `check-all.sh` | Проверка работоспособности всех компонентов |
| `new-project.sh` | Создать/зарегистрировать проект (AGENTS.md + конфиг) |
| `sync-agents.sh` | Синхронизация AGENTS.md + конфигов во все проекты |
| `gen-opencode-config.sh` | Генератор `.opencode/opencode.json` (MCP/skills) |
| `sync-aris.sh` | ARIS-скиллы → skills-store (список из aris-skills.txt) |
| `consolidate-skills.sh` | Сборка skills-store + очистка глобальных каталогов |
| `chrome-version.sh` | Версия Chrome под пин tldraw-cli |
| `check-wolfram-license.sh` | Срок лицензии Wolfram |
| `craft-install.sh` | Установка/обновление GUI Craft Apps (запуск в терминале пользователя) |
| `proxy.sh` | Маршрутизация трафика через ISP-прокси (status / git on-off / test) |
| `projects.txt` | Реестр проектов (по одному пути на строку) |
| `aris-skills.txt` | Список из 14 ARIS-скиллов |
| `skills/` | 8 standalone-скиллов (источник) |
| `skills-store/` | Runtime-хранилище 60 скиллов (gitignored, генерируется) |
| `craft-cli/` | Headless-CLI офисных Craft Apps (gitignored, ставится setup.sh) |
| `craft-downloads/` | Загруженные DMG/zip установщиков Craft Apps (gitignored) |
| `WolframLanguage/` | Пользовательские Wolfram-пакеты |
| `paraview-mcp/`, `manim-mcp/`, `julia-mcp/`, `tldraw-mcp/`, `aris-research-repo/`, `WolframLanguageForJupyter/` | Клонированные внешние репозитории (gitignored) |

### Wolfram Language
- **Wolfram Engine** — бесплатная лицензия для разработчиков
- Запуск: `wolframscript`
- MCP сервер: `Wolfram` (в .opencode/opencode.json проекта)
- Jupyter kernel: `wolframlanguage15` (для Jupyter notebooks)
- Лицензия: продлевать на https://www.wolfram.com/engine/ каждые ~40 дней
- Данные лицензии живут на машине (~/Library/Wolfram*) и ПЕРЕЖИВАЮТ сбросы сессии и git pull
- Креды для активации: ~/.stack-wolfram.conf (пишет apply-first-start.sh из формы); если файла нет — запросить у пользователя
- Процедура при истечении: 1) продление на сайте; 2) попытка `wolframscript -activate` (интерактивный ввод: если в конфе есть WOLFRAM_ID/PASS — попробовать неинтерактивно; если нет — попросить пользователя ввести)
- Проверка лицензии: `wolframscript -code 'Print[$LicenseExpirationDate]'`
- Пакеты: ~/stack/WolframLanguage/ (пользовательские пакеты, создаются по мере необходимости)
- Jupyter интеграция: ~/stack/WolframLanguageForJupyter/

### Manim
- **Manim** (community edition) — основная версия для анимаций
- **ManimGL** (3Blue1Brown) — OpenGL версия
- Окружение: ~/stack/manim-env (Python 3.12)
- Активация: `source ~/stack/manim-env/bin/activate`
- Запуск (community): `manim script.py SceneName`
- Запуск (GL): `manimgl script.py SceneName`
- MCP сервер: `manim` (в .opencode/opencode.json проекта)
- MCP использует community `manim` для headless-рэндера; `manimgl` остаётся отдельным интерактивным CLI

### ParaView
- **ParaView** (GUI + pvpython) — определяется автоматически: `ls -d /Applications/ParaView-*.app`
- pvpython: `$PVAPP/Contents/bin/pvpython` (определи путь: `PVAPP=$(ls -d /Applications/ParaView-*.app | head -1)`)
- Python API: `paraview.simple`
- Скрипты: писать → запускать через pvpython или вставлять в GUI Python Shell
- MCP сервер: `ParaView` (в .opencode/opencode.json проекта)
- Окружение: ~/stack/paraview-mcp-env (Python 3.12)
- MCP инструменты: load_data, create_source, create_isosurface, create_slice, toggle_volume_rendering, color_by, rotate_camera, reset_camera, plot_over_line, warp_by_vector, create_streamline, get_pipeline, и др.
- **Скриншоты:** папка `~/stack/paraview-mcp/screenshots/`
  - Сохраняй скриншоты туда с понятными именами (например `isosurface_temp.png`)
  - Говори агенту: "скриншот в ~/stack/paraview-mcp/screenshots/имя.png — можешь смотреть"
  - MCP скриншоты не доступны (bridge работает в отдельном pvprocess и не видит render view GUI)
- **Workflow запуска (обязательно!):**
  1. Запустить ParaView GUI: `PVAPP=$(ls -d /Applications/ParaView-*.app | head -1) && open "$PVAPP"`
  2. Запустить pvserver: `"$PVAPP/Contents/bin/pvserver" --multi-clients --server-port=11111`
  3. В GUI: File → Connect → localhost:11111
  4. Запустить TCP-мост: `"$PVAPP/Contents/bin/pvpython" ~/stack/paraview-mcp/paraview_bridge.py`
  5. MCP сервер подключается к мосту автоматически
- **Workflow завершения:**
  1. Закрыть ParaView GUI (просто закрыть окно)
  2. Остановить pvserver: `kill $(pgrep -f pvserver)`
  3. Остановить bridge: `kill $(pgrep -f paraview_bridge)`

### LaTeX
- **MacTeX** — `pdflatex` в PATH
- Запуск: `pdflatex document.tex`
- Интеграция: расширение LaTeX Workshop в VS Code

### Julia
- **Julia** (через juliaup)
- Запуск: `julia`
- MCP сервер: `julia` (в .opencode/opencode.json проекта)
- Пакеты: LinearAlgebra, SparseArrays, Plots, DifferentialEquations, StaticArrays, Optim, JuMP, IJulia, Flux, Turing, DataFrames, CSV, ForwardDiff, SymPy, SpecialFunctions, StatsBase, Distributions, Polynomials, FFTW, IterativeSolvers

### tldraw
- **tldraw MCP** — управление canvas через MCP (30 инструментов)
- MCP сервер: `tldraw` (в .opencode/opencode.json проекта)
- Сервер: ~/stack/tldraw-mcp/ (Node.js, zero browser deps)
- Инструменты: create_geo, create_text, create_arrow, create_note, create_frame, move_shapes, group_shapes, set_camera, save_document, load_document и др.
- Экспорт: `.tldr` → PNG/SVG через `@kitschpatrol/tldraw-cli`; после обновления CLI нужно проверять совместимость схемы MCP-файлов.
- Текущий MCP надёжно создаёт/сохраняет `.tldr` и редактирует документ; live-синхронизация с уже открытым desktop canvas не гарантируется.

> [!IMPORTANT]
> Если `~/.stack-secrets.sh` не существует — стек ещё не настроен: попроси пользователя заполнить форму.

### Первый старт (сообщи пользователю, если стек ещё не настроен)
- Персональные данные (прокси, Wolfram ID, git identity) живут вне репозитория
- Если `~/.stack-secrets.sh` отсутствует: попроси пользователя заполнить
  `~/stack/first-start.txt` (шаблон: `first-start.template.txt`) и запустить
  `bash ~/stack/apply-first-start.sh`; после этого `bash ~/stack/proxy.sh test`

### Craft Apps (офисные документы, ArtCraft)
- **WordCraft / GridCraft / DeckCraft / PdfCraft / FigCraft** — Word/Excel/PowerPoint/PDF/UI-дизайн, установлены в /Applications/ (alpha-версии)
- MCP серверы: `wordcraft`, `gridcraft`, `deckcraft`, `pdfcraft`, `figcraft` (в .opencode/opencode.json проекта)
- Headless CLI: `~/stack/craft-cli/<name>-cli` — convert, run, inspect, info, commands
- **Финальные офисные деливераблы (.docx/.xlsx/.pptx/.pdf) делай через Craft Apps**, не python-скриптами
- Компиляция .tex — по-прежнему pdflatex; WordCraft только импортирует/экспортирует .tex
- Live-режим (правки в открытом окне): `/Applications/<App>.app/Contents/MacOS/<app> --control 798X`; порты: wordcraft 7981, gridcraft 7982, deckcraft 7983, pdfcraft 7984, figcraft 7985
- Установка/обновление GUI: `bash ~/stack/craft-install.sh` (в терминале пользователя); версии проверяет update-all.sh
- Скилл: `craft-office` (подробный workflow)

### Jupyter
- **JupyterLab** окружение: ~/stack/jupyter-env
- Запуск: `source ~/stack/jupyter-env/bin/activate && jupyter-lab`
- Kernel: Python 3.12 + Wolfram Language 15
- Пакеты: numpy, matplotlib, pandas, sympy, plotly, ipywidgets
- XLSX support: openpyxl, markitdown

### VS Code
- Расширения: Jupyter, Python, Julia, LaTeX Workshop, Wolfram Language
- Конфиг: ~/Library/Application Support/Code/User/settings.json

### OpenCode
- Конфиг MCP: .opencode/opencode.json проекта (генерируется gen-opencode-config.sh; глобально стек не поднимается — MCP и скиллы живут только в проектах из projects.txt)
- **Версия:** OpenCode **v2** (brew `anomalyco/tap/opencode-v2`, v1 удалён). Жертвы v2: LSP-серверов нет (поле `lsp` игнорируется), переменных `OPENCODE_DISABLE_*_SKILLS` нет. MCP-конфиг v1-формы нормализуется автоматически.
- **Диагностика кода:** через запуск линтеров/компиляторов/тестов напрямую — `bash -n` (.sh), `python` (.py), `npm run build` (.ts), `julia` (.jl), `pdflatex` (.tex). Проверяй правки компилятором до того, как заявить результат.
- Skills: ARIS research pipeline, Firecrawl, render-visual, xlsx, data-analysis, grill-me, epistemic-rigor, deep-mind, dag-hallucination-detector, и др. (60 скиллов, хранилище: ~/stack/skills-store (проектные, через skills.paths))
- ARIS работает в local-only режиме: внешние Codex/Oracle/manual-review MCP не используются и не считаются доступными.
- Для многораундовой проверки используются локальные OpenCode subagents; результат нельзя называть независимой cross-model экспертизой.
- Для исследовательских утверждений явно разделять verified, inferred и unknown; отсутствие источника не считать подтверждением.

### Визуализация и маршрутизация
- `render-visual` — polished PNG/SVG/PDF, слайды, архитектурные схемы и GIF через headless Chromium.
- tldraw MCP — редактируемые whiteboard `.tldr` документы и shapes.
- Если нужен data chart из числового набора, использовать `data-analysis`/matplotlib/plotly, а не schematic `render-visual` charts.
- Если запрос неоднозначен между tldraw и render-visual, сначала уточнить нужный результат: редактируемый canvas или финальная картинка.


## STACK.md — справка по ситуации

~/stack/STACK.md — полная документация стека. Открывай его:
- перед первой в сессии работой с инструментом (Wolfram, Manim, ParaView, tldraw, Julia, Jupyter) — раздел этого инструмента;
- когда нужны горячие клавиши, примеры кода, ссылки на документацию;
- когда задач касается визуализация или обновление, а деталей этого файла не хватает.

Целиком не читай — бери только нужный раздел инструмента.

## Конвенции

- Все Python проекты в venv (PEP 668 защищает системный Python)
- Julia — через juliaup, пакеты в глобальном окружении
- Wolfram — wolframscript для CLI, MCP для AI интеграции
- Скрипты для ParaView писать на Python (`paraview.simple`)

## Управление пакетами

### Manim (~/stack/manim-env)
```bash
source ~/stack/manim-env/bin/activate
pip list                          # список пакетов
pip install <package>             # добавить
pip install --upgrade <package>   # обновить
pip install --upgrade manim manimgl  # обновить всё
```

### Jupyter (~/stack/jupyter-env)
```bash
source ~/stack/jupyter-env/bin/activate
pip list
pip install <package>
pip install --upgrade jupyterlab
```

### Julia
```julia
julia
using Pkg
Pkg.status()          # список пакетов
Pkg.add("PackageName") # добавить
Pkg.update()          # обновить всё
```

### Wolfram
```bash
wolframscript -code 'PacletInformation[]'  # список пакетов
wolframscript -code 'PacletInstall["PackageName"]'  # добавить
wolframscript -code 'PacletInstall["Wolfram/AgentTools"]'  # обновить
```

### Проверка полноты
```bash
cd ~/stack && bash check-all.sh  # проверить что всё работает
cd ~/stack && bash update-all.sh  # обновить весь стек
```
<!-- STACK:END -->
