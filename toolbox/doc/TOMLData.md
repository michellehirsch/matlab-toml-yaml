# TOMLData

**TOML configuration data container**

TOMLData represents structured configuration data from TOML files with dot notation access and support for special characters in field names.

## Creation

### Syntax

```matlab
data = TOMLData
data = readtoml(filename)
```

### Description

`data = TOMLData` creates an empty TOMLData object.

`data = readtoml(filename)` creates a TOMLData object by reading from a TOML file. See [readtoml](readtoml.md).

## Properties

### Data
Internal storage for configuration data.
*Type:* `containers.Map`
*Access:* Public

### KeyAliases
Mapping from valid MATLAB names to original keys with special characters.
*Type:* `containers.Map`
*Access:* Public

### OriginalKeys
List of keys in original insertion order.
*Type:* string array
*Access:* Public

### SourceFormat
Format of the source data.
*Type:* string scalar
*Access:* Protected (read-only)
*Default:* `"toml"`

## Object Functions

### Data Access
- [`keys`](#keys) — Get list of keys
- [`iskey`](#iskey) — Check if key exists
- [`fieldnames`](#fieldnames) — Get field names (alias for keys)
- [`isfield`](#isfield) — Check if field exists (alias for iskey)
- [`properties`](#properties) — Get list of dynamic properties

### Data Conversion
- [`struct`](#struct) — Convert to standard MATLAB struct
- [`map`](#map) — Convert to containers.Map

### Data Modification
- [`rmfield`](#rmfield) — Remove a field
- [`remove`](#remove) — Remove a key (alias for rmfield)
- [`copy`](#copy) — Create deep copy of object

### Display
- [`show`](#show) — Display contents as TOML text

## Usage

### Dot Notation Access

Access fields using dot notation:

```matlab
data = TOMLData;
data.project.name = "my-package";
data.project.version = "1.0.0";
name = data.project.name;  % "my-package"
```

### Special Character Keys

Use dynamic field names for keys with special characters:

```matlab
data = TOMLData;
data.("build-system").requires = ["setuptools"; "wheel"];
data.("build-system").("build-backend") = "setuptools.build_meta";
backend = data.("build-system").("build-backend");
```

### Datetime Values

TOMLData handles TOML datetime types:

```matlab
data = TOMLData;
data.created = datetime("now");
data.updated = datetime("2025-01-08");
```

## Examples

### Create Python Project Configuration

Build a pyproject.toml programmatically:

```matlab
% Create TOMLData
project = TOMLData;

% Build system configuration
project.("build-system").requires = ["setuptools>=61.0"; "wheel"];
project.("build-system").("build-backend") = "setuptools.build_meta";

% Project metadata
project.project.name = "my-package";
project.project.version = "1.0.0";
project.project.authors = ["Alice <alice@example.com>"; "Bob <bob@example.com>"];

% Dependencies
project.project.dependencies = ["numpy>=1.20.0"; "pandas>=1.3.0"];

% Write to file
writetoml(project, "pyproject.toml");
```

### Read and Modify TOML File

Load, modify, and save configuration:

```matlab
% Read existing TOML
config = readtoml("pyproject.toml");

% Modify values
config.project.version = "1.1.0";
config.project.dependencies = [config.project.dependencies; "scipy>=1.7.0"];

% Write updated configuration
writetoml(config, "pyproject_updated.toml");
```

### Access Nested Tables

Navigate complex TOML structures:

```matlab
% Read TOML with nested tables
config = readtoml("config.toml");

% Access nested data
host = config.database.connection.host;
port = config.database.connection.port;
poolSize = config.database.pool.size;

% Check for optional sections
if isfield(config, "cache")
    ttl = config.cache.ttl;
end
```

### Display as TOML

Preview TOML output:

```matlab
% Create configuration
config = TOMLData;
config.server.host = "localhost";
config.server.port = 8080;
config.debug = true;

% Display as TOML
config.show;
% [server]
% host = "localhost"
% port = 8080
%
% debug = true
```

### Create Independent Copy

TOMLData is a handle class:

```matlab
% Read original
original = readtoml("config.toml");

% Create reference (shares data)
ref = original;
ref.server.port = 8081;  % Modifies original!

% Create independent copy
independent = copy(original);
independent.server.port = 8081;  % Does not modify original
```

For comprehensive examples, see [readtomlExample.m](../../examples/readtomlExample.m).

## Tips

- TOMLData is a handle class. Use `copy` to create independent copies when needed.
- Use `show` to preview TOML output without writing to a file.
- TOML commonly uses hyphens in keys; access them with dynamic field names: `data.("field-name")`.
- Convert to struct with `struct(data)` for compatibility with functions expecting structs.
- TOMLData preserves field insertion order for consistent file output.

## More About

### Handle Class Behavior

TOMLData extends `handle`, meaning:
- Assignment creates references, not copies
- Modifications affect all references
- Use `copy` for independent copies

```matlab
data1 = TOMLData;
data2 = data1;          % Reference, not copy
data3 = copy(data1);    % Independent copy
```

### TOML-Specific Features

TOMLData is optimized for TOML format:
- Preserves key order for reproducible output
- Handles TOML-specific types (datetime, inline tables, arrays of tables)
- Supports both bare keys and quoted keys

### Key Aliasing for Special Characters

TOML frequently uses hyphens and dots in keys. TOMLData handles these with key aliasing:

```matlab
data.("build-system") = "value";
% Creates alias: buildsystem -> build-system
```

### Common TOML Patterns

**Python projects (pyproject.toml):**
```matlab
config.("build-system").requires = ["setuptools"; "wheel"];
config.project.name = "package-name";
config.project.dependencies = ["numpy"; "pandas"];
```

**Configuration files:**
```matlab
config.database.host = "localhost";
config.database.credentials.username = "admin";
config.logging.level = "INFO";
```

## Limitations

- Properties `Data`, `KeyAliases`, and `OriginalKeys` are public but should generally not be modified directly.
- Very deeply nested structures may impact performance due to recursive object creation.
- Field names are case-sensitive, matching TOML behavior.

## See Also

[readtoml](readtoml.md), [writetoml](writetoml.md), [YAMLData](YAMLData.md), [ConfigurationData](ConfigurationData.md)

## Version History

- Introduced in 2025a
