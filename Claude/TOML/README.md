# MATLAB TOML Toolbox

A MATLAB toolbox for reading and writing TOML (Tom's Obvious Minimal Language) configuration files. This toolbox provides a simple, native MATLAB interface for working with TOML files using structs.

## Features

- **Read TOML files** into MATLAB structs with automatic type conversion
- **Write MATLAB structs** to TOML format
- **Round-trip support** with metadata tracking to preserve key ordering
- **Comprehensive type support**: strings, numbers (integer/float/hex/octal/binary), booleans, arrays, tables, inline tables, and datetime values
- **Nested tables and dotted keys** for hierarchical configuration
- **UTF-8 encoding** support
- **File protection** to prevent accidental overwrites

## Installation

### From MLTBX File

1. Download the latest `.mltbx` file from the `release/` folder
2. Double-click the file or use `matlab.addons.install('toml.mltbx')`
3. The toolbox will be installed and added to your MATLAB path

### From Source

1. Clone or download this repository
2. Add the `toolbox/` folder to your MATLAB path:

```matlab
addpath('path/to/toml/toolbox')
```

## Quick Start

### Reading TOML Files

```matlab
% Read a TOML configuration file
config = readtoml("config.toml");

% Access nested values using struct syntax
serverAddress = config.database.server;
port = config.database.port;
```

### Writing TOML Files

```matlab
% Create configuration as a struct
config.app_name = "My Application";
config.version = 2.1;
config.database.server = "localhost";
config.database.port = 5432;
config.features = ["auth", "logging", "metrics"];

% Write to TOML file
writetoml("config.toml", config);
```

### Round-Trip with Key Ordering

```matlab
% Read with metadata to preserve key order
[data, metadata] = readtoml("input.toml");

% Modify the data
data.database.port = 3306;

% Write back preserving original key order
writetoml("output.toml", data, "Metadata", metadata, "OverWrite", true);
```

## API Reference

### `readtoml`

Read a TOML file and parse it into a MATLAB struct.

**Syntax:**
```matlab
data = readtoml(filename)
[data, metadata] = readtoml(filename)
data = readtoml(filename, Name=Value)
```

**Parameters:**
- `filename` (string): Path to the TOML file to read
- `DatetimeType` (optional): How to handle datetime values
  - `"datetime"` (default): Parse as MATLAB datetime objects
  - `"string"`: Keep as string values

**Returns:**
- `data` (struct): Parsed TOML data as a MATLAB struct
- `metadata` (dictionary): Key ordering information for round-trip support

**Example:**
```matlab
% Basic reading
config = readtoml("config.toml");

% Read with metadata
[config, meta] = readtoml("config.toml");

% Read dates as strings
config = readtoml("config.toml", "DatetimeType", "string");
```

### `writetoml`

Write a MATLAB struct to a TOML file.

**Syntax:**
```matlab
writetoml(filename, data)
writetoml(filename, data, Name=Value)
```

**Parameters:**
- `filename` (string): Path to the output TOML file
- `data` (struct): MATLAB struct to serialize
- `OverWrite` (optional, logical): Allow overwriting existing files (default: `false`)
- `Metadata` (optional, dictionary): Metadata from `readtoml()` to preserve key ordering

**Example:**
```matlab
% Basic writing
data.title = "My Config";
data.version = 1.0;
writetoml("output.toml", data);

% Overwrite existing file
writetoml("output.toml", data, "OverWrite", true);

% Write with metadata for key ordering
[original, meta] = readtoml("input.toml");
original.database.port = 3306;
writetoml("output.toml", original, "Metadata", meta, "OverWrite", true);
```

## Supported Data Types

| TOML Type | MATLAB Type | Example |
|-----------|-------------|---------|
| String | `string` | `"hello world"` |
| Integer | `double` | `42`, `0xFF`, `0o755`, `0b1010` |
| Float | `double` | `3.14`, `1e-5` |
| Boolean | `logical` | `true`, `false` |
| Array | Array | `[1, 2, 3]` or `["a", "b"]` |
| Table | `struct` | `[database]` → `data.database` |
| Inline Table | `struct` | `{x=1, y=2}` → `data.x`, `data.y` |
| Datetime | `datetime` | `2024-01-15T10:30:00Z` |

## Examples

See the `toolbox/examples/` folder for complete examples:

- **`demo_examples.m`**: Live Script demonstrating all features
- **`simple_config.toml`**: Basic configuration with nested tables
- **`arrays_demo.toml`**: Array examples
- **`nested_tables.toml`**: Deeply nested structures
- **`matlab_project.toml`**: MATLAB project configuration example

## Requirements

- **MATLAB R2022b or later** (required for dictionary support used in metadata tracking)
- Supports all platforms: Windows, Linux, macOS, and MATLAB Online

## Development

### Running Tests

Run the complete test suite:
```matlab
buildtool test
```

Run a single test:
```matlab
result = runtests("tests/toml_test.m", "Name", "testSimpleKeyValue");
```

### Code Quality Checks

Run MATLAB's code analyzer:
```matlab
buildtool check
```

### Packaging

Build the toolbox `.mltbx` file:
```matlab
buildtool package
```

This runs all checks and tests before packaging.

### Build All

Run checks, tests, and packaging:
```matlab
buildtool
```

## Architecture

The toolbox uses a recursive descent parser that builds MATLAB structs directly:

- **`readtoml.m`**: Main parser (~600 lines) with functions for parsing values, tables, arrays, and tracking metadata
- **`writetoml.m`**: Serializer (~360 lines) that converts structs to TOML format with optional metadata for key ordering
- **`tests/toml_test.m`**: Comprehensive test suite with 26 test methods

### Key Design Decisions

1. **Struct-based output**: Returns MATLAB structs (not dictionaries) for natural MATLAB integration and cleaner syntax
2. **Metadata for round-trip**: Optional dictionary tracks key ordering for faithful round-trip operations
3. **Struct-by-value handling**: All modification functions return updated structs to handle MATLAB's pass-by-value semantics
4. **Overwrite protection**: Requires explicit `OverWrite=true` to prevent accidental file loss

See `CLAUDE.md` for detailed architectural documentation.

## License

This project is licensed under the BSD 3-Clause License - see the [LICENSE.txt](LICENSE.txt) file for details.

## Contributing

Contributions are welcome! Please ensure all tests pass before submitting:
```matlab
buildtool test
```

## Acknowledgments

Built with MATLAB R2026a using the TOML specification from https://toml.io
