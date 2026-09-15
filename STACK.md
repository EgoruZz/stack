# Полная документация стека

## 1. Wolfram Language / Engine

### Как я использую
- `wolframscript -code '...'` — выполняю код напрямую
- MCP сервер `Wolfram` в OpenCode — автоматически вызываю когда нужен расчёт
- Jupyter kernel `wolframlanguage15` — пишу ноутбуки

### Как ты используешь
- **CLI:** `wolframscript` → вводишь код → `Ctrl+D` для выхода
- **Jupyter:** `source ~/stack/jupyter-env/bin/activate && jupyter-lab` → выбрать kernel Wolfram Language 15
- **VS Code:** `Cmd+Shift+P` → New Jupyter Notebook → выбрать kernel Wolfram
- **GUI:** открыть `Wolfram Engine.app` из Applications

### Как вместе
- Ты пишешь "построй график sin(x)" → я пишу код → ты запускаешь
- Или я выполняю через MCP → результат сразу в чате

### Визуализация
- Jupyter: прямо в ячейке (интерактивная)
- wolframscript: `wolframscript -code 'Export["plot.png", Plot[Sin[x],{x,0,2Pi}]]'`
- Просмотр: `open plot.png`

### Горячие клавиши (Jupyter)
- `Shift+Enter` — выполнить ячейку
- `Esc` — выйти из ячейки
- `A` — добавить ячейку сверху
- `B` — добавить ячейку снизу
- `DD` — удалить ячейку
- `M` — markdown ячейка
- `Y` — code ячейка

### Важные ссылки
- Документация: https://reference.wolfram.com/language/
- Wolfram|Alpha: https://www.wolframalpha.com
- Function Repository: https://resources.wolframcloud.com/FunctionRepository
- Продление лицензии: https://www.wolfram.com/engine/

### Обновление
```bash
# Wolfram Engine
brew upgrade --cask wolfram-engine

# Пакеты Wolfram
wolframscript -code 'PacletUpdate["Wolfram/AgentTools"]'
```

---

## 2. Manim

### Версии
- **Manim** (community edition) — основная, больше возможностей, проще в использовании
- **ManimGL** (3Blue1Brown) — OpenGL, оригинальная версия

### Как я использую
- Пишу `.py` файлы с кодом анимации
- Ты запускаешь: `manim script.py SceneName` (community) или `manimgl script.py SceneName` (GL)

### Как ты используешь
```bash
# Активация окружения
source ~/stack/manim-env/bin/activate
# Или
manim-activate

# Community edition (рекомендуется)
manim my_animation.py CircleToSquare

# С превью (откроет окно)
manim -p my_animation.py CircleToSquare

# Низкое качество (быстро)
manim -ql my_animation.py CircleToSquare

# Высокое качество
manim -qh my_animation.py CircleToSquare

# ManimGL (OpenGL версия)
manimgl my_animation.py CircleToSquare
```

### Как вместе
- Ты: "сделай анимацию вращения куба"
- Я: пишу код в файл `cube_rotation.py`
- Ты: `manim cube_rotation.py CubeRotation`
- Результат: видео в `media/videos/`

### Визуализация
- Плеер открывается автоматически после рендера (с флагом -p)
- Файлы: `media/videos/<имя_файла>/1080p60/<SceneName>.mp4`
- Превью: `open media/videos/.../*.mp4`

### Структура кода (community)
```python
from manim import *

class MyScene(Scene):
    def construct(self):
        circle = Circle()
        self.play(Create(circle))
        self.wait(2)
```

### Структура кода (ManimGL)
```python
from manimlib import *

class MyScene(Scene):
    def construct(self):
        circle = Circle()
        self.play(ShowCreation(circle))
        self.wait(2)
```

### Горячие клавиши (ManimGL плеер)
- `Space` — пауза/продолжить
- `R` — перемотка назад
- `F` — полноэкранный режим
- `Q` — выход
- `→` — перемотка вперёд
- `←` — перемотка назад

### Важные ссылки
- Документация (community): https://docs.manim.community/
- GitHub (community): https://github.com/ManimCommunity/manim
- GitHub (3b1b): https://github.com/3b1b/manim
- Примеры: https://github.com/ManimCommunity/manim/tree/main/examples

