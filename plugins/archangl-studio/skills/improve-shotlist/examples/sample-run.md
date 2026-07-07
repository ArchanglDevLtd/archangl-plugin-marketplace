# Sample run — full shot list, end to end

A complete input → output pass of the `improve-shotlist` skill. Input is typical upstream-writer prose (emotion-flavored). Output is exactly what the skill emits in production: full rewrite, no original echo, spec lines with Higgsfield dialect params.

---

## INPUT (as received from the upstream writer)

> **Brand:** IRONHIDE · **Product:** IRONHIDE R1 electric pickup (must stay visible in every exterior shot)
> **Theme:** modern western · **Target:** Higgsfield Cinema Studio v2, 16:9 · **Length:** ~60s, 10 shots
>
> 1. The desert at dawn, endless and ancient. The truck feels impossibly small against it — and yet it belongs.
> 2. Inside the cab, the terrain gets rough but they feel invincible, grinning as the world shakes.
> 3. From above, the dry lakebed looks like the skin of another planet. The truck's path is destiny written in dust.
> 4. Pure exhilaration — the R1 devours the canyon road, and we fly alongside it, breathless.
> 5. We chase the truck through the slot canyon, weightless, adrenaline everywhere.
> 6. At the lonely gas station, the old diesel rival pulls up opposite. The tension is unbearable. This is a showdown.
> 7. The R1 launches off the ridge crest. The landing hits like thunder.
> 8. The driver steps out on the ridge at sunset, victorious, larger than life.
> 9. The details are jewelry — the light bar, the badge, the machined ports. Pure desire.
> 10. Night falls. Campfire by the tailgate. This is what freedom has always looked like.

---

## OUTPUT (skill emission)

### Shot 1 — dawn scale
**Prompt:** villeneuve scale wide from two miles back on a long lens: the IRONHIDE R1 a lone fleck crawling the base of the mesa wall, frame drifting a hair, dawn haze stacking the distance — the scale does the acting.
**Spec:** villeneuve scale wide (DIRECTOR) · lock: horizon · motion: subject (minute) · beat: awe + isolation · higgsfield: genre=western, duration=8

### Shot 2 — cab, rough terrain
**Prompt:** hood mount framing back through the windshield: camera hard-bolted to the R1's hood, rock-steady two-shot while the suspension bucks them laughing in their seats, dust streaming up the glass between lens and faces.
**Spec:** hood mount (VEHICLE) · lock: frame-to-chassis · motion: subject (shaken) · beat: adrenaline, in-cab · higgsfield: genre=western, duration=5

### Shot 3 — lakebed from above
**Prompt:** overhead god's-eye at true 90°: straight down from altitude, the cracked lakebed a planet-skin texture, the R1 crossing frame corner to corner, its dust plume drawing one straight line across the pattern.
**Spec:** overhead god's-eye (CRANE) · lock: pattern plane · motion: subject · beat: fate/omniscience · higgsfield: genre=western, duration=6

### Shot 4 — canyon road pass
**Prompt:** russian-arm orbit at speed: gyro-stabilized crane off the chase car's roof swings the lens from tarmac level up over the R1's bed rail and settles at the driver's window mid-corner — truck pinned center, canyon walls wheeling.
**Spec:** russian arm (VEHICLE) · lock: product · motion: world · beat: adrenaline/speed · higgsfield: genre=action, duration=6

### Shot 5 — slot canyon chase
**Prompt:** FPV drone oner: hard-mounted racing quad dives off the rim, threads the slot canyon gap at full tilt, skims the R1's roof and exits through the dust cone it's towing — one unbroken breath.
**Spec:** FPV drone oner (AERIAL) · lock: none (1:1 with pilot) · motion: camera · beat: adrenaline/weightless · higgsfield: genre=action, duration=8

### Shot 6 — gas station showdown
**Prompt:** leone standoff ladder at the pumps: (1) extreme scope wide fixing the geography, R1 nose-to-nose with the diesel; (2) driver's eyes in ECU; (3) rival's hand on the fuel nozzle, her hand on the charge cable; (4) cuts doubling eyes-hands-eyes — resolved in one sudden locked wide as the R1 pulls silently away.
**Spec:** leone standoff ladder (DIRECTOR) · lock: triangle blocking · motion: cut rhythm · beat: tension/standoff · higgsfield: multi_shots=true, multi_prompt (4 beats above), genre=western, duration=12

### Shot 7 — ridge jump landing
**Prompt:** crash cam bolted at the landing point: expendable body hard-mounted in the dirt where the R1 touches down — undercarriage fills frame, gravel spraying the lens on impact, hold one beat past the hit.
**Spec:** crash cam (VEHICLE) · lock: camera-to-ground · motion: subject (impact) · beat: impact · higgsfield: speedramp=impact, genre=action, duration=4

### Shot 8 — driver at sunset
**Prompt:** bayhem rise: low wide lens at boot level orbiting on a curve as she steps down from the cab in slow-mo, sun flaring the frame's edge behind her shoulder, the R1's silhouette anchoring the background — a monument in motion.
**Spec:** bayhem hero-rise orbit (DIRECTOR) · lock: subject · motion: camera+time · beat: triumph · higgsfield: speedramp=slowmo, genre=spectacle, duration=7

### Shot 9 — detail jewelry
**Prompt:** probe-lens pass along the front fascia: lens tip travels the light bar's machined channel, crosses the IRONHIDE badge at bug-eye scale, exits through the charge-port door as it irises open — wide-macro depth, desert dusk bokeh beyond.
**Spec:** probe lens flythrough (SPECIAL) · lock: product surface · motion: camera · beat: seduction/luxury detail · higgsfield: genre=intimate, duration=6

### Shot 10 — campfire close
**Prompt:** malick magic-hour drift: wide-lens steadicam low through the scrub grass behind her trailing hand toward the tailgate campfire, no fill light, sun rimming the R1's roofline and every head at the fire — silhouettes on a burning sky.
**Spec:** malick magic-hour steadicam (DIRECTOR) · lock: none (wandering) · motion: camera · beat: nostalgia/freedom · higgsfield: genre=western, duration=8

**List checks:** family sequence DIR·VEH·CRANE·VEH·AERIAL·DIR·VEH·DIR·SPECIAL·DIR — no adjacent repeats ✓ · deploy-once setups used ≤1× ✓ · product visible in all 10 (interior shot 2 frames through R1 glass) ✓ · durations within Cinema Studio v2's 3–12 s, shot 6 split via multi_prompt ✓

---

## Why each translation (eval notes, not part of skill output)

| Shot | Emotion in prose | Index row → setup | Key conversion |
|---|---|---|---|
| 1 | "impossibly small… belongs" | awe + isolation → villeneuve wide | scale replaces adjectives |
| 2 | "feel invincible" | in-cab adrenaline → hood mount | invincibility = stable frame vs shaking world |
| 3 | "destiny written in dust" | fate → god's-eye | omniscience = true 90° flatten |
| 4 | "pure exhilaration… breathless" | adrenaline → russian arm | breathless = impossible orbiting support |
| 5 | "weightless, adrenaline" | adrenaline → FPV oner | weightless = 1:1 pilot camera |
| 6 | "tension is unbearable" | standoff → leone ladder | tension = accelerating cut geometry |
| 7 | "hits like thunder" | impact → crash cam | thunder = lens at the impact point |
| 8 | "victorious, larger than life" | triumph → bayhem rise | larger-than-life = low wide + orbit + slow-mo |
| 9 | "pure desire" | seduction → probe lens | desire = impossible closeness |
| 10 | "what freedom has always looked like" | nostalgia → malick magic hour | always = elegiac natural light |
