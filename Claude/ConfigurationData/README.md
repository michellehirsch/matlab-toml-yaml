# ConfigurationData - Modern Configuration Object for MATLAB

This folder contains the design and prototype for a new MATLAB class that provides convenient access to configuration data from files like YAML, TOML, and JSON.

## Problem Statement

MATLAB structs don't allow field names with hyphens or other special characters, but configuration file formats (YAML, TOML, JSON) commonly use them:

```yaml
app-name: MyApp
database:
  host-name: localhost
  connection-pool:
    max-size: 20
```

Current solutions:
- Convert hyphens to underscores (loses original names)
- Use `containers.Map` (awkward nested access)
- Use `dictionary` (requires homogeneous types, awkward cell wrapping)

## Proposed Solution

A custom `ConfigurationData` class using `matlab.mixin.indexing.RedefinesDot` that provides:

### Clean Dot Notation Access

```matlab
data = ConfigurationData();
data.name = "MyApp";
data.version = 2.5;
data.("app-name") = "MyApp";  % Hyphenated keys work!

% Nested access
data.database.host = "localhost";
data.database.("connection-pool").("max-size") = 20;

% Reading
host = data.database.host;
appName = data.("app-name");
```

### Key Features

- ✅ Preserves original key names (including hyphens)
- ✅ Auto-generates valid MATLAB name aliases (`app_name` → `app-name`)
- ✅ Nested structures return ConfigurationData (consistent interface)
- ✅ Convert to struct or containers.Map when needed
- ✅ Track insertion order
- ✅ Modern MATLAB API (RedefinesDot, not subsref)

### Usage Example

```matlab
% Load YAML file (future integration)
data = yamlread('config.yaml');  % Returns ConfigurationData

% Access with dot notation
data.database.host                           % Clean
data.("app-name")                            % Hyphenated
data.database.("connection-pool").("max-size") % Deeply nested

% Check existence
if isfield(data, "database")
    % ...
end

% Get all keys
allKeys = keys(data);  % Returns: ["app-name", "database", "version"]

% Convert to struct (for compatibility)
s = toStruct(data);  % Field names: app_name, database, version
```

## Files in This Folder

- `ConfigurationData.m` - Prototype implementation
- `design_exploration.md` - Initial design thinking (scope, trade-offs)
- `README.md` - This file

## Design Decisions

1. **Scope**: Initially for config files (YAML, TOML, JSON), expandable to generic use
2. **Indexing**: Dot notation only (not parentheses/braces)
3. **Implementation**: `matlab.mixin.indexing.RedefinesDot` (R2021b+)
4. **Mutability**: Handle class (mutable, efficient)
5. **Namespace**: TBD - options: top-level, `matlab.io.*`, `config.*`

## Future Class Hierarchy

```
ConfigurationData (abstract base)
├── yaml.YAMLData (YAML-specific features like comments)
├── toml.TOMLData (TOML-specific features)
└── json.JSONData (JSON-specific features)
```

## Current Status

- [x] Initial design exploration
- [x] Prototype implementation
- [ ] Fix protected method access levels
- [ ] Test with real YAML data
- [ ] Integrate with yamlread/yamlwrite
- [ ] Add comprehensive tests
- [ ] Create YAML-specific subclass
- [ ] Documentation

## Next Steps

1. Test the prototype in MATLAB
2. Fix any access level issues
3. Integrate with existing YAML toolbox
4. Gather feedback
5. Iterate on design

## Questions to Resolve

- Should we use `matlab.io.*` namespace or something else?
- How should `disp` format the output?
- Should we support array indexing? (`data(1).key`)
- How to handle null vs missing values?
- Error message style?

## Related

- YAML Toolbox: `../yaml/yamlToolbox/`
- Design docs: `design_exploration.md`
