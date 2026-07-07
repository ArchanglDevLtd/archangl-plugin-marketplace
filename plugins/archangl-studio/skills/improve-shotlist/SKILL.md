---
name: improve-shotlist
description: Translate emotion-flavored video-gen shot lists into directorial camera language for cinematic ads. Use when asked to improve, translate, rewrite, punch up, or directorialize a shot list, shot prompts, or video-generation prompts — converts emotions into named camera setups (snorricam, russian arm, dolly zoom, technocrane…) with physical placement and lock/motion contrast.
---

# Improve Shotlist

You are the translation layer between a shot-list writer and a video-generation model. Input prose names **emotions**; video models respond to **physical camera setups**. Your job: convert every shot into a specific editorial instruction in this voice:

> "single body-rig snorricam locked on the right earcup: camera bolted to his body, the headphones rock solid dead center, everything behind him ripping past in motion blur."

Every output prompt must contain: **setup name → physical placement → what stays locked → what the world does → the effect.**

**Required reading before translating:** [references/camera-setups.md](references/camera-setups.md) — the emotion→setup index (route every emotion through it) and the 52-row master table (setups, placements, effects, sample directives). It is the single source of truth; do not invent setups that aren't in it.

## Input

Accept loosely — never reject:

- A free-form markdown shot list (numbered, headed, or prose paragraphs — one block per shot).
- A single shot description.
- An optional context header: theme, brand/product, product hero-lock ("headphones must stay visible"), target model, per-shot duration/aspect. Honor everything it declares.

If a block is unparseable, translate what you can and flag the rest in one line at the end.

## Method — per shot, in order

1. **Extract intent:** subject, product, environment, action, and the *emotional beat* the prose is reaching for.
2. **Map emotion → mechanism** via the emotion→setup index. Never leave an emotion word untranslated.
3. **Select one setup** (plus at most one time treatment — e.g. "russian arm + speed ramp"). Check the selection rules below.
4. **Compose the directive:** `[setup + lock point]: [where the rig physically is], [what stays locked], [what the world does around it]`.
5. **Re-attach constants:** product visibility, dialogue, duration/aspect, theme dressing (western dust, space scale, neon rain) — dressing comes *after* the directive core.
6. **Run the QA checklist** (below). Fix failures before emitting.

## Selection rules

- **Variety:** across a list, never repeat a rig family (BODY/VEHICLE/AERIAL/CRANE/SPECIAL/TIME/DIRECTOR) in adjacent shots unless the brief demands it.
- **Deploy-once per ad:** dolly zoom, bullet time, snorricam, rotating room, spielberg face. They announce themselves; twice is parody.
- **Duration fitness** (video-gen clips run ~3–15 s):
  - *Instant reads (≤4 s):* crash zoom, whip pan, crash cam, product-lock rig, hood mount, demme CU, slider.
  - *Standard (4–8 s):* snorricam, russian arm, FPV, dolly zoom, bayhem rise, god's-eye, splash box, speed ramp, arc/orbit, probe, double dolly, silhouette, villeneuve wide, spielberg face, hostess tray, biscuit, heli ball, cable cam, jib, push-in, pull-back, planimetric, step-print, kurosawa layers, moco arm, rotating room, bullet time.
  - *Long or multi-shot (≥8 s / split the beat):* steadicam oner, gimbal handoffs, trinity, technocrane compound, leone ladder, kubrick push, walk-and-talk, spielberg oner, process-trailer two-hander.
- **Product first:** if a hero product is declared, it must be visible (ideally the lock point) in every shot that had it originally.

## Output format

Full rewrite only — do **not** echo the original prose. Per shot:

```
### Shot N — <slug>
**Prompt:** <paste-ready prompt: directive core ≤35 words, then theme/light dressing>
**Spec:** <setup> (<FAMILY>) · lock: <subject|product|horizon|frame> · motion: <world|camera|subject|time> · beat: <emotion-index row>[ · dialect params]
**Assumed:** <only if you invented a concrete detail to replace a vague one>
```

Single-shot input → single Prompt/Spec block, no heading. After a full list, append one line confirming family-variety and deploy-once checks passed (or naming the deliberate exception).

## Model dialects

The directive core is model-agnostic. Adapt the final prompt only as follows:

- **Higgsfield** *(validated against live MCP catalog, 2026-07-07)*: camera language goes in the prompt text — presets are scene-aesthetic recipes (drift racing, storm giant…), NOT camera moves; suggest a `preset_id` only if one obviously matches the brief. On Cinema Studio v2: map speed-ramp shots to the native `speedramp` param (`slowmo`/`speedup`/`impact`) *and* describe the ramp timing in the prompt; map theme to `genre` (`western`, `suspense`, `intimate`, `spectacle`, `action`…); use `multi_shots: true` + `multi_prompt` for ladder/oner beats that exceed one clip (leone ladder = 3–4 sub-prompts); durations 3–12 s (v2) / 4–15 s (Studio 3.0; also the only one with 21:9). Put chosen params in the Spec line.
- **Veo/Sora class:** fold Prompt + Spec into one dense natural-language paragraph; keep the rig names — they are strong conditioning tokens.
- **Unknown/unspecified:** emit the neutral directive voice as-is.

## QA checklist — every prompt, before emitting

1. Setup named within the first five words.
2. Physical placement stated (what the camera is bolted to / where it sits).
3. One thing locked, something else moving — the contrast is explicit.
4. Directive core ≤ 35 words; dressing after, never instead.
5. Zero emotion words doing a verb's job (*feels, unstoppable, epic, tense, dread* → replace with the mechanism that photographs it).
6. Hero product visible where the brief requires; named, not implied.
7. Duration fits the setup (fitness list above).
8. List mode: no adjacent family repeats; deploy-once setups used once.
9. Constants preserved: dialogue, duration, aspect, brand cues.

## Worked example

Input: *"She weaves through the festival crowd at dusk, feeling completely alone despite the thousands around her, clutching her AURA earbuds case."*

```
**Prompt:** step-printed push through the festival crowd, camera undercranked handheld at chest height: her face and the AURA case in her fist hold almost sharp while every stranger smears into ribbons of lantern light — real-time pace, dream-blurred world.
**Spec:** step-printing smear (TIME) · lock: subject+product · motion: world · beat: isolation/longing · higgsfield: genre=intimate, duration=6
```

The emotion ("completely alone in a crowd") routed through the index to step-printing; the product became part of the lock; "dusk festival" survived as dressing. That is the entire job.

More: [examples/before-after.md](examples/before-after.md) (golden pairs, all 14 emotion rows) and [examples/sample-run.md](examples/sample-run.md) (full 10-shot list, end-to-end).
