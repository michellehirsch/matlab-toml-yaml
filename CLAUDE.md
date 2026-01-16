# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MATLAB toolbox for reading/writing YAML, TOML, and INI configuration files with dot notation access. No external toolboxes required. Minimum MATLAB version: R2022b (for `dictionary` type with value semantics).

## Commands

### Run Tests
```matlab
% In MATLAB
runtests('tests/yamltest.m')
runtests('tests/tomltest.m')
runtests('tests/initest.m')
runtests('tests/subsasgnTest.m')
runtests('tests/ConfigurationPerformanceTest.m')

% From terminal
matlab -batch "runtests('tests/yamltest.m')"
```

### Setup Path
```matlab
addpath('toolbox')
% Or open ConfigurationFileIO.prj
```

### Static Analysis
```matlab
% Via MCP server
mcp__matlab__check_matlab_code('toolbox/readyaml.m')
```

## Architecture

### Class Hierarchy
```
ConfigurationData (value class, base)
├── YAMLData
├── TOMLData
└── INIData
```

ConfigurationData inherits from:
- `matlab.mixin.indexing.RedefinesDot` - custom dot notation
- `matlab.mixin.indexing.OverridesPublicDotMethodCall` - data keys take priority over methods
- `matlab.mixin.CustomDisplay` - custom disp/display

### Internal Storage (ConfigurationData)
- `Data` - dictionary<string, cell> storing values wrapped in cells
- `KeyAliases` - dictionary<string, string> mapping valid MATLAB names to original keys
- `OriginalKeys` - string array preserving insertion order

### I/O Pattern
Reader functions (`readyaml`, `readtoml`, `readini`) return data objects. Writer functions (`writeyaml`, `writetoml`, `writeini`) accept data objects or structs.

## Critical Design Decisions

### Method Calling Convention
Methods must use function syntax due to `OverridesPublicDotMethodCall`:
```matlab
% CORRECT
keys(config)
isfield(config, 'database')
show(config)

% WRONG - these access data keys, not methods
config.keys
config.isfield
config.show
```

This allows users to have data keys named "keys", "show", "isfield", etc.

### Value Class Semantics
ConfigurationData is a value class (not handle). Assignment creates independent copies:
```matlab
copy = original;  % copy is independent
copy.field = 'new';  % does not affect original
```

### Key Aliasing
Keys with special characters get valid MATLAB aliases:
```matlab
config.("build-system")  % original key with hyphens
config.build_system      % aliased name also works
```

### Nested Object Creation
Assigning to nested paths auto-creates intermediate objects preserving class type:
```matlab
config = YAMLData;
config.new.section.value = 42;  % creates nested YAMLData objects
```

## Key Files

| File | Purpose |
|------|---------|
| `toolbox/ConfigurationData.m` | Base class with dot notation handling |
| `toolbox/readyaml.m` | YAML parser (~400 lines) |
| `toolbox/readtoml.m` | TOML parser (~1,250 lines, most complex) |
| `toolbox/writeyaml.m` | YAML writer with formatting options |
| `toolbox/writetoml.m` | TOML writer with formatting options |
| `Claude/DESIGN_DECISIONS.md` | Naming rationale and design philosophy |
| `Claude/ISSUE_14_RESERVED_NAMES.md` | Reserved name handling explanation |

## Known Limitations

- **YAML**: No anchors/aliases, no multi-document, no literal/folded strings
- **TOML**: Array of tables reading has bugs (writing works)
- **Array indexing**: Cannot do `obj.field(i).subfield = value` directly; extract array first
- **Comments**: Not preserved during round-trip
- **Tab completion**: IDE shows methods in `obj.` completion even though they require function syntax (MATLAB limitation with RedefinesDot classes)

## Test Files Location

Sample configuration files for testing are in `tests/SampleFiles/` (27+ real-world files including GitHub Actions workflows, Kubernetes manifests, pyproject.toml variants).

## Development Documentation

The `Claude/` folder contains 13 detailed design documents explaining implementation decisions, known issues, and architecture rationale.
