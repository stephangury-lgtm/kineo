# Kineo ES2 — enrichment batch 2 — 2026-10-06

## Scope
Second sourced enrichment pass for `kineo-es` level `ES2` only. ES1/ES3/ES4 were not modified.

## Lessons
All 20 published ES2 lessons were expanded without changing their UVic source set.

Post-update lesson length:
- minimum: 967 characters
- maximum: 1084 characters
- average: 1021 characters

The expansion focuses on practical reasoning, functional interpretation, professional safety and terminology already present in the sourced lesson scope.

## Questions
Two additional sourced exercises were added to every ES2 topic:
- display order 7: Spanish clinical/stage vocabulary (`fill_blank`)
- display order 8: short applied reasoning case (`clinical_case`)

Current ES2 published question bank:
- 40 `mcq`
- 20 `matching`
- 60 `fill_blank`
- 40 `clinical_case`
- total: 160 published questions
- exactly 8 published questions per topic

## QA
- 10 active ES2 units
- 20 active topics
- 20 published lessons
- 160 published questions
- 0 missing lesson sources
- 0 missing question source labels
- 0 free-answer questions without accepted answers
- existing MCQ/matching QA remains clean

## Sources
Existing UVic-UCC 2026-2027 course pages already attached to each ES2 lesson were preserved, including Bioestadística y Sistemas de la Información, Fisiopatología, Fisioterapia del Sistema Musculo-esquelético I/II, Valoración y Diagnóstico II, Bioética, Salud Pública, Farmacología, Fisioterapia en Neurología I and Prácticum I.

## UI availability
`src/curriculum/programs.ts` already exposes Kineo España levels ES1, ES2, ES3 and ES4, so ES2 is selectable without an additional front-end level configuration change.
