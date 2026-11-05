# colon

```
                               i※xi※※※
 +※※xxx                     +x※x:※※※※※i
 ※※※※※※i※※※i             +※※※ii※※※i※i+
 ii+※※※※※+8:※i※xxx※※x※x※ii88※※※※※x:-sx
  s+·  x※※※※※※※※xi88※※※※※※※※※※8i:-※i※+
  ※si-   i※※i※※※※※※※※※※※※※※i※i  +++:※※
  i:xi:          +iii           i+s※※i
 :++::·                         +ss※※※i
 x※※+s+                         :s※※※※i
 ※※:sx+          hello          ixi+x※x
x※+i:+-           from          ※x++※※※x
xxxi+:++         colon          +s※8i+ii
i※※※8※※※x                        s※※※x※※i
※※※※+8+※※x※                     -i:si+i※i
x※※x※※iii※※※i                   xs+※※※※※
 +※※※※※※※i※※i                  xxx8ix※※i
  i※※※※※xiii           i※x+:i※※i++※※※※i
    xiii+  +       xx※※※※※※※8++※i8※※※※i
            x     ※※※※※※※※※i※※※※※iiii
            x     i※※※xs:x※※i※※※※i
                   +※※s+
                   +※※※i
                   i※※※i
                     xi
```

Ask Claude about the command you just ran, without leaving the prompt.

```
~ pnpm update-self
 ERR_PNPM_… something broke
~ : why error? fix
· Read package.json
· Edit package.json
The lockfile pins pnpm 9 but … fixed the `packageManager` field.
~ pnpm install▌                     ← suggested next command, ready to run
```

- `: <question>` asks. The answer streams inline, then you're back at your prompt.
- Claude sees the last command, its exit code and **its output**, and may read and edit files.
  It can't run commands. When a command is the fix, it's placed at your prompt for you to run.
- One conversation per terminal window: later `:` questions are follow-ups. `:new` starts over.
- `:colon` says hello.
- Answers are tinted orange. Set `COLON_COLOR` to another SGR code (`36`, `38;5;110`), or to empty for none.

## Install

Needs zsh, python3 (stdlib only) and [Claude Code](https://claude.com/claude-code) (`claude`) on `PATH`.

```sh
git clone https://github.com/kkrll/colon ~/.colon
```

Then near the **top** of `~/.zshrc`:

```zsh
source ~/.colon/colon.zsh
```

Open a new terminal window.

## How it sees output

`colon.zsh` restarts your shell under `bin/colon shell`, a small pty wrapper that passes
every byte through unchanged. zsh marks where each command's output starts and ends
(OSC 133 `C` / `D`, the same marks terminals use for jump-to-prompt). The wrapper keeps:

- **only the last command's output.** It's cleared when the next command starts.
- **only its last 300 lines**, in memory. Nothing is written to disk.
- **until it's read once.** `:` takes it over a socket only your user can open, and then it's gone.

Output leaves your machine only when you type `:`. If the last command printed a secret, don't ask.

Because it starts early in `.zshrc`, the shell that gets replaced has done little work.
Under Ghostty, Ghostty's shell integration is loaded again in the new shell.

## Replacing ForgeCode

ForgeCode binds Enter too. Comment out its `# >>> forge initialize >>>` block in `~/.zshrc`.
