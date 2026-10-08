# TYPECHECK.md — GATE T

Reel: `claude-liam-walker-ninja-firefighter-joe-gamedev`  |  Checked: 2026-10-07T22:11  |  Overall: **FAIL**  |  Beats checked: 24  |  FAILs: 9

Spec: `skills/make/kerning/reference/type-spec.md` §8.  Floor: 1.9% frame-height.  Contrast: 4.5:1 WCAG.  Kern threshold: 3.5× expected advance.  Wordy budget: 2 elements.

| beat | lane | polarity | worst finding | status | fix |
|------|------|----------|---------------|--------|-----|
| B00 | ? | light | min-size §8.1: hand-drawn pattern (ClaudeComposerAsk) — §8.1 hachure/crossbar fragments ar… | PASS | — |
| B01 | ? | light | min-size §8.1: min text-run height 51px >= floor 41px | PASS | — |
| B02 | ? | light | contrast-local §8.3b: per-blob contrast 1.08:1 < 3.0:1 — text unreadable on actual local b… | **FAIL** | Use INK on cream; add backing plate under accent text |
| B03 | ? | light | no-wordy-card §8.5: no prose payload found | PASS | — |
| B04 | ? | light | contrast-local §8.3b: per-blob contrast 2.07:1 < 3.0:1 — text unreadable on actual local b… | **FAIL** | Use INK on cream; add backing plate under accent text |
| B05 | ? | light | no-wordy-card §8.5: no prose payload found | PASS | — |
| B06 | ? | light | no-wordy-card §8.5: pull-quote (3 words ≤ 12) | PASS | — |
| B07 | ? | light | overflow §8.2: 5 text run(s) outside title-safe box (192,108)→(3648,2052) at 3840×2160 | **FAIL** | Move text inside title-safe 90% box |
| B08 | ? | light | no-wordy-card §8.5: pull-quote (3 words ≤ 12) | PASS | — |
| B09 | ? | light | overflow §8.2: 2 text run(s) outside title-safe box (192,108)→(3648,2052) at 3840×2160 | **FAIL** | Move text inside title-safe 90% box |
| B10 | ? | light | no-wordy-card §8.5: pull-quote (3 words ≤ 12) | PASS | — |
| B11 | ? | light | contrast-local §8.3b: per-blob contrast 1.74:1 < 3.0:1 — text unreadable on actual local b… | **FAIL** | Use INK on cream; add backing plate under accent text |
| B12 | ? | light | contrast-local §8.3b: per-blob contrast 2.30:1 < 3.0:1 — text unreadable on actual local b… | **FAIL** | Use INK on cream; add backing plate under accent text |
| B13 | ? | light | no-wordy-card §8.5: no prose payload found | PASS | — |
| B14 | ? | light | no-wordy-card §8.5: pull-quote (3 words ≤ 12) | PASS | — |
| B15 | ? | light | overflow §8.2: 2 text run(s) outside title-safe box (192,108)→(3648,2052) at 3840×2160 | **FAIL** | Move text inside title-safe 90% box |
| B16 | ? | light | min-size §8.1: smallest text run 35px < floor 41px (1.9% of 2160px logical); likely a capt… | **FAIL** | Increase font_size in scenes.py or Remotion component |
| B17 | ? | light | no-wordy-card §8.5: no prose payload found | PASS | — |
| B18 | ? | light | no-wordy-card §8.5: pull-quote (3 words ≤ 12) | PASS | — |
| B19 | ? | light | min-size §8.1: smallest text run 40px < floor 41px (1.9% of 2160px logical); likely a capt… | **FAIL** | Increase font_size in scenes.py or Remotion component |
| B20 | ? | light | no-wordy-card §8.5: no prose payload found | PASS | — |
| B21 | ? | light | min-size §8.1: hand-drawn pattern (ClaudeVerdictArtifact) — §8.1 hachure/crossbar fragment… | PASS | — |
| B22 | ? | light | min-size §8.1: hand-drawn pattern (ClaudeComposerAsk) — §8.1 hachure/crossbar fragments ar… | PASS | — |
| B23 | ? | dark | min-size §8.1: min text-run height 44px >= floor 41px | PASS | — |

---

## Failures requiring action before cut

