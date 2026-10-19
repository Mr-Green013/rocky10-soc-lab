**English** · [ภาษาไทย](chapter-template.th.md)

# Chapter template

Every chapter uses the same structure, so readers always know where they are in the work.

```
Chapter N  <title>
  Chapter summary box   3–5 goals, course labs, machines used, estimated time, start/end snapshot
  N.1 Theory             Concepts to understand before starting + diagram + "Security view" box
  N.2 Prerequisites      hardware/software, chapters to finish first, lab files used (table of repo paths)
  N.3 Hands-on steps     steps 1..n, each with: what, why, the commands (with the machine), screen illustration
  N.4 Expected result    State of the system when finished + examples of correct output
  N.5 Verification       Automatic check script + one-by-one check commands with the values you should see
  N.6 Troubleshooting    Table of symptom | cause | fix, ordered by the step where it usually happens
  N.7 Summary and review What you learned, review questions, extra exercises, cleanup/rollback, next chapter
```

## Conventions used in the book

### Always say which machine

Every code block has a label saying where it runs and as whom

| Label | Meaning |
| --- | --- |
| `[Windows · PowerShell (Admin)]` | PowerShell started with Run as administrator on the Windows machine |
| `[Windows · PowerShell]` | Normal PowerShell |
| `[pve-01 · root]` | The Proxmox shell (SSH `root@192.168.10.1` or Shell in the Web UI) |
| `[ipa-01 · aod]` | SSH into that machine as the user `aod`; commands that need privileges start with `sudo` |
| `[console · VM 9000]` | The VM console in the Proxmox Web UI (used while there is no network yet) |

### Values to replace

`<name>` in a command is a value readers replace themselves, such as `<iso-file>`. Values without angle brackets are typed as shown

### Callout boxes

| Box | Used for |
| --- | --- |
| **Note** | Extra information, safe to skip |
| **Warning** | Getting it wrong costs time or data |
| **Security view** | Links the task to SOC work: how it is attacked and how it is detected |
| **Admin Fast Track** | For readers with experience: shortcuts or what can be skipped |

### Figures

- **Diagrams** are already drawn. The SVG sources are in `assets/diagrams/chNN/` (the English set is in `assets/diagrams/chNN/en/`)
- **Screen illustrations** (GUI and terminal) are drawn and embedded in the book, marked "ภาพจำลอง" (illustration) in the top-right corner. File names follow the pattern `ch01-fig05-hyperv-switches.png`
- Figures are numbered continuously through a chapter: Figure 1-1, 1-2, … with no separate numbering for diagrams and illustrations
- To replace an illustration with a real screenshot, capture at 1600 px wide or more, crop to the relevant part, hide public IPs, tokens and email addresses before putting it in the book, and keep the same file name and caption

### Snapshots

At the end of a chapter that has a snapshot, run `pve-snapshot.sh chNN-<name>` on pve-01. Every following chapter can start from the previous chapter's snapshot. If the lab breaks, `qm rollback <vmid> <snapshot>`

### Secrets

There are no passwords or tokens in the repo. Every script that needs a secret asks for it with `read -s` (bash) or `Read-Host -AsSecureString` (PowerShell), or reads it from a `.env` file listed in `.gitignore`
