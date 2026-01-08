# IniData

**INI configuration data container**

IniData represents structured configuration data from INI files with dot notation access and support for special characters in field names.

## Creation

### Syntax

```matlab
data = IniData()
data = readini(filename)
```

### Description

`data = IniData()` creates an empty IniData object.

`data = readini(filename)` creates an IniData object by reading from an INI file. See [readini](readini.md).

## Properties

### Data
Internal storage for configuration data.
*Type:* `containers.Map`
*Access:* Hidden

### KeyAliases
Mapping from valid MATLAB names to original keys with special characters.
*Type:* `containers.Map`
*Access:* Hidden

### OriginalKeys
List of keys in original insertion order.
*Type:* string array
*Access:* Hidden

### SourceFormat
Format of the source data.
*Type:* string scalar
*Access:* Protected (read-only)
*Default:* `"ini"`

## Object Functions

### Data Access
- [`keys`](#keys) — Get list of field names
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
- [`show`](#show) — Display contents as INI text

## Usage

### Dot Notation Access

Access fields using dot notation:

```matlab
data = IniData();
data.server.host = 'localhost';
data.server.port = 8080;
host = data.server.host;  % 'localhost'
```

### Special Character Keys

Use dynamic field names for keys with special characters:

```matlab
data = IniData();
data.("database-pool").("max-size") = 20;
data.("database-pool").("min-size") = 5;
maxSize = data.("database-pool").("max-size");
```

## Examples

### Create Application Configuration

Build an application config programmatically:

```matlab
% Create IniData
config = IniData();

% Server section
config.server.host = 'localhost';
config.server.port = 8080;
config.server.ssl = 'false';

% Database section
config.database.host = 'db.example.com';
config.database.port = 5432;
config.database.name = 'myapp';

% Write to file
writeini(config, 'app.ini');
```

### Read and Modify INI File

Load, modify, and save configuration:

```matlab
% Read existing INI
config = readini('app.ini');

% Modify values
config.server.port = 9000;
config.database.name = 'myapp_prod';

% Write updated configuration
writeini(config, 'app_updated.ini');
```

### Access Nested Sections

Navigate configuration sections:

```matlab
% Read INI with sections
config = readini('config.ini');

% Access section values
host = config.database.host;
port = config.database.port;

% Check for optional sections
if isfield(config, 'cache')
    ttl = config.cache.ttl;
end
```

### Display as INI

Preview INI output:

```matlab
% Create configuration
config = IniData();
config.app.name = 'MyApp';
config.app.version = '1.0.0';
config.server.host = 'localhost';
config.server.port = 8080;

% Display as INI
config.show();
% [app]
% name=MyApp
% version=1.0.0
%
% [server]
% host=localhost
% port=8080
```

### Create Independent Copy

IniData is a handle class:

```matlab
% Read original
original = readini('config.ini');

% Create reference (shares data)
ref = original;
ref.server.port = 9000;  % Modifies original!

% Create independent copy
independent = copy(original);
independent.server.port = 9000;  % Does not modify original
```

## Tips

- IniData is a handle class. Use `copy` to create independent copies when needed.
- Use `show` to preview INI output without writing to a file.
- INI keys with special characters are accessed via dynamic field names: `data.("field-name")`.
- Convert to struct with `struct(data)` for compatibility with functions expecting structs.
- IniData preserves field insertion order for consistent file output.

## More About

### Handle Class Behavior

IniData extends `handle`, meaning:
- Assignment creates references, not copies
- Modifications affect all references
- Use `copy()` for independent copies

```matlab
data1 = IniData();
data2 = data1;          % Reference, not copy
data3 = copy(data1);    % Independent copy
```

### Windows INI Dialect

IniData implements the Windows INI format with:
- Sections: `[SectionName]`
- Key-value pairs: `key=value` or `key:value`
- Comments: Lines starting with `;` or `#`
- One level of nesting (sections with keys)
- All values are strings (no type conversion on read)

### Common INI Patterns

**Application settings:**
```matlab
config.application.name = 'MyApp';
config.application.version = '1.0.0';
config.application.debug = 'false';
```

**Server/database configuration:**
```matlab
config.server.host = '0.0.0.0';
config.server.port = 8080;
config.database.url = 'postgresql://localhost/mydb';
config.database.pool_size = 20;
```

## Limitations

- No support for deep nesting (only one section level).
- No type preservation (all values read as strings; write as strings unless MATLAB type detected).
- No support for multiline values.
- No support for escaped characters in keys/values.

## See Also

[readini](readini.md), [writeini](writeini.md), [ConfigurationData](ConfigurationData.md), [YAMLData](YAMLData.md), [TOMLData](TOMLData.md)

## Version History

- Introduced in 2026a