### B02 (?)
- **contrast-local §8.3b**: per-blob contrast 1.08:1 < 3.0:1 — text unreadable on actual local background (blob@(664,1158)–(763,1223) fg≈(72, 72, 72) bg≈(77, 77, 77)); move label off its background or change text color
- **bbox-overlap §8.6b**: text-run bbox overlap 100% >= 10% — two labels are printing on top of each other: blob@(3201,520)–(3354,602) ∩ blob@(3282,533)–(3352,576) (100% of smaller); separate label positions in scenes.py or Remotion component | §8.6c ADVISORY: possible fused run(s) — blob@(211,292)–(1750,401) h=109px (1.8×med), blob@(2096,519)–(2367,642) h=123px (2.0×med), blob@(2388,725)–(2738,941) h=216px (3.6×med), blob@(2203,808)–(2742,977) h=169px (2.8×med), blob@(3116,822)–(3363,974) h=152px (2.5×med), blob@(1929,1016)–(2745,1473) h=457px (7.6×med), blob@(2771,1016)–(3552,1157) h=141px (2.4×med), blob@(650,1019)–(1058,1264) h=245px (4.1×med), blob@(1323,1097)–(1682,1296) h=199px (3.3×med), blob@(1929,1228)–(2603,1473) h=245px (4.1×med), blob@(240,1329)–(836,1476) h=147px (2.5×med)
- **Fix:** Use INK on cream; add backing plate under accent text

### B04 (?)
- **contrast-local §8.3b**: per-blob contrast 2.07:1 < 3.0:1 — text unreadable on actual local background (blob@(3464,988)–(3541,1035) fg≈(72, 58, 44) bg≈(149, 93, 86)); move label off its background or change text color
- **bbox-overlap §8.6b**: text-run bbox overlap 93% >= 10% — two labels are printing on top of each other: blob@(727,1152)–(899,1223) ∩ blob@(734,1184)–(899,1226) (93% of smaller); separate label positions in scenes.py or Remotion component | §8.6c ADVISORY: possible fused run(s) — blob@(687,1027)–(895,1161) h=134px (2.1×med), blob@(523,1103)–(729,1226) h=123px (1.9×med)
- **Fix:** Use INK on cream; add backing plate under accent text

### B07 (?)
- **overflow §8.2**: 5 text run(s) outside title-safe box (192,108)→(3648,2052) at 3840×2160
- **contrast-local §8.3b**: per-blob contrast 2.92:1 < 3.0:1 — text unreadable on actual local background (blob@(1388,1160)–(1522,1240) fg≈(50, 58, 62) bg≈(127, 127, 136)); move label off its background or change text color
- **bbox-overlap §8.6b**: text-run bbox overlap 100% >= 10% — two labels are printing on top of each other: blob@(0,1688)–(2431,2011) ∩ blob@(0,1777)–(136,1865) (100% of smaller); separate label positions in scenes.py or Remotion component | §8.6c ADVISORY: possible fused run(s) — blob@(435,1357)–(1592,1543) h=186px (2.3×med), blob@(2926,1610)–(3407,1783) h=173px (2.2×med), blob@(0,1688)–(2431,2011) h=323px (4.0×med)
- **Fix:** Move text inside title-safe 90% box

### B09 (?)
- **overflow §8.2**: 2 text run(s) outside title-safe box (192,108)→(3648,2052) at 3840×2160
- **contrast-local §8.3b**: per-blob contrast 1.19:1 < 3.0:1 — text unreadable on actual local background (blob@(3140,1066)–(3244,1128) fg≈(80, 60, 41) bg≈(99, 27, 21)); move label off its background or change text color
- **bbox-overlap §8.6b**: text-run bbox overlap 100% >= 10% — two labels are printing on top of each other: blob@(2088,666)–(2831,1109) ∩ blob@(2509,676)–(2583,723) (100% of smaller); separate label positions in scenes.py or Remotion component | §8.6c ADVISORY: possible fused run(s) — blob@(2088,666)–(2831,1109) h=443px (6.2×med), blob@(504,1406)–(1204,1543) h=137px (1.9×med), blob@(2536,1795)–(3099,1997) h=202px (2.8×med), blob@(3395,1843)–(3639,2005) h=162px (2.3×med)
- **Fix:** Move text inside title-safe 90% box

