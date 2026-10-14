# CHANGE-BRIEF — walker-ninja-firefighter-joe-3d

> v1 · 2026-10-14 · written after my "learn the window" session and before building anything. Later revisions are added at the bottom, not rewritten.

Three simple 3D props for my Assignment 2 game, where Extinguisho, a deadpan ninja firefighter, rescues a person and a dog from two burning buildings. My game is 2D, so the props go in a small Godot 3D scene: a floor, one light, a camera, and the three props side by side at game scale.

## Rules for every asset

- At most 6 basic shapes, flat-colour materials, at most 500 triangles (my own budgets below are lower).
- No sculpting, textures, rigging or animation. Nothing downloaded or AI-generated as a mesh.
- Built with Claude through the Blender MCP. Poly Haven, Sketchfab, Poly Pizza, Hyper3D, Hunyuan3D and Tripo stay off.
- Each asset in its own `.blend`, built around the world origin with its base on the floor. Metres. Export `.glb` with +Y Up, rotation and scale applied.

## Scale

Extinguisho is **64 px** tall in my 640×360 game. I treat him as **1.8 m**, a normal adult height, so **1 px ≈ 0.028 m** (1.8 / 64 = 0.028125).

---

## Asset 1 — Fire hydrant

| | |
|---|---|
| **What / where** | A street prop on the burning street between the two buildings, the thing a firefighter's hose connects to. |
| **Size (W × D × H)** | about 0.4 × 0.4 × **0.8 m** |
| **Why that size** | 0.8 m is a real hydrant's height, about mid-thigh on Extinguisho (1.8 m). In the game it would be about 28 px next to his 64 px. |
| **Origin** | Bottom centre, so it stands on the floor. |
| **Look** | A red cylinder body on a wider base, a rounded cap, a small nut on top, two side outlets. Red `#c0392b`, grey caps `#9aa3ab`. About 6 shapes. |
| **Triangle budget** | **≤ 400.** Cylinders and the cap with low segment counts; a default sphere alone would use most of the 500. |

## Asset 2 — Rescue bag

| | |
|---|---|
| **What / where** | The orange rescue duffel Extinguisho carries on his back; the person and the dog ride in it. |
| **Size (W × D × H)** | **0.6 × 0.3 × 0.3 m** |
| **Why that size** | Real duffel size. In the game it's drawn 9 px (about 0.25 m), but that's an icon, and a 0.25 m bag couldn't carry a dog. Next to a 1.8 m firefighter, 0.6 m reads as a big carry bag. |
| **Origin** | Bottom centre, so it rests on the floor. |
| **Look** | A duffel shape (cylinder lying on its side), a flap on top, a handle. The game's own colours: orange `#e67e22`, darker seam `#b8621b`, dark handle `#1b2230`. 3 shapes. |
| **Triangle budget** | **≤ 300.** The handle is the risky part; a default torus is over 1,000 triangles. |

## Asset 3 — Rooftop ledge

| | |
|---|---|
| **What / where** | The ledges Extinguisho jumps between on the building fronts. |
| **Size (W × D × H)** | **2.5 × 1.0 × 0.45 m** |
| **Why that size** | My level's small ledges are 90 × 16 px, so 90 × 0.028 = 2.5 m wide and 16 × 0.028 = 0.45 m thick. The game is 2D, so depth isn't in the game; I picked 1.0 m. |
| **Origin** | Bottom centre. |
| **Look** | A slab with a thin strip on top, matching how the game draws ledges: concrete grey `#b8b2a6` with a green top strip `#438e7d` (4 px ≈ 0.11 m). No railing. 2 shapes. |
| **Triangle budget** | **≤ 100.** Two boxes are 24 triangles. |

---

## Predicted failures

| # | What I think will go wrong | Which | How I'll check |
|---|---|---|---|
| P1 | **It arrives lying on its side in Godot.** Blender's up is Z (I saw it on the gizmo) and Godot's up is Y. | all | In Godot the height (0.8 m for the hydrant) should be on Y; and look at it from the side. |
| P2 | **It sinks into the floor.** A new object's origin is in its middle; my default cube had a corner at Z = -1 m, half under the grid. | all | In Godot the bottom of each asset should be at the floor (0); look for sinking or floating. |
| P3 | **The colours don't survive the export.** The orange or green comes out grey or a different shade in Godot. | all | Look at each asset in the Godot scene next to the colours in this brief. |
| P4 | **The MCP won't connect.** The course hasn't run the MCP route, and the setup has several steps. | — | Check the add-on's status in Blender (N panel, MCP tab) and whether Claude can see the scene; log every error in FRICTIONAL.md. |

---

## Revisions

<!-- Dated revisions go here. The v1 text above is not edited. -->

