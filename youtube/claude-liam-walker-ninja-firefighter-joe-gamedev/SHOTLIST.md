# SHOTLIST

| Beat | Heading | Visual | Source / label on screen |
|---|---|---|---|
| B00 | The prompt | ClaudeComposerAsk | Brutalist bookend scene (illustrative reconstruction) |
| B01 | What was built | BrutalistHesitantWriter | Brutalist bookend scene |
| B02 | Four pillars, designed first | Image(s): storyboard-grid.png | CONCEPT.md · STORYBOARD.md · design before generation |
| B03 | The character sheet as a contract | Image(s): silhouette.png | CHARACTER-SHEET.md · silhouette at game size (64 px), enlarged |
| B04 | One asset, traced: the design | Image(s): panel-3b.png, toss-prompt.png, toss-raw.png | Storyboard sketch → prompt → raw generation (rejected) |
| B05 | The edit, then the texture | Image(s): toss-edit.png, pipeline.png | Edit prompt → edited generation (accepted) → game texture (tools/make_sprites.py) |
| B06 | One image per state | Code: features/player/player.gd lines 71+ | Godot editor reconstruction · exact source, revision 241c3f2 |
| B07 | The toss, in the running game | Gameplay: take 'rescue' | Actual Godot output · scripted normal input · Movie Maker · revision 241c3f2; HELD FRAME labeled where narration outlasts the action |
| B08 | Choosing the state | Code: features/player/player.gd lines 85+ | Godot editor reconstruction · exact source, revision 241c3f2 |
| B09 | Every state in play | Gameplay: take 'montage' | Actual Godot output · scripted normal input · Movie Maker · revision 241c3f2; HELD FRAME labeled where narration outlasts the action |
| B10 | The collision box | Code: features/player/player.gd lines 48+ | Godot editor reconstruction · exact source, revision 241c3f2 |
| B11 | Art against the box | Image(s): collision-rows.png | Diagnostic overlay on in-engine screenshots (cyan = collision box) · evidence/compare |
| B12 | A background that hid him | Image(s): bg-v1.png, bg-v2.png | Screenshots: ENV-BG v1 (2026-10-06 build) → ENV-BG v2 (revision 241c3f2) |
| B13 | Five sounds, cleaned the same way | Image(s): sounds.png | ElevenLabs Sound Effects (elevenlabs.io) → tools/make_audio.sh → godot/audio |
| B14 | A sound follows its event | Code: game/session.gd lines 194+ | Godot editor reconstruction · exact source, revision 241c3f2 |
| B15 | Burned, then back | Gameplay: take 'fire' | Actual Godot output · scripted normal input · Movie Maker · revision 241c3f2; HELD FRAME labeled where narration outlasts the action |
| B16 | Game audio, no narration | Gameplay: take 'audio' | Actual Godot output · scripted normal input · Movie Maker · revision 241c3f2 · GAME AUDIO — no narration |
| B17 | Sixteen bars that loop | Image(s): music-raw.png, music-loop.png | Eleven Music recording → loop 14.10–39.70 s → godot/audio/music_loop.ogg |
| B18 | The music follows the game | Code: game/session.gd lines 561+ | Godot editor reconstruction · exact source, revision 241c3f2 |
| B19 | Readable with the sound off | Gameplay: take 'muted' | Actual Godot output · scripted normal input · Movie Maker · revision 241c3f2; HELD FRAME labeled where narration outlasts the action |
| B20 | What the tests prove | Image(s): tests.png | Recorded test output, not a reconstruction |
| B21 | Verdict | ClaudeVerdictArtifact | Brutalist bookend scene |
| B22 | Your turn | ClaudeComposerAsk | Brutalist bookend scene (illustrative reconstruction) |
| B23 | Outro | ClaudeTitleOutro | Brutalist bookend scene |
