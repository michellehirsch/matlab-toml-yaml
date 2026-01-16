# RFA Spec: Configuration File I/O Toolbox

**Project:** Configuration File I/O Toolbox
**Author:** Michelle Hirsch
**Date:** January 15, 2026
**Status:** Draft

---

# Project Details

## Project Kickoff

### Motivation and Key Users (REQUIRED)

#### Problem Statement

MATLAB lacks native support for reading and writing modern configuration file formats that are ubiquitous in software development:

- **YAML** — Used by GitHub Actions, Docker Compose, Kubernetes, Ansible, and countless other tools
- **TOML** — Used by Python (pyproject.toml), Rust (Cargo.toml), and modern configuration systems
- **INI** — Legacy but still common configuration format

MATLAB users working in mixed-language environments or DevOps workflows must either:
1. Use external tools to convert files to JSON/XML (which MATLAB does support)
2. Write custom parsers for each project
3. Use third-party File Exchange submissions of varying quality

#### Key Users

| User Type | Description |
|-----------|-------------|
| **MATLAB Developers** | Engineers building applications that need configuration management |
| **Platform Engineers** | Teams managing CI/CD pipelines with MATLAB components |
| **Package Maintainers** | Developers creating MATLAB toolboxes with modern metadata |

#### Workflows Supported

1. **CI/CD Pipeline Management** — Read and modify GitHub Actions workflows programmatically
2. **Project Configuration** — Parse pyproject.toml for Python/MATLAB interop projects
3. **Container Orchestration** — Manage Docker Compose and Kubernetes configurations
4. **Application Settings** — Store and retrieve application configuration with structured data

#### Technical Constraints

- **MATLAB Version:** R2022b or later (required for `dictionary` type with value semantics)
- **No External Dependencies:** Pure MATLAB implementation, no Java libraries or MEX files
- **Subset Parsers:** Focus on common patterns rather than full spec compliance

#### Risks and Assumptions

| Risk | Mitigation |
|------|------------|
| Full YAML 1.2 spec is extremely complex | Implement subset covering 95%+ of real-world config files |
| Handle vs value semantics confusion | Migrated to value classes for intuitive MATLAB behavior |
| Performance on large files | Target config files (<1MB), not data files |

---

# Requirements Analysis

## User Roles and Goals (REQUIRED)

| **ID** | **Priority** | **User Role** | **User Goal** | **Notes** |
|--------|--------------|---------------|---------------|-----------|
| RG_Platform | HIGH | (Reluctant) Platform Engineer | Read and modify CI/CD workflow files (GitHub Actions YAML) from within MATLAB | Primary driver for YAML support |
| RG_PYTHON_INTEROP | HIGH | MATLAB Power User | Access Python project metadata from pyproject.toml in MATLAB workflows | Primary driver for TOML support |
| RG_CONFIG_MGMT | MEDIUM | Application Developer | Store application settings in human-readable config files | Supports all three formats |
| RG_CONTAINER | MEDIUM | Platform Engineer | Programmatically generate Docker Compose configurations | YAML with complex nesting |
| RG_LEGACY | LOW | System Administrator | Read legacy INI configuration files | INI format support |

## Use Cases

### Use Case UC_GITHUB_ACTIONS

