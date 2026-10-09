# Perforator

Perforator is a daily admission stub for people who will flip one card and do one small thing. It is not a thirty-day program.

## Architecture

A Deal is a closed fold: Sealed, Revealed, Kept, or Passed. The year is that same fold keyed by a YYYYMMDD daykey. Reveal writes Revealed from the bundled pool at `dayOrdinalInYear % count`. Crease writes a CreaseMark and files Kept. Pass files Passed and leaves the cell empty, with no streak. A second Reveal on the same daykey is refused. The pool wraps only after it completes a cycle. Retract peels today's mark while the daykey is still today and returns Revealed.

That fold suits this product because the whole year is one transition table. The poster never keeps a parallel status. DealStore is the only writer, and the chart is one Codable record.

## Reveal-then-crease

This is the reason to keep the app. Home is one card for today. Reveal turns it face up, then dragging the perforation files that micro-action on the year wall. Pass leaves the cell empty, with no streak. A second reveal on the same day is refused, and the stock wraps only after the pool finishes a cycle. Collection counts the creased stubs. Settings exports that collection on this device and opens https://perforator-deal.pro/contact-us.

## Art

Soft 3D clay icons, illustrated as solid studio objects with a matte modeled skin and a gentle rounded highlight. One clear subject, quiet field, hairline depth, no text, no letters, no glass, no wire frame, no hollow box, no film-set diorama, no wall of equal figures.

- `pfo_AppIcon`: Soft 3D clay icon, illustrated. One solid clay admission stub with a perforated edge, opaque, centered, filling the canvas edge to edge. No text, no letters, no rounded mask, no drop shadow outside the canvas.
- `pfo_Splash`: Soft 3D clay illustration, vertical, filling the canvas. A short stack of solid clay admission stubs, matte, with a quiet empty middle third so a wordmark can sit there. No text, no letters.
- `pfo_Onboarding1`: Soft 3D clay icon, illustrated cutout. One solid face-down clay admission stub, opaque subject centered, matte skin, perforated edge.
- `pfo_Onboarding2`: Soft 3D clay icon, illustrated cutout. One solid clay admission stub bent at the perforation, mid-crease, opaque subject centered.
- `pfo_Onboarding3`: Soft 3D clay icon, illustrated cutout. A small uneven stack of solid creased clay stubs, opaque, centered, matte.
- `pfo_EmptyHome`: Soft 3D clay icon, illustrated cutout. One solid sealed clay stub lying closed, fully opaque, calm, centered.
- `pfo_EmptyList`: Soft 3D clay icon, illustrated cutout. One solid clay tray with a single empty recess, fully opaque ceramic-like clay, centered.
- `pfo_CardBackdrop`: Soft 3D clay field filling the canvas, low detail, quiet center, matte, so type can sit on it. No text, no letters, no busy pattern.
- `pfo_ControlFace`: Soft 3D clay icon, illustrated cutout. One solid clay perforation tab, the drag tooth, opaque, centered, matte.
- `pfo_TwistHero`: Soft 3D clay icon, illustrated cutout. One solid clay stub creased onto a small clay year cell, opaque, centered.
- `pfo_SuccessMark`: Soft 3D clay icon, illustrated cutout. One solid filled clay plug, thick and opaque, occupying the middle.
- `pfo_HeaderDecor`: Soft 3D clay illustration, a wide horizontal perforation band, matte, quiet, filling the width. No text, no letters.

## How this differs

Same daily-card family as other stubs, with a different home verb: crease the perforation on a UIKit type poster. Kept stubs and CreaseMarks replace stamped leaves. Poster-locked chrome replaces a deck tab. Collection, Year, and Settings are sheets.

## Build

```bash
cd apps/Perforator
xcodegen generate
xcodebuild build-for-testing -scheme Perforator -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
```
