# Configuration File I/O Toolbox

A unified MATLAB toolbox for reading and writing YAML and TOML configuration files with intuitive dot notation access and full round-trip support.

## Features

- 📄 **YAML & TOML Support** - Read and write both formats with consistent interface
- 🔑 **Dot Notation Access** - Natural MATLAB syntax: `config.database.host`
- 🔤 **Special Characters** - Handle keys with hyphens, spaces: `config.("build-system")`
- 🔄 **Full Round-Trip** - Read, modify, write back without data loss
- 📊 **Smart Arrays** - Automatic conversion to optimal MATLAB types
- 🎨 **Customizable Output** - Control formatting, indentation, array styles
- 💪 **GitHub Actions Ready** - Properly handles workflow files and sequences

## Installation

Add the toolbox to your MATLAB path:

```matlab
addpath('/path/to/ConfigurationFileIO/toolbox')
```

Or use the MATLAB Project file `ConfigurationFileIO.prj`.

## Quick Start

### Reading Files

```matlab
% Read YAML
config = readyaml('config.yaml');
host = config.database.host;

% Read TOML
project = readtoml('pyproject.toml');
name = project.project.name;

% Keys with special characters
deps = config.("build-system").requires;
```

### Writing Files

```matlab
% Create data
config = YAMLData;
config.name = 'MyApp';
config.database.host = 'localhost';
config.database.port = 5432;

% Write YAML
writeyaml(config, 'config.yaml');

% Write TOML
writetoml(config, 'config.toml');
```

### Working with Arrays

```matlab
% YAML/TOML arrays convert automatically
config.ports = [8080, 8443, 9000];        % Numeric array
config.servers = ["alpha", "beta"];       % String array

% Control output style
writeyaml(config, 'config.yaml', 'ArrayStyle', 'flow');
% Output: ports: [8080, 8443, 9000]

writeyaml(config, 'config.yaml', 'ArrayStyle', 'block');
% Output:
% ports:
%   - 8080
%   - 8443
%   - 9000
```

## Main Functions

### YAML
- `readyaml(filename)` - Read YAML file, returns YAMLData object
- `writeyaml(data, filename)` - Write YAML file
- `YAMLData` - Create YAML data object

### TOML
- `readtoml(filename)` - Read TOML file, returns TOMLData object
- `writetoml(data, filename)` - Write TOML file
- `TOMLData` - Create TOML data object

### Common Options

**readyaml:**
- `'SequenceRule'` - `'auto'` (default) or `'cell'` - Control array conversion

**writeyaml:**
- `'ArrayStyle'` - `'block'` (default) or `'flow'` - Array formatting
- `'NumIndentationSpaces'` - Integer (default: 2) - Indentation
- `'SectionSpacing'` - `'loose'` (default) or `'compact'` - Spacing
- `'Precision'` - Integer (default: 6) - Numeric precision

**writetoml:**
- Similar options available

## Data Objects

### YAMLData and TOMLData

Both extend `ConfigurationData` with format-specific features:

```matlab
% Create and populate
config = YAMLData;
config.version = '1.0.0';
config.database.host = 'localhost';

% Access keys
keys = config.keys;           % Get all keys
exists = isfield(config, 'db'); % Check existence

% Display full content
config.show;                  % Shows formatted YAML/TOML

% Convert to struct
s = struct(config);             % Standard MATLAB struct
```

### Handling Special Characters

Keys with hyphens, spaces, or other special characters use parentheses notation:

```matlab
config.("build-system").requires = ["setuptools"];
config.("my key").value = 123;

% Field names are automatically aliased
config.build_system  % Also works! (uses makeValidName)
```

## Examples

See `GettingStarted.mlx` for an interactive walkthrough, or explore the `examples/` folder:

**YAML Examples:**
- `github-actions-ci.yaml` - GitHub Actions workflow
- `docker-compose.yaml` - Docker Compose configuration
- `kubernetes-deployment.yaml` - Kubernetes deployment

**TOML Examples:**
- `pyproject.toml` - Python project configuration
- `matlab_project.toml` - MATLAB project settings

**Demo Scripts:**
- `demo_yaml_examples.m` - Interactive YAML demos
- `yamlGettingStarted.m` - YAML introduction

## Working with GitHub Actions

The toolbox fully supports GitHub Actions workflows:

```matlab
% Read workflow
workflow = readyaml('github-actions-ci.yaml');

% Access steps (returns object array)
steps = workflow.jobs.test.steps;

% Modify a step
steps(1).uses = 'actions/checkout@v5';

% Write back
writeyaml(workflow, 'updated-workflow.yaml');
```

## Supported Data Types

### Reading
- **Strings** → char or string
- **Numbers** → double
- **Booleans** → logical
- **Arrays** → numeric, string, or cell arrays (auto-detected)
- **Objects** → YAMLData/TOMLData with nested fields
- **Dates** → datetime objects (TOML)

### Writing
- All MATLAB types: numeric, string, char, logical, datetime
- Nested structures
- Arrays (with formatting control)
- Object arrays

## Limitations

- **YAML**: Subset parser, not full YAML 1.2 spec (no anchors, aliases, multi-document)
- **TOML**: Array of tables bug in reading (writing works)
- **Chained indexing**: `obj.field(i).subfield` requires extracting array first
- **Custom tags**: Not supported

For production use cases requiring full spec compliance, consider Java-based libraries.

## Requirements

- MATLAB R2019b or later (for `arguments` blocks)
- No additional toolboxes required

## Project Structure

```
ConfigurationFileIO/
├── toolbox/              ← Add this to path
│   ├── readyaml.m
│   ├── writeyaml.m
│   ├── readtoml.m
│   ├── writetoml.m
│   ├── YAMLData.m
│   ├── TOMLData.m
│   └── ConfigurationData.m
├── examples/             ← Example files and demos
├── tests/                ← Test files
└── Claude/               ← Development documentation
```

## Development Documentation

Detailed development notes, design decisions, and implementation details are in the `Claude/` folder:
- `Claude/YAML/` - YAML implementation notes
- `Claude/TOML/` - TOML implementation notes  
- `Claude/ConfigurationData/` - Base class design

## License

Copyright 2025 The MathWorks, Inc.

## Contributing

This is a personal project. For bugs or suggestions, please create an issue.

---

**Version:** 1.0.0  
**Last Updated:** December 31, 2025
