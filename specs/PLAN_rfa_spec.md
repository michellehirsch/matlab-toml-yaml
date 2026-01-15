# Plan: Writing the RFA Spec for Configuration File I/O Toolbox

**Created:** January 15, 2026

## Overview

This plan documents the approach for writing the RFA (Requirements, Functional Design, Architecture) specification for the Configuration File I/O Toolbox.

## Template Structure

The RFA template (RFATemplate.md) has these major sections:

### 1. Project Kickoff (REQUIRED)
- **Motivation and Key Users**
  - Problem: MATLAB lacks native YAML/TOML/INI support
  - Workflows: Reading config files, CI/CD pipelines, project metadata
  - Technical constraints: MATLAB R2022b+ for dictionary support

### 2. Requirements Analysis
- **User Roles and Goals (REQUIRED)**
  - MATLAB developers working with configuration files
  - DevOps engineers managing CI/CD pipelines
  - Data scientists with Python/MATLAB workflows
  - Package maintainers (pyproject.toml, etc.)

- **Use Cases**
  - UC_GITHUB_ACTIONS: Reading/writing GitHub Actions workflows
  - UC_PYPROJECT: Reading Python project metadata
  - UC_DOCKER: Managing Docker Compose files
  - UC_APP_CONFIG: Application configuration management

- **Requirements (REQUIRED)**
  - R_READ_YAML: Read YAML files into MATLAB objects
  - R_WRITE_YAML: Write MATLAB data to YAML files
  - R_READ_TOML: Read TOML files into MATLAB objects
  - R_WRITE_TOML: Write MATLAB data to TOML files
  - R_READ_INI: Read INI files into MATLAB objects
  - R_WRITE_INI: Write MATLAB data to INI files
  - R_DOT_NOTATION: Natural dot notation access (config.database.host)
  - R_SPECIAL_CHARS: Handle keys with hyphens/special characters
  - R_ROUNDTRIP: Full round-trip fidelity (read → modify → write)
  - R_ARRAYS: Smart array conversion to optimal MATLAB types
  - R_VALUE_SEMANTICS: Value class behavior (intuitive assignment)

### 3. Functional Design
- **Design Summary (REQUIRED)**
  - ConfigurationData hierarchy with format-specific subclasses
  - Unified API: read<format>/write<format> pattern

- **Design Details (REQUIRED)**
  - Class hierarchy diagram
  - API signatures with code examples
  - Parameter options (SequenceRule, ArrayStyle, etc.)

- **Design Rationale**
  - Naming: read<type> pattern (aligns with readstruct)
  - SequenceRule vs ArrayStyle naming
  - Keys vs fields terminology

- **Error Conditions**
  - File not found
  - Parse errors (invalid syntax)
  - Unsupported features (anchors, multi-document)

- **Alternate Designs Considered**
  - Option 1: Plain structs (rejected: no special char support)
  - Option 2: containers.Map directly (rejected: handle semantics)
  - Option 3: Third-party Java libraries (rejected: complexity)

### 4. Architectural Design
- **Architecture Summary (REQUIRED)**
  - Value class hierarchy using dictionary storage
  - RedefinesDot mixin for dot notation

- **Architecture Details (REQUIRED)**
  - Class diagram with inheritance
  - dictionary vs containers.Map decision
  - Value semantics implementation

- **Non-Functional Requirements**
  - Performance: Suitable for typical config files (<1MB)
  - Compatibility: MATLAB R2022b+ (for dictionary)
  - No external dependencies

- **Alternate Architectures**
  - Handle class approach (original, rejected for value semantics)
  - Pure struct approach (rejected for API limitations)

### 5. Test Strategy
- **Unit Tests**
  - yamltest.m (34 tests)
  - tomltest.m
  - initest.m (10 tests)

- **Integration Tests**
  - Round-trip tests with real-world files
  - Sample files: GitHub Actions, Docker Compose, Kubernetes

### 6. Documentation Notes
- README.md with quick start
- GettingStarted.mlx interactive tutorial
- Example files in examples/ folder
- Development docs in Claude/ folder

---

## Information Sources

### Primary Sources (in project)
| File | Content |
|------|---------|
| Claude/DESIGN_DECISIONS.md | Naming rationale, architecture decisions, terminology |
| Claude/DEVELOPMENT_NOTES.md | Implementation details, known issues, future work |
| Claude/SESSION_NOTES.md | Bug fixes, learnings from development |
| Claude/INI_IMPLEMENTATION_SUMMARY.md | INI support implementation details |
| Claude/PLAN_value_class_migration.md | Value class migration plan |
| README.md | User-facing documentation |
| tests/*.m | Test coverage and test cases |

### GitHub Issues
| Issue | Title | Status |
|-------|-------|--------|
| #1 | Class type preservation | CLOSED |
| #2 | struct() with arrays of tables | CLOSED |
| #3 | Test against spec | OPEN |
| #4 | Mappings in flow sequences | CLOSED |
| #5 | Value class migration | CLOSED |
| #6 | Working with YAML/TOML examples | OPEN |
| #8 | Create specs | OPEN (this work) |
| #9 | Design review presentation | OPEN |
| #10 | YAML roundtrip test failure | CLOSED |

### ~/.claude Project History
- Extensive session history in ~/.claude/projects/
- Multiple development sessions captured

---

## Writing Approach

1. **Create RFA.md** following the template structure
2. **Pull content from existing docs** rather than rewriting
3. **Use proper markdown tables** for requirements, use cases, rationale
4. **Include code snippets** showing the API in action
5. **Link to existing docs** where appropriate
6. **Mark sections as REQUIRED** per template

---

## Output Files

- `specs/RFA.md` — The main specification document
- `specs/PLAN_rfa_spec.md` — This plan (for reference)

---

## Next Steps After Spec

1. Review spec with stakeholder
2. Create design review presentation (Issue #9)
3. Use presentation template provided
