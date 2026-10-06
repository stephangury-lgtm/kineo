# Content enrichment batch 15 — 2026-10-06

## Kineo ES
- Added 6 source-validated `matching` exercises.
- Topics: Anatomía I, Anatomía II, ayudas técnicas y marcha, bíceps/tríceps, biofísica aplicada, fundamentos de biofísica/biomecánica.
- Goal: increase active recall and bilingual association without adding redundant MCQs.

## Kineo FR
- Enriched 5 source-backed K2 lessons:
  - Articulations tibio-fibulaires et subtalaire
  - Loge antérieure de la jambe
  - Chaînes cinétiques et principes de progression
  - Rotateurs du genou
  - Modes de contraction et courses musculaires
- Final lesson lengths in this batch: 1234–1310 characters.

## IFSI 2026
- Added 6 source-validated `matching` exercises, one per semester S1–S6.
- Topics: douleur, sécurité numérique/identitovigilance, administration médicamenteuse, lecture critique, analyse de pratique, autonomie professionnelle.

## QA
- Batch 15 matching: 12 added, 0 bad status, 0 missing source.
- Matching total across multi-curriculum base: 30 published, 0 malformed, 0 missing source.
- IFSI matching coverage after batch: 3 per semester S1–S6.
- Kineo FR updated lessons all include the targeted enrichment section.

## UX
- Matching answer choices are now shuffled deterministically per question in `CurriculumTopicPage.tsx`, avoiding positional hints while keeping the order stable during a session.
