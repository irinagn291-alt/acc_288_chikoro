<!-- gf-brief source=139542897f171832937e043b64122fe5583d7f2d77bce61a38c1dbd86474367e written=2026-09-29T17:55:33+03:00 -->
# Chikoro

## What it is

Chikoro is a daily tally board for people who keep several everyday counts in one place. Rows share one circuit: only the lit bead accepts a tap, that tap adds one for today, and the light moves to the next bead. A dark bead is refused. A full circuit files a lap.

## Launch and onboarding

On a cold first launch the system launch screen appears (portrait, dark). A blank dark field can sit for a few seconds before the first page. If opening is slow, a spinner may show on that field. There is no sign-in and no permission prompt.

Onboarding is three pages. **Skip** is always at the top right. A page number **1**, **2**, or **3** (device number format) sits above the bottom button. Pages 1 and 2 use **Continue**; page 3 uses **Finish**. **Skip** on any page and **Finish** on the last page both end onboarding, seat three rows named **Cups**, **Pages**, and **Calls**, light **Cups**, and open the board.

1. Title: **One tap order.** Body: **Several everyday counts share one board. You tick the lit bead.** Button: **Continue**.
2. Title: **Tick the lit bead.** Body: **That tap adds one for today and moves the light to the next bead.** Button: **Continue**.
3. Title: **A full circuit files a lap.** Body: **A dark bead is refused. The light stays until you tick the lit one.** Button: **Finish**.

Later launches skip these pages and open the board with the saved rows and marks. **Show onboarding** in Settings walks the same three pages again. Leaving the app before **Skip** or **Finish** returns to page **1** on the next launch; the page you were on is not saved.

## Screens

There is no tab bar. The board stays on screen. **Library**, **Stats**, **History**, and **Settings** open as full-height sheets. Sheets have no Close button; swipe down to return to the board. On a narrow width the four board controls wrap onto two rows (**Library** / **Stats**, then **History** / **Settings**). The board has no app-name title; the large word is the lit row’s name.

### Board

The home screen. After onboarding it shows the four controls, a plate for the lit row, a vertical rod of beads (one per row, with a lantern mark on the lit bead), today’s figures, and **Undo**.

- **Library** — opens the Library sheet.
- **Stats** — opens the Stats sheet.
- **History** — opens the History sheet.
- **Settings** — opens the Settings sheet.

The plate shows the lit row’s name, then **Counts today. Tick the lit seat.** Under that, a status line:

- **Bead lit.** after a successful tick that did not complete a circuit, after a successful undo, and when the board first appears
- **Lap filed.** when a tick completes a full circuit
- **Tick refused. That bead is dark. Tick the lit seat.** when a dark row is tapped
- **Tick refused.** when a tick cannot land

Each row shows its name, a **Lit** or **Dark** chip, and today’s count. The lit row also shows **Tick**. Tapping the lit row (or **Tick**) adds one to that row for today, moves the light to the next row in board order, and may file a lap. Tapping a **Dark** row does not add to the count; it records a miss and leaves the light where it is. VoiceOver on the lit row is **Tick [name]. Lit.** On a dark row it is **[name]. Dark.**

Along the bottom of the list:

- **Laps** — how many full circuits have been filed (all days)
- **Ticks** — accepted taps today
- **Misses** — refused dark taps today

**Undo** reverses the last accepted tick, steps the light back, and removes a lap if that tick filed one. It does not undo a miss. When there is nothing to undo, **Undo** is faded and does not respond (VoiceOver: **Undo last tick**).

If every row is gone, the board shows **Board bare.**, **Add a counter to light the first bead.**, and **Add a counter**, which opens Library.

If the board cannot be read, it shows **Board unreadable.** and a detail line, then **Retry**. **Retry** dismisses the notice so the board can be used. The detail may be **Board restored from the backup.** or **Board unreadable. Started a bare board.**

### Library

Title: **Library**.

Empty: **Library empty.**, **Add a counter.**, a **Row name** field, and **Add**. The keyboard has **Done**.