### Revision 1 — 2026-10-14, rescue bag (after building and looking)

- **What I saw:** v1 (a cylinder lying on its side, a flap, one ring handle) passed every number (264 triangles, 0.60 × 0.28 × 0.30 m, scale 1, origin at the base), but in my own viewport check it read as a barrel or a log, not a bag. The ring handle was almost entirely buried inside the body; only ~1.5 cm showed. Evidence: `evidence/bag-v1-my-viewport-check.png`, `evidence/bag-angles-v1.png`.
- **Change:** v2 has an oval body (wider than tall, 0.30 × 0.24), **two strap handles** arching over the top, and a dark **zip line** along the top; the flap is gone. 4 shapes, 248 triangles (budget still ≤ 300).
- **New size:** 0.60 × 0.30 × **0.33 m** (height 0.30 → 0.33 because the handles now stand above the body). Colours: orange `#e67e22` body, dark `#1b2230` handles and zip.

### Revision 2 — 2026-10-14, rescue bag becomes a backpack

- **Why:** v2 read as a bag, but I asked what the bag is *for*: in my game it rides on Extinguisho's back in every pose and the survivors are tossed into it. A backpack fits that better than a carried duffel.
- **v3 (boxy backpack):** 292 triangles, 0.38 × 0.35 × 0.59 m. It read as a backpack from the back and side, but "more like a box" (`evidence/bag-v3-my-viewport-check.png`). I also noticed it is tiny in the viewport: a grid square is 1 m (`evidence/bag-v3-tiny-in-viewport.png`).
- **v4 (rounded backpack, final):** an oval, slightly tapered body, a rounded top flap, a rounded front pocket, two shoulder straps on the back and a grab handle. 6 shapes, **296 triangles** (budget ≤ 300), **0.36 × 0.31 × 0.61 m** (a third of Extinguisho's 1.8 m height, a real backpack size). Colours unchanged: orange `#e67e22`, darker `#b8621b`, dark `#1b2230`. Origin bottom centre.
- The duffel v2 is kept as `blender/rescue_bag_v2_duffel.blend`.

### Revision 3 — 2026-10-14, asset 3: the rooftop ledge is replaced by a flame

- **What happened:** the ledge was built exactly to the brief (24 triangles, 2.5 × 1.0 × 0.45 m, the game's concrete and green strip, origin at the base, scale 1; `evidence/ledge-angles-v1.png`, `evidence/ledge-my-viewport-check.png`). Looking at it, I found it "fine but it's just a ledge, nothing interesting".
- **Decision (mine):** replace it with a **flame**, the main hazard of my game (Extinguisho's whole job is putting fires out). I kept the count at three assets rather than adding a fourth, because of the deadline. The ledge stays in the repo as a dropped asset (`blender/rooftop_ledge.blend`, `tools/blender/build_rooftop_ledge.py`).

#### Asset 3 — Flame

| | |
|---|---|
| **What / where** | A fire hazard: the flames burning on the ledges and in the street that kill Extinguisho on touch and that he hoses down. |
| **Size (W × D × H)** | about 0.43 × 0.34 × **0.62 m** |
| **Why that size** | In my game a small fire hazard is a 14 × 14 px rectangle, drawn 18 × 22 px with the flame art (`game/session.gd`): 22 × 0.028 ≈ 0.62 m tall, about a third of Extinguisho's height, low enough to jump over. |
| **Origin** | Bottom centre, so it burns on the floor like the game's hazards. |
| **Look** | Stacked, not nested, so every colour shows from every side: a yellow bulb at the bottom `#f1c40f`, an orange middle `#e67e22`, a red tip `#c0392b`, plus two side tongues (orange and red) leaning outwards. 5 shapes, each a low-poly sphere reshaped into a teardrop (round bottom, pointed top). |
| **Triangle budget** | **≤ 400** (it came out at 336). |

- **Predictions P1–P3 apply to the flame too.** A flame is also likely to look **too stiff and symmetrical** (it is built from identical teardrops); that is my hand-edit target.

### Revision 4 — 2026-10-14, flame v1 → v2 (after looking)

- **What I saw:** flame v1 (three stacked straight teardrops on one axis plus two mirrored side spikes; 336 triangles) "doesn't look like a flame, looks like a christmas tree with 2 spikes" (`evidence/flame-v1-my-viewport-check.png`).
- **Change:** v2 is five uneven tongues of different heights whose tips bend sideways (left and right), on a round yellow base, so nothing is mirrored and the tips lick like fire. 5 shapes, **320 triangles** (budget ≤ 400), **0.41 × 0.35 × 0.62 m**, origin at the base. Same colours. (`evidence/flame-angles-v2.png`)