### Обновление
```bash
source ~/stack/manim-env/bin/activate
pip install --upgrade manim manimgl
```

---

## 3. ParaView

### Как я использую
- Пишу скрипты на Python (`paraview.simple`)
- MCP сервер `ParaView` — управляю пайплайном через MCP (load_data, create_source, create_isosurface, create_slice, color_by и др.)

### Как ты используешь
```bash
# Определи путь к ParaView
PVAPP=$(ls -d /Applications/ParaView-*.app 2>/dev/null | head -1)

# GUI
open "$PVAPP"

# Скрипт через pvpython
"$PVAPP/Contents/bin/pvpython" my_script.py

# Или добавь в PATH
export PATH="$PVAPP/Contents/bin:$PATH"
pvpython my_script.py
```

### MCP workflow (рекомендуемый)
Я управляю пайплайном через MCP, ты контролируешь визуал в GUI.

**Запуск:**
```bash
# 1. Ты: открой ParaView GUI
PVAPP=$(ls -d /Applications/ParaView-*.app 2>/dev/null | head -1)
open "$PVAPP"

# 2. Ты (или я): запусти pvserver в отдельном терминале
"$PVAPP/Contents/bin/pvserver" --multi-clients --server-port=11111 &

# 3. Ты: в GUI → File → Connect → localhost:11111

# 4. Ты (или я): запусти TCP-мост (нужен pvpython)
"$PVAPP/Contents/bin/pvpython" ~/stack/paraview-mcp/paraview_bridge.py &

# 5. MCP сервер (ParaView) подключается к мосту автоматически при вызове инструментов
```

**Завершение:**
```bash
# 1. Ты: закрой GUI (просто закрой окно)
# 2. Остановить серверы:
kill $(pgrep -f pvserver) $(pgrep -f paraview_bridge)
```

**Скриншоты:** MCP скриншоты не доступны. Договорённость:
- Нажимай `P` в GUI для сохранения скриншота
- Сохраняй в `~/stack/paraview-mcp/screenshots/` с понятным именем
- Говори агенту путь к файлу — он сможет его прочитать и описать

### Как вместе
- Ты: "загрузи VTK файл и покажи распределение температуры"
- Я: через MCP загружаю данные, создаю фильтры, раскрашиваю
- Ты: видишь результат в GUI, делаешь скриншот через `P`

### Визуализация
- GUI: полноценное 3D окно
- Скриншоты: `P` в GUI
- Скрипты: `SaveScreenshot("output.png", view)`

### Пример скрипта (без MCP)
```python
from paraview.simple import *

reader = XMLUnstructuredGridReader(FileName='data.vtu')
display = Show(reader)
ColorBy(display, ('POINTS', 'Temperature'))
Render()
SaveScreenshot('output.png', GetActiveView())
```

### Горячие клавиши (GUI)
- `Ctrl+R` — рендер
- `Ctrl+S` — сохранить
- `F` — фокус на объект
- `P` — скриншот
- `Ctrl+Z` — отмена
- `Space` — rotate view

### Важные ссылки
- Документация: https://docs.paraview.org/
- Python API: https://docs.paraview.org/en/latest/Python/
- Download: https://www.paraview.org/download/

### Обновление
```bash
# ParaView обновляется через скачивание новой версии с сайта:
# https://www.paraview.org/download/
# После установки обнови путь в конфиге, если версия изменилась
```

---

## 4. Julia

### Как я использую
- `~/.juliaup/bin/julialauncher -e '...'` — выполняю код
- MCP сервер `julia` в OpenCode — persistent сессии

### Как ты используешь
```bash
# Запуск REPL
julia

# Выполнение скрипта
julia my_script.jl

# Выполнение кода
julia -e 'using LinearAlgebra; println(det([1 2; 3 4]))'

# Установка пакетов (в REPL)
using Pkg
Pkg.add("Plots")
```

### Как вместе
- Ты: "реши систему уравнений"
- Я: пишу код или выполняю через MCP
- Результат: прямо в чате или в файле

### Визуализация
```julia
using Plots
plot(sin, 0, 2π)
savefig("plot.png")
```
- Jupyter: прямо в ячейке
- Отдельное окно: `plot()` открывает GUI