With rows: the same **Row name** field and **Add**, then one block per row with a **Name** field, **Rename**, and **Archive**. Drag handles stay on so rows can be reordered. Reorder does not move the light; the same row stays lit.

- **Add** seats a new row. The first row on a bare board becomes lit. Later adds do not steal the light. A blank or whitespace name shows **Name refused. Enter a name.** and does not add.
- **Rename** saves that row’s **Name** field. A blank name shows **Name refused. Enter a name.**
- **Archive** removes the row from the board and from Library. If that row was lit, the next remaining row becomes lit. If it was the last row, the board becomes **Board bare.** There is no restore control. Stats may still list the archived seat.

If Library cannot be read: **Library unreadable.** and **Retry**.

### Stats

Title: **Stats**.

Empty (no ticks, laps, or day totals): **Stats empty.** and **Tick the lit seat. Totals land here.** The button is **Add a counter** when there are no rows, or **Tick the lit seat** when rows exist. Both act on this sheet: if there are no rows, a **Cups** row is seated and ticked; if rows exist, the lit seat is ticked. Totals then appear here. This does not open Library.

With totals: **Seat counts**, **Open a day, or tick the lit seat.**, then **Ticks** and **Laps** (all accepted ticks and all laps, all days). Each seat shows its name, its latest day’s count (or **0**), **Lit seat** or **Dark seat**, and either **No day yet** or **Open** plus that day’s label (day number, then month and year in the device’s locale, for example **29 September 2026**). Seats with **No day yet** do not open. A seat with a day opens that day. **Tick the lit seat** here closes Stats and returns to the board; it does not tick.

A day page uses that day’s label as the title, then **Seat counts for this day.** Each seat shows its count for that day. If there are marks, they appear as lines such as **Tick Cups.**, **Miss Pages.**, **Lap filed.**, **Undo Calls.**, **Day closed Cups.** At most six of those lines are shown. **Seat counts** returns to the totals list. **Tick the lit seat** closes Stats and returns to the board.

If Stats cannot be read: **Stats unreadable.** and **Retry**.

### History

Title: **History**.

Empty (no marks yet): **History empty.**, **Marks for each day land here.**, and **Add a counter** or **Tick the lit seat** with the same in-sheet tick behaviour as empty Stats (seat **Cups** if needed, then tick the lit seat). The sheet stays open and fills once a mark exists.

With marks: the selected day’s number and month–year, then **Earlier** and **Later**. Days are newest first, and today is always in the list. **Later** is faded on the newest day. **Earlier** is faded on the oldest day.

A day with marks lists lines such as **Tick Cups.**, **Miss Pages.**, **Lap filed.**, **Undo Calls.**, **Day closed Cups.**

A day with no marks shows **This day's marks**, **No marks on this day.**, and either **Tap Earlier to open the day that has ticks.** or **Tick the lit seat to file the first mark.** Active seats show **0**. If there are no seats, **Add a counter, then tick the lit seat.** The bottom button is **Earlier** when an earlier day exists, otherwise **Tick the lit seat**, which files a tick on the board.

If History cannot be read: **History unreadable.** and **Retry**.

### Settings

Title: **Settings**.

Usual contents:

- **Show onboarding** — dismisses Settings and shows the three onboarding pages again. **Skip** or **Finish** returns to the board, seats **Cups**, **Pages**, and **Calls** if they are missing, un-archives those three if they were archived, restores those three names if they were renamed, and lights **Cups**.
- **Erase the board** — opens **Erase the board?** with **Counters and marks on this device are deleted.** **Erase the board** clears every row and mark and treats onboarding as unfinished. **Cancel** leaves the board as it is.
- **Contact** — opens the support page.

After an erase, while Settings is still open: **Settings ready.** and **Seat rows from onboarding, or erase later.**, with the same three controls. Dismissing Settings then shows onboarding again.

If Settings cannot be read: **Settings unreadable.** and **Retry**.

## Features

