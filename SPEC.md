# Soroban — Build Specification

> Portfolio app 140, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Track several everyday counts in one fair order.

| Field | Value |
| --- | --- |
| Product name | Soroban |
| Bundle identifier | `com.soroban.board` |
| Domain | https://soroban-board.pro |
| Contact URL | https://soroban-board.pro/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone and iPad, portrait |
| Interface style | Dark |
| Asset prefix | `srb_` |
| User-Agent | `Soroban/1.0 (iOS; +https://soroban-board.pro)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Soroban -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A keeper taps the lit bead so today's count advances one rail at a time around the board.

### 2.1 User flow

1. Tap the lit bead on the board to add one to that counter for today
2. Watch the lantern move to the next bead so only that one accepts the next tap
3. Open Library as a sheet to add, rename, reorder, or archive counters
4. Open Stats as a sheet to see TickMarks, LapMarks, and per-counter day totals
5. Open History as a sheet to scrub prior daykeys
6. Open Settings as a sheet to reset local data

### 2.2 Essential behaviour

- Board of counters with exactly one lit lantern bead
- Tick increments the lit counter for today's daykey and advances the lantern
- Tick on a dark bead writes MissMark and is refused
- Full circuit writes LapMark
- Library to add, rename, reorder, archive counters
- Stats for TickMarks, LapMarks, and per-counter totals
- Local UserDefaults+Codable persistence with Int YYYYMMDD daykeys
- Seed seats three counters and lights the first so opening Tick lands

---

## 3. Uniqueness assignment for Soroban

| Axis | Assigned value |
| --- | --- |
| Architecture | **Lantern-circuit ADT fold (Bare | Lit | Lapped); the board is a fold over Counters; Tick on the lit Counter writes a TickMark, increments that Counter's DayTally, and advances the Lantern index; Tick on a dark Counter writes a MissMark and keeps the Lantern; completing one circuit writes a LapMark and stays Lit on the first Counter; Tick on Bare is refused; empty board writes Bare** |
| UI approach | **SwiftUI SceneKit integration · spritekit-accent** |
| Naming convention | **Soroban / lantern-bead lexicon** |
| File organization | **By soroban role (Board, Counter, Lantern, TickMark, MissMark, LapMark, DayTally)** |
| Dependency strategy | **None (zero external dependencies) · no SPM entry, no CocoaPods, no vendored source; UIKit, Core Graphics, AVFoundation and URLSession only** |
| Design direction | **sanity · index-list · duotone** |
| Typography | **Trebuchet MS** |
| Navigation pattern | **Lantern-locked chrome (the bead board never leaves; Library, Stats, History and Settings arrive as sheets; tick fuses on Board)** |
| AI art style | **Vaporwave · photography-driven** |
| Functional twist | **Lantern-circuit (only the lit bead accepts Tick; a miss is refused; a full circuit writes LapMark)** |
| Persistence | **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — multi_counter

**Core** — A keeper taps the lit bead so today's count advances one rail at a time around the board.

**Audience** — People who track several everyday counts at once and want one fair tap order instead of racing every button.

**User flow**

1. Tap the lit bead on the board to add one to that counter for today
2. Watch the lantern move to the next bead so only that one accepts the next tap
3. Open Library as a sheet to add, rename, reorder, or archive counters
4. Open Stats as a sheet to see TickMarks, LapMarks, and per-counter day totals
5. Open History as a sheet to scrub prior daykeys
6. Open Settings as a sheet to reset local data

**Essential features**

- Board of counters with exactly one lit lantern bead
- Tick increments the lit counter for today's daykey and advances the lantern
- Tick on a dark bead writes MissMark and is refused
- Full circuit writes LapMark
- Library to add, rename, reorder, archive counters
- Stats for TickMarks, LapMarks, and per-counter totals
- Local UserDefaults+Codable persistence with Int YYYYMMDD daykeys
- Seed seats three counters and lights the first so opening Tick lands

**Twist** — Lantern-circuit. Only the lit Counter accepts Tick. Tick writes a TickMark, increments that Counter for today, and advances the Lantern to the next Counter in board order. Tick on a dark Counter writes a MissMark and is refused. Completing one full circuit writes a LapMark. Seed already seats three Counters and lights the first so the opening Tick can land. Home verb: tick-the-lit-bead — not tap-any-counter and not click-a-rod.

**Why this is not a repeat** — multi_counter with a new home verb: tick-the-lit-bead via lantern advance, not Waywiser's dual Trip/Life rod click, not Runout's seat-then-tick gauge, and not a three-tab Counters/Stats/Settings stamp. Seed keeps the primary CTA live. Axes take graph leftovers for closed catalogs and propose new values only where the catalog is exhausted.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: Brutalist grid of dedicated − / + cards.
- Invariant: value = max(0, value+δ). Every tap logged. Auto-reset snaps to 0 when the period elapses (log −old). Optional goal.
- Never: Not a program. Not goals-required.
- Desk `watch_rate`: OLS s/day vs day; R²; DU/DD/CU/CL/CD spread; COSC |dev|≤4.
- Taste DNA is section 7.6. Do not invent a second look.
- A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

### 3.1 Architecture contract

BoardFold is a sum of Bare, Lit, and Lapped, and the board is a fold over Counters in library order. An empty or fully archived board is Bare, Tick on Bare is refused with no mark, and seating the first Counter folds Bare to Lit on that Counter. Tick on the lit Counter writes a TickMark, sets that Counter's DayTally for today's Int YYYYMMDD daykey to max(0, value + 1), and advances the lantern, which tracks the lit Counter id, to the next active Counter. Tick on a dark Counter writes a MissMark, keeps the lantern, and is refused. The tick that returns the lantern to the first Counter also writes a LapMark and leaves the stored phase Lit on that first Counter, with Lapped naming that completing tick. Every tap is logged, including a miss and an undo of the last accepted tick (delta -1 under the same max(0, value + delta) clamp, lantern stepped back, LapMark removed if that tick wrote one), and a new calendar day starts each DayTally at 0 while the log records the closed tally as a negative delta.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

Board is one SwiftUI screen hosting a single SCNView through UIViewRepresentable. The SceneKit rod aligns one solid bead to each index row. SCNView.overlaySKScene is the spritekit accent and draws only the lantern on the lit bead, inside that same view. Library, Stats, History, and Settings are stock List and Form sheets with no custom drawing. The layout is a dense index-list: hairline rules, edge-to-edge rows, almost no boxes, the lit counter name as one oversized word, then a quiet index. The lit row wears the accent. Tick and the dark-bead controls are native Buttons with contentShape and a 44pt minimum. The tick control uses the primary ButtonStyle (default, pressed, disabled) on the section 7.4 tinted glass. Archive and erase use the destructive style. Press scale is 0.97 over 140 to 180ms ease-out. Sheets scale from 0.96 to 1 and fade. Reduce Motion keeps opacity only. The index fills the remaining height, iPad uses the full width, and the background fills the safe area.

### 3.3 Naming contract

Convention: Soroban / lantern-bead lexicon.

Examples to follow: `BoardFold`, `BoardChart`, `DayTally`, `advanceLantern()`

### 3.4 Dependency contract

Zero external dependencies. project.yml has no packages key. No SPM, no CocoaPods, no vendored source. System frameworks are SwiftUI, Foundation, SceneKit for the bead rod, SpriteKit only as that SCNView overlay, and UIKit only to host the view. Core Graphics, AVFoundation, and URLSession stay unlinked. Do not import AVFoundation, do not request camera access, and do not call cgi/search.pl.

### 3.5 Navigation contract

The bead board never leaves. Library, Stats, History, and Settings are sheets over Board, and dismissing one returns to the same lantern. Tick is a control on Board, fused to the lit bead, not a separate destination. There is no TabView. Chrome buttons for the four sheets sit inside Board, each a Button with contentShape, a 44pt hit, and a VoiceOver label. Read ProcessInfo.processInfo.arguments once after onboarding. -ReviewScreen today shows Board, log shows History, goals shows Stats, library shows Library, and settings shows Settings.

### 3.6 Screen composition contract

Board holds the lit-bead circuit; Library, Stats, History and Settings arrive as sheets over the board — destinations, never a three-tab TabView

1. Onboarding. Three pages. Continue is full width at the bottom. Skip and finish both seat Cups, Pages, and Calls and light Cups so Tick can land. Re-run from Settings.
2. Board. Home. Dense index of counters. One SceneKit bead per row, lantern on the lit row, today tally through NumberFormatter, and the word Lit or Dark in text. Tick on the lit bead. A dark bead writes a miss. Undo reverses the last accepted tick. Empty Bare is a full page: EmptyHome art, headline Board bare., one line Add a counter to light the first bead., and the button Add a counter at the bottom with frame maxHeight infinity.
3. Library sheet. Add, rename, reorder, and archive. Reorder keeps the same Counter lit. Archiving the lit Counter lights the next active Counter, or folds Bare when none remain. Empty copy: Library empty. Add a counter.
4. Stats sheet. Counts of TickMarks and LapMarks, plus each counter total by daykey. This is the -ReviewScreen goals frame. It is a totals index, not a goal program.
5. History sheet. Scrub prior daykeys and list that day marks. This is the -ReviewScreen log frame.
6. Settings sheet. Re-run onboarding, erase with the confirm Erase the board? Counters and marks on this device are deleted., and a tappable Contact link to https://soroban-board.pro/contact-us.

Copy is status first. Bead lit. Tick refused. That bead is dark. Lap filed. One haptic on a successful tick or undo. None on a miss or on opening a sheet. The simulator seed behind srb.demo.v1 fills Board, Stats, and History with several marks and one lap, marks onboarding complete, and does not run on a device.

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

---

## 4. Target file organization

Scheme: **By soroban role (Board, Counter, Lantern, TickMark, MissMark, LapMark, DayTally)**

```
Soroban/
  Board/
  BoardFold.swift
  BoardChart.swift
  BoardView.swift
  BeadScene.swift
  LibrarySheet.swift
  StatsSheet.swift
  HistorySheet.swift
  SettingsSheet.swift
Counter/
  Counter.swift
Lantern/
  Lantern.swift
TickMark/
  TickMark.swift
MissMark/
  MissMark.swift
LapMark/
  LapMark.swift
DayTally/
  DayTally.swift
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Counters
A first-class screen for **Counters**. Must render empty, populated and error states.

### 5.3 Stats
A first-class screen for **Stats**. Must render empty, populated and error states.

### 5.4 Settings
A first-class screen for **Settings**. Must render empty, populated and error states.

### 5.5 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.6 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


---

## 6. Domain model

Minimum entities, named per this app's convention:

- **Counter** — named per this app's convention.
- **CountLog** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **sanity · index-list · duotone**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#2C271B` | Screen background |
| `surface` | `#3A3D29` | Cards, rows, sheets |
| `ink` | `#F4F3F1` | Primary text and icons |
| `accent` | `#D3EB5C` | Primary action, key figure, progress fill |
| `muted` | `#BFBAB0` | Secondary text, dividers, disabled |

The scaffold already wrote these exact values to `Soroban/DesignTokens.swift`
(`DesignTokens.bg`, `.surface`, `.ink`, `.accent`, `.muted`, plus
`DesignTokens.fontFamily`). Reach every colour through `DesignTokens` — a
typed accessor on top of it is fine. Keep the file and its hex values; do not
move them into `Assets.xcassets` and never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **Trebuchet MS**

Trebuchet MS is the only face. Bundle it, register it in UIAppFonts, and reach it as Font.custom("Trebuchet MS", size: relativeTo:) through one accessor. The move is an oversized single word, then silence, with an editorial feel: the display step is the lit counter name, one word, Trebuchet MS Bold, and the index under it stays quiet. At most six steps: display, title, headline, body, caption, micro. Body is the 17pt step with editorial leading and one hairline rule under the display word. Tallies, lap counts, and daykeys go through NumberFormatter with monospaced digits. No second face. Dynamic Type and @ScaledMetric keep that word on one line at the largest size by dropping a step instead of clipping. Day edges use Calendar.current.startOfDay, then an Int in YYYYMMDD form.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **4pt** for cards, sheets and primary surfaces; **2pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **hairline+fill** — a 1pt hairline border plus a flat fill tint, reused everywhere a surface sits above another.

Primary control: **tinted glass** — primary chrome sits on a tinted translucent surface (`Material` plus the accent colour at low opacity), never plain flat colour.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

### 7.5 Custom rendering scope

This app's `ui` axis is **SwiftUI SceneKit integration · spritekit-accent**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **SwiftUI SceneKit integration · spritekit-accent** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

### 7.6 Taste DNA

Aesthetic: **editorial** (Editorial: measure, rules, type hierarchy, almost no boxes.)

