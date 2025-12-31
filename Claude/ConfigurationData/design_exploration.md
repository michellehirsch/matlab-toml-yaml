# Custom Configuration Data Type - Design Exploration

## Scope Options

### Option 1: YAML-Specific (`YamlData`)
**Scope:** Only for YAML files
**Pros:**
- Focused, single purpose
- Can include YAML-specific metadata (comments, anchors, etc.)
- Clear naming: `YamlData` or `yaml.Data`

**Cons:**
- Limited reuse - would need `TomlData`, `XmlData`, etc.
- Duplicate code across similar types
- Users working with multiple formats need to learn multiple APIs

**Use case:** User only cares about YAML, wants YAML-specific features

---

### Option 2: Config File Types (`ConfigData`)
**Scope:** YAML, TOML, JSON, XML, INI
**Pros:**
- Single API for all config formats
- Shared implementation, less duplication
- Natural fit - these formats have similar needs (nested key-value)
- Could convert between formats: `toml(yamlData)`

**Cons:**
- Not all formats map perfectly (XML attributes, JSON arrays)
- May need format-specific options
- Broader scope = more complexity

**Use case:** User works with multiple config formats, wants consistency

---

### Option 3: Generic Hash/Map (`StructMap`, `DynamicStruct`)
**Scope:** Any nested key-value data
**Pros:**
- Maximum reuse - useful beyond config files
- Could replace containers.Map in many uses
- Clean abstraction - no format-specific baggage
- Community could use for general purpose

**Cons:**
- No format-specific features (comments, special types)
- Generic name may not convey purpose
- Competes with built-in containers.Map/dictionary

**Use case:** General-purpose nested key-value storage

---

## Key Design Questions

### 1. Access Syntax - What should be supported?

```matlab
% Option A: Dot notation only (like struct)
data.key
data.nested.key

% Option B: Parentheses only (like containers.Map)
data('key')
data('nested')('key')

% Option C: Both (flexible)
data.key          % Clean for valid names
data("app-name")  % For names with special chars
data.("app-name") % Dynamic field reference

% Option D: Smart hybrid
data.app_name     % Auto-maps to "app-name" if exists
data("app-name")  % Explicit access
```

**Recommendation:** Option C or D
- Allows both clean syntax for valid names and flexibility for hyphens
- Users can choose their preferred style

---

### 2. Key Name Handling - How to handle invalid MATLAB names?

```matlab
% Strategy A: Store original, provide both accessors
data.("app-name")   % Original key
data.app_name       % Converted key (auto-generated alias)

% Strategy B: Store both explicitly
% Internal: keys = ["app-name", "app_name"]  (both point to same value)

% Strategy C: Store only original, convert on access
% User types: data.app_name
% Class intercepts and looks for: "app_name", "app-name", "appName", etc.
```

**Recommendation:** Strategy A or B
- Preserves original names from file
- Provides convenient access
- Clear about what the canonical key is

---

### 3. Nesting - How should nested access work?

```matlab
% Option A: Return nested instances
data.database          % Returns another ConfigData/YamlData object
data.database.host     % Chained access works naturally

% Option B: Return containers.Map for nests
data.database          % Returns containers.Map
data.database('host')  % Syntax changes at nesting

% Option C: Return struct for nests
data.database          % Returns struct
data.database.host     % Familiar struct syntax
```

**Recommendation:** Option A
- Consistent interface at all levels
- Methods available on nested data (toStruct, keys, etc.)
- Can track path for better error messages

---

### 4. Mutability - Should it be mutable?

```matlab
% Mutable (handle class)
config.database.host = "newhost"  % Modifies in place
data2 = config;                   % data2 and config share data

% Immutable (value class)
newConfig = config.set('database.host', 'newhost')  % Returns new copy
data2 = config;                   % data2 is independent copy
```

**Recommendation:** Mutable (handle class)
- More intuitive for configuration data
- Better performance (no copying)
- Matches containers.Map behavior
- Can still provide immutable methods if desired

---

### 5. Additional Features - What else should it support?

```matlab
% Essential features
keys(data)              % Get all keys
values(data)            % Get all values  
isfield(data, 'key')    % Check existence
toStruct(data)          % Convert to struct
toMap(data)             % Convert to containers.Map

% Nice-to-have features
merge(data1, data2)     % Merge two configs
get(data, 'key', default)  % Get with default
flatten(data)           % Flatten to dot notation keys
unflatten(flatData)     % Reverse of flatten
paths(data)             % All paths: ["app.name", "app.version", ...]

% Format-specific (if not generic)
data.comments           % Access comments (YAML)
save(data, 'file.yaml') % Save back to file
format(data)            % Return source format ('yaml', 'toml', etc.)
```

---

## Recommendation Matrix

| Feature | YAML-Specific | Config Files | Generic Hash |
|---------|--------------|--------------|--------------|
| **Reusability** | Low | Medium | High |
| **Simplicity** | High | Medium | Medium |
| **Format Features** | Full | Some | None |
| **Learning Curve** | Low | Low | Medium |
| **Maintenance** | Low | Medium | Medium |
| **Community Value** | Low | Medium | High |

---

## Proposed Solution: Start Narrow, Design for Growth

### Phase 1: Config-Specific (`ConfigData` or `yaml.Data`)
- Build for YAML/TOML initially
- Design API to be format-agnostic
- Store format in metadata
- Package in +config or +yaml namespace

```matlab
% Usage
data = yamlread('config.yaml');  % Returns yaml.Data
data.database.host               % Clean access
data.("app-name")                % Hyphenated keys
yamlwrite('out.yaml', data)      % Write back

% Could later add
data = tomlread('config.toml');  % Returns toml.Data (or config.Data)
data = jsonread('config.json');  % Same interface
```

### Phase 2: Generalize if Successful
- If users love it, extract to generic type
- Keep format-specific subclasses for special features
- `ConfigData` as base, `yaml.Data` adds YAML features

---

## Questions for You

1. **Scope**: YAML-only, config files (YAML+TOML+JSON), or generic?
2. **Naming**: What would you call it? `ConfigData`, `YamlData`, `StructMap`, `DynamicStruct`?
3. **Namespace**: Top-level, or in package like `yaml.Data` or `config.Data`?
4. **Access**: Support both dot and parentheses, or just one?
5. **Priority**: Is this for your toolbox only, or do you envision wider use?
6. **Timeline**: Quick fix (use containers.Map for now), or invest in custom type?

---

## My Take

For the **YAML toolbox specifically**, I'd recommend:

**Short term:** Use `containers.Map` for `PreserveVariableNames=true`
- Gets the test passing
- Works well enough
- Low risk, low effort

**Medium term:** Build `yaml.Data` class
- Lives in your YAML toolbox
- Optimized for YAML use cases
- Can iterate based on feedback

**Long term:** If successful, generalize
- Extract to `config.Data` or contribute to File Exchange
- Add TOML, JSON, XML support
- Could become community standard

Start small, prove value, then grow. Don't over-engineer before you know what users need.