### Горячие клавиши (REPL)
- `Ctrl+C` — прервать
- `Ctrl+D` — выход
- `;` — shell mode
- `?` — help mode
- `Ctrl+R` — поиск истории
- `Tab` — автодополнение

### Важные ссылки
- Документация: https://docs.julialang.org/
- Пакеты: https://juliahub.com/
- Plots: https://docs.juliaplots.org/
- DifferentialEquations: https://diffeq.sciml.ai/

### Обновление
```bash
juliaup update
```

---

## 5. JupyterLab

### Как я использую
- Пишу `.ipynb` ноутбуки
- Ты запускаешь и смотришь результат

### Как ты используешь
```bash
# Запуск
source ~/stack/jupyter-env/bin/activate && jupyter-lab

# Или через alias
jupyter-jlab

# Остановка: Ctrl+C в терминале
```

### Как вместе
- Я пишу ноутбук → ты открываешь → правишь → вместе дорабатываем
- Или я выполняю ячейки через MCP

### Визуализация
- Графики прямо в ячейках (matplotlib, plotly)
- 3D: `ipyvolume`, `plotly`
- Интерактивные виджеты: `ipywidgets`
- Анимации: `matplotlib.animation`

### Горячие клавиши (JupyterLab)
- `Shift+Enter` — выполнить ячейку
- `Ctrl+Enter` — выполнить и остаться
- `Esc` — command mode
- `A` — ячейка сверху
- `B` — ячейка снизу
- `DD` — удалить
- `M` — markdown
- `Y` — code
- `Ctrl+Shift+-` — разбить ячейку
- `Shift+M` — объединить ячейки

### Важные ссылки
- Документация: https://jupyterlab.readthedocs.io/
- shortcuts: https://jupyterlab.readthedocs.io/en/stable/user/shortcuts.html

### Обновление
```bash
source ~/stack/jupyter-env/bin/activate
pip install --upgrade jupyterlab
```

---

## 6. LaTeX (MacTeX)

### Как я использую
- Пишу `.tex` файлы
- Ты компилируешь: `pdflatex document.tex`

### Как ты используешь
```bash
# Компиляция
pdflatex document.tex

# С библиографией
pdflatex document.tex
bibtex document
pdflatex document.tex
pdflatex document.tex

# Или через latexmk (автоматически)
latexmk document.tex
```

### Как вместе
- Ты: "напиши отчёт по физике"
- Я: пишу `.tex` файл
- Ты: `pdflatex report.tex && open report.pdf`

### Визуализация
- PDF viewer: `open report.pdf`
- VS Code: расширение LaTeX Workshop показывает превью

### Горячие клавиши (LaTeX Workshop)
- `Cmd+L Cmd+C` — компиляция
- `Cmd+L Cmd+V` — превью PDF
- `Cmd+L Cmd+R` — build & view

### Важные ссылки
- Overleaf (онлайн): https://www.overleaf.com/
- Документация: https://www.latex-project.org/help/documentation/
- Wikibook: https://en.wikibooks.org/wiki/LaTeX

### Обновление
```bash
brew upgrade --cask mactex
```

---

## 7. VS Code

### Расширения (установлены)
| Расширение | Назначение |
|---|---|
| Jupyter | Ноутбуки прямо в VS Code |
| Python | Автодополнение, отладка |
| Julia | Julia language support |
| LaTeX Workshop | Компиляция LaTeX |
| Wolfram Language | Подсветка, MCP |

### Как использовать
1. Открыть папку проекта: `code ~/projects/my-project`
2. `Cmd+Shift+P` → выбрать действие
3. `Cmd+P` → быстрый переход к файлу
4. `Cmd+Shift+F` — поиск по всем файлам
5. `` Cmd+` `` — терминал

### Горячие клавиши (VS Code)
- `Cmd+P` — быстрый переход к файлу
- `Cmd+Shift+P` — команда
- `Cmd+K Cmd+S` — горячие клавиши
- `` Cmd+` `` — терминал
- `Cmd+Shift+F` — поиск
- `Cmd+F` — поиск в файле
- `Ctrl+G` — перейти к строке
- `Cmd+D` — следующее совпадение
- `Alt+↑/↓` — переместить строку
- `Shift+Alt+↑/↓` — дублировать строку
- `Cmd+/` — комментарий
- `Cmd+Shift+K` — удалить строку

