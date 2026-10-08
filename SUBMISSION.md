# SUBMISSION

- **Assignment:** Assignment 2 - Generate Art, Sound, and Music for Your Game
- **Student:** Sreeja Pulaparty
- **Project name:** walker-ninja-firefighter-joe
- **Game concept in one sentence:** Extinguisho, a deadpan ninja firefighter, has 40 seconds to kung-fu jump over flames, hose the fire blocking the way, toss a person and a dog into his rescue bag, and escape off a burning rooftop.
- **GitHub repository/folder URL:** https://github.com/nikbearbrown/csye-7270-building-virtual-environments/tree/main/fall-2026/sreeja-p/assignment-2/walker-ninja-firefighter-joe (also on the fork: pulapartys/csye-7270-building-virtual-environments, branch `sreeja-p/assignment-2`)
- **Started from:** my Assignment 1 project (`walker-jumpman-joe`), which extended nikbearbrown/walker-jumpman
- **Submitted commit SHA:** the commit that adds this file, given in the Canvas copy of SUBMISSION.md (a commit cannot contain its own SHA). It changes no game source after the film revision.
- **Source revision shown in the film:** `241c3f2` (verified: no file under `godot/` differs between `241c3f2` and the submitted commit)
- **Godot version and operating system:** Godot 4.7.2 stable, macOS
- **Generative models used (name, version, where run, license):**
  - ChatGPT image generation (Instant mode; model name not shown), chatgpt.com, ChatGPT Plus on OpenAI's free student offer, OpenAI Terms of Use: storyboard sketches, character references and poses, ENV-BG, ENV-FIRE
  - ElevenLabs Music ("Music v2"), elevenlabs.io free plan; Eleven Music terms: attribution "Created in collaboration with ElevenLabs" given; downloads not permitted on the free plan, so recorded from playback with Audacity (approved by the course staff): music loop
  - ElevenLabs Sound Effects (version not shown), elevenlabs.io free plan; free plan = non-commercial, attribution "elevenlabs.io" given: event sounds
- **Final film URL and filename:** https://northeastern-my.sharepoint.com/:f:/g/personal/pulaparty_s_northeastern_edu/IgAIP7WoCQfYQqLBHNgRfXv8ATHXvgLoeUTGjfj3LlelU8w?e=g5m7aQ · `claude-liam-walker-ninja-firefighter-joe-gamedev.mp4`
- **Final film SHA-256:** `7c0d484b7aba9e780f0f04dbb1f24b2f9f0551a38210db6a8458ac846c296230`
- **Summary of my work:** I designed Extinguisho, a deadpan ninja firefighter, and an asset slice of my Assignment 1 game before generating anything: the concept and pillars, a six-panel storyboard, and a character sheet. I generated every image in ChatGPT from one side-profile reference, judging each pose against it, and rejected or edited the ones that drifted. I also changed the design along the way: the toss goes up, the background was regenerated so he stays visible, and the start siren was cut. I made the five sound effects in ElevenLabs and the music loop in Eleven Music, choosing which versions to keep and changing the win to a cheer. Claude Code wrote the code, prompts, tests, and film script under my direction. I playtested many times, with sound and muted; three playtests are written up in TEST-REPORT, and each changed the game: speed, pose timing, the close-ups, and the background. *(Drafted by Claude Code from my logged decisions; reviewed, corrected, and approved by me.)*
- **Known limitations:** the character's face doesn't read at 64 px, so the punchlines use two close-ups; muted, the fire death relies on its on-screen text; the level, survivors, rescue bag, and HUD are code-drawn (from A1); the run is slower, the jump floatier, and the fire-death hold longer than A1; ChatGPT exposes no seeds, so regenerations are similar, not identical; tested on macOS only.
