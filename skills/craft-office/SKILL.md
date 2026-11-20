---
name: craft-office
description: "Work with office documents (.docx, .xlsx, .pptx, .pdf) through the Craft Apps installed on this machine: WordCraft (Word), GridCraft (Excel), DeckCraft (PowerPoint), PdfCraft (PDF). Use when the user mentions Word/Excel/PowerPoint/PDF files, needs a .docx/.xlsx/.pptx/.pdf created, read, edited, converted, formatted, or when research deliverables must be produced in office formats (reports, papers, decks, merged documents). Prefer these tools over raw python libraries for the FINAL document deliverable."
---

# Craft Apps — офисные документы через ArtCraft

Четыре нативных macOS-приложения ArtCraft, установленных в `/Applications/`, с headless-CLI и MCP-серверами. CLI-бинарники живут в `~/stack/craft-cli/`.

| MCP-сервер | Приложение | Форматы | CLI |
|-----------|-----------|---------|-----|
| `wordcraft` | WordCraft | .docx (нативно), .odt/.rtf/.html/.md/.tex/.txt, PDF-экспорт | `~/stack/craft-cli/wordcraft-cli` |
| `gridcraft` | GridCraft | .xlsx (нативно), .csv | `~/stack/craft-cli/gridcraft-cli` |
| `deckcraft` | DeckCraft | .pptx (нативно), .potx, экспорт PDF/PNG/GIF | `~/stack/craft-cli/deckcraft-cli` |
| `pdfcraft` | PdfCraft | .pdf — объединение, разделение, защита, комментарии | `~/stack/craft-cli/pdfcraft-cli` |

## Приоритет инструментов

- **Финальный офисный файл (.docx/.xlsx/.pptx/.pdf) для человека** — используй Craft Apps (MCP или CLI), не python-скрипты: нативная совместимость форматов, PivotTables, трекинг правок, цитирования (APA/MLA/Chicago/IEEE через WordCraft, есть Zotero-интеграция).
- **Программный анализ данных** (EDA, графики из кода) — python/pandas как раньше; GridCraft — для табличного деливерабла.
- **Компиляция .tex статей** — по-прежнему `pdflatex`; WordCraft лишь импортирует/экспортирует .tex, не компилирует.
- **Черновое чтение файлов** — `markitdown` по-прежнему доступен для быстрого извлечения текста.

## Подключение (OpenCode v2)

MCP-серверы уже прописаны в `.opencode/opencode.json` всех проектов стека (`mcp.wordcraft` и т.д.). Если не видишь их — запусти `bash ~/stack/sync-agents.sh` и перезапусти OpenCode.

## CLI без MCP (скриптами)

```bash
# Конвертация (docx→pdf и т.д.)
~/stack/craft-cli/wordcraft-cli convert report.docx report.pdf
~/stack/craft-cli/deckcraft-cli convert deck.pptx deck.pdf

# Структура и текст
~/stack/craft-cli/wordcraft-cli inspect report.docx        # структура, JSON
~/stack/craft-cli/wordcraft-cli info report.docx           # страницы/слова, JSON
~/stack/craft-cli/gridcraft-cli inspect book.xlsx          # листы/диапазоны

# Применить команды без окна
~/stack/craft-cli/wordcraft-cli run --file report.docx \
  --cmd 'select.text={"text":"X"}' --cmd format.bold --save out.docx

# Список всех команд приложения
~/stack/craft-cli/wordcraft-cli commands            # (добавь --json для скриптов)
```

## Live-режим (параллельная работа человека и агента)

По умолчанию агент работает headless (в фоне, окно не открывается). Если пользователь хочет видеть правки в реальном времени в открытом окне:

```bash
open -a WordCraft
/Applications/WordCraft.app/Contents/MacOS/wordcraft --control 7981
# затем MCP-команда агента: ~/stack/craft-cli/wordcraft-cli mcp --connect 127.0.0.1:7981
```

Порты не пересекаются: wordcraft 7981, gridcraft 7982, deckcraft 7983, pdfcraft 7984.

## Осторожно

- Приложения в статусе **alpha** (WordCraft/DeckCraft v0.18, GridCraft v0.19, PdfCraft v0.21): сложные документы из MS Office могут отображаться не идеально. Для важных файлов проси пользователя проверить рендер или хранить копию.
- Track changes и комментарии агента помечай автором: MCP-конфиг можно дополнить аргументом `--author "AI agent"`.
- Не редактируй документы, открытые пользователем в окне, без его явной просьбы.