---

## 8. OpenCode (AI ассистент)

### MCP серверы (настроены)
| Сервер | Статус | Функция |
|---|---|---|
| Wolfram | ✅ | Выполнение Wolfram Language |
| Julia | ✅ | Persistent Julia сессии |
| Manim | ✅ | Генерация анимаций (headless) |
| ParaView | ✅ | Визуализация данных (через TCP-мост) |
| tldraw | ✅ | Управление canvas, диаграммы (30 инструментов) |

### tldraw MCP — инструменты
| Инструмент | Описание |
|------------|----------|
| `tldraw_create_geo` | Геометрические shapes (rectangle, ellipse, diamond, star...) |
| `tldraw_create_text` | Текстовые labels |
| `tldraw_create_arrow` | Стрелки с привязками к shapes |
| `tldraw_create_note` | Sticky notes |
| `tldraw_create_frame` | Frames для группировки |
| `tldraw_move_shapes` | Перемещение shapes |
| `tldraw_group_shapes` | Группировка shapes |
| `tldraw_set_camera` | Позиция и зум камеры |

MCP работает с in-memory документом и `.tldr` файлами. Это не live-контроллер
уже открытого desktop canvas. Экспорт через `tldraw` CLI требует совместимой
версии схемы; текущий стек сохраняет `.tldr`, но PNG/SVG export после генерации
нужно проверять отдельно.

### ParaView MCP — workflow
```bash
# === ЗАПУСК ===
# 1. Ты: открой ParaView GUI
PVAPP=$(ls -d /Applications/ParaView-*.app 2>/dev/null | head -1)
open "$PVAPP"

# 2. Ты (или я): запусти pvserver в отдельном терминале
nohup "$PVAPP/Contents/bin/pvserver" --multi-clients --server-port=11111 > /tmp/pvserver.log 2>&1 &

# 3. Ты: File → Connect → localhost:11111

# 4. Ты (или я): запусти TCP-мост (нужен pvpython)
"$PVAPP/Contents/bin/pvpython" ~/stack/paraview-mcp/paraview_bridge.py &

# 5. MCP сервер (ParaView) подключается к мосту автоматически при вызове инструментов

# === ЗАВЕРШЕНИЕ ===
# 1. Ты: закрой GUI (просто закрой окно)
# 2. Остановить серверы:
kill $(pgrep -f pvserver) $(pgrep -f paraview_bridge)
```

### ParaView MCP — скриншоты
MCP скриншоты не доступны. Договорённость:
- Нажимай `P` в GUI для сохранения скриншота
- Сохраняй в `~/stack/paraview-mcp/screenshots/` с понятным именем
- Говори агенту путь к файлу — он сможет его прочитать и описать

### Manim MCP — как работает
- MCP сервер использует `manim` (community edition) для headless рендера
- Анимация рендерится в файл без открытия окна
- Результат: `.mp4` или `.png` в папке `media/`
- Temp-директории: auto-cleaned через 1 час; также доступен ручной `cleanup_manim_temp_dir`
- ManimGL остаётся отдельным интерактивным CLI (`manimgl`) и не используется этим MCP сервером

### Как использовать
- Пиши мне что нужно → я выполняю через MCP или пишу скрипты
- `AGENTS.md` в проекте → я знаю контекст

### Skills (установлены)
- `render-visual` — polished PNG/SVG/PDF, слайды, схемы и GIF
- `tldraw-skill` — редактируемые `.tldr` whiteboard-диаграммы
- `xlsx` — Excel/CSV/TSV с формулами и проверкой
- `data-analysis` — EDA, визуализация данных, отчёты и гипотезы
- `grill-me` — проверка планов и скрытых допущений
- `deep-mind` + `epistemic-rigor` — критическое мышление и anti-sycophancy
- `dag-hallucination-detector` — проверка цитат, URL, статистики и противоречий
- `aris-research-pipeline` — research pipeline в local-only режиме
- `firecrawl-*` — live web research, scraping и workflow deliverables
- Полный список: `ls ~/.config/opencode/skills/` (50+ скиллов)