### B11 (?)
- **contrast-local §8.3b**: per-blob contrast 1.74:1 < 3.0:1 — text unreadable on actual local background (blob@(1780,1350)–(1841,1387) fg≈(78, 51, 42) bg≈(143, 73, 58)); move label off its background or change text color
- **Fix:** Use INK on cream; add backing plate under accent text

### B12 (?)
- **contrast-local §8.3b**: per-blob contrast 2.30:1 < 3.0:1 — text unreadable on actual local background (blob@(2408,966)–(2486,997) fg≈(70, 77, 91) bg≈(122, 134, 153)); move label off its background or change text color
- **bbox-overlap §8.6b**: text-run bbox overlap 50% >= 10% — two labels are printing on top of each other: blob@(2996,1162)–(3604,1414) ∩ blob@(2834,1276)–(3159,1414) (50% of smaller); separate label positions in scenes.py or Remotion component | §8.6c ADVISORY: possible fused run(s) — blob@(235,742)–(1888,1414) h=672px (4.9×med), blob@(2996,1162)–(3604,1414) h=252px (1.8×med)
- **Fix:** Use INK on cream; add backing plate under accent text

### B15 (?)
- **overflow §8.2**: 2 text run(s) outside title-safe box (192,108)→(3648,2052) at 3840×2160
- **contrast-local §8.3b**: per-blob contrast 1.25:1 < 3.0:1 — text unreadable on actual local background (blob@(3322,1236)–(3401,1287) fg≈(85, 100, 120) bg≈(100, 115, 134)); move label off its background or change text color
- **Fix:** Move text inside title-safe 90% box

### B16 (?)
- **min-size §8.1**: smallest text run 35px < floor 41px (1.9% of 2160px logical); likely a caption/label too small — increase font_size or check if this is a data label needing §7 treatment
- **overflow §8.2**: 5 text run(s) outside title-safe box (192,108)→(3648,2052) at 3840×2160
- **contrast-local §8.3b**: per-blob contrast 1.50:1 < 3.0:1 — text unreadable on actual local background (blob@(2680,1918)–(2817,1983) fg≈(90, 100, 118) bg≈(142, 126, 89)); move label off its background or change text color
- **bbox-overlap §8.6b**: text-run bbox overlap 23% >= 10% — two labels are printing on top of each other: blob@(2680,1918)–(2817,1983) ∩ blob@(2784,1920)–(3839,2011) (23% of smaller); separate label positions in scenes.py or Remotion component | §8.6c ADVISORY: possible fused run(s) — blob@(820,1357)–(1420,1543) h=186px (2.6×med), blob@(3310,1610)–(3791,1783) h=173px (2.4×med)
- **Fix:** Increase font_size in scenes.py or Remotion component

### B19 (?)
- **min-size §8.1**: smallest text run 40px < floor 41px (1.9% of 2160px logical); likely a caption/label too small — increase font_size or check if this is a data label needing §7 treatment
- **overflow §8.2**: 2 text run(s) outside title-safe box (192,108)→(3648,2052) at 3840×2160
- **contrast-local §8.3b**: per-blob contrast 1.10:1 < 3.0:1 — text unreadable on actual local background (blob@(904,1678)–(954,1711) fg≈(87, 102, 123) bg≈(92, 109, 130)); move label off its background or change text color
- **bbox-overlap §8.6b**: text-run bbox overlap 100% >= 10% — two labels are printing on top of each other: blob@(0,1539)–(2431,2011) ∩ blob@(1436,1540)–(1508,1586) (100% of smaller); separate label positions in scenes.py or Remotion component | §8.6c ADVISORY: possible fused run(s) — blob@(0,1539)–(2431,2011) h=472px (5.8×med)
- **Fix:** Increase font_size in scenes.py or Remotion component

---

## Check summary

| Check | Beats checked | FAILs |
|-------|---------------|-------|
| no-wordy-card §8.5 | 14 | 0 |
| min-size §8.1 | 24 | 2 |
| overflow §8.2 | 24 | 5 |
| contrast §8.3 | 24 | 0 |
| contrast-local §8.3b | 24 | 9 |
| bbox-overlap §8.6b | 24 | 7 |
| card-clip §8.13 | 24 | 0 |
| kerning §8.4 | 0 | 0 |
| redundancy §8.10 (advisory) | 1 | 0 (advisory — no exit effect) |

---

*GATE T: any FAIL blocks `./art run` and `./art final`. Fix the flagged beats and re-run `scripts/type_check.py` until green.*
