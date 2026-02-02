# Namespace Design: Formal and Informal Interfaces

**Date:** February 2, 2026
**Status:** Implementing
**Issue:** [#25 - Put classes in namespaces](https://github.com/michellehirsch/matlab-toml-yaml/issues/25)

---

## Table of Contents

1. [Problem Statement](#problem-statement)
2. [Background: MATLAB Interface Design Philosophy](#background)
3. [Alternatives Considered](#alternatives-considered)
4. [Decision](#decision)
5. [Implementation Details](#implementation-details)
6. [Migration Impact](#migration-impact)
7. [References](#references)

---

## Problem Statement

The current class hierarchy (`ConfigurationData`, `TOMLData`, `YAMLData`, `INIData`) lives in the global MATLAB namespace. This creates several issues:

1. **Namespace pollution** - Classes occupy global names that could conflict with user code
2. **No formal/informal separation** - Software developers subclassing these types use the same interface as casual users doing quick config edits
3. **Discoverability** - Classes aren't grouped logically with related MATLAB I/O functionality
4. **Constructor complexity** - Class constructors handle conversion from struct/dictionary, mixing construction with data transformation

---

## Background

### MATLAB Interface Design Philosophy

MathWorks distinguishes between two types of interfaces:

**Informal interfaces** (for technical computing):
- Rapid insight and prototyping
- Used by engineers/scientists solving problems
- Functions in global namespace
- Simple, memorable names

**Formal interfaces** (for software development):
- Code as deliverable
- Used by developers building libraries/applications
- Classes in namespaces
- Full qualification enables precision

**Key insight:** It's fine for an informal interface function to return a class that is in a formal interface. Example: `figure` creates `matlab.ui.Figure`.

---

## Alternatives Considered

### Option 1: Single Namespace (`matlab.io.config`)

```matlab
matlab.io.config.ConfigurationData  % abstract base
matlab.io.config.TOMLData
matlab.io.config.YAMLData
matlab.io.config.INIData
```

**Pros:**
- Groups all configuration classes together
- Mirrors `matlab.io.datastore` pattern
- Clear relationship between types

**Cons:**
- Verbose for direct construction: `d = matlab.io.config.TOMLData(s)`
- Less discoverable without `import`
- No informal interface for casual use

### Option 2: Format-Specific Namespaces

```matlab
matlab.io.ConfigurationData         % base in parent
matlab.io.toml.Data                 % or TOMLData
matlab.io.yaml.Data                 % or YAMLData
matlab.io.ini.Data                  % or INIData
```

**Pros:**
- Allows future expansion (e.g., `matlab.io.toml.encode`)
- Parallels Python's module organization

**Cons:**
- Fragmentary with only one class per namespace
- `matlab.io.json` already exists (MathWorks), potential confusion
- Spreads related classes across multiple namespaces

### Option 3: Formal + Informal Interface Split (Chosen)

```matlab
% Formal interface (namespace)
matlab.io.config.ConfigurationData
matlab.io.config.TOMLData
matlab.io.config.YAMLData
matlab.io.config.INIData

% Informal interface (global)
tomldata(input)   % wrapper function
yamldata(input)   % wrapper function
inidata(input)    % wrapper function
readtoml, writetoml, readyaml, writeyaml, readini, writeini  % already exist
```

**Pros:**
- Follows established MATLAB pattern (`figure` / `matlab.ui.Figure`)
- Clean syntax for both audiences
- Conversion logic lives in informal wrappers (separation of concerns)
- Class constructors stay simple (name-value pairs only)

**Cons:**
- More files to maintain (3 wrapper functions)
- Two ways to create objects (namespace class vs wrapper function)

---

## Decision

**Adopt Option 3: Formal + Informal Interface Split**

### Rationale

1. **Follows MathWorks pattern** - The `figure` → `matlab.ui.Figure` pattern is well-established and understood by MATLAB users

2. **Clean separation of concerns**:
   - Class constructors: Simple, accept name-value pairs for properties
   - Wrapper functions: Handle conversion from struct/dictionary
   - Reader functions: Handle file I/O

3. **Optimal for both audiences**:
   - Engineers/scientists: `config = tomldata(myStruct)` - simple, memorable
   - Software developers: `classdef MyConfig < matlab.io.config.ConfigurationData` - formal, precise

4. **Simplifies constructor logic** - Removing conversion from constructors makes the classes easier to understand and maintain

5. **No breaking change to primary workflow** - `readtoml`, `writetoml`, etc. continue to work exactly as before

6. **Lowercase naming for informal functions** - `tomldata`, `yamldata`, `inidata` follow MATLAB conventions for informal interfaces (like `figure`, `axes`, `table`)

### Additional Design Decisions

**Remove containers.Map support:**
- `containers.Map` is a legacy type, rarely used in modern MATLAB
- Simplifies conversion logic
- Users can convert to struct first if needed

**Constructor simplification:**
- Class constructors accept only name-value pairs for properties
- No conversion from struct/dictionary in constructors
- Conversion happens only in informal wrapper functions

---

## Implementation Details

### Directory Structure

```
toolbox/
├── +matlab/
│   └── +io/
│       └── +config/
│           ├── ConfigurationData.m   % abstract base
│           ├── TOMLData.m
│           ├── YAMLData.m
│           └── INIData.m
├── tomldata.m          % informal wrapper
├── yamldata.m          % informal wrapper
├── inidata.m           % informal wrapper
├── readtoml.m          % unchanged API
├── writetoml.m         % unchanged API
└── ...
```

### Informal Wrapper Function Pattern

```matlab
function data = tomldata(input)
%TOMLDATA Create a TOMLData object for TOML configuration data
%   DATA = TOMLDATA() creates an empty TOMLData object.
%
%   DATA = TOMLDATA(S) converts struct S to a TOMLData object.
%
%   DATA = TOMLDATA(D) converts dictionary D to a TOMLData object.
%
%   See also: readtoml, writetoml, matlab.io.config.TOMLData

    if nargin == 0
        data = matlab.io.config.TOMLData();
    else
        data = matlab.io.config.TOMLData();
        data = importFrom(data, input);
    end
end
```

### Class Constructor Pattern

```matlab
classdef TOMLData < matlab.io.config.ConfigurationData
    methods
        function obj = TOMLData()
            obj@matlab.io.config.ConfigurationData();
            obj.xInternal__.SourceFormat = "toml";
        end
    end
end
```

---

## Migration Impact

### Breaking Changes

| Change | Impact | Mitigation |
|--------|--------|------------|
| Class names change | Code using `TOMLData` directly breaks | Use `tomldata()` wrapper or full namespace |
| Constructor signature | `TOMLData(struct)` no longer works | Use `tomldata(struct)` instead |
| `containers.Map` support removed | Rare use case | Convert to struct first |

### Non-Breaking

| API | Status |
|-----|--------|
| `readtoml`, `writetoml` | Unchanged |
| `readyaml`, `writeyaml` | Unchanged |
| `readini`, `writeini` | Unchanged |
| Dot notation access | Unchanged |
| All methods (`keys`, `isfield`, etc.) | Unchanged |

### Upgrade Path

```matlab
% Old code
config = TOMLData(myStruct);

% New code (informal)
config = tomldata(myStruct);

% New code (formal)
config = matlab.io.config.TOMLData();
config = importFrom(config, myStruct);
```

---

## References

### Related Design Documents
- [DESIGN_DECISIONS.md](DESIGN_DECISIONS.md) - Function naming rationale
- [ISSUE_14_RESERVED_NAMES.md](ISSUE_14_RESERVED_NAMES.md) - Method calling conventions

### MATLAB Patterns
- `figure` → `matlab.ui.Figure`
- `axes` → `matlab.graphics.axis.Axes`
- `table` → direct (fundamental type, exception)

### External
- [GitHub Issue #25](https://github.com/michellehirsch/matlab-toml-yaml/issues/25)

---

*This design follows MathWorks' principle of providing informal interfaces for technical computing and formal interfaces for software development.*