### Ограничения research pipeline
- Codex CLI/MCP намеренно не установлен: он не нужен для обычной работы и может требовать отдельную оплату/авторизацию.
- ARIS использует локальные OpenCode subagents для review. Это многораундовая проверка, но не независимая cross-model экспертиза.
- Если нужен именно внешний независимый reviewer, это отдельная опциональная настройка, а не часть текущего стека.

### Проверка визуальных зависимостей
```bash
# render-visual использует Chromium из Playwright
CHROME_PATH="$HOME/Library/Caches/ms-playwright/chromium_headless_shell-1234/chrome-headless-shell-mac-arm64/chrome-headless-shell" \
  node ~/.config/opencode/skills/render-visual/scripts/doctor.mjs

# tldraw CLI
```

---

## Общие команды

### Обновить всё (одной командой)
```bash
cd ~/stack && bash update-all.sh
```

### Или вручную
```bash
# Homebrew
brew update && brew upgrade

# Python пакеты
source ~/stack/manim-env/bin/activate && pip install --upgrade manim manimgl
source ~/stack/jupyter-env/bin/activate && pip install --upgrade jupyterlab

# Julia
juliaup update

# Wolfram
wolframscript -code 'PacletUpdate[]'
```

### Проверить что всё работает
```bash
cd ~/stack && bash check-all.sh
```

### Или вручную
```bash
echo "=== Wolfram ===" && wolframscript -version
echo "=== ParaView ===" && "$(ls -d /Applications/ParaView-*.app 2>/dev/null | head -1)/Contents/bin/pvpython" --version 2>/dev/null || echo "не найден"
echo "=== Julia ===" && julia --version
echo "=== LaTeX ===" && pdflatex --version | head -1
echo "=== Manim ===" && source ~/stack/manim-env/bin/activate && python3 -c "import manim; print('Manim', manim.__version__)"
echo "=== ManimGL ===" && source ~/stack/manim-env/bin/activate && python3 -c "import manimlib; print('OK')"
echo "=== Jupyter ===" && source ~/stack/jupyter-env/bin/activate && jupyter --version | head -1
```

---

## 9. Управление пакетами

### Структура проектов

```
~/
├── stack/              # Инструменты (не трогаем)
└── projects/           # Твои проекты
    ├── wolfram/
    ├── manim/
    ├── julia/
    ├── paraview/
    └── latex/
```

### Добавление пакетов

#### Python (Manim / Jupyter)
```bash
# Активировать окружение
source ~/stack/manim-env/bin/activate  # для Manim
source ~/stack/jupyter-env/bin/activate  # для Jupyter

# Установить пакет
pip install numpy
pip install pandas matplotlib seaborn

# Установить из requirements.txt
pip install -r requirements.txt
```

#### Julia
```bash
julia
using Pkg
Pkg.add("PackageName")
Pkg.add(["Package1", "Package2"])  # несколько сразу
```

#### Wolfram
```bash
wolframscript -code 'PacletInstall["PackageName"]'
```

### Обновление пакетов

```bash
# Всё сразу
cd ~/stack && bash update-all.sh

# Или по отдельности
source ~/stack/manim-env/bin/activate && pip install --upgrade manim manimgl
source ~/stack/jupyter-env/bin/activate && pip install --upgrade jupyterlab numpy matplotlib
juliaup update
wolframscript -code 'PacletUpdate[]'
```

### Просмотр установленных пакетов

```bash
# Python
source ~/stack/manim-env/bin/activate && pip list
source ~/stack/jupyter-env/bin/activate && pip list

# Julia
julia -e 'using Pkg; Pkg.status()'

# Wolfram
wolframscript -code 'PacletInformation[]'
```

### Удаление пакетов

```bash
pip uninstall package_name
# Julia:
julia -e 'using Pkg; Pkg.rm("PackageName")'
```

### Проверка зависимостей

```bash
# Python - проверить что всё импортируется
source ~/stack/manim-env/bin/activate && python3 -c "import manim; import numpy; import scipy; print('OK')"

# Julia
julia -e 'using Pkg; Pkg.test("PackageName")'
```