| **User Role** | Platform Engineer (RG_Platform) |
|---------------|------------------------------|
| ** User Type** | (reluctantR Platform Engineer |

| Step | **Current Workflow** | **Pain Point ID(s)** | **Examples** |
|------|---------------------|---------------------|--------------|
| 1 | Open YAML file in text editor | PP_MANUAL_EDIT | `.github/workflows/ci.yaml` |
| 2 | Manually edit matrix values, step configurations | PP_ERROR_PRONE | Easy to break YAML syntax |
| 3 | Commit and push to test changes | PP_SLOW_ITERATION | No local validation |

**Pain Points:**
- **PP_MANUAL_EDIT:** Cannot programmatically generate or modify workflows
- **PP_ERROR_PRONE:** Manual YAML editing leads to syntax errors
- **PP_SLOW_ITERATION:** Must push to GitHub to test workflow changes

### Use Case UC_PYPROJECT

| **User Role** | MATLAB Power User (RG_PYTHON_INTEROP) |
|---------------|-------------------------------------|
| **PRISM User Type** | Power User |

| Step | **Current Workflow** | **Pain Point ID(s)** | **Examples** |
|------|---------------------|---------------------|--------------|
| 1 | Need to read Python package metadata | PP_NO_TOML | `pyproject.toml` |
| 2 | Manually parse file or convert to JSON | PP_WORKAROUND | Using Python to convert |
| 3 | Import JSON into MATLAB | PP_DATA_LOSS | Comments and formatting lost |

**Pain Points:**
- **PP_NO_TOML:** MATLAB has no native TOML support
- **PP_WORKAROUND:** Requires external tools or manual parsing
- **PP_DATA_LOSS:** Conversion loses structure and comments

### Use Case UC_APP_CONFIG

| **User Role** | Application Developer (RG_CONFIG_MGMT) |
|---------------|----------------------------------------|
| **PRISM User Type** | Developer |

| Step | **Current Workflow** | **Pain Point ID(s)** | **Examples** |
|------|---------------------|---------------------|--------------|
| 1 | Store config as .mat file or hardcoded | PP_NOT_EDITABLE | Binary or code changes required |
| 2 | Load config at runtime | PP_NOT_PORTABLE | .mat files not human-readable |
| 3 | Share config with non-MATLAB users | PP_INTEROP | JSON/XML verbose for config |

**Pain Points:**
- **PP_NOT_EDITABLE:** Users cannot easily modify configuration
- **PP_NOT_PORTABLE:** .mat files not readable outside MATLAB
- **PP_INTEROP:** JSON/XML verbose and unfamiliar for config

## Other User Knowledge

### Related MATLAB Functions

The toolbox design draws inspiration from existing MATLAB I/O functions:

- **`readstruct` / `writestruct`** — Closest analogue, handles structured data (XML, JSON)
- **`readtable` / `writetable`** — Naming convention precedent
- **`jsondecode` / `jsonencode`** — JSON support (but no file I/O)

### Competitive Analysis

| Solution | Pros | Cons |
|----------|------|------|
| File Exchange YAML parsers | Available now | Inconsistent quality, handle classes, limited maintenance |
| Java SnakeYAML | Full spec compliance | Complex setup, Java dependency, not idiomatic MATLAB |
| Python interop | Full ecosystem | Requires Python, context switching |

## Requirements (REQUIRED)

### Functional Requirements

| **ID** | **Statement** | **Pain Point ID(s)** | **Priority** |
|--------|---------------|---------------------|--------------|
| R_READ_YAML | Read YAML files and return structured MATLAB objects | PP_MANUAL_EDIT, PP_NO_TOML | MUST HAVE |
| R_WRITE_YAML | Write MATLAB data structures to valid YAML files | PP_MANUAL_EDIT | MUST HAVE |
| R_READ_TOML | Read TOML files and return structured MATLAB objects | PP_NO_TOML | MUST HAVE |
| R_WRITE_TOML | Write MATLAB data structures to valid TOML files | PP_NO_TOML | MUST HAVE |
| R_READ_INI | Read INI files and return structured MATLAB objects | PP_NOT_EDITABLE | NICE TO HAVE |
| R_WRITE_INI | Write MATLAB data structures to valid INI files | PP_NOT_EDITABLE | NICE TO HAVE |
| R_DOT_NOTATION | Access nested data using natural dot notation (`config.database.host`) | PP_ERROR_PRONE | MUST HAVE |
| R_SPECIAL_CHARS | Support keys with hyphens and special characters (`config.("build-system")`) | PP_ERROR_PRONE | MUST HAVE |
| R_ROUNDTRIP | Preserve data fidelity through read-modify-write cycles | PP_DATA_LOSS | MUST HAVE |
| R_ARRAYS | Automatically convert arrays to optimal MATLAB types (numeric, string, cell) | PP_WORKAROUND | MUST HAVE |
| R_FORMAT_OPTIONS | Provide formatting options for output (indentation, array style) | PP_NOT_EDITABLE | NICE TO HAVE |

### Non-Functional Requirements

| **ID** | **Statement** | **Pain Point ID(s)** | **Priority** |
|--------|---------------|---------------------|--------------|
| R_VALUE_SEMANTICS | Use value class semantics for intuitive MATLAB behavior | PP_ERROR_PRONE | MUST HAVE |
| R_PERFORMANCE | Handle typical config files (<1MB) with acceptable performance | — | MUST HAVE |
| R_COMPATIBILITY | Support MATLAB R2022b and later | — | MUST HAVE |
| R_NO_DEPENDENCIES | No external toolboxes or libraries required | PP_WORKAROUND | MUST HAVE |
| R_FULL_YAML_SPEC | Support full YAML 1.2 specification (anchors, aliases, multi-document) | — | OUT OF SCOPE |
| R_COMMENT_PRESERVE | Preserve comments through round-trip | — | OUT OF SCOPE |

---

# Functional Design

## Proposed Functional Design: Summary (REQUIRED)

The Configuration File I/O Toolbox provides a unified API for reading and writing YAML, TOML, and INI configuration files through:

1. **Format-specific reader/writer functions** following MATLAB's `read<type>`/`write<type>` convention
2. **A `ConfigurationData` value class hierarchy** enabling natural dot notation access to nested data
3. **Smart type conversion** that automatically maps file data to optimal MATLAB types

## Proposed Design: Details (REQUIRED)

### Design Description & Design Cases

#### Class Hierarchy

```
ConfigurationData (abstract base - value class)
├── YAMLData      — YAML-specific data object
├── TOMLData      — TOML-specific data object
└── INIData       — INI-specific data object
```

#### API Overview

**Reading Files:**
```matlab
% YAML
config = readyaml("config.yaml");
config = readyaml("config.yaml", SequenceRule="cell");

% TOML
project = readtoml("pyproject.toml");

% INI
settings = readini("app.ini");
```

**Writing Files:**
```matlab
% YAML
writeyaml(config, "config.yaml");
writeyaml(config, "config.yaml", ArrayStyle="flow", NumIndentationSpaces=4);

% TOML
writetoml(project, "pyproject.toml");

% INI
writeini(settings, "app.ini");
```

**Working with Data:**
```matlab
% Dot notation access
host = config.database.host;
port = config.database.port;

% Special character keys
deps = config.("build-system").requires;

% Key management
allKeys = keys(config);
hasDB = isfield(config, "database");

% Display content
show(config);

% Convert to struct
s = struct(config);
```

#### Function Signatures

**readyaml**
```matlab
function data = readyaml(filename, options)
    arguments
        filename {mustBeTextScalar, mustBeFile}
        options.SequenceRule {mustBeMember(options.SequenceRule, {'auto', 'cell'})} = 'auto'
    end
```

**writeyaml**
```matlab
function writeyaml(data, filename, options)
    arguments
        data
        filename {mustBeTextScalar} = "untitled.yaml"
        options.ArrayStyle {mustBeMember(options.ArrayStyle, {'block', 'flow'})} = 'block'
        options.NumIndentationSpaces (1,1) {mustBeInteger, mustBePositive} = 2
        options.SectionSpacing {mustBeMember(options.SectionSpacing, {'compact', 'loose'})} = 'loose'
        options.Precision (1,1) {mustBeInteger, mustBePositive} = 6
    end
```

#### Design Case: GitHub Actions Workflow

```matlab
% Read existing workflow
workflow = readyaml(".github/workflows/ci.yaml");

% Inspect structure
show(workflow);

% Modify test matrix
workflow.jobs.test.strategy.matrix.matlab = ["R2022b", "R2023a", "R2024a"];

% Add a new step
newStep = YAMLData;
newStep.name = "Run coverage";
newStep.run = "matlab -batch 'runCoverage'";
workflow.jobs.test.steps(end+1) = newStep;

% Write back
writeyaml(workflow, ".github/workflows/ci.yaml");
```

#### Design Case: Python Project Metadata

```matlab
% Read pyproject.toml
project = readtoml("pyproject.toml");

% Access metadata
name = project.project.name;
version = project.project.version;
authors = project.project.authors;

% Check dependencies
deps = project.project.dependencies;
```

### Design Rationale

| # | **Pros** | **Priority** |
|---|----------|--------------|
| 1 | `read<type>`/`write<type>` naming aligns with modern MATLAB conventions (`readstruct`, `readtable`) | HIGH |
| 2 | Dot notation provides natural MATLAB syntax for nested access | HIGH |
| 3 | Value class semantics match user expectations for data objects | HIGH |
| 4 | Shared base class reduces code duplication across formats | MEDIUM |
| 5 | Special character support via `("key-name")` syntax handles real-world files | HIGH |

| # | **Cons** | **Mitigation Plans** | **Priority** |
|---|----------|---------------------|--------------|
| 1 | Subset parser doesn't support full YAML 1.2 spec | Document limitations clearly; covers 95%+ of config files | MEDIUM |
| 2 | Requires R2022b+ for dictionary support | Clear minimum version requirement in documentation | LOW |
| 3 | Comments not preserved on round-trip | Document as known limitation; common in config parsers | LOW |

### Error Conditions and Edge Cases

| # | **Condition** | **Proposed Error / Warning Message** |
|---|---------------|-------------------------------------|
| 1 | File not found | `Error: Unable to open file "filename.yaml". File does not exist.` |
| 2 | Invalid YAML syntax | `Error: YAML parse error at line N: <description>` |
| 3 | Invalid TOML syntax | `Error: TOML parse error at line N: <description>` |
| 4 | Unsupported YAML feature (anchors) | `Warning: YAML anchors and aliases are not supported. Data may be incomplete.` |
| 5 | Empty file | Returns empty ConfigurationData object (no error) |
| 6 | Key with invalid MATLAB identifier | Automatically creates alias; accessible via `("original-key")` |

## Alternate Designs Considered

### Category A: Return Type Alternatives

#### A1: Plain MATLAB Structs

**Description:** Return plain MATLAB structs from reader functions instead of custom classes.

```matlab
config = readyaml("config.yaml");  % Returns struct
config.database.host              % Works
```

| # | **Pros** | **Priority** |
|---|----------|--------------|
| 1 | Familiar to all MATLAB users | HIGH |
| 2 | No custom class learning curve | MEDIUM |

| # | **Cons** | **Priority** |
|---|----------|--------------|
| 1 | Cannot handle keys with hyphens/special characters | HIGH |
| 2 | Awkward or impossible to round-trip if coerce keys into valid MATLAB identifiers | HIGH |
| 3 | Can't customize display to use domain-relevant terminology and conveniences | MEDIUM |

**Decision:** Rejected due to special character limitation.

---

#### A2: containers.Map Directly

**Description:** Return `containers.Map` as the primary data structure.

```matlab
config = readyaml("config.yaml");  % Returns containers.Map
config("database")("host")         % Access pattern
```

| # | **Pros** | **Priority** |
|---|----------|--------------|
| 1 | Native MATLAB type, no custom classes | MEDIUM |
| 2 | Supports any key type | HIGH |

| # | **Cons** | **Priority** |
|---|----------|--------------|
| 1 | Handle class semantics cause confusion (`b = a` shares data) | HIGH |
| 2 | Verbose access syntax, not dot notation | HIGH |
| 3 | No format-specific metadata | LOW |

**Decision:** Rejected due to handle semantics and verbose syntax.

---

### Category B: Class Semantics Alternatives

#### B1: Handle Class Semantics

**Description:** Use handle class semantics for ConfigurationData objects.

```matlab
config = readyaml("config.yaml");
copy = config;       % Both point to same data
copy.name = "new";   % Modifies original too!
```

| # | **Pros** | **Priority** |
|---|----------|--------------|
| 1 | Works with older MATLAB versions (pre-R2022b) | MEDIUM |
| 2 | Simpler nested modification (no write-back needed internally) | LOW |

| # | **Cons** | **Priority** |
|---|----------|--------------|
| 1 | Handle semantics confuse users: `b = a; b.x = 1` modifies `a` | HIGH |
| 2 | Requires explicit `copy()` method for independent copies | MEDIUM |
| 3 | Inconsistent with MATLAB data object expectations | HIGH |

**Decision:** Initially implemented, then migrated away (Issue #5). Value semantics provide more intuitive behavior for data objects.

---

#### B2: Support Comma-Separated List for Array Field Access

**Description:** Make `arr.name` return comma-separated list like struct arrays when `arr` is a ConfigurationData array.

```matlab
% With struct arrays:
s(1).name = "Alice"; s(2).name = "Bob";
s.name  % Returns: "Alice", "Bob" (comma-separated list)

% Should ConfigurationData do the same?
data.users.name  % Return all names?
```

| # | **Pros** | **Priority** |
|---|----------|--------------|
| 1 | Matches struct array behavior | MEDIUM |
| 2 | Convenient for extracting fields | MEDIUM |

| # | **Cons** | **Priority** |
|---|----------|--------------|
| 1 | ConfigurationData arrays can have heterogeneous keys | HIGH |
| 2 | Behavior unpredictable if elements have different keys | HIGH |
| 3 | Code relying on this would fail at runtime depending on data | HIGH |

**Decision:** Rejected. Instead, provide helpful error message with workarounds:
```
Cannot access field 'name' on a [1 3] array of TOMLData objects.
Index into the array first, e.g., obj(1).name or use:
  arrayfun(@(x) x.name, obj)
```

---

### Category C: Class Hierarchy Alternatives

#### C1: Format-Specific Classes Without Shared Base

**Description:** Create separate `YAMLData` and `TOMLData` classes without a common `ConfigurationData` base class.

| # | **Pros** | **Priority** |
|---|----------|--------------|
| 1 | Simpler class hierarchy | LOW |
| 2 | Format-specific optimizations possible | LOW |

| # | **Cons** | **Priority** |
|---|----------|--------------|
| 1 | Code duplication across formats | HIGH |
| 2 | Inconsistent APIs between formats | MEDIUM |
| 3 | Cannot use `isa(obj, 'ConfigurationData')` for type checking | MEDIUM |

**Decision:** Rejected. Shared base class reduces duplication and ensures consistent API.

---

#### C2: Generic Hash/Map Class (Beyond Config Files)

**Description:** Create a general-purpose dictionary-like class that could be used beyond configuration files.

| # | **Pros** | **Priority** |
|---|----------|--------------|
| 1 | Maximum code reuse | MEDIUM |
| 2 | Useful for other domains | LOW |

| # | **Cons** | **Priority** |
|---|----------|--------------|
| 1 | Would compete with MATLAB's built-in `dictionary` | HIGH |
| 2 | Scope creep beyond configuration file use case | MEDIUM |
| 3 | Harder to optimize for config file patterns | LOW |

**Decision:** Rejected. Too broad; `dictionary` (R2022b+) already serves this purpose.

---

### Category D: Function Naming Alternatives

#### D1: Format-First Naming (`yamlread`, `yamlwrite`)

**Description:** Use `<format>read` / `<format>write` pattern like legacy MATLAB I/O functions.

```matlab
config = yamlread("config.yaml");
yamlwrite(config, "output.yaml");
```

| # | **Pros** | **Priority** |
|---|----------|--------------|
| 1 | Consistent with legacy functions (`xlsread`, `csvread`) | MEDIUM |
| 2 | Format is immediately visible in function name | LOW |

| # | **Cons** | **Priority** |
|---|----------|--------------|
| 1 | Inconsistent with modern MATLAB (`readtable`, `readstruct`) | HIGH |
| 2 | Legacy pattern is being phased out | MEDIUM |
| 3 | `readstruct`/`writestruct` is closest analogue and uses type-first | HIGH |

**Decision:** Rejected. Modern MATLAB uses `read<type>`/`write<type>` pattern. `readstruct`/`writestruct` is the closest existing analogue and establishes the precedent.

---

### Category E: Parameter Naming Alternatives

#### E1: `ArrayFormat` Instead of `SequenceRule`

**Description:** Use `ArrayFormat` parameter name for controlling how YAML sequences are converted.

```matlab
config = readyaml("file.yaml", ArrayFormat="cell");
```

| # | **Pros** | **Priority** |
|---|----------|--------------|
| 1 | Uses familiar "Array" terminology | MEDIUM |

| # | **Cons** | **Priority** |
|---|----------|--------------|
| 1 | Confusingly similar to `ArrayStyle` (write option) | HIGH |
| 2 | "Format" is ambiguous — could mean output formatting | MEDIUM |
| 3 | Doesn't use correct YAML terminology ("sequence") | LOW |

**Decision:** Rejected. `SequenceRule` provides clear distinction from `ArrayStyle` and uses correct YAML terminology. "Rule" suffix matches MATLAB convention (`VariableNamingRule` in `detectImportOptions`).

---

#### E2: Exposing Heuristic Thresholds

**Description:** Provide parameters to control automatic behavior thresholds, e.g., `InlineTableMaxFields`, `InlineArrayMaxElements`.

```matlab
writetoml(data, "file.toml", InlineTableMaxFields=5, InlineArrayMaxElements=10);
```

| # | **Pros** | **Priority** |
|---|----------|--------------|
| 1 | Maximum user control | LOW |
| 2 | Predictable behavior | LOW |

| # | **Cons** | **Priority** |
|---|----------|--------------|
| 1 | Overfits API to implementation details | HIGH |
| 2 | Heuristics may change; API becomes unstable | HIGH |
| 3 | Increases cognitive load for users | MEDIUM |
| 4 | Violates MATLAB philosophy of "useful automatic behavior" | HIGH |

**Decision:** Rejected. Following MATLAB patterns (`DatetimeType="auto"`, `Normalization="auto"`), heuristics are intentionally opaque. Users get `"auto"`, `"expanded"`, or `"inline"` — not threshold tweaking. See `Claude/TOMLWRITE_FORMAT_OPTIONS.md`.

---

#### E3: `TableStyle` and `TableArrayStyle` Naming Alternatives

**Description:** Alternative names for TOML table formatting options.

| Candidate | Evaluation |
|-----------|-----------|
| `ArrayOfTablesStyle` | Contains "Of" (PRISM discourages prepositions); verbose |
| `TableListStyle` | TOML uses "array", not "list" |
| `TableSequenceStyle` | Not TOML terminology |
| `RepeatedTableStyle` | Obscure, indirect |
| **`TableArrayStyle`** | Clear, concise, TOML-native |

**Decision:** `TableArrayStyle` chosen — uses TOML's terminology, avoids prepositions, reads naturally in MATLAB syntax.

---

#### E4: `StringStyle` vs `StringEscapeStyle` + `StringLayout`

**Description:** Single `StringStyle` parameter vs. orthogonal `StringEscapeStyle` and `StringLayout`.

| # | **Single `StringStyle`** | **Orthogonal Parameters** |
|---|--------------------------|---------------------------|
| 1 | Simpler API surface | More precise control |
| 2 | Fewer combinations to understand | Separates semantic concerns |
| 3 | May not cover all use cases | Each parameter has clear purpose |

**Decision:** Chose orthogonal parameters:
- `StringEscapeStyle` — Controls escape processing (`"auto"`, `"escaped"`, `"literal"`)
- `StringLayout` — Controls line formatting (`"auto"`, `"singleline"`, `"multiline"`)

Rationale: Separates semantic intent (escape processing) from presentation (layout). Aligns with PRISM principle of clear, single-purpose parameters.

---

### Category F: Terminology Alternatives

#### F1: "Fields" vs "Keys" vs "Properties"

**Description:** What terminology to use for ConfigurationData members.

| Term | Context | Decision |
|------|---------|----------|
| **keys** | Primary — `keys(obj)`, display, documentation | YAML/TOML specs use "keys"; target users expect it |
| **fields** | Alias — `isfield()`, `fieldnames()`, `rmfield()` | Maintains MATLAB struct compatibility |
| **properties** | Avoid in display | Conflicts with MATLAB OOP `properties()` |

**Decision:** "Keys" as primary terminology; "fields" supported as aliases for struct compatibility. See `Claude/DESIGN_DECISIONS.md`.

## Design Assessment

### Definition of Done

- [ ] All reader functions parse corresponding sample files correctly
- [ ] All writer functions produce valid, parseable output
- [ ] Round-trip tests pass: `read → write → read` produces identical data
- [ ] Dot notation access works for nested structures
- [ ] Special character keys accessible via `("key")` syntax
- [ ] Value semantics: `a = config; a.x = 1` does not modify `config`
- [ ] All unit tests pass (yamltest, tomltest, initest)

### Compatibility Considerations

- **MATLAB Version:** R2022b minimum (dictionary requirement)
- **No toolbox dependencies:** Works with base MATLAB
- **File encoding:** UTF-8 for all file I/O

---

# Architectural Design

## Proposed Architectural Design: Summary (REQUIRED)

The toolbox uses a **value class hierarchy** with `dictionary`-based storage to provide intuitive MATLAB semantics. The `ConfigurationData` base class implements dot notation access via `RedefinesDot` mixin, while format-specific subclasses (`YAMLData`, `TOMLData`, `INIData`) handle format identification.

## Proposed Design: Details (REQUIRED)

### Architecture Description

#### Core Components

```
┌─────────────────────────────────────────────────────────────────┐
│                    ConfigurationData (base)                      │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │ Properties:                                                  ││
│  │   Data: dictionary (string → cell)                          ││
│  │   KeyAliases: dictionary (string → string)                  ││
│  │   OriginalKeys: string array                                ││
│  │   SourceFormat: string                                      ││
│  └─────────────────────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────────────┐│
│  │ Mixins:                                                      ││
│  │   matlab.mixin.indexing.RedefinesDot (dot notation)         ││
│  │   matlab.mixin.CustomDisplay (formatted display)            ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
            │                    │                    │
     ┌──────┴──────┐     ┌───────┴───────┐    ┌──────┴──────┐
     │  YAMLData   │     │   TOMLData    │    │   INIData   │
     │SourceFormat │     │ SourceFormat  │    │SourceFormat │
     │  = "yaml"   │     │   = "toml"    │    │   = "ini"   │
     └─────────────┘     └───────────────┘    └─────────────┘
```

#### Value Semantics via dictionary

The critical architectural decision is using `dictionary` (introduced R2022b) instead of `containers.Map`:

| Aspect | containers.Map | dictionary |
|--------|---------------|------------|
| **Semantics** | Handle (reference) | Value (copy) |
| **Assignment** | `b = a` shares data | `b = a` copies data |
| **Modification** | `b.x = 1` affects `a` | `b.x = 1` does NOT affect `a` |
| **MATLAB Feel** | Confusing | Intuitive |

**Implementation Pattern:**
```matlab
% dictionary requires cell wrapper for heterogeneous values
obj.Data(key) = {value};        % Store
value = obj.Data(key){1};       % Retrieve
obj.Data = remove(obj.Data, key); % Remove (must capture return)
```

### Overview Document

See [DESIGN_DECISIONS.md](../Claude/DESIGN_DECISIONS.md) for detailed rationale on:
- Function naming (`read<type>` vs `<type>read`)
- Parameter naming (`SequenceRule` vs `ArrayFormat`)
- Terminology (keys vs fields vs properties)

### Non-Functional Requirements

#### Performance

- **Target:** Config files up to 1MB parsed in <1 second
- **Not optimized for:** Large data files, streaming, or memory-constrained environments
- **Bottlenecks:** String operations in parsers, regex matching in TOML

#### Compatibility

- **Minimum MATLAB Version:** R2022b (for `dictionary` and `configureDictionary`)
- **Tested Versions:** R2022b, R2023a, R2024a, R2024b
- **Platform:** Windows, macOS, Linux (pure MATLAB)

### Architecturally-Significant Design Cases

#### Case 1: Nested Object Access

The `RedefinesDot` mixin intercepts dot notation and routes through `dotReference` and `dotAssign`:

```matlab
config.database.host = "localhost";

% Internally:
% 1. dotAssign receives indexOp = ["database", "host"]
% 2. Checks if "database" exists, creates YAMLData if not
% 3. Recursively assigns "host" = "localhost" to nested object
% 4. Writes modified nested object back (value semantics)
```

#### Case 2: Special Character Keys

Keys with hyphens create aliases:

```matlab
% YAML: build-system: ...
config.("build-system")  % Primary access
config.build_system      % Alias via makeValidName

% Implementation:
% KeyAliases("build_system") = "build-system"
% Both route to same Data entry
```

### Design Rationale

| # | **Pros** | **Priority** |
|---|----------|--------------|
| 1 | Value semantics eliminate handle class confusion | HIGH |
| 2 | dictionary is native MATLAB type (R2022b+) | HIGH |
| 3 | RedefinesDot provides natural syntax | HIGH |
| 4 | Base class shares implementation across formats | MEDIUM |

| # | **Cons** | **Mitigation Plans** | **Priority** |
|---|----------|---------------------|--------------|
| 1 | Requires R2022b+ (dictionary) | Document requirement clearly | MEDIUM |
| 2 | Cell wrapper adds complexity | Encapsulate in base class methods | LOW |
| 3 | Cannot use chained indexing `obj.arr(i).field` | Document workaround: extract array first | LOW |

## Alternate Architecture Designs Considered

### Alternate Architecture 1: `containers.Map` vs `dictionary` for Internal Storage

**Description:** Use `containers.Map` instead of `dictionary` for storing key-value data internally.

| # | **Pros** | **Priority** |
|---|----------|--------------|
| 1 | Works with older MATLAB versions (pre-R2022b) | MEDIUM |
| 2 | `containers.Map` is well-understood | LOW |

| # | **Cons** | **Priority** |
|---|----------|--------------|
| 1 | `containers.Map` is a handle class — propagates handle semantics to containing class | HIGH |
| 2 | Requires explicit deep copy in `copy()` method | MEDIUM |
| 3 | `dictionary` is the modern MATLAB approach | LOW |

**Decision:** Chose `dictionary` (R2022b+). Its value semantics enable the containing class to have intuitive value behavior without complex copy logic.

---

### Alternate Architecture 2: `dynamicprops` Instead of `RedefinesDot`

**Description:** Use MATLAB's `dynamicprops` mixin to create dynamic properties at runtime instead of `RedefinesDot` with internal dictionary storage.

```matlab
classdef ConfigurationData < dynamicprops
    % Properties added dynamically via addprop()
end
```

| # | **Pros** | **Priority** |
|---|----------|--------------|
| 1 | Array indexing works naturally: `arr(2).field = value` | HIGH |
| 2 | Simpler implementation, built-in MATLAB behavior | MEDIUM |
| 3 | Better performance (native properties) | LOW |

| # | **Cons** | **Priority** |
|---|----------|--------------|
| 1 | Cannot handle special characters — `addprop(obj, 'build-system')` fails | HIGH |
| 2 | Loses key ordering — `properties()` returns alphabetically sorted | HIGH |
| 3 | Heterogeneous arrays fail — `arr.email` errors if any element lacks `email` | HIGH |

**Decision:** Rejected. Special characters are essential for TOML/YAML (kebab-case keys like `build-system` are ubiquitous). Key ordering matters for configuration files. See `Claude/DYNAMICPROPS_ANALYSIS.md`.

---

### Alternate Architecture 3: Struct with Metadata Wrapper

**Description:** Return structs with a thin wrapper for metadata only.

```matlab
[data, meta] = readyaml("file.yaml");
data.database.host  % Plain struct access
meta.sourceFormat   % Metadata separate
```

| # | **Pros** | **Priority** |
|---|----------|--------------|
| 1 | Structs are familiar | MEDIUM |
| 2 | No custom class needed for data | LOW |

| # | **Cons** | **Priority** |
|---|----------|--------------|
| 1 | Special character keys not supported | HIGH |
| 2 | Two outputs awkward for users | MEDIUM |
| 3 | Cannot add methods to data | MEDIUM |

**Decision:** Rejected due to special character limitation.

---

### Alternate Architecture 4: Override `subsasgn` for Array Indexing

**Description:** To fix array indexing limitations (e.g., `data.users(2).name = "Suzie"`), override `subsasgn` instead of enhancing `dotAssign`.

| # | **Pros** | **Priority** |
|---|----------|--------------|
| 1 | Standard MATLAB approach for custom indexing | MEDIUM |
| 2 | Separates concerns from RedefinesDot | LOW |

| # | **Cons** | **Priority** |
|---|----------|--------------|
| 1 | `RedefinesDot` explicitly forbids `subsasgn` override | HIGH |
| 2 | Would conflict with mixin's internal implementation | HIGH |

**Decision:** Rejected. Discovered that `RedefinesDot` forbids `subsasgn` override. Fixed by enhancing `dotAssign` to handle `Paren` type in indexOp chain. See `Claude/ARRAY_INDEXING_LIMITATIONS.md`.

---

# Test Strategy & Testability

## Test Strategy

### Unit Tests

| Test File | # Tests | Coverage |
|-----------|---------|----------|
| `tests/yamltest.m` | 34 | YAML read, write, round-trip, edge cases |
| `tests/tomltest.m` | ~30 | TOML read, write, round-trip, arrays of tables |
| `tests/initest.m` | 10 | INI read, write, type detection |

### Test Categories

1. **Basic Reading Tests**
   - Simple key-value pairs
   - Nested structures
   - Arrays (block and flow style)
   - Special characters in keys

2. **Basic Writing Tests**
   - Simple data output
   - Nested structures
   - Array formatting options
   - Section spacing

3. **Round-Trip Tests**
   - Read → Write → Read produces identical data
   - Real-world files: GitHub Actions, Docker Compose, Kubernetes
   - Complex nesting and arrays

4. **Edge Cases**
   - Empty files
   - Comments (should be ignored)
   - Quoted strings
   - Boolean variations (`true`, `yes`, `on`)
   - Null values

5. **Value Semantics Tests**
   - Assignment creates independent copy
   - Modification doesn't affect original
   - Nested modification behavior

### Sample Test Files

Located in `tests/SampleFiles/`:
- `server_config.yaml`
- `arrays_config.yaml`
- `simple-github-actions.yaml`
- `simple-docker-compose.yaml`
- `kubernetes-service.yaml`
- `github-actions-ci.yaml`
- `kubernetes-deployment.yaml`

### Test Execution

```matlab
% Run all YAML tests
results = runtests("tests/yamltest.m");

% Run specific test
results = runtests("yamltest/testRoundtripSimpleDockerCompose");

% Run all tests in project
results = runtests(pwd, IncludeSubfolders=true);
```

## Testability Features

- **Pure MATLAB:** No external dependencies simplify test environment
- **Sample Files:** Curated collection of real-world config files
- **Temporary Files:** Tests use `TemporaryFolderFixture` for isolation
- **Round-Trip Pattern:** Standard verification approach

---

# Documentation Notes

## Existing Documentation

| Document | Location | Purpose |
|----------|----------|---------|
| README.md | Project root | User-facing quick start and overview |
| GettingStarted.mlx | Project root | Interactive MATLAB tutorial |
| examples/*.m | examples/ | Runnable example scripts |
| Claude/*.md | Claude/ | Development documentation and design decisions |

## Documentation Deliverables

- [ ] Function reference pages (readyaml, writeyaml, readtoml, writetoml, readini, writeini)
- [ ] Class reference page (ConfigurationData, YAMLData, TOMLData, INIData)
- [ ] "Working with YAML Data" example (Issue #6)
- [ ] "Working with TOML Data" example (Issue #6)
- [ ] Limitations and troubleshooting guide

## Key Documentation Points

1. **Minimum MATLAB Version:** R2022b (for dictionary support)
2. **Subset Parser:** Not full YAML 1.2 or TOML 1.0 compliance
3. **Value Semantics:** Assignment creates copies (unlike handle classes)
4. **Special Characters:** Use `("key-name")` syntax for keys with hyphens
5. **Round-Trip:** Data preserved, but comments and formatting may change
