# YAMLData

**YAML configuration data container**

YAMLData represents structured configuration data from YAML files with dot notation access and support for special characters in field names.

## Creation

### Syntax

```matlab
data = YAMLData
data = readyaml(filename)
```

### Description

`data = YAMLData` creates an empty YAMLData object.

`data = readyaml(filename)` creates a YAMLData object by reading from a YAML file. See [readyaml](readyaml.md).

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
*Default:* `"unknown"`

## Object Functions

### Data Access
- [`keys`](#keys) — Get list of keys
- [`isfield`](#isfield) — Check if field exists
- [`fieldnames`](#fieldnames) — Get field names (alias for keys)
- [`iskey`](#iskey) — Check if key exists (alias for isfield)
- [`properties`](#properties) — Get list of dynamic properties

### Data Conversion
- [`struct`](#struct) — Convert to standard MATLAB struct
- [`map`](#map) — Convert to containers.Map

### Data Modification
- [`rmfield`](#rmfield) — Remove a field
- [`remove`](#remove) — Remove a key (alias for rmfield)
- [`copy`](#copy) — Create deep copy of object

### Display
- [`show`](#show) — Display contents as YAML text

## Usage

### Dot Notation Access

Access fields using dot notation:

```matlab
data = YAMLData;
data.app.name = "MyApp";
data.app.version = "1.0.0";
value = data.app.name;  % "MyApp"
```

### Special Character Keys

Use dynamic field names for keys with special characters:

```matlab
data = YAMLData;
data.("app-name") = "MyApp";
data.("build-system").requires = ["setuptools"; "wheel"];
appName = data.("app-name");  % "MyApp"
```

### Array Indexing

YAMLData objects can contain arrays:

```matlab
data = YAMLData;
data.ports = [8080; 8443; 9000];
firstPort = data.ports(1);  % 8080
```

## Examples

### Create and Populate YAMLData

Build configuration data programmatically:

```matlab
% Create empty YAMLData
config = YAMLData;

% Add fields using dot notation
config.database.host = "localhost";
config.database.port = 5432;
config.cache.enabled = true;
config.cache.ttl = 3600;

% Display as YAML
show(config);
```

### Read from YAML File

Load configuration from file:

```matlab
% Read YAML file
config = readyaml("config.yaml");

% Access nested data
host = config.database.host;
port = config.database.port;

% Check if field exists
if isfield(config, "cache")
    ttl = config.cache.ttl;
end
```

### Convert to Struct

Work with standard MATLAB structs:

```matlab
% Read YAML
data = readyaml("config.yaml");

% Convert to struct
s = struct(data);

% Now use as regular struct
host = s.database.host;
```

### Create Independent Copy

YAMLData is a handle class:

```matlab
% Create original
original = readyaml("config.yaml");

% Create copy (not independent)
ref = original;
ref.database.port = 5433;  % Modifies original!

% Create independent copy
independent = copy(original);
independent.database.port = 5433;  % Does not modify original
```

### Modify and Save

Read, modify, and write back:

```matlab
% Read configuration
config = readyaml("config.yaml");

% Modify values
config.database.port = 5433;
config.cache.ttl = 7200;

% Write back to file
writeyaml(config, "config_updated.yaml");
```

For comprehensive examples, see [readyamlExample.m](../../examples/readyamlExample.m).

## Tips

- YAMLData is a handle class. Use `copy` to create independent copies when needed.
- Use `show` to view the YAML representation without writing to a file.
- Access fields with special characters using dynamic field names: `data.("field-name")`.
- Convert to struct with `struct(data)` for compatibility with functions expecting structs.
- The `OriginalKeys` property preserves field order for consistent file output.

## More About

### Handle Class Behavior

YAMLData extends `handle`, meaning:
- Assignment creates references, not copies
- Modifications affect all references
- Use `copy` for independent copies

```matlab
data1 = YAMLData;
data2 = data1;          % Reference, not copy
data3 = copy(data1);    % Independent copy
```

### Dot Notation Implementation

YAMLData uses `matlab.mixin.indexing.RedefinesDot` to enable dot notation access to dynamic fields stored in the internal `Data` map.

### Key Aliasing

Keys with special characters (hyphens, spaces, dots) are stored in `OriginalKeys` with aliases in `KeyAliases` for valid MATLAB name access:

```matlab
data.("app-name") = "MyApp";
% Creates alias: appname -> app-name
```

### Field Order Preservation

The `OriginalKeys` property maintains insertion order, ensuring consistent YAML output when writing files.

## Limitations

- Properties `Data`, `KeyAliases`, and `OriginalKeys` are public but should generally not be modified directly.
- Very deeply nested structures may impact performance due to recursive object creation.
- Field names are case-sensitive, matching YAML behavior.

## See Also

[readyaml](readyaml.md), [writeyaml](writeyaml.md), [TOMLData](TOMLData.md), [ConfigurationData](ConfigurationData.md), [containers.Map](https://www.mathworks.com/help/matlab/ref/containers.map.html)

## Version History

- Introduced in 2025a