Reference system: **sanity** — steal rhythm and restraint, not their colours or logos.

Mood: **Headless CMS. Red accent, content-first editorial layout.**.

Home rhythm (`index-list`, dense): Dense typographic index. Table-like, almost no cards.

Editorial: measure, rules, type hierarchy, almost no boxes. Layout `index-list`, density dense. Kit 4/2, hairline+fill, tinted glass. Palette recipe `duotone`. Press scale 0.97, 140-180ms ease-out. Sheets scale 0.96 to 1 plus fade. Reduce Motion: opacity only. Reduce Motion: fade only. Do not invent a second radius or a second accent.

Type move: Oversized single word, then silence. Reference type feel: editorial.

Motion (`snap`): Press scale 0.97, 140-180ms ease-out. Sheets scale 0.96 to 1 plus fade. Reduce Motion: opacity only.

Voice (`tactical`): Status-first. Noun plus state. 'Scan failed. Try again.'

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- The app is portrait-only on iPhone. Lock it in the Info settings and do not
  write rotation-dependent layout.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Sibling cards, images and titles never overlap. Each cell owns its frame;
  `scaledToFill` is clipped to that cell. A chopped headline or two canvases
  in one slot is a defect, not a collage.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Pick one base spacing unit and use only multiples of it. No arbitrary values.

**Keyboard**

- The grams field uses `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with `NumberFormatter`, never string interpolation. Group
  separators and decimal separators must follow the locale.
- Energy is shown as a whole number of kcal. Macros are shown with at most one
  decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown macro values render as a dash or the word "unknown", never as 0.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- Animations are short (0.2 to 0.35 s) and use a single shared easing curve.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.


---

## 10. Persistence engineering

Chosen technology: **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark**

UserDefaults stores one Codable Chart root, BoardChart, as JSON under the single key srb.board.v1. BoardChart holds schemaVersion, the ordered Counters, the lit Counter id, TickMarks, MissMarks, LapMarks, and DayTallies keyed by counter id plus an Int daykey in YYYYMMDD form. Islands, Books, Sessions, Runs, and Rhumbs are not fields of this record. Each mark schedules one debounced save about 400ms after the last change, and scenePhase inactive or background flushes immediately. The previous JSON is copied to srb.board.v1.bak before replace. Decode failure restores the backup, then an empty Bare board, and tells the user. Daykeys come from Calendar.current.startOfDay. Views talk only to the store seam. resetAllData() deletes both keys and is reachable from Settings. The simulator seed runs once behind srb.demo.v1, writes Cups, Pages, and Calls with Cups lit, prior marks, and one LapMark, marks onboarding complete, and never runs on a device.

This app persists to **files on disk**. The following are mandatory.

- Write atomically. Either `Data.write(to:options: .atomic)` or write to a
  temporary file and `FileManager.replaceItemAt`. A non-atomic write that is
  interrupted leaves a truncated file and the app will not launch.
- Create the containing directory with
  `withIntermediateDirectories: true` before the first write.
- Every document carries a `schemaVersion` field from version 1, and the decoder
  switches on it.
- Decoding failure must be recoverable: keep the previous good file as a
  `.backup`, fall back to it, and if that also fails start from empty state and
  tell the user. Never crash on a corrupt file.
- All file IO happens off the main thread. The main thread never blocks on disk.
- Debounce writes during rapid edits, but force a flush when `scenePhase`
  becomes `.inactive` or `.background`, and after any destructive action.
- Exclude caches from backup with `URLResourceValues.isExcludedFromBackup` where
  appropriate; user data belongs in Application Support and should be backed up.
- Keep an explicit in-memory source of truth and treat the file as a projection
  of it, so a failed write never leaves the UI showing data that does not exist.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Soroban/1.0 (iOS; +https://soroban-board.pro)` on every request. Never reuse another app's string.
