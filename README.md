# Soroban

A keeper ticks the lit bead. Today's count advances one rail at a time around the board. Only that bead accepts the tap. A dark bead writes a miss and stays dark. A full circuit writes a lap and leaves the lantern on the first bead.

## Why a lantern-circuit fold

The product is a fair tap order, not a list of counters you can race. `BoardFold` is Bare, Lit, or Lapped. The board is a fold over counters in library order. Empty or fully archived is Bare, and Tick on Bare writes nothing. Seating the first counter folds Bare to Lit on that counter. Tick on the lit counter writes a TickMark, sets that counter's DayTally for today's YYYYMMDD daykey to max(0, value + 1), and advances the lantern. Tick on a dark counter writes a MissMark and keeps the lantern. The tick that returns to the first counter also writes a LapMark and stores Lit on that first counter. Lapped names that completing tick. Undo steps the lantern back and removes the lap if that tick wrote one. A new calendar day starts each tally at 0 and logs the closed tally as a negative delta.

Home is that circuit: one SceneKit bead per row, a SpriteKit lantern on the lit bead, and Tick fused to that row. Library, Stats, History, and Settings are sheets. The board does not leave.

## Asset prompts

Art style: Vaporwave, photography-driven. Photographed physical objects on a staged set: a solid wooden soroban bead, a small metal lantern, a rod, and retro consumer electronics as props. A perspective grid built into the set, film grain, soft optical bloom, shallow depth, magazine still-life lighting. No illustration, no 3D render, no clay, no glass sculpture, no wire frame, no text, no letters, no logo.

Image sets are named and left empty for the asset pass: `srb_AppIcon`, `srb_Splash`, `srb_Onboarding1`, `srb_Onboarding2`, `srb_Onboarding3`, `srb_EmptyHome`, `srb_EmptyList`, `srb_CardBackdrop`, `srb_ControlFace`, `srb_TwistHero`, `srb_SuccessMark`, `srb_HeaderDecor`. Prompts for each set are in SPEC.md section 13.2.
