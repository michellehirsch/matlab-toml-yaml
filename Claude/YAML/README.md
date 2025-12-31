# YAML Toolbox for MATLAB

A pure MATLAB implementation for reading and writing YAML files with full support for round-tripping, special characters in keys, and GitHub Actions workflows.

## Features

- ✅ **Read YAML files** into MATLAB with `readyaml()`
- ✅ **Write YAML files** from MATLAB with `writeyaml()`
- ✅ **Full round-trip support** - Read, modify, and write back without data loss
- ✅ **Special character support** - Keys with hyphens, spaces, and other special characters
- ✅ **Dot notation access** - Natural MATLAB syntax: `config.database.host`
- ✅ **GitHub Actions support** - Properly parses sequences of mappings
- ✅ **Object arrays** - YAML sequences return as MATLAB object arrays
- ✅ **Multiple output formats** - Flow style `[a, b, c]` or block style lists
- ✅ **Customizable formatting** - Control indentation, spacing, and array styles

## Installation

Add the `toolbox` folder to your MATLAB path:
```matlab
addpath('/path/to/yaml/yamlToolbox/toolbox')
```

## Quick Start

### Reading YAML
```matlab
% Read a YAML file
config = readyaml('config.yaml');

% Access fields with dot notation
host = config.database.host;
port = config.database.port;

% Access keys with special characters
branches = config.("pull-request").branches;
```

### Writing YAML
```matlab
% Create data
config = YAMLData();
config.name = 'My App';
config.version = '1.0.0';
config.database.host = 'localhost';
config.database.port = 5432;

% Write to file
writeyaml(config, 'config.yaml');

% Or use default filename
writeyaml(config);  % Creates untitled.yaml
```

### Formatting Options
```matlab
% Compact format with 4-space indentation
writeyaml(data, 'config.yaml', ...
    'NumIndentationSpaces', 4, ...
    'SectionSpacing', 'compact');

% Flow-style arrays
writeyaml(data, 'config.yaml', 'ArrayStyle', 'flow');
% Output: ports: [8080, 8443]

% Block-style arrays (default)
writeyaml(data, 'config.yaml', 'ArrayStyle', 'block');
% Output:
% ports:
%   - 8080
%   - 8443
```

## Working with GitHub Actions

The toolbox fully supports GitHub Actions workflows with sequences of mappings:

```matlab
% Read GitHub Actions workflow
workflow = readyaml('github-actions-ci.yaml');

% Access workflow steps (returns object array)
steps = workflow.jobs.test.steps;  % [1x5 YAMLData]

% Access individual steps
firstStep = steps(1);
stepName = steps(1).name;  % "Checkout code"

% Modify and write back
steps(1).uses = 'actions/checkout@v5';
writeyaml(workflow, 'updated-workflow.yaml');
```

## Data Types

### YAMLData Objects
- Returned by `yamlread()`
- Extends `ConfigurationData` with YAML-specific features
- Supports dot notation for field access
- Preserves key order and special characters
- Has a `show()` method to display full YAML content

### Object Arrays
YAML sequences (lists) of mappings return as object arrays:
```matlab
% YAML:
% steps:
%   - name: Build
%     run: make build
%   - name: Test
%     run: make test

% MATLAB:
workflow = yamlread('workflow.yaml');
steps = workflow.jobs.build.steps;  % [1x2 YAMLData]
steps(1).name  % "Build"
steps(2).name  % "Test"
```

**Note**: For chained indexing, extract arrays first:
```matlab
% Extract array, then index
steps = workflow.jobs.build.steps;
name = steps(1).name;  % Works ✓

% Direct chaining not supported
name = workflow.jobs.build.steps(1).name;  % Doesn't work ✗
```

## Advanced Features

### Custom Display with Hyperlinks
Objects with nested hierarchy show a "Show all values" link in the display:
```matlab
>> config
  YAMLData with properties:
    database: [1×1 ConfigurationData]
    server: [1×1 ConfigurationData]
    
    Show all values  % <-- Click to see full YAML
```

### Array Format Options
Control how YAML flow-style sequences `[1, 2, 3]` are converted:
```matlab
% Auto (default): Use specialized arrays when possible
data = readyaml('config.yaml', 'SequenceRule', 'auto');
% [1, 2, 3]        → [1, 2, 3] (numeric array)
% [a, b, c]        → ["a", "b", "c"] (string array)
% [1, "two", true] → {1, "two", true} (cell array)

% Cell: Always use cell arrays
data = readyaml('config.yaml', 'SequenceRule', 'cell');
% [1, 2, 3]        → {1, 2, 3} (cell array)
```

### Converting to Standard MATLAB Types
```matlab
% Convert to struct
s = struct(yamlData);

% Get keys
keys = yamlData.keys();

% Check if field exists
if isfield(yamlData, 'optional-field')
    % ...
end
```

## Examples

See `toolbox/examples/` for complete examples:
- `demo_yaml_examples.m` - Interactive demo of reading and writing
- `github-actions-ci.yaml` - GitHub Actions workflow example
- `kubernetes-deployment.yaml` - Kubernetes configuration
- `docker-compose.yaml` - Docker Compose file

## API Reference

### yamlread
```matlab
data = readyaml(filename)
data = readyaml(filename, 'SequenceRule', rule)
```
**Options:**
- `'SequenceRule'`: `'auto'` (default) or `'cell'`

### writeyaml
```matlab
writeyaml(data)                              % Default: untitled.yaml
writeyaml(data, filename)
writeyaml(data, filename, Name, Value, ...)
```
**Options:**
- `'ArrayStyle'`: `'block'` (default) or `'flow'`
- `'NumIndentationSpaces'`: Positive integer (default: 2)
- `'SectionSpacing'`: `'loose'` (default) or `'compact'`
- `'Precision'`: Positive integer for numeric values (default: 6)

### YAMLData Methods
- `show()` - Display full YAML content
- `struct()` - Convert to struct
- `keys()` - Get all keys
- `isfield(key)` - Check if field exists
- `rmfield(key)` - Remove a field

## Limitations

- **Parser**: Simple recursive parser, not a full YAML 1.2 spec implementation
- **Anchors/Aliases**: Not supported (`&anchor`, `*alias`)
- **Multi-document**: Not supported (files with `---` separators)
- **Custom tags**: Not supported (`!!str`, `!!int`, etc.)
- **Complex keys**: Only string keys supported
- **Chained indexing**: `obj.field(i).subfield` requires extracting array first

For full YAML 1.2 spec compliance, consider using Java-based libraries.

## Requirements

- MATLAB R2019b or later (for `arguments` blocks)
- No additional toolboxes required

## License

Copyright 2025 The MathWorks, Inc.

## Contributing

This is a personal project. For bugs or feature requests, please create an issue.

---

**Version**: 1.0.0  
**Last Updated**: December 31, 2025
