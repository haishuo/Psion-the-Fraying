# Images

Character art and cards for *Psion: The Fraying*. Markdown files reference these by paths relative to their own folders (for example, `People/Marcus Thiel.md` uses `../images/marcus-thiel.png`).

**Save finalized images with these exact filenames** (PNG) so the embeds resolve. If you save in another format, change the extension here and in the referencing doc to match.

| File | Subject | Embedded in |
|------|---------|-------------|
| `marcus-thiel.png` | Marcus Thiel — "Mind Hunter" character card | `People/Marcus Thiel.md` (top) |
| `isolde.png` | Isolde — Ventrue character + stat card (finalized oWoD block) | `People/Marcus Thiel.md` ("Isolde — the exception") |
| `eve-taranis-vire.png` | Eve Taranis Vire — "The Anomaly" character card | `People/Eve.md` (top) |
| `eve-parents-lyra-julian.png` | Lyra Taranis & Julian Vire — "The Parents of Eve" card | `People/Eve.md` ("The Bloodline") |
| `metaconcert-seven-circuits.png` | The MetaConcert — Seven Circuits infographic poster | `MetaConcert/The MetaConcert - Overview.md` (top) |
| `Marcus and Leah/Verbena.png` | Leah — ordinary Verbena presentation | `People/Leah Mercer.md` (top) |
| `Marcus and Leah/Verbena2.png` | Leah performing a blood rite | `People/Leah Mercer.md` ("Appearance") |
| `Marcus and Leah/Leah and Marcus planting.png` | Marcus and Leah planting together | `People/Leah Mercer.md` ("The Job") |
| `Marcus and Leah/Marcus and Preggo Leah.png` | Marcus and Leah expecting a child — authored future | `People/Leah Mercer.md` ("The Authored Future") |
| `Marcus and Leah/Thiel Family Breakfast.png` | The Thiel family — authored future | `People/Leah Mercer.md` ("The Authored Future") |
| `Marcus and Leah/Old Farts still in love.png` | Marcus and Leah in old age — authored future | `People/Leah Mercer.md` ("The Authored Future") |

*All cards are illustrative reference art, not rules text. Where a card shows a stat block, the doc text remains the canonical source.*

---

## These files are not in git — author's ruling, 2026-08-05

**The images live in Backblaze B2, not in this repository.** They are on disk here as the working
copy, so every embed in the project renders exactly as before, but git does not track them and
`.gitignore` keeps them out.

```
./sync_art.sh status     what differs between local and B2 (default)
./sync_art.sh verify     compare every file by hash
./sync_art.sh push       upload  — DRY RUN unless you add --yes
./sync_art.sh pull       download — DRY RUN unless you add --yes
```

Bucket `haishuo-writing-images`, prefix `psion-the-fraying/`, at paths mirroring this repository,
with B2 file versioning on — a replaced or deleted image keeps its prior version and is
recoverable from the B2 console.

**Why.** Git stores meaning in text: a small edit to a document costs bytes and reads as that edit.
A PNG has no diffable interior, so git stores a whole new multi-megabyte object and returns nothing
for it. At the time of the move, the nine images were **24 MB of a 25 MB repository** whose entire
text history packed to under 900 KB. Art needs durability rather than history, and that is a
different problem with a different tool.

**Consequences to know.** A **fresh clone has no images** — run `./sync_art.sh pull --yes` after
cloning. Embeds render correctly in any reader that resolves relative paths against your filesystem;
they show as broken images **on github.com**, which renders from the repository tree and cannot see
your disk. That is accepted, and re-adding the PNGs is not the fix.

**Filenames still matter exactly as much as before.** The embeds resolve by name, so the naming rule
above is unchanged — save finalized images with the exact filenames listed, and if you change one,
change it in the referencing doc, in this table, and then `./sync_art.sh push --yes`.

*The table lists embedded assets only. `panopticon.png` and the remaining studies in
`Marcus and Leah/` are currently embedded nowhere.*
