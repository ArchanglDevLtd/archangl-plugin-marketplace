# Golden pairs — before/after

Teaching corpus for the `improve-shotlist` skill. Each pair shows upstream emotion-flavored prose (**Before**) and the skill's output (**After**). Skill output in production never echoes the Before — it appears here only for training/eval.

Together with [sample-run.md](sample-run.md), these exercise **all 14 rows of the emotion→setup index** (coverage matrix at the bottom).

---

## P1 · Action-thriller — running shoes

**Before:** "He tears through the midnight city, hunted, heart slamming, the VELOX shoes the only thing keeping him ahead of whatever is behind him."

**After:**

**Prompt:** back-mount snorricam locked over his shoulder: camera bolted to his torso, his head and the VELOX collar logo rock-solid dead center while alleys, fire escapes and sodium light pitch and smear around him.
**Spec:** snorricam (BODY) · lock: subject+product · motion: world · beat: panic/unraveling · higgsfield: genre=suspense, duration=6

---

## P2 · Space adventure — expedition suit

**Before:** "She sees the alien megastructure for the first time and it takes her breath away — pure wonder fills her face."

**After:**

**Prompt:** spielberg-face push: slow dolly into her upturned face inside the helmet, pale structure-light blooming across the visor, reveal withheld — hold on her eyes a beat too long — THEN cut to the megastructure.
**Spec:** spielberg face (DIRECTOR) · lock: subject · motion: camera · beat: awe/wonder · higgsfield: genre=spectacle, duration=8
**Assumed:** structure-light is pale blue-white (original gave no color).

---

## P3 · Luxury spirits — cognac

**Before:** "The pour is pure elegance — golden liquid catching the light, effortless, seductive, expensive."

**After:**

**Prompt:** moco arm + 1000fps locked on the glass: robot arm whips 180° around the snifter at the exact frame the pour hits — crown of amber droplets held mid-air, razor sharp, candle-lit bar melting to bokeh behind.
**Spec:** motion-control arm + high-speed (SPECIAL) · lock: product · motion: time+camera · beat: seduction/luxury · higgsfield: speedramp=impact, genre=intimate, duration=5

---

## P4 · Smart-home security — thriller flavor

**Before:** "The empty hallway radiates dread. Something is wrong in this house, and the SENTINEL system knows it."

**After:**

**Prompt:** kubrick one-point push down the hallway: wide lens centered on the vanishing point, every line converging on the far door, dolly creeping at constant speed, nothing moving but us — the SENTINEL panel glowing sharp on the wall mid-frame.
**Spec:** kubrick one-point push (DIRECTOR) · lock: frame geometry · motion: camera · beat: dread/menace · higgsfield: genre=horror, duration=8

---

## P5 · Energy drink — street-festival mayhem

**Before:** "Total chaos at the street race — the crowd is electric, flags everywhere, and through it all she stays focused, VOLT can in hand."

**After:**

**Prompt:** kurosawa telephoto stack from the rooftop: 300mm compresses crowd, flags, confetti and smoke into four flat moving layers — she alone tack-sharp in the third layer, VOLT can raised, every other layer a wall of motion.
**Spec:** kurosawa telephoto layers (DIRECTOR) · lock: subject+product · motion: world · beat: chaos-with-clarity · higgsfield: genre=action, duration=6

---

## P6 · Electric sedan — night drive

**Before:** "Inside the car it's just the two of them, a quiet honest conversation while the city glides by. Warm. Close. Real."

**After:**

**Prompt:** hostess tray on the driver's door: her profile locked at window height, face steady on the dovetail-leveled frame while boulevard neon streaks past the glass behind her jaw — his hand on the console edge of frame.
**Spec:** hostess tray (VEHICLE) · lock: subject · motion: world · beat: intimacy/connection · higgsfield: genre=intimate, duration=7

---

## P7 · Artisan chocolate — playful precision

**Before:** "A charming, whimsical tour of the chocolatier's world — everything precise, delightful, storybook-perfect."

**After:**

**Prompt:** planimetric frame: chocolatier centered frontal against the tiled wall, deadpan; 90° whip pan to the marble counter; overhead god's-eye insert of hands squaring nine BONBON pralines into a perfect grid.
**Spec:** planimetric framing + 90° compass moves (DIRECTOR) · lock: symmetry grid · motion: camera (gridded) · beat: whimsy/precision · higgsfield: genre=comedy, duration=8

---

## P8 · Rugby boots — the hit

**Before:** "The tackle is seismic. You feel the collision in your bones. TERRA boots hold the turf."

**After:**

**Prompt:** speed-ramp the tackle from turf level: full speed to the plant foot — TERRA boot biting the grass fills foreground — 40x slow through the pads meeting, mud beads hanging, snap back to real time as both bodies spin off.
**Spec:** speed ramp (TIME) · lock: time at impact · motion: subject · beat: impact · higgsfield: speedramp=impact, genre=action, duration=6

---

## Coverage matrix — emotion→setup index vs corpus

| Emotion-index row | Exercised by |
|---|---|
| awe, wonder | P2 (spielberg face) · S1 (villeneuve wide) |
| dread, menace | P4 (kubrick push) |
| panic, unraveling | P1 (snorricam) |
| adrenaline, speed | S4 (russian arm) · S5 (FPV oner) |
| triumph, heroism | S8 (bayhem rise) |
| seduction, luxury | P3 (moco + high-speed) · S9 (probe lens) |
| isolation, longing | S1 (villeneuve wide) · SKILL.md worked example (step-print) |
| tension, standoff | S6 (leone ladder) |
| intimacy, connection | P6 (hostess tray) |
| chaos with clarity | P5 (kurosawa layers) |
| whimsy, precision | P7 (planimetric) |
| nostalgia, memory | S10 (malick magic hour) |
| fate, omniscience | S3 (god's-eye) |
| impact | P8 (speed ramp) · S7 (crash cam) |

S-numbers refer to [sample-run.md](sample-run.md). All 14 rows covered; ≥4 themes (thriller, space, luxury, automotive, sports, whimsy, western); ≥5 rig families across the corpus. Every prompt above passed the SKILL.md QA checklist (setup named first, placement stated, lock/motion contrast, ≤35-word core, no emotion words as verbs, product visible).
