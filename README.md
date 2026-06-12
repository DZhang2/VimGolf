# Vim Golf - Terminal Edition

A terminal-based vim golf game. Solve editing challenges in as few keystrokes as possible.

## How to Play

```bash
chmod +x vimgolf.sh
./vimgolf.sh
```

## Rules

Each level presents a **START** text and a **GOAL** text side by side. Your job is to transform START into GOAL using vim, in as few keystrokes as possible. Vim opens with `-u NONE -N` (no vimrc, nocompatible mode).

- Your keystrokes are recorded via `vim -W`
- The save command (`:wq`, `ZZ`, `:x`) is **not** counted
- Beat par to earn a star on the scoreboard
- Two hint levels per puzzle: press `h` once for a nudge, again for more detail

## Controls

### Main Menu

| Key | Action |
|-----|--------|
| `t` | Tutorial (beginner track) |
| `p` | Play all (normal) levels sequentially |
| `l` | Level select |
| `h` | Hard mode (unlocked per level) |
| `e` | Expert track (no solution key) |
| `s` | Scoreboard |
| `k` | Solution key |
| `r` | Reset scores |
| `q` | Quit |

### During a Level

| Key | Action |
|-----|--------|
| `Enter` | Launch vim |
| `h` | Show hint (press again for a more specific hint) |
| `s` | Skip level |
| `q` | Quit |

### After Completing a Level

| Key | Action |
|-----|--------|
| `Enter` | Next level |
| `r` | Retry (improve your score) |
| `m` | Back to menu |
| `q` | Quit |

## Tracks

The game has three independent level tracks plus a scaled hard mode:

- **Tutorial** (`tutorial/`, 15 levels) — a beginner ramp that teaches vim
  fundamentals through hands-on editing: **motions and text objects**,
  **visual-block** edits, **search-and-jump**, and short **macros**. Ordered
  easiest-first.
- **Normal** (`levels/`, 15 levels) — the original challenges, leaning on
  powerful Ex commands (`:s`, `:g`, `:sort`, `:norm`, external filters).
- **Hard** — a programmatically-scaled variant of the Normal levels (see below).
- **Expert** (`expert/`, 6 levels) — brutal multi-stage challenges that demand
  combining many techniques in one solution (multiline regex, the `\=`
  expression register, `:global` reordering, registers + macros, visual-block
  arithmetic). Each operates on **100+ lines of input**, so a manual,
  line-by-line approach can't reach par — only a scale-invariant command or
  macro solution wins (same philosophy as Hard mode). **No solution key** —
  each shows as hidden. Par 37–49. Ordered
  easiest-first.

### Tutorial levels

| # | Challenge | Category | Par |
|---|-----------|----------|-----|
| 1 | Fix the transposed letters (`xp`) | manual | 2 |
| 2 | Join three lines into one (`3J`) | manual | 2 |
| 3 | Swap two lines (`ddp`) | manual | 3 |
| 4 | Make four copies of a line (`yy3p`) | manual | 4 |
| 5 | Delete the function arguments (`di(`) | motion | 5 |
| 6 | Keep only the first sentence (`f.lD`) | motion | 4 |
| 7 | Delete the parenthesized list (`f(d%`) | motion | 4 |
| 8 | Uppercase the second word (`gUiw`) | motion | 5 |
| 9 | Replace the text inside the quotes (`ci"`) | motion | 13 |
| 10 | Move the last line to the top | manual | 6 |
| 11 | Delete the line containing 'delete' (search) | search | 10 |
| 12 | Delete a leading column (visual block) | manual | 4 |
| 13 | Comment out every line (visual block) | manual | 7 |
| 14 | Append a semicolon to every line (visual block) | manual | 7 |
| 15 | Greet each name using a macro | macro | 19 |

### Normal levels

| # | Challenge | Category | Par | Hard Par |
|---|-----------|----------|-----|----------|
| 1 | Delete the middle line | manual | 3 | 5 |
| 2 | Change 'foo' to 'bar' on every line | ex | 12 | 12 |
| 3 | Reverse the order of lines | ex | 8 | 8 |
| 4 | Surround each word with quotes | ex | 11 | 11 |
| 5 | Convert camelCase to snake_case | ex | 16 | 16 |
| 6 | Sort lines and remove duplicates | ex | 7 | 7 |
| 7 | Increment all numbers by 1 | macro | 10 | 12 |
| 8 | Convert CSV to a markdown table | ex | 30 | 30 |
| 9 | Align the equals signs | manual | 20 | 22 |
| 10 | Extract function names into a list | ex | 20 | 20 |
| 11 | Swap two columns | ex | 27 | 27 |
| 12 | Remove blank lines | ex | 7 | 7 |
| 13 | Convert flat list to JSON array | ex | 24 | 24 |
| 14 | Number each line | manual | 16 | 17 |
| 15 | The Final Boss: flatten to valid YAML | ex | 25 | 25 |

### Expert levels

No hints below — these intentionally ship without solutions. Each combines
several techniques into one chain, and each runs on 100+ lines so manual
editing can't reach par.

| # | Challenge | Input lines | Par |
|---|-----------|-------------|-----|
| 1 | Collapse 100 indented outline blocks into `parent::Child` breadcrumbs | 300 | 37 |
| 2 | Pretty-print 100 messy `KEY: Value` lines as one JSON object | 100 | 43 |
| 3 | Strip a qualifier, reverse, and renumber 100 enum members 1..N | 100 | 44 |
| 4 | Collapse 100 INI-style `[user]` blocks into one CSV row each | 499 | 47 |
| 5 | Extract the 100 ERR lines from 200, reformat, and reverse | 200 | 48 |
| 6 | Number 100 ids 1..N, then set each cap to id×50 | 100 | 49 |

## Adding Levels

Level content lives in [`tutorial/`](tutorial/), [`levels/`](levels/), and
[`expert/`](expert/) — one `NN.level` file per level,
separate from the game logic. To add a level, drop the next-numbered file into
the track's directory (e.g. `tutorial/16.level` or `levels/16.level`); the game
counts the files in each directory automatically and the solution key picks it
up. Each file looks like:

```
desc: Short description shown in menus
category: motion        # ex | manual | motion | search | macro
par: 5
hint1: A gentle nudge
hint2: A more specific hint
solution: f(di(
note: Explanation line shown in the solution key.
note: (use multiple note: lines for multi-line explanations)
--- START ---
result = compute(a, b, c)
--- GOAL ---
result = compute()
--- END ---
```

Whitespace inside the START/GOAL blocks is preserved exactly, which matters
for alignment and indentation puzzles.

The `solution:` and `note:` lines are optional — omit them (as the Expert
levels do) and that level shows as *hidden* in the solution key. `category`
also accepts `expert`.

## Hard Mode

Hard mode is a programmatically-scaled variant of the 15 **Normal** levels
(the Tutorial track has no hard variant).

Each hard level scales the same concept to 50-200 lines. The par stays nearly identical because the *correct* vim solution doesn't depend on file size — if your approach requires per-line manual work, it won't scale.

Hard levels unlock after completing the corresponding normal level.

Examples of what changes:
- Level 1: Delete line 50 out of 100 (can't just `jdd` 50 times)
- Level 6: Sort and deduplicate 200 lines (same `:sort u` command)
- Level 14: Number 100 lines (manual typing is impossible at par)

## Requirements

- vim
- bash
- perl (for hard level 5 goal generation)
- `xxd` (for keystroke counting)
- A terminal with at least 70 columns (for side-by-side display)
