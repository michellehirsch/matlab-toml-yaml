# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a MATLAB toolbox for reading and writing TOML (Tom's Obvious Minimal Language) configuration files. The toolbox provides two main functions:
- `readtoml()`: Parses TOML files into MATLAB structs with optional metadata for round-trip support
- `writetoml()`: Serializes MATLAB structs to TOML format with optional metadata to preserve key ordering

## Build and Test Commands

### Run Tests
```matlab
buildtool test
```
Runs all unit tests in `tests/toml_test.m`.

### Run Code Quality Checks
```matlab
buildtool check
```
Runs MATLAB's code analyzer (checkcode) on the toolbox folder.

### Package Toolbox
```matlab
buildtool package
```
Runs checks and tests, then packages the toolbox into an `.mltbx` file in the `release/` folder.

### Run All (Default)
```matlab
buildtool
```
Equivalent to running check, test, and package in sequence.

### Run Single Test
Use MATLAB's test framework to run individual tests:
```matlab
result = runtests('tests/toml_test.m', 'Name', 'testSimpleKeyValue');
```

## Code Architecture

### Core Functions

**`readtoml.m`** (~600 lines)
- Main entry point for parsing TOML files
- Uses recursive descent parsing approach
- Returns MATLAB struct, with optional metadata output for key ordering
- Key internal functions:
  - `parseToml()`: Main parser that processes line-by-line
  - `handleTable()`: Processes `[table]` syntax and updates root struct
  - `handleArrayOfTables()`: Processes `[[array.of.tables]]` syntax
  - `parseKeyValue()`: Parses `key = value` lines and updates struct
  - `parseValue()`: Dispatches to type-specific parsers
  - `parseArray()`, `parseInlineTable()`, `parseString()`, `parseNumber()`, `parseDatetime()`
  - `trackKeyOrder()`: Records key insertion order in metadata dictionary
  - `ensureStructPath()`: Creates nested struct paths as needed
  - `setStructPath()`: Updates values at nested struct paths

**`writetoml.m`** (~360 lines)
- Main entry point for writing TOML files
- Serializes MATLAB structs to TOML format
- Includes overwrite protection (default: error if file exists)
- Accepts optional metadata to preserve key ordering
- Key internal functions:
  - `serializeToml()`: Main serialization orchestrator
  - `serializeTable()`: Handles table headers and array of tables
  - `serializeStruct()`: Serializes struct content without headers
  - `serializeValue()`: Dispatches type-specific serialization
  - `serializeKeyValue()`: Formats individual key-value pairs

### Parsing Strategy

The parser builds MATLAB structs directly (not dictionaries). Key challenges:
- **Structs are pass-by-value**: All modification functions return updated structs
- **Metadata tracking**: A dictionary tracks key insertion order at each nesting level
- **Path navigation**: Functions thread the root struct through all operations

The parser maintains state through:
- `data`: Root struct being built (returned and updated by value)
- `currentTable`: Reference to current struct location (updated by value)
- `currentTablePath`: String tracking the current table's dotted path
- `metadata`: Dictionary tracking key order at each path (updated by value)
- `arrayOfTables`: Dictionary tracking which paths represent arrays of tables

Tables are handled as nested structs. The `[[double bracket]]` syntax creates arrays of structs.

### Type Handling

**Reading:**
- Strings: Supports both basic (`"..."`) and literal (`'...'`) strings with escape sequence processing
- Numbers: Integers, floats, hex (0x), octal (0o), binary (0b), with underscore support
- Booleans: `true`/`false` as MATLAB logical
- Datetimes: Parsed to MATLAB datetime objects (or kept as strings with `DatetimeType='string'`)
- Arrays: Homogeneous arrays enforced (mixed types throw error)
- Inline tables: `{key = value}` syntax parsed to structs

**Writing:**
- Integers: Written without decimal point (heuristic: `value == floor(value)`)
- Floats: Written with decimal representation
- Booleans: Written as `true`/`false`
- Strings: Escaped with `\"`, `\\`, `\n`, `\t`, `\r`
- String arrays: Written as `["elem1", "elem2", ...]` (fixed: checks for non-scalar strings)
- Numeric arrays: Written as `[elem1, elem2, ...]`
- Nested tables: Written with `[table.path]` headers
- Inline tables: Single-level structs written as `{key = value, ...}`

### Toolbox Structure

```
toolbox/
  readtoml.m          - TOML reader
  writetoml.m         - TOML writer
  examples/           - Example TOML files and demo scripts
    demo_examples.m   - Live Script demonstrating all features
    simple_config.toml
    arrays_demo.toml
    nested_tables.toml
    all_types.toml
    matlab_project.toml

tests/
  toml_test.m         - Comprehensive test suite (26 test methods)

buildfile.m           - Build automation (test, check, package)
packageToolbox.m      - Toolbox packaging helper
toolboxOptions.m      - Toolbox metadata and configuration
```

### Key Design Decisions

