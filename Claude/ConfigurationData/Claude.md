# ConfigurationData Project

## Quick Start

**Location:** `/Users/michellehirsch/Coding/Agent Experiments/MATLAB/Claude/ConfigurationData`

**What it is:** A MATLAB class that provides convenient dot notation access to configuration data with support for hyphenated keys (like `"app-name"`, `"connection-pool"`).

**Run the demo:**
```matlab
cd('/Users/michellehirsch/Coding/Agent Experiments/MATLAB/Claude/ConfigurationData')
test_ConfigurationData  % Live Script demo
```

## Core Features

```matlab
data = ConfigurationData();

% Basic assignment
data.name = "MyApp";
data.version = 2.5;

% Hyphenated keys
data.("app-name") = "MyApplication";  % Use dynamic field reference
data.app_name                          % Access via auto-generated alias

% Nested structures
data.database.host = "localhost";
data.database.("connection-pool").("max-size") = 20;

% Chained access
data.database.("connection-pool").("max-size")  % Returns 20

% Scalar to nested conversion
data.version = 2.5;           % Start with scalar
data.version.major = 1;       % Automatically converts to nested
```

## API Reference

**Dual terminology** - both naming conventions supported:

| Struct-like | Key-value | Description |
|------------|-----------|-------------|
| `keys(data)` | `fieldnames(data)` | Get all keys |
| `isfield(data, key)` | `iskey(data, key)` | Check existence |
| `rmfield(data, key)` | `remove(data, key)` | Remove field |

**Conversion:**
- `struct(data)` - Convert to struct (hyphenated names → underscores)
- `map(data)` - Convert to containers.Map (preserves original names)

**Copying:**
- `copy(data)` - Create independent copy (ConfigurationData is a handle class)

**Tab completion:**
- `properties(data)` - Returns all keys (enables tab completion)

## Design Decisions

1. **Handle class** (not value) - Simple nested assignment, explicit `copy()` for independence
2. **CustomDisplay** - Struct-like formatting with smart value display
3. **Dual terminology** - Both struct-like and key-value method names
4. **Scalar→nested** - Silently overwrites when assigning to sub-field
5. **RedefinesDot** - Modern indexing API (R2021b+)

## Implementation Status

### ✅ Complete
- Dot notation with hyphenated keys
- Nested assignment and chained reference
- Automatic alias generation
- CustomDisplay with struct-like formatting
- Tab completion support
- Dual terminology (struct & key-value)
- Conversion to struct/map
- Handle semantics with explicit copy()
- **YAMLData subclass for YAML files**
- **Integration with yamlread/yamlwrite**

### 🔄 Next Steps
1. **YAML subclass enhancements** - Add comment preservation, anchors
2. **Unit tests** - Add MATLAB Testing Framework tests
3. **Performance testing** - Test with large configs
4. **Deep nesting fix** - Make nested auto-creation use same class as parent

## Files

```
ConfigurationData/
├── ConfigurationData.m              # Main implementation (~340 lines)
├── test_ConfigurationData.m         # Live Script demo
├── README.md                        # Project overview
├── STATUS.md                        # Implementation status
├── REFINEMENTS.md                   # Design decisions summary
├── design_exploration.md            # Initial design thinking
├── LIVESCRIPT_SKILL_UPDATE.md       # Notes on Live Script best practices
└── Claude.md                        # This file
```

## Related Projects

**YAML Toolbox:** `../yaml/yamlToolbox/`
- Has failing test that needs ConfigurationData
- Located at: `/Users/michellehirsch/Coding/Agent Experiments/MATLAB/Claude/yaml/yamlToolbox`
- Test file: `tests/testYamlread.m` (testInvalidFieldNames fails)

## Git Status

**Branch:** main  
**Last commit:** Rename methods: toStruct→struct, toMap→map; hide helper methods

**Commit history:**
1. Initial commit: ConfigurationData prototype
2. Implement nested assignment and chained reference
3. Add comprehensive test suite
4. Convert test to plain text Live Script format
5. Refine design: handle class, CustomDisplay, dual terminology, properties()
6. Update test script with new features
7. Streamline Live Script - fewer outputs, handle semantics at end
8. Remove fprintf from Live Script - use natural output instead
9. Rename methods: toStruct→struct, toMap→map; hide helper methods

## Quick Reference Examples

### Creating and accessing
```matlab
data = ConfigurationData();
data.app.name = "WebServer";
data.app.("build-number") = 42;
data.app.name                    % "WebServer"
data.app.build_number            % 42 (alias works)
```

### Converting
```matlab
s = struct(data);                % Struct with valid field names
s.app.build_number               % 42

m = map(data);                   % containers.Map with original keys
m('app')                         % [containers.Map]
```

### Copying
```matlab
data1 = ConfigurationData();
data1.name = "Original";
data2 = data1;                   % Shares data (handle class)
data3 = copy(data1);             % Independent copy
data2.name = "Modified";
data1.name                       % "Modified" (shared)
data3.name                       % "Original" (independent)
```

### Kubernetes-style config
```matlab
k8s = ConfigurationData();
k8s.("api-version") = "v1";
k8s.metadata.name = "my-service";
k8s.metadata.labels.("app.kubernetes.io/name") = "myapp";
k8s.metadata.labels.("app.kubernetes.io/name")  % "myapp"
```

## Known Limitations

1. **Nested aliases don't work** - `data.database.connection_pool` won't work if stored as `"connection-pool"`. Use `data.database.("connection-pool")` instead.
2. **Handle class** - Assignment shares data; must use `copy()` for independence.
3. **No validation** - No type checking or schema validation.
4. **Display shows Map** - Nested structures show `[containers.Map]` until accessed.

## Testing Checklist

Before integrating with YAML toolbox:
- [ ] Test with real YAML files
- [ ] Verify nested structure handling
- [ ] Check memory usage with large configs
- [ ] Test with various data types
- [ ] Verify alias generation edge cases

## Context for Claude

When resuming this project:
1. We're at the point of testing with YAML toolbox integration
2. The class is feature-complete for basic use
3. Main decision was handle vs value class - chose handle for simplicity
4. Next major task is YAML subclass with comment support
5. User preference: Clean API, minimal method names, no unnecessary helpers exposed

---

**Last updated:** 2025-12-31  
**Status:** Ready for YAML integration testing
