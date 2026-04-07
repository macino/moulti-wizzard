# moulti-wizard

An interactive [Moulti](https://moulti.run/) wizard for Ansible playbooks.

Automatically discovers scenarios from your `site.yml` playbook and presents them as clickable buttons. When a scenario is chosen, it runs `ansible-playbook` with the matching tag — and all Ansible task output appears as collapsible Moulti steps.

```
╔══════════════════════════════════╗
║      Choose scenario             ║
║  [After Dev Checks] [After Update]  [Cache Clean]  ...  [<exit>]  ║
╚══════════════════════════════════╝
▶ TASK: ECS check & fix
▶ TASK: JS lint fix
▶ TASK: PHPStan analyse
▶ TASK: Run all checks
```

## Installation

Copy (or symlink) `moulti-wizard` to anywhere on your `$PATH`:

```bash
cp moulti-wizard ~/.local/bin/moulti-wizard
# or
ln -s "$PWD/moulti-wizard" ~/.local/bin/moulti-wizard
```

**Requirements:**
- [`moulti`](https://moulti.run/install/) — `pipx install moulti`
- `ansible-playbook` (ansible-core)
- `python3` with `pyyaml` — `pip install pyyaml` (usually installed with Ansible)

## Usage

```bash
cd /path/to/your/project
moulti-wizard
```

Options:

| Flag | Default | Description |
|------|---------|-------------|
| `--playbook <path>` | `site.yml` | Path to the Ansible playbook |
| `--title <string>` | `Moulti Ansible Wizard` | Title shown in Moulti header |
| `--collapse-tasks` | off | Collapse passing Ansible tasks (sets `MOULTI_ANSIBLE_COLLAPSE=task`) |

## Playbook convention

Each play that should appear as a wizard button must have:
- **`name:`** — used as the button label
- **`tags:`** — first tag used as the scenario ID (passed to `--tags`)

Plays without both `name` and `tags` are silently skipped.

```yaml
# site.yml
- name: "After Development Checks"   # ← button label
  tags: [ADC]                         # ← scenario ID (first tag)
  hosts: localhost
  connection: local
  gather_facts: false
  tasks:
    - name: Run linter
      ansible.builtin.command: ./bin/ecs check --fix
```

See [`examples/previo2/site.yml`](examples/previo2/site.yml) for a complete example.

## Environment variables

| Variable | Description |
|----------|-------------|
| `MOULTI_INSTANCE` | Name of the Moulti instance (default: `moulti-wizard`) |
| `MOULTI_ANSIBLE_COLLAPSE` | Set to `task` to auto-collapse passing tasks (or use `--collapse-tasks`) |

## How it works

1. Parses `site.yml` with Python's `pyyaml` to extract `(tag, name)` pairs
2. Starts a Moulti instance via `moulti run`
3. Presents a `buttonquestion` widget — one button per discovered play
4. On selection, runs `ansible-playbook site.yml --tags <tag>` with Moulti's Ansible callback active
5. Loops back to the button menu until the user clicks `<exit>`