1. **Struct-Based Output**: Returns MATLAB structs (not dictionaries) for natural MATLAB integration
   - Structs handle heterogeneous types without cell wrapping
   - Cleaner syntax: `config.database.port` vs `config{"database"}{"port"}`
   - Field names created with `matlab.lang.makeValidName()` for special characters

2. **Metadata for Round-Trip**: Optional metadata dictionary preserves key ordering
   - `[data, metadata] = readtoml(file)` returns both struct and metadata
   - `writetoml(file, data, 'Metadata', metadata)` uses metadata to write keys in original order
   - Metadata structure: `metadata{path}{1}` contains string array of keys in order
   - Paths use dotted notation: `""` for root, `"table.subtable"` for nested

3. **Struct-by-Value Handling**: All modification functions return updated structs
   - Cannot modify structs in-place (MATLAB limitation)
   - Functions thread struct through operations: `[rootData, metadata] = func(rootData, ..., metadata)`
   - Careful propagation of changes back to root struct

4. **Dotted Keys**: Keys like `a.b.c = value` create nested struct structure automatically

5. **Overwrite Protection**: `writetoml()` requires explicit `OverWrite=true` to replace existing files

6. **UTF-8 Encoding**: All file I/O uses UTF-8 encoding

7. **Array Homogeneity**: Enforced per TOML spec - arrays must contain single type

## API Examples

### Basic Reading
```matlab
% Read TOML file as struct
config = readtoml('config.toml');
server = config.database.server;
port = config.database.port;
```

### Reading with Metadata
```matlab
% Read with metadata for round-trip
[config, metadata] = readtoml('config.toml');

% Metadata tracks key order at each level
rootKeys = metadata{""}{1};  % ["title", "version", "database"]
dbKeys = metadata{"database"}{1};  % ["server", "port", "enabled"]
```

### Basic Writing
```matlab
% Create struct
data.title = "My App";
data.database.server = "localhost";
data.database.port = 5432;

% Write to TOML
writetoml('output.toml', data);
```

### Round-Trip with Key Ordering
```matlab
% Read with metadata
[data, metadata] = readtoml('input.toml');

% Modify data
data.database.port = 3306;

% Write with metadata preserves key order
writetoml('output.toml', data, 'Metadata', metadata, 'OverWrite', true);
```

### Date/Time Handling
```matlab
% Read dates as datetime objects (default)
data = readtoml('config.toml');
timestamp = data.created;  % datetime object

% Read dates as strings
data = readtoml('config.toml', 'DatetimeType', 'string');
timestamp = data.created;  % string
```

## Testing Notes

- Tests use MATLAB's `matlab.unittest.TestCase` framework
- Each test creates a temporary working folder (cleaned up automatically)
- Tests cover: primitives, arrays, tables, nested tables, inline tables, comments, round-trip serialization
- Metadata testing: Verifies key order preservation
- Error cases tested: mixed-type arrays, overwrite protection
- **26 test methods** covering read, write, and round-trip functionality
- All tests use struct syntax (no dictionary syntax)

## MATLAB Version Compatibility

- **R2022b or later** required for dictionary support (used internally for metadata tracking)
- Toolbox configured to support all platforms (Win64, Glnxa64, Maci64, MATLAB Online)
- Structs are compatible with all MATLAB versions, but metadata feature requires R2022b+

## Implementation Notes

### Why Structs Instead of Dictionaries?

TOML tables contain heterogeneous types (strings, numbers, booleans, nested tables). MATLAB dictionaries require homogeneous value types, which would force wrapping all values in cells:
```matlab
% Dictionary approach (rejected)
data = dictionary("string", "cell");
data{"title"} = {"My App"};  % Everything wrapped in cells
title = data{"title"}{1};     // Awkward access

% Struct approach (current)
data.title = "My App";         % Natural MATLAB
title = data.title;            % Direct access
```

### Struct-by-Value Challenges

MATLAB structs are passed by value, not reference. This means:
```matlab
function modifyStruct(s)
    s.newField = 123;  % Only modifies local copy!
end
```

Solution: Return modified struct from all functions:
```matlab
function s = modifyStruct(s)
    s.newField = 123;  % Return modified struct
end

s = modifyStruct(s);  // Capture returned value
```

This pattern is used throughout `readtoml.m`:
- `[rootData, tableRef, tablePath, metadata] = handleTable(...)`
- `[rootData, tableRef, metadata] = parseKeyValue(...)`
- `[s, metadata] = ensureStructPath(...)`

### Metadata Dictionary Structure

Metadata uses a dictionary with cell values to track key order:
```matlab
metadata = configureDictionary("string", "cell");

% Track keys at root level
metadata{""} = {["title", "version", "database"]};

% Track keys in nested table
metadata{"database"} = {["server", "port", "enabled"]};

% Track keys in deeply nested table
metadata{"database.connection"} = {["timeout", "retries"]};
```

The cell wrapping `{[...]}` is required because dictionaries need homogeneous value types.
