---
name: xlsx
description: "Use this skill any time a spreadsheet file is the primary input or output. This means any task where the user wants to: open, read, edit, or fix an existing .xlsx, .xlsm, .xltx, .csv, or .tsv file (e.g., adding columns, computing formulas, formatting, charting, cleaning messy data); create a new spreadsheet from scratch or from other data sources; or convert between tabular file formats. Trigger especially when the user references a spreadsheet file by name or path — even casually (like 'the xlsx in my downloads') — and wants something done to it or produced from it. Also trigger for cleaning or restructuring messy tabular data files (malformed rows, misplaced headers, junk data) into proper spreadsheets. The deliverable must be a spreadsheet file. Do NOT trigger when the primary deliverable is a Word document, HTML report, standalone Python script, database pipeline, or Google Sheets API integration, even if tabular data is involved."
---

# XLSX creation, editing, and analysis

| Task | Approach |
|---|---|
| **Create** or **edit** with formulas/formatting | `openpyxl` — see gotchas below |
| **Bulk data** in or out | `pandas` (`read_excel`, `to_excel`) |
| **Quick look** at a sheet | `markitdown file.xlsx` — `## SheetName` per sheet |
| **Read** a model (formulas *and* values) | two `load_workbook` passes — see gotchas |

## Requirements for every output

- **Professional font** (Arial, Times New Roman) throughout, unless the user says otherwise.
- **Zero formula errors.** Never ship while recalc reports errors.
- **Use formulas, never hardcoded results.** Write `=SUM(B2:B9)`, not the Python-computed total.
- **Follow the user's spec literally.** Exact tab names, exact column headers.
- **Document every assumption and hardcoded number** in a cell comment or adjacent cell.

## Recalculate (mandatory whenever the file contains formulas)

```bash
python scripts/recalc.py output.xlsx [timeout_seconds]
```

## openpyxl gotchas

- **Reading a model takes two loads.** `data_only=True` yields cached values; default yields formula strings.
- **`data_only=True` is destructive if you save.** Formulas are permanently replaced with literals.
- **Merged cells: write the top-left anchor only.**
- **`.xlsm` loses its macros unless you pass `keep_vba=True`.**
- **Sheet names with spaces must be quoted** in cross-sheet references.

## Financial models

- **Color:** blue text for hardcoded inputs, black for formulas, green for cross-sheet links, yellow fill for key assumptions.
- **Numbers:** currency `$#,##0`, zeros as `-`, percentages as fractions (0.15 = 15.0%).
- **Structure:** every assumption in its own labeled cell, formulas consistent across projection periods.

## Dependencies

`openpyxl`, `pandas`, `markitdown` — preinstalled, import directly.