No required remote catalog. Network only if this product actually needs it.

---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- Portrait only, iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


### First minute on a clean install (Guideline 2.1)

A reviewer judges completeness (Guideline 2.1) in the first minute on a clean
install. The loop must finish there without knowing the app's rules. Long form:
`docs/REVIEW-LESSONS-2026-09-25.md`.

- The home verb writes a visible object on the first tap of a clean install:
  a row, a card, a mark on the dial. No second screen needed to see it.
- Never leave the home control disabled until an unexplained condition holds
  ("two links first", "long press first", "add a volume first"). Accept the
  first input with sane defaults and show the rule afterwards.
- The twist fires after a successful write, as a visible consequence (a highlight,
  a caption, a next step), never instead of the write.
- A refusal is allowed only after the first success, and it must name the next
  tap that works.
- Nothing in the first session waits for midnight, a second day, a second item or
  a streak. A screen that can only fill later shows its action, not a wait.
- Every empty state names one action, and that action completes on the spot.
- Next to home there is at least one more screen that works on a clean install.
- The subtitle and the first description line name an everyday action a stranger
  understands. Coined words may decorate labels; each primary button still says
  what it does.
- A failed network lookup falls back to local data or typed input with a message;
  the loop still finishes offline.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.lifestyle`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Dark
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.lifestyle
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Lantern-circuit (only the lit bead accepts Tick; a miss is refused; a full circuit writes LapMark)

Only the lit bead accepts Tick. That tick writes a TickMark, adds one to the lit Counter for today's daykey, and advances the lantern one seat in board order. A tap on a dark bead writes a MissMark and leaves both the lantern and the tally unchanged. A tick that completes the circuit also writes a LapMark and leaves the lantern lit on the first Counter. The opening state seats three Counters and lights the first so Tick can land, and the home verb is tick-the-lit-bead. Unit-test the fold, the dark-bead refusal, the lap wrap, max(0, value + delta), and the day-boundary snap to 0.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **Vaporwave · photography-driven**


Base prompt, reused and extended for every asset:

```
Vaporwave mood, photography-driven. Photographed physical objects on a staged set: a solid wooden soroban bead, a small metal lantern, a rod, and retro consumer electronics as props. A perspective grid built into the set, film grain, soft optical bloom, shallow depth, magazine still-life lighting. No illustration, no 3D render, no clay, no glass sculpture, no wire frame, no text, no letters, no logo.
```

All 12 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `srb_` prefix.

### 13.1 App icon rules (strict)

The icon is rejected by App Store Connect if any of these are wrong:

- Exactly **1024 x 1024 px**.
- **No alpha channel.**
- sRGB colour profile, 8 bits per channel, PNG.
- **No text and no words** in the artwork.
- **No rounded corners and no built-in mask.**
- The subject stays inside the middle 80%.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `srb_AppIcon` | 1024x1024 | **NO** | App Store icon. NO alpha channel, NO transparency, NO text, NO rounded corners, NO drop shadow outside the canvas. |
| 2 | `srb_Splash` | 1290x2796 | fill | Launch background. The middle third must stay quiet so the wordmark reads on top. |
| 3 | `srb_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 4 | `srb_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 5 | `srb_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 6 | `srb_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 7 | `srb_EmptyList` | 1024x1024 | **required cutout** | Empty state: a secondary list has no rows. |
| 8 | `srb_CardBackdrop` | 1200x800 | fill | Backdrop art for a primary card. Low contrast so text stays readable. |
| 9 | `srb_ControlFace` | 512x512 | **required cutout** | Custom control artwork used for the primary interactive element. |
| 10 | `srb_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Lantern-circuit (only the lit bead accepts Tick; a miss is refused; a full circuit writes LapMark)' feature screen. |
| 11 | `srb_SuccessMark` | 512x512 | **required cutout** | Shown briefly when the primary action succeeds. |
| 12 | `srb_HeaderDecor` | 1200x600 | **required cutout** | Decorative header accent on the main screen. |

### Prompt per asset

**`srb_AppIcon`** — 1024x1024

