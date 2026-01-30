# ConfigurationData

**Base class for structured configuration data**

ConfigurationData provides a foundation for configuration data containers with dot notation access, support for special characters in field names, and key order preservation.

## Creation

### Syntax

```matlab
data = ConfigurationData
data = ConfigurationData(s)
data = ConfigurationData(d)
data = ConfigurationData(m)
```

### Description

`data = ConfigurationData` creates an empty ConfigurationData object.

`data = ConfigurationData(s)` converts struct `s` to ConfigurationData. Nested structs become nested ConfigurationData objects.

`data = ConfigurationData(d)` converts dictionary `d` to ConfigurationData.

`data = ConfigurationData(m)` converts containers.Map `m` to ConfigurationData.

ConfigurationData serves as the base class for [YAMLData](YAMLData.md), [TOMLData](TOMLData.md), and [INIData](INIData.md). Users typically work with the subclasses rather than creating ConfigurationData instances directly.

## Object Functions

### Data Access
- `keys` — Get list of keys in insertion order
- `isfield` — Check if field exists
- `fieldnames` — Get field names (alias for keys)
- `iskey` — Check if key exists (alias for isfield)
- `properties` — Get list of dynamic properties

### Data Conversion
- `struct` — Convert to standard MATLAB struct
- `dictionary` — Convert to MATLAB dictionary
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

Work with structs, dictionaries, and maps:

```matlab
% Create ConfigurationData
data = ConfigurationData;
data.server.host = "localhost";
data.server.port = 8080;

% Convert to struct
s = struct(data);
s.server.host  % "localhost"

% Convert to dictionary
d = dictionary(data);
d{"server"}  % dictionary with host, port keys

% Convert to containers.Map
m = map(data);
m("server")  % ConfigurationData with host, port
```

### Value Class Behavior

ConfigurationData uses value semantics - assignment creates independent copies:

```matlab
% Create original
original = ConfigurationData;
original.value = 100;

% Assignment creates independent copy
copied = original;
copied.value = 200;
original.value  % 100 (not modified!)

% copy() method also works (for compatibility)
another = copy(original);
another.value = 300;
original.value  % 100 (not modified)
```

### Create from Struct

Convert existing structs to ConfigurationData:

```matlab
% Create struct
s = struct('name', 'MyApp', 'database', struct('host', 'localhost', 'port', 5432));

% Convert to YAMLData (or TOMLData, INIData)
config = YAMLData(s);
config.name           % "MyApp"
config.database.host  % "localhost"

% Write directly from struct
writeyaml(s, 'config.yaml');
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

- ConfigurationData is a value class. Assignment creates independent copies automatically.
- Use dynamic field names `data.("field-name")` to access keys with special characters.
- ConfigurationData preserves insertion order for reproducible output.
- Convert to struct with `struct(data)`, dictionary with `dictionary(data)`.
- Create from struct: `config = YAMLData(myStruct)`.
- YAMLData, TOMLData, and INIData extend ConfigurationData with format-specific features.

## More About

### Value Class Semantics

ConfigurationData is a value class:
- Assignment creates independent copies
- Modifications to one copy do not affect others
- The `copy()` method is provided for compatibility but is equivalent to assignment

```matlab
data1 = ConfigurationData;
data2 = data1;          % Independent copy
data3 = copy(data1);    % Also independent copy (same as assignment)
```

### Dot Notation Implementation

ConfigurationData uses `matlab.mixin.indexing.RedefinesDot` to provide dynamic property access. Field access through dot notation is mapped to internal storage.

### Key Aliasing System

Keys containing special characters are automatically aliased to valid MATLAB identifiers:

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

YAMLData, TOMLData, and INIData extend ConfigurationData:
- Override `show` for format-specific display
- Override `validateAndConvertValue` for format-specific type handling

## Limitations

- Very deeply nested structures may impact performance.
- Field names are case-sensitive.
- Direct array indexing `data(1)` is not supported; use dot notation instead.

## See Also

[YAMLData](YAMLData.md), [TOMLData](TOMLData.md), [INIData](INIData.md), [readyaml](readyaml.md), [readtoml](readtoml.md), [dictionary](https://www.mathworks.com/help/matlab/ref/dictionary.html), [containers.Map](https://www.mathworks.com/help/matlab/ref/containers.map.html)

## Version History

- Introduced in 2025a
