---
name: data-analysis
description: >
  End-to-end data analysis assistant for any structured dataset (CSV, JSON, Excel, SQL).
  Use whenever the user wants to analyze, explore, profile, clean, or model a dataset;
  build visualizations or dashboards; generate reproducible analysis code; write an
  analysis report; run data-quality checks; or generate testable research hypotheses.
  Triggers: "analyze this data/CSV", "explore this dataset", "what patterns are in X",
  "visualize / chart / plot this data", "build a dashboard", "write analysis code for X",
  "generate a report on this data", "check the data quality of X", "clean this dataset",
  "what hypotheses can we test", "EDA on X", "find correlations / outliers / segments / trends in X".
---

# Data Analysis Assistant

A structured data analysis workflow that profiles data, discovers patterns, visualizes
findings, generates reproducible code, validates quality, and writes decision-useful reports.

## Pipeline

1. **Setup** — Locate the dataset. Confirm it exists and note its size before loading.
2. **Quality** — Profile: shape, dtypes, missing values, duplicates, ranges. Surface issues before analysis.
3. **Explore** — Univariate → bivariate → multivariate. Summary stats, distributions, correlations, outliers.
4. **Visualize** — Turn key findings into charts. Save static (PNG) and interactive (HTML).
5. **Code** — Emit clean, documented, tested scripts for reproducibility.
6. **Report** — Synthesize into audience-appropriate report (executive / technical / BI).
7. **Hypothesize** — Convert patterns into testable hypotheses with experimental designs.

## Request routing

- "analyze / explore / EDA / find patterns" → **Explore** (run Quality first)
- "visualize / chart / plot / dashboard" → **Visualize** (run Explore first)
- "generate / write code / script" → **Code**
- "report / summary / writeup" → **Report**
- "quality / clean / validate" → **Quality**
- "hypothesis / experiment" → **Hypothesize**
- "analyze everything / full analysis" → full pipeline

## Project layout

```
data_storage/        # input datasets
visualizations/      # generated charts
generated_code/      # reproducible scripts
analysis_reports/    # written reports
quality_reports/     # data-quality assessments
hypothesis_reports/  # hypotheses + experiments
```

## Tools

- **Python**: pandas, matplotlib, seaborn, plotly, scipy, sklearn
- **Polars**: preferred for large datasets (faster, lower memory)
- **SQL**: for database sources

## Rules

- Validate before concluding. Double-check statistics, verify test assumptions.
- Never fabricate. If a value isn't in the data, say so.
- Document transformations. Every cleaning step must be recorded.
- Charts must do work. Maximize data-ink ratio, use colorblind-safe palettes.
- Lead with findings that matter; relegate exhaustive stats to appendix.