```
Vaporwave product photograph. One solid wooden soroban bead filling the square edge to edge, opaque, centered, no text, no letters, no rounded mask, no drop shadow outside the canvas.
```

**`srb_Splash`** — 1290x2796

```
Vaporwave product photograph, vertical. A bead rod on a staged grid set, film grain, soft bloom. The middle third stays quiet and empty so a wordmark can sit on it. No text, no letters.
```

**`srb_Onboarding1`** — 1024x1536

```
Vaporwave product photograph, cutout. A solid wooden soroban with one bead seated forward, opaque subject centered, real surroundings absent.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`srb_Onboarding2`** — 1024x1536

```
Vaporwave product photograph, cutout. A solid bead mid-slide on a short rod, the tap about to land, opaque wood and metal, centered.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`srb_Onboarding3`** — 1024x1536

```
Vaporwave product photograph, cutout. Three solid beads on a rod with a small metal lantern resting on the first bead, opaque, centered.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`srb_EmptyHome`** — 1024x1024

```
Vaporwave product photograph, cutout. A closed solid wooden bead case, fully opaque, no beads outside it, calm, centered.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`srb_EmptyList`** — 1024x1024

```
Vaporwave product photograph, cutout. An empty solid wooden tray, opaque, no glass, centered.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`srb_CardBackdrop`** — 1200x800

```
Vaporwave photographic backdrop, edge to edge. Soft grain and a faint perspective grid, low detail in the center so type stays readable. No text, no letters, no object in the middle.
```

**`srb_ControlFace`** — 512x512

```
Vaporwave product photograph, cutout. One solid wooden soroban bead, the control face, opaque, centered, no hole through the middle.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`srb_TwistHero`** — 1024x1024

```
Vaporwave product photograph, cutout. One solid bead visibly lit beside two matte beads on a short rod, a small metal lantern on the lit bead, opaque subjects, centered.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`srb_SuccessMark`** — 512x512

```
Vaporwave product photograph, cutout. A small solid metal ring, a lap token, opaque, centered.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`srb_HeaderDecor`** — 1200x600

```
Vaporwave product photograph, cutout. A short row of solid wooden beads on a rod, wide ornament, opaque subjects, centered, no painted rectangle behind them.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated SOLID opaque subject in the center, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail. A hollow glass box or wire frame with a transparent center is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`srb.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.
- A `TabView` with exactly three tabs. That is the factory stamp — two or
  four-to-five destinations, or a different chrome. ReviewScreen keys are
  not tabs.


---

## 17. Tests

Add a unit test target `SorobanTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. `Soroban/ReviewLaunch.swift` (scaffold, keep it) parses `ProcessInfo.processInfo.arguments`.
   Read `ReviewLaunch.screen` once after onboarding:
   `-ReviewScreen today|log|goals` switches the running app's live navigation. Extra cover slugs open those screens.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Soroban -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.

**Uniqueness**
- [ ] Architecture matches **Lantern-circuit ADT fold (Bare | Lit | Lapped); the board is a fold over Counters; Tick on the lit Counter writes a TickMark, increments that Counter's DayTally, and advances the Lantern index; Tick on a dark Counter writes a MissMark and keeps the Lantern; completing one circuit writes a LapMark and stays Lit on the first Counter; Tick on Bare is refused; empty board writes Bare** with no leakage across layers.
- [ ] UI approach matches **SwiftUI SceneKit integration · spritekit-accent**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Lantern-locked chrome (the bead board never leaves; Library, Stats, History and Settings arrive as sheets; tick fuses on Board)**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **Trebuchet MS** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Soroban
xcodegen generate
xcodebuild build-for-testing -scheme Soroban -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.soroban.board/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
xcodebuild -scheme Soroban -destination 'generic/platform=iOS' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.soroban.board/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
xcrun simctl list devices available
xcodebuild test-without-building -scheme Soroban -destination 'platform=iOS Simulator,id=<UDID>' -jobs 4 -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.soroban.board/DerivedData'
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY, DEVELOPMENT_TEAM, SWIFT_TREAT_WARNINGS_AS_ERRORS or -derivedDataPath in project.yml — they are command-line only. CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
