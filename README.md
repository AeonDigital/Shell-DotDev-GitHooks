Shell-DotDev-GitHooks
================================

> [Aeon Digital](http://aeondigital.com.br)  
> rianna@aeondigital.com.br

&nbsp;

> A unified, automated Git Hook quality gatekeeper designed to natively orchestrate
> codebase compliance, Shell standardization, and Human-Centric Markdown readability.

&nbsp;

Enforcing ecosystem consistency goes far beyond writing clean functions — it requires
automated barriers that prevent out-of-spec code from entering your repository. **Shell-DotDev-GitHooks**
is a modular quality assurance framework engineered as an agnostic Git submodule.

Instead of forcing developers to manually invoke separate linters or isolated utility
tools before every push, this project hooks directly into the core Git lifecycle.
It intercepts `git commit` actions to evaluate modified content in real time, executing
strict aesthetic formatting, documentation compliance, and compilation automation
before any code leaves the local workstation.




&nbsp;
________________________________________________________________________________

## PREREQUISITES

Before deploying the toolchain, ensure your local environment meets the following
minimal requirements:

- **Git** (v2.25.0 or higher)
- **Bash** (v4.0 or higher)
- **Curl** (for the remote installer stream)
- **GNU Make** (to orchestrate lifecycle maintenance commands)




&nbsp;
________________________________________________________________________________

## QUICK INSTALL

To deploy this quality gatekeeper into your workspace instantly and transparently,
run the command below from the exact root folder of your project repository. The
automated installer will evaluate your environment, provision the isolated `.dev/`
path layouts, and attach the submodule safely:

```bash
# Pull and execute the environmental core provisioning pipeline
curl -sSL "https://raw.githubusercontent.com/AeonDigital/Shell-DotDev-GitHooks/refs/heads/main/install.sh" | bash
```

The setup script operates defensively and outputs real-time diagnostic reports to
stdout. If the execution path is not a valid Git repository root, or if an existing
toolchain footprint is detected under `.dev/tools/githooks`, the installation is
aborted immediately to protect local repository assets from data loss.




&nbsp;
________________________________________________________________________________

## HOW IT WORKS & USAGE

Once installed, the framework integrates seamlessly into your standard Git workflow.
You do not need to learn new commands:

1. **Triggering the Gatekeeper:** Whenever you execute `git commit`, the pre-commit
   hook automatically intercepts the action and scans *only the staged files*.
2. **Evaluation Pass:** If all modified `.sh` and `.md` files comply with the formatting
   rules, and the distribution bundle builds successfully, the commit is recorded.
3. **Failing the Gate:** If any file violates the strict aesthetic or syntax rules,
   the gatekeeper blocks the commit, outputs a detailed diagnostic report, and points
   out exactly what needs to be fixed.




&nbsp;
________________________________________________________________________________

## CORE ARCHITECTURAL PILLARS

The orchestrator operates by centralizing three specialized engineering and compliance
engines, managing the local workstation ecosystem using a modular and predictable
layout:

- **Shell Code Standardization:** Native integration with **Shell-Formatter**. The
  engine intelligently scans modified `.sh` scripts, interprets syntax comments using
  natural Markdown rules, and automatically triggers word wrapping while maintaining
  uniform column widths and precise indentation margins.


- **Plain-Text Documentation Compliance:** Verification and geometric alignment of
  `.md` assets under the strict rules of the **MD-ReadI** initiative. Guarantees
  structural breathing spaces, predictable vertical rhythms, and exact character-width
  horizontal dividers for comfortable reading inside legacy terminal viewports.


- **Automated Asset Ingestion & Distribution Compilation:** Native binding to the
  **Shell-Mngm-Package** toolset. When source files within application paths are
  updated, the pre-commit gatekeeper triggers the *Exporter* to minify and flatten
  dependencies into a single-file distribution bundle (*Single-File Bundle*), while
  its *Installer* counterpart safely handles remote transport streams and environment
  package tracking.




&nbsp;
________________________________________________________________________________

## THE ISOLATED ECOSYSTEM PHILOSOPHY

The architecture of this project is built on the principle of absolute isolation
to safeguard the custom project workspace, strictly decoupling immutable engine core
logic from mutable user properties:

```text
your-host-project/
└── .dev/
    ├── config/githooks/        <-- SACRED USER SPACE (Editable)
    │   └── [Local configuration blueprints and custom rule sets]
    └── tools/githooks/         <-- GIT SUBMODULE ROOT (Read-Only Core)
        ├── src/                <-- Diagnostic modules and validation logic
        └── setup/              <-- Baseline factory presets and templates
```


The `.dev/tools/githooks/` path is the physical root directory of the attached Git
submodule and must be treated as **Read-Only**. Any downstream release or engine
update changes this internal tree exclusively. Any modification or custom project
behavior a developer wishes to override must take place strictly inside the `.dev/config/githooks/`
directory space. This clean separation guarantees that updating the submodule will
never overwrite local project configurations.




&nbsp;
________________________________________________________________________________

## MAINTENANCE & LIFE CYCLE

Once the provisioning process completes successfully, the host repository features
simplified maintenance utilities to orchestrate the submodule lifecycle. You can
discover all available administrative operations by invoking the native helper target:

```bash
# Consult available update, reset, and lifecycle management targets
make help
```




&nbsp;
________________________________________________________________________________

## OPTIONAL TOOLCHAIN EXTENSIONS

During the automated interactive installation stream, the core pipeline allows you
to provision two decoupled operational extensions to accelerate your localized development
velocity



### 1. Dynamic Context Loader (`devexec.sh`)

If enabled, a localized instance of the execution loader is safely detached and written
directly into your host project folder at `.dev/devexec.sh`.

This runtime orchestrator recursively discovers and sources raw shell functions from
your `src/` tree on-the-fly, granting you immediate execution access within your
active terminal session. It operates defensively, using strict sorting barriers to
isolate production functions from test or automation dependencies.

```text
your-host-project/
└── .dev/
    └── devexec.sh              <-- VOLATILE DEV INTERFACE (Active loader)
```

Because this utility mutates your active shell context, it must be evaluated using
the native shell built-in evaluation pointers (`source` or `.`):

```bash
# Evaluate and bind active source functions into your immediate shell context
. .dev/devexec.sh
```

**Architectural Constraints & Rules:**

- **Path Isolation:** Must be executed strictly from the base root directory of your
  project.
- **Defensive Exclusions:** Automatically skips unit testing scopes (`*_test.sh`)
  and continuous deployment or initialization pathways (`*_autoexec.sh`) to eliminate
  memory context leakage.



### 2. Tailored VS Code Workspace Tasks

If authorized, the interactive installer will automatically inspect your editor assets,
safely creating or merging native automation macros inside `.vscode/tasks.json`.

If an existing configuration footprint is detected, the provisioning script executes
a non-destructive merge routine to inject the specialized **Shell-Formatter** and
**MD-ReadI Formatter** configurations into your task sequence without wiping out
pre-existing workspace profiles.


#### Advanced Velocity: Desktop Keybindings

To execute these formatting pipelines instantly on your active buffer without navigating
menus, append the following blueprint directly to your global VS Code user keybindings
(`keybindings.json`):

```json
[
  {
    "key": "ctrl+alt+f",
    "command": "workbench.action.tasks.runTask",
    "args": "Run Shell-Formatter",
    "when": "editorLangId == shellscript && editorTextFocus"
  },
  {
    "key": "ctrl+alt+f",
    "command": "workbench.action.tasks.runTask",
    "args": "Run MD-ReadI Formatter",
    "when": "editorLangId == markdown && editorTextFocus"
  }
]
```




&nbsp;
________________________________________________________________________________

## MARKDOWN READABILITY INITIATIVE

This project documentation follows the structural and semantic guidelines proposed
by the [Markdown Readability Initiative](https://github.com/AeonDigital/MD-ReadI).




&nbsp;
________________________________________________________________________________

## LICENSE

This project is offered under the [MIT license](LICENSE.md).