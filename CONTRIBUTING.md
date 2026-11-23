# Contributing

Спасибо, что хочешь улучшить стек! Предлагай **всё, что захочешь** — баги, идеи, кастомизацию, вопросы. Владелец и ИИ-ассистент рассмотрят каждое предложение и помогут довести до результата: не знаешь bash — опиши словами, сделаем вместе.

> Про workflow: `workflow.txt` в репо — это **личный** git-флоу автора. Контрибьютору он не нужен — достаточно fork → ветка → PR, любым привычным тебе способом.
>
> Code of Conduct не заведён (для личного репо не требуется); GitHub при желании подключает стандартный одним кликом в настройках.

Спасибо, что хочешь улучшить стек! Предлагай **всё, что захочешь** — баги, идеи, кастомизацию, вопросы. Владелец и ИИ-ассистент рассмотрят каждое предложение и помогут довести до результата: не знаешь bash — опиши словами, сделаем вместе.

## Как предложить (любым удобным способом)

- **Issue** — просто напиши: что не работает или чего не хватает. Этого достаточно.
- **PR** (если комфортно с git): fork → ветка `fix/...` → правки → push → Pull Request. Агент и владелец посмотрят, подскажут, доведут.
- Не уверен, баг это или вопрос — пиши issue, разберёмся.

## Как мы проверяем предложения

Ты ничего не обязан проверять сам — но если удобно, вот что мы делаем с любым изменением:

| Проверка | Команда |
|---|---|
| Синтаксис скриптов | `bash -n <скрипт>.sh` |
| Ничего не сломалось | `bash ~/stack/check-all.sh` |
| Документация согласована | счётчики (CLI/MCP/скиллы/шаги) совпадают в README, AGENTS.md, STACK.md |
| Идемпотентность | повторный запуск скрипта безопасен |

## Что важно знать

- Стек **личный и авторский**, но приветствует любые предложения: от опечатки до нового инструмента
- Секреты никогда не попадают в репозиторий (шаблоны — да, значения — нет)
- Персональные пути — через `{env:HOME}`; личные данные — в `~/.stack-secrets.sh` и `.zshrc`
- Подробный git-workflow — в `workflow.txt`


---

## 🌍 Languages (in-place)

<details>
<summary><b>🇬🇧 English</b></summary>

**🇷🇺 Русский** · English (here)

Thanks for wanting to improve the stack! Propose **anything** — bugs, ideas, customization, questions. The owner and the AI assistant will review every proposal and help land it: if you don't write bash, just describe the problem in words.

- **Issue** — simply write what doesn't work or what's missing. That's enough.
- **PR** (if comfortable with git): fork → branch `fix/...` → changes → push → Pull Request.
- Not sure whether it's a bug or a question — open an issue.

What we check for every change (we do it for you): script syntax `bash -n`, `check-all.sh`, docs counters consistent, idempotency. Secrets never enter the repo (templates yes, values no); personal data lives in `~/.stack-secrets.sh` and `.zshrc`.
</details>

<details>
<summary><b>🇯🇵 日本語</b></summary>

スタック改善への貢献を歓迎します。**何でも提案してください** — バグ、アイデア、カスタマイズ、質問。オーナーとAIアシスタントがすべて確認し、完成まで支援します。

- **Issue** で報告するだけで十分です。PR も歓迎(fork → `fix/...` → push → Pull Request)。
- 変更時のチェック(私たちが実施します): `bash -n`、`check-all.sh`、ドキュメントの整合性、冪等性。
- 秘密情報はリポジトリに入れません(テンプレートのみ)。
</details>

<details>
<summary><b>🇨🇳 中文</b></summary>

欢迎为技术栈做贡献!**什么都可以提**——缺陷、想法、自定义、问题。所有者和 AI 助理会审阅每个提案并帮助落地。

- **Issue** 描述即可;也欢迎 PR(fork → `fix/...` → push → Pull Request)。
- 每次变更的检查(由我们完成): `bash -n`、`check-all.sh`、文档计数一致、幂等性。
- 秘密信息绝不进入仓库(只允许模板)。
</details>

<details>
<summary><b>🇰🇷 한국어</b></summary>

스택 개선에 기여해 주셔서 감사합니다! **무엇이든 제안하세요** — 버그, 아이디어, 커스터마이징, 질문. 소유자와 AI 어시스턴트가 모든 제안을 검토하고 완성을 돕습니다.

- **Issue** 로 제안하면 충분합니다. PR 도 환영(fork → `fix/...` → push → Pull Request).
- 변경 시 점검(저희가 수행): `bash -n`, `check-all.sh`, 문서 일관성, 멱등성.
- 비밀 정보는 저장소에 넣지 않습니다(템플릿만).
</details>

<details>
<summary><b>🇩🇪 Deutsch</b></summary>

Danke für das Interesse, den Stack zu verbessern! **Schlage alles vor** — Bugs, Ideen, Anpassungen, Fragen. Owner und KI-Assistent prüfen jeden Vorschlag und helfen bei der Umsetzung.

- **Issue** genügt; PRs sind willkommen (fork → `fix/...` → push → Pull Request).
- Prüfung jeder Änderung (übernehmen wir): `bash -n`, `check-all.sh`, konsistente Doku-Zähler, Idempotenz.
- Secrets kommen nie ins Repo (nur Templates).
</details>

<details>
<summary><b>🇪🇸 Español</b></summary>

¡Gracias por querer mejorar el stack! **Propón cualquier cosa** — bugs, ideas, personalización, preguntas. El propietario y el asistente de IA revisarán cada propuesta y ayudarán a llevarla a cabo.

- **Issue** es suficiente; también bienvenidos PR (fork → `fix/...` → push → Pull Request).
- Verificación de cada cambio (la hacemos nosotros): `bash -n`, `check-all.sh`, contadores de docs consistentes, idempotencia.
- Los secretos nunca entran al repositorio (solo plantillas).
</details>

<details>
<summary><b>🇫🇷 Français</b></summary>

Merci de vouloir améliorer le stack ! **Proposez tout ce que vous voulez** — bugs, idées, personnalisations, questions. Le propriétaire et l'assistant IA examineront chaque proposition et aideront à la concrétiser.

- **Issue** suffit ; les PR sont bienvenues (fork → `fix/...` → push → Pull Request).
- Vérification de chaque changement (faite par nous) : `bash -n`, `check-all.sh`, compteurs de docs cohérents, idempotence.
- Les secrets n'entrent jamais dans le repo (modèles uniquement).
</details>

<details>
<summary><b>🇧🇷 Português</b></summary>

Obrigado por querer melhorar o stack! **Proponha qualquer coisa** — bugs, ideias, personalização, perguntas. O proprietário e o assistente de IA analisarão cada proposta e ajudarão a concretizá-la.

- **Issue** é suficiente; PRs também são bem-vindos (fork → `fix/...` → push → Pull Request).
- Verificação de cada mudança (feita por nós): `bash -n`, `check-all.sh`, contadores de docs consistentes, idempotência.
- Segredos nunca entram no repositório (apenas templates).
</details>