- Several everyday counts on one board
- Tick the lit bead only
- A tap adds one for today and moves the light to the next bead
- A dark bead is refused and records a miss
- A full circuit files a lap
- **Undo** the last accepted tick
- Library: add, rename, reorder, and archive rows
- Starter rows **Cups**, **Pages**, and **Calls**
- Stats: seat counts, ticks, laps, and a day page
- History: earlier and later days and that day’s marks
- Today’s counts start at 0 on a new calendar day; closed days can show **Day closed** plus the seat name
- **Show onboarding**
- **Erase the board**
- **Contact**

## Behaviours that can look like bugs

- Onboarding does not continue past the last page until **Finish** (or **Skip** on any page). **Continue** on pages 1 and 2 only advances.
- Leaving before **Skip** or **Finish** shows page **1** again. That is intended.
- A short blank field (sometimes with a spinner) can appear before onboarding. Wait; the first page follows.
- **Add** and **Rename** refuse a blank name and show **Name refused. Enter a name.** Type a name, then try again.
- **Undo** stays faded until at least one accepted tick exists. A miss does not enable it.
- A **Dark** row never increments. Status becomes **Tick refused. That bead is dark. Tick the lit seat.** Tick the row marked **Lit**.
- **Archive** removes a row from the board and Library with no restore control. Re-running onboarding only brings back **Cups**, **Pages**, and **Calls**. **Erase the board** is the only full reset.
- After **Archive** of the last row, the board shows **Board bare.** Use **Add a counter**.
- **Add a counter** on the bare board opens Library. The same label on empty Stats or empty History seats **Cups** and ticks it immediately.
- **Tick the lit seat** on empty Stats or empty History actually ticks. On populated Stats (and on a Stats day page) it only closes the sheet.
- History can open on today with **No marks on this day.** even after older days have marks. Use **Earlier**.
- **Later** does nothing on the newest day; **Earlier** does nothing on the oldest. Both look faded.
- Stats seats with **No day yet** do not open. Tick that seat on the board first.
- **Laps** on the board is the all-time circuit count; **Ticks** and **Misses** are today only. On a new calendar day the per-row figures, **Ticks**, and **Misses** return to 0 while **Laps** does not. Stats still shows the latest day that has a count until today is ticked.
- A Stats day page shows at most six mark lines. History lists each mark on its own row.
- **Show onboarding** then **Skip** or **Finish** restores the names **Cups**, **Pages**, and **Calls** for those starter rows and lights **Cups**.
- After **Erase the board**, onboarding returns. That is intended.
- **Retry** only clears an unreadable notice so the screen can be used again. The title **Board unreadable.** can appear even when the detail is **Board restored from the backup.**

## Starter content and resume

After **Skip** or **Finish** on a device, three rows are seated: **Cups**, **Pages**, and **Calls**. **Cups** is lit. There are no sample ticks.

On Simulator only, a first empty launch can skip onboarding and already show those three rows, with one tick on each for the previous day, one lap, and **Day closed** marks for that day. Today’s counts are 0. That seed does not run on a physical device.

Rows, today’s counts, laps, misses, and history stay on this device and come back on the next launch. Unfinished onboarding does not resume mid-page; it starts at **One tap order.** again. Unsubmitted **Row name** / **Name** text in Library is not kept if the sheet is dismissed. Work on the board can be resumed after the app is left or killed. Open sheets are not restored.

## Permissions

None.

## Absent

Genuinely absent: login or accounts, in-app purchase, ads, analytics, public or shared user-generated content, an account deletion flow, and an App Tracking Transparency prompt. People only type private row names on this device.

## Data and support

Data stays on this device. The erase confirmation says **Counters and marks on this device are deleted.**

The on-screen control is **Contact**. It opens the support page.

## Scanning and health

None.

## Platform

English UI. Day labels and numbers follow the device’s region and calendar. No region lock. Portrait only, full screen, dark appearance. iPhone and iPad. Minimum iOS 17.0.

## Category

Lifestyle.
