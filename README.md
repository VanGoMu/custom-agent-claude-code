# Custom Agents para Claude Code

[![Release](https://img.shields.io/badge/release-v1.0.0-blue)](https://github.com/epicuro/custom-agent-claude-code/releases)
[![Handoff Smoke CI](https://github.com/epicuro/custom-agent-claude-code/actions/workflows/handoff-install-smoke.yml/badge.svg)](https://github.com/epicuro/custom-agent-claude-code/actions/workflows/handoff-install-smoke.yml)
[![License](https://img.shields.io/github/license/epicuro/custom-agents-vs-code)](https://github.com/VanGoMu/custom-agent-claude-code/blob/main/LICENSE)

Colección de **skills y agentes** para Claude Code.

---

## Comparativa con VS Code

| VS Code (`.agent.md`)               | Claude Code                                                              |
| ----------------------------------- | ------------------------------------------------------------------------ |
| `user-invocable: true`              | **Skill** (`~/.claude/skills/`) — invocado con `/nombre`                 |
| `user-invocable: false` (subagente) | **Agente** (`~/.claude/agents/`) — instrucciones pasadas al `Agent` tool |
| `tools: [...]`                      | Herramientas mencionadas en las instrucciones (sin restricción dura)     |
| `agents: [A, B, C]` handoffs        | El skill orquestador lee los archivos de agentes y usa el `Agent` tool   |
| Cuerpo de instrucciones             | Contenido del archivo `.md`                                              |

---

## Skills disponibles

Los skills son los **orquestadores user-invocables**. Se invocan con `/nombre` en Claude Code.

| Skill               | Invocación           | Descripción                                                                                                                     |
| ------------------- | -------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| `init-project`      | `/init-project`      | Inicializa cualquier proyecto: valida el prompt → genera plan → descompone en sprints                                           |
| `shell-project`     | `/shell-project`     | Flujo TDD shell completo: framework OCP → tests bats (RED) → scripts (GREEN) → DevOps                                           |
| `python-project`    | `/python-project`    | Flujo TDD Python completo: paradigma OOP/Funcional → tests pytest (RED) → implementación (GREEN) → DevOps                       |
| `node-project`      | `/node-project`      | Flujo TDD Node.js/TypeScript completo: paradigma + Jest/Vitest (RED) → implementación (GREEN) → DevOps                          |
| `langchain-project` | `/langchain-project` | Flujo TDD LangChain completo: LCEL/Chains o Agent+Tools → contratos tipados → tests (RED) → implementación (GREEN) → DevOps     |
| `crewai-project`    | `/crewai-project`    | Flujo TDD CrewAI completo: gate PromptValidator → crew secuencial/jerárquico → contratos → tests (RED) → implementación (GREEN) |

---

## Agentes disponibles

Los agentes son las **instrucciones de subagentes especializados**. No se invocan directamente; los skills los usan a través del `Agent` tool de Claude Code.

### Transversales

| Agente             | Descripción                                                                            |
| ------------------ | -------------------------------------------------------------------------------------- |
| `prompt-validator` | Valida si el prompt tiene suficiente información (devuelve JSON `proceed: true/false`) |
| `project-planner`  | Genera plan de proyecto: objetivos, MVP, stack, arquitectura, riesgos                  |
| `sprint-planner`   | Descompone el plan en sprints con backlog priorizado y roadmap Mermaid                 |

### Shell

| Agente                    | Descripción                                                                      |
| ------------------------- | -------------------------------------------------------------------------------- |
| `shell-project-organizer` | Scaffoldea el framework shell con OCP (plugins/hooks) y registro de dependencias |
| `shell-developer`         | Fase GREEN: implementa scripts con SOLID, cabeceras y validación shellcheck      |
| `shell-test-engineer`     | Fases RED y VERIFY: suite bats con stubs, Docker Ubuntu/Alpine                   |
| `shell-devops`            | CI local (pre-commit) y GitHub Actions con matriz Ubuntu/Alpine                  |

### Python

| Agente                     | Descripción                                                                   |
| -------------------------- | ----------------------------------------------------------------------------- |
| `python-project-organizer` | Decide OOP/Funcional, scaffoldea src-layout con SOLID, valida con ruff + mypy |
| `python-developer`         | Fase GREEN: implementa código mínimo con type hints + SOLID                   |
| `python-test-engineer`     | Fases RED y VERIFY: suite pytest con mocks de ports, cobertura >= 80%         |
| `python-devops`            | CI local (pre-commit) y GitHub Actions dockerizada                            |

### Node.js / TypeScript

| Agente                   | Descripción                                                                    |
| ------------------------ | ------------------------------------------------------------------------------ |
| `node-project-organizer` | Decide OOP/Funcional + Jest/Vitest, scaffoldea TypeScript src-layout con SOLID |
| `node-developer`         | Fase GREEN: implementa TypeScript estricto sin `any` ni `@ts-ignore`           |
| `node-test-engineer`     | Fases RED y VERIFY: suite Jest/Vitest con doubles tipados, cobertura >= 80%    |
| `node-devops`            | CI local (pre-commit) y GitHub Actions con detección automática Jest/Vitest    |

### LangChain

| Agente                        | Descripción                                                                                |
| ----------------------------- | ------------------------------------------------------------------------------------------ |
| `langchain-project-organizer` | Decide LCEL/Chains o Agent+Tools, scaffoldea src-layout con contracts/ports tipados        |
| `langchain-developer`         | Fase GREEN: implementa mínimo por módulo (schemas → ports → prompts → pipeline → adapters) |
| `langchain-test-engineer`     | Fases RED y VERIFY: doubles para LLM/tools, cobertura >= 80%, Docker CI                    |
| `langchain-devops`            | CI local (pre-commit) y GitHub Actions dockerizada con gate ruff + mypy + pytest           |

### CrewAI

| Agente                     | Descripción                                                                                 |
| -------------------------- | ------------------------------------------------------------------------------------------- |
| `crewai-project-organizer` | Decide crew secuencial o jerárquico, scaffoldea src-layout con contracts/ports/crew tipados |
| `crewai-developer`         | Fase GREEN: implementa mínimo por módulo (schemas → ports → agents → tasks → orchestrator)  |
| `crewai-test-engineer`     | Fases RED y VERIFY: doubles para LLM/tools/memory, cobertura >= 80%, Docker CI              |
| `crewai-devops`            | CI local (pre-commit) y GitHub Actions dockerizada con gate ruff + mypy + pytest            |

---

## Instalación

### Desde GitHub (sin clonar)

```bash
# Listar todos los agentes y skills disponibles
curl -fsSL https://raw.githubusercontent.com/VanGoMu/custom-agent-claude-code/refs/heads/main/scripts/bootstrap.sh | bash -s -- --list

# Instalar todo en el perfil de usuario
curl -fsSL https://raw.githubusercontent.com/VanGoMu/custom-agent-claude-code/refs/heads/main/scripts/bootstrap.sh | bash -s -- --all --scope profile

# Instalar solo un skill
curl -fsSL https://raw.githubusercontent.com/VanGoMu/custom-agent-claude-code/refs/heads/main/scripts/bootstrap.sh | bash -s -- --skill python-project

# Instalar solo un agente
curl -fsSL https://raw.githubusercontent.com/VanGoMu/custom-agent-claude-code/refs/heads/main/scripts/bootstrap.sh | bash -s -- --agent prompt-validator
```

### Desde el repo clonado

```bash
# Instalar todo en el perfil de usuario (disponible en todos los workspaces)
./scripts/install.sh --all --scope profile

# Instalar solo el skill shell-project en el repo actual
./scripts/install.sh --skill shell-project --scope repo

# Instalar solo el agente shell-developer en el perfil de usuario
./scripts/install.sh --agent shell-developer

# Ver todos los skills y agentes disponibles
./scripts/install.sh --list
```

### Desde otro repo (ruta relativa o absoluta)

```bash
# Desde un repo hermano
../custom-agent-claude-code/scripts/install.sh --all --scope profile

# Con ruta absoluta
/path/to/custom-agent-claude-code/scripts/install.sh --skill node-project
```

### Destinos de instalación

| Scope               | Skills              | Agentes             |
| ------------------- | ------------------- | ------------------- |
| `profile` (default) | `~/.claude/skills/` | `~/.claude/agents/` |
| `repo`              | `.claude/skills/`   | `.claude/agents/`   |

---

## Uso en Claude Code

Una vez instalado, invoca los flujos con:

```
/init-project       <- inicializa cualquier proyecto nuevo
/shell-project      <- flujo TDD completo para proyectos shell
/python-project     <- flujo TDD completo para proyectos Python
/node-project       <- flujo TDD completo para proyectos Node.js/TypeScript
/langchain-project  <- flujo TDD completo para aplicaciones LangChain
/crewai-project     <- flujo TDD completo para aplicaciones CrewAI
```

Claude Code leerá las instrucciones del skill y orquestará los subagentes automáticamente.

---

## Cómo funcionan los orquestadores

Cada skill sigue este patrón de ejecución:

```
1. Valida el contexto del usuario (preguntas de contexto o PromptValidator)
2. Para cada paso del flujo:
   a. Lee el archivo del agente desde ~/.claude/agents/<nombre>.md
   b. Usa el Agent tool con esas instrucciones + contexto acumulado
   c. Guarda la respuesta como [PASO_N]
3. Presenta los artefactos finales al usuario
```

Los subagentes tienen acceso a todas las herramientas de Claude Code: `Bash`, `Read`, `Write`, `Edit`, `Glob`, `Grep`, `WebFetch`.

---

## Estructura del repositorio

```
custom-agent-claude-code/
├── README.md
├── skills/                           # Orquestadores user-invocables
│   ├── init-project.md               # /init-project
│   ├── shell-project.md              # /shell-project
│   ├── python-project.md             # /python-project
│   ├── node-project.md               # /node-project
│   ├── langchain-project.md          # /langchain-project
│   └── crewai-project.md             # /crewai-project
├── agents/                           # Instrucciones de subagentes
│   ├── prompt-validator.md
│   ├── project-planner.md
│   ├── sprint-planner.md
│   ├── shell-project-organizer.md
│   ├── shell-developer.md
│   ├── shell-test-engineer.md
│   ├── shell-devops.md
│   ├── python-project-organizer.md
│   ├── python-developer.md
│   ├── python-test-engineer.md
│   ├── python-devops.md
│   ├── node-project-organizer.md
│   ├── node-developer.md
│   ├── node-test-engineer.md
│   ├── node-devops.md
│   ├── langchain-project-organizer.md
│   ├── langchain-developer.md
│   ├── langchain-test-engineer.md
│   ├── langchain-devops.md
│   ├── crewai-project-organizer.md
│   ├── crewai-developer.md
│   ├── crewai-test-engineer.md
│   └── crewai-devops.md
└── scripts/
    └── install.sh
```

---

## Añadir un nuevo agente

1. Crea `agents/<nombre>.md` con las instrucciones del agente.
2. Si es un orquestador user-invocable, crea también `skills/<nombre>.md`.
3. Actualiza este README con la tabla correspondiente.
4. Instala con `./scripts/install.sh --agent <nombre>` o `--skill <nombre>`.

### Plantilla de agente

```markdown
# NombreAgente

Descripción del rol y responsabilidad del agente.

Herramientas disponibles: Bash, Read, Write, Edit, Glob, Grep.

---

## Flujo de trabajo

### FASE 1 — ...

...

## Respuesta al usuario

...
```
