<!-- gf-brief source=addc7c4248f5abe72ef8b38ce603984f87a14a843f9ebbf557ea74584155426c written=2026-10-09T13:01:32+03:00 -->
# Polinodrom
## What it is
Polinodrom is a once-a-day card for people who will open one small prompt and either keep it or skip the day. Each calendar day deals a single stub: a short word and a micro-action from a fixed set of eight. There is no streak, no program, and no account.

## Launch and onboarding
Cold launch is a pale, empty screen with no wordmark, no illustration, and no buttons. The home screen then opens.

If onboarding has not been finished, a full-screen sequence covers home. **Skip** is on every page and ends onboarding. **Continue** advances. On the last page the button still reads **Continue** (VoiceOver: “Continue to today”) and then shows today.

1. **One card today** — “The day deals a single stub from the bundled stock.” Buttons: **Skip**, **Continue**.
2. **Reveal, then crease** — “Open the card, then drag the perforation onto the year.” Buttons: **Skip**, **Continue**.
3. **Pass without a streak** — “Skip the day and the cell stays empty. No penalty.” Buttons: **Skip**, **Continue**.

After **Skip** or the last **Continue**, home is today’s card. There is no sign-in and no tab bar. Onboarding does not run again unless **Run onboarding again** is used in Settings.

While today is still opening, the large word is **Today**, the line is “Opening today's stub.”, and the job line is “One card, then crease the perforation.” A spinner may sit on the card.

## Screens

### Today (home)
No navigation title. Decorative header art at the top. Three icon-only controls (VoiceOver: **Collection**, **Year**, **Settings**) open those sheets. Below: a large word, a **Day** caption with the day-of-year number (1–365 or 366), a job line, a micro-action line, a card that flips face up after a reveal, then a strip with **Creased** and the crease count, a phase word (**Sealed**, **Revealed**, **Kept**, or **Passed**), and an eight-digit date number (year, month, day with no separators). **Reveal**, **Pass**, and **Retract** sit in a row. A bottom control labelled **Crease** is a drag, not a tap: pull it most of the way to the right to file today. VoiceOver names that control **Crease the perforation** and its value **Face down** or **Face up**.

While today is still **Sealed**, a full-page plate covers the card, the verbs, and the **Crease** drag. The three sheet icons stay available.

- **Today's card is waiting**
- “Drag the perforation after you reveal it.”
- **Crease** — reveals today’s card. It does not crease yet. The plate then hides.

The **Reveal** button is enabled only while **Sealed**, which is the same time this plate covers it. The usual way to open the card is the plate’s **Crease**, not **Reveal**.

After a reveal, the large word is the stub word, the micro-action is shown, the job line is “Drag the perforation to crease today's stub.”, and the phase is **Revealed**. If the card were visible while still sealed, the micro-action line would be “The micro-action stays shut until you reveal it.” and the job line “Reveal the card, then drag the perforation.” If there is no stub, the large word is **Sealed**.

Controls:

- **Reveal** (VoiceOver: “Reveal today's card”) — opens today’s stub. Enabled only while **Sealed**. After that it stays dimmed. A second reveal does nothing.
- **Pass** (VoiceOver: “Pass today”) — files today as empty on the year wall. Enabled while **Sealed** or **Revealed**. After **Pass**, the job line is “Today stays empty. No streak, no penalty.” and the phase is **Passed**. The word and micro-action stay on the home card; Collection does not gain a row.
- **Retract** (VoiceOver: “Retract today”) — undoes today’s **Kept** or **Passed** and returns the card to **Revealed**. The word and action stay visible. The matching Collection row is removed. Enabled only after **Kept** or **Passed**, and only for today.
- **Crease** (drag) — files today as **Kept**. Enabled only while **Revealed**. After a crease, the job line is “Today is filed on the year wall.”, the phase is **Kept**, a mark flashes, and VoiceOver can announce “Creased”.
- **Collection** — opens the Collection sheet.
- **Year** — opens the Year sheet.
- **Settings** — opens the Settings sheet.

If today’s stub cannot be opened, a full-page plate replaces home (the sheet icons are covered too):

- **Today's stub did not open**
- “The chart on this device could not be read. Try again.”
- **Try again** — reloads today.

At local midnight (or when the app returns to the foreground after the date changes), yesterday stays as it was on the year wall and a new sealed card appears. Only today’s stub can change.

The eight stubs, in rotation, one per calendar day:

- **Walk** — “Step outside for ten minutes and come back.”
- **Water** — “Drink one full glass of water before the next task.”
- **Page** — “Read one page of something already on the shelf.”
- **Stretch** — “Roll both shoulders slowly, ten times each way.”
- **Thanks** — “Send a short thanks to one person you meant to write.”
- **Clear** — “Clear one small surface you look at every day.”
- **Breath** — “Take six slow breaths with both feet on the floor.”
- **Song** — “Play one song all the way through, then stop.”

### Collection
Title is **Collection** plus the count, for example **Collection 0**. **Close** (X control) dismisses the sheet.

When at least one stub is creased: a large count, the caption “Creased stubs on this device”, then a list. Each row is the stub word; under it, the eight-digit date, a period, and the micro-action. Rows do not open a further screen. The list grows with each crease and is ordered with the newest day first.

When none are creased:

- **No stubs creased yet**
- “Crease today's stub and it files here.”
- **Crease** — closes the sheet. It does not crease from here.

If the list cannot be read and is empty:

- **The collection could not be read**
- “The last chart on this device did not open. You can crease today again.”
- **Try again** — reloads, then shows the list or the empty plate.

### Year
Title **Year** (large title). **Close** dismisses the sheet.

The wall is a long scrolling list of every day of the current calendar year, starting at 1 January. It does not jump to today. Each row shows the month name and day number (month names follow the device language), the eight-digit date, and a status: **Kept**, **Passed**, **Sealed**, or **Revealed**. Days that were never opened read **Sealed** and do not preview that day’s stub.

Tap a row for an alert titled with the date and status, then **Close**:

- **Kept** — “{word}. {action}”
- **Passed** — “Passed. The cell stays empty.”
- **Revealed** — “{word}. Drag the perforation on today to crease it.”
- **Sealed** — “Sealed. This day has not been opened.”

If the wall cannot be read:

- **The year could not be read**
- “The chart on this device did not open. Today can still be creased.”
- **Crease** — closes the sheet.

A plate **The year wall is clear** / “Reveal today and the first cell files here.” / **Crease** exists, but a normal year already has a row for every day, so this plate is not the usual first view.

### Settings
Title **Settings**. **Close** dismisses the sheet. Four rows:

- **Export collection** — opens the system share sheet with a text file of creased stubs. Each line is the eight-digit date, the word, a period, and the action. If nothing is creased yet, the file still shares and its text is “No stubs creased yet.” If the file cannot be written, a footer reads “The collection file could not be written. It is still on this device.”
- **Contact** — opens the support page.
- **Run onboarding again** — closes Settings and shows the three onboarding pages on return to home. Existing creases and passes are not erased.
- **Erase the collection** — alert **Erase the collection?** / “Creased stubs on this device are deleted.” Buttons: **Keep** (dismiss) and **Erase**. **Erase** clears creased stubs, passed days, and the year wall; today becomes a sealed card again; onboarding is not shown again.

When there is at least one crease, a footer reads “{n} creased stubs on this device.” If the collection cannot be read and the count is zero, the footer is “The chart could not be read. Try again from the poster.”

## Features
- One stub per calendar day from the bundled eight, in a fixed rotation.
- **Reveal** (from the waiting plate’s **Crease**) to open the word and micro-action.
- Drag **Crease** to file today as **Kept** on the year wall and in Collection.
- **Pass** to leave the year cell empty, with no streak and no penalty.
- **Retract** the same day to undo a crease or a pass.
- **Collection** of creased stubs on this device.
- **Year** wall of **Kept**, **Passed**, **Sealed**, and **Revealed** days.
- **Export collection** as a shareable text file.
- **Contact** for support.
- **Run onboarding again**.
- **Erase the collection** after a confirm.

## Behaviours that can look like bugs
- Until today is revealed, the waiting plate covers **Reveal**, **Pass**, **Retract**, and the **Crease** drag. The plate button is **Crease** but it only reveals. Tap it, then use the real controls.
- **Reveal** is dimmed once the card is open. A second reveal does nothing.
- The bottom **Crease** is dimmed until the phase is **Revealed**. A short drag snaps back; only a long drag to the right files **Kept**.
- **Pass** is dimmed after **Kept** or **Passed**. **Retract** is dimmed until today is **Kept** or **Passed**.
- After **Pass**, home still shows the word and micro-action. “Empty” means the year cell, not a blank home card. Collection does not list passed days.
- **Retract** only works for today, and only before the date changes. After midnight, yesterday stays as filed.
- **Retract** returns today to **Revealed**, not to a sealed card. The waiting plate does not come back that day.
- Collection starts at **No stubs creased yet** until the first crease. **Crease** on that plate only closes the sheet.
- Year opens on 1 January. Most rows read **Sealed** on a new install. That is the wall, not a failed load. Scroll to find today.
- After **Erase**, Collection is empty, passed days are gone, the year wall is **Sealed** again, and today is sealed. Onboarding does not return unless **Run onboarding again** is used. The Settings footer may still show the old count until the sheet is closed and opened again.
- **Export collection** still opens a share sheet when the list is empty; the file says “No stubs creased yet.”
- If home shows **Today's stub did not open**, tap **Try again**. The same plate can return. Sheet icons stay covered until that plate is gone.
- Disabled verbs look faded. They also stay dim while a change is in flight.

## Starter content and resume
The eight stubs listed under Today ship with the app. A new install on a device has no creased stubs and today’s card is sealed.

A reveal that is not creased or passed is kept and can be finished later the same day. After midnight that day stays as it was on the year wall and a new sealed card appears. Creases, passes, and finished onboarding survive relaunch. **Erase the collection** clears creases, passes, and the year wall, and reseals today; it does not clear finished onboarding.

## Permissions
None.

## Absent
Login or accounts, in-app purchase, ads, analytics, user-generated content, account deletion flow, and an App Tracking Transparency prompt are all absent.

## Data and support
Creases, passes, and today’s card stay on this device unless the person exports or erases. **Contact** in Settings opens the support page.

## Scanning and health
None. The app does not scan barcodes or QR codes. The daily stubs are ordinary prompts, not health or medical information, and there are no citations.

## Platform
Interface copy is English. Month names on Year follow the device region and language. Numbers are shown without grouping separators. The calendar day is the device’s local day. Portrait only, light appearance, full screen. iPhone and iPad. Minimum iOS 17.0.

## Category
Lifestyle
