# ConfigurationData

**Base class for structured configuration data**

ConfigurationData provides a foundation for configuration data containers with dot notation access, support for special characters in field names, and key order preservation.

## Creation

### Syntax

```matlab
data = ConfigurationData
```

### Description

`data = ConfigurationData` creates an empty ConfigurationData object.

ConfigurationData serves as the base class for [YAMLData](YAMLData.md) and [TOMLData](TOMLData.md). Users typically work with the subclasses rather than creating ConfigurationData instances directly.

## Object Functions

### Data Access
- `keys` — Get list of keys in insertion order
- `isfield` — Check if field exists
- `fieldnames` — Get field names (alias for keys)
- `iskey` — Check if key exists (alias for isfield)
- `properties` — Get list of dynamic properties

### Data Conversion
- `struct` — Convert to standard MATLAB struct
- `map` — Convert to containers.Map

### Data Modification
- `rmfield` — Remove a field
- `remove` — Remove a key (alias for rmfield)
- `copy` — Create deep copy

### Display
- `show` — Display contents in format-specific representation (overridden in subclasses)

## Usage

### Dot Notation Access

Access and modify fields using dot notation:

```matlab
data = ConfigurationData;
data.server.host = "localhost";
data.server.port = 8080;
host = data.server.host;  % "localhost"
```

### Special Character Keys

Use dynamic field names for keys with special characters:

```matlab
data = ConfigurationData;
data.("app-name") = "MyApp";
data.("build-system").requires = ["setuptools"];
appName = data.("app-name");  % "MyApp"
```

### Key Management

Work with keys and fields:

```matlab
data = ConfigurationData;
data.host = "localhost";
data.port = 8080;
data.debug = true;

% Get all keys
allKeys = keys(data);  % ["host"; "port"; "debug"]

% Check if field exists
if isfield(data, "debug")
    level = data.debug;
end

% Remove field
data = rmfield(data, "debug");
```

## Examples

### Create and Populate ConfigurationData

Build structured configuration:

```matlab
% Create empty ConfigurationData
config = ConfigurationData;

% Add nested structure
config.database.host = "localhost";
config.database.port = 5432;
config.database.pool.size = 10;
config.database.pool.timeout = 30;

% Access nested data
poolSize = config.database.pool.size;  % 10
```

### Convert Between Types

Work with structs and maps:

```matlab
% Create ConfigurationData
data = ConfigurationData;
data.server.host = "localhost";
data.server.port = 8080;

% Convert to struct
s = struct(data);
s.server.host  % "localhost"

% Convert to containers.Map
m = map(data);
m("server")  % [1×1 ConfigurationData]
```

### Handle Class Behavior

Understand reference semantics:

```matlab
% Create original
original = ConfigurationData;
original.value = 100;

% Assignment creates reference
ref = original;
ref.value = 200;
original.value  % 200 (modified!)

% Create independent copy
independent = copy(original);
independent.value = 300;
original.value  % 200 (not modified)
```

### Key Order Preservation

Order is maintained for consistent output:

```matlab
config = ConfigurationData;
config.zebra = 1;
config.apple = 2;
config.monkey = 3;

keys(config)  % ["zebra"; "apple"; "monkey"] - insertion order preserved
```

### Working with Subclasses

ConfigurationData is typically used through subclasses:

```matlab
% YAMLData extends ConfigurationData
yamlData = readyaml("config.yaml");
show(yamlData);  % Display as YAML

% TOMLData extends ConfigurationData
tomlData = readtoml("pyproject.toml");
show(tomlData);  % Display as TOML

% Both support the same interface
keys(yamlData)
struct(tomlData)
```

## Tips

- ConfigurationData is a handle class. Use `copy` to create independent copies.
- Use dynamic field names `data.("field-name")` to access keys with special characters.
- The `OriginalKeys` property preserves insertion order for reproducible output.
- Convert to struct with `struct(data)` for compatibility with functions expecting structs.
- YAMLData and TOMLData extend ConfigurationData with format-specific features.

## More About

### Handle Class Semantics

ConfigurationData extends `handle`:
- Assignment creates references, not copies
- Modifications through any reference affect all references
- Use `copy` method for independent copies

```matlab
data1 = ConfigurationData;
data2 = data1;          % Reference (shares data)
data3 = copy(data1);    % Independent copy
```

### Dot Notation Implementation

ConfigurationData uses `matlab.mixin.indexing.RedefinesDot` to provide dynamic property access. Field access through dot notation is mapped to the internal `Data` containers.Map.

### Key Aliasing System

Keys containing special characters are stored with their original names in `OriginalKeys`. The `KeyAliases` map allows access through valid MATLAB identifiers:

**Original key:** `"app-name"`
**Alias:** `"appname"` → `"app-name"`

Both `data.("app-name")` and `data.appname` work.

### Custom Display

ConfigurationData uses `matlab.mixin.CustomDisplay` to provide struct-like display in the command window:

```matlab
>> data
  ConfigurationData:
    host: "localhost"
    port: 8080
    debug: true
```

### Subclass Extension

YAMLData and TOMLData extend ConfigurationData:
- Override `show` for format-specific display
- Override `wrapNested` to create appropriate subclass instances
- Set `SourceFormat` to identify the configuration type

## Limitations

- Properties `Data`, `KeyAliases`, and `OriginalKeys` are public but should generally not be modified directly. Use object methods instead.
- Very deeply nested structures may impact performance.
- Field names are case-sensitive.
- Direct array indexing `data(1)` is not supported; use dot notation instead.

## See Also

[YAMLData](YAMLData.md), [TOMLData](TOMLData.md), [readyaml](readyaml.md), [readtoml](readtoml.md), [containers.Map](https://www.mathworks.com/help/matlab/ref/containers.map.html), [handle](https://www.mathworks.com/help/matlab/ref/handle-class.html)

## Version History

- Introduced in 2025a
