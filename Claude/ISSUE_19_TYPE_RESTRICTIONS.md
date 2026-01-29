# Issue #19: Type Restrictions Analysis

## Implementation Summary (Completed)

Type validation is now implemented in `ConfigurationData.validateAndConvertValue()`:

**Allowed types:**
- `double`, `single`, `int*`, `uint*` (all numeric types)
- `logical`
- `char`, `string`
- `cell` (recursively validated)
- `struct` (recursively validated)
- `ConfigurationData` subclasses
- `datetime` - converted to ISO 8601 in YAMLData, kept native in TOMLData
- `duration` - converted to numeric seconds
- `[]` (empty) - allowed for now

**Disallowed types (with helpful error messages):**
- `function_handle` - cannot be serialized
- `table`, `timetable` - suggests `struct(yourTable)`
- `categorical` - suggests `string(yourCategorical)`
- Complex numbers - configuration files don't support imaginary numbers
- Other objects - generic error with list of supported types

**Format-specific behavior:**
- `YAMLData`: Converts `datetime` to ISO 8601 string at assignment time
- `TOMLData`: Keeps `datetime` native (TOML has native datetime support)

---

## The Problem (Background)

Currently, ConfigurationData allows assigning ANY MATLAB type:

```matlab
config = YAMLData();
config.func = @sin;           % function handle - can't serialize
config.tbl = table(...);      % table - can't serialize
config.cat = categorical(...); % categorical - can't serialize
config.dt = datetime('now');  % datetime - serializes poorly
```

The failures happen late (at write time) with confusing errors, or worse, produce unexpected output.

## Current Behavior

| Type | What Happens at Write |
|------|----------------------|
| double, logical | Works correctly |
| char, string | Works correctly |
| struct | Works (recursively converted) |
| cell array | Works (becomes YAML sequence) |
| ConfigurationData | Works (nested object) |
| datetime | **Silently produces locale-dependent string** ("29-Jan-2026 11:53:58") |
| function_handle | Error: "Conversion to string from function_handle is not possible" |
| table | Error: "Conversion to string from table is not possible" |
| categorical | Error: "First argument must be text" |
| objects | Varies - tries `string(obj)`, usually fails |

## The Core Question

**When should validation happen?**

### Option A: Validate at Assignment Time (Early Validation)

```matlab
config.value = @sin;  % ERROR thrown immediately
```

**Pros:**
- Fail-fast: Users discover problems immediately
- Clear error location: Stack trace points to the problematic line
- Prevents invalid state: ConfigurationData is always serializable
- Simplifies writer code: No need to handle edge cases

**Cons:**
- More restrictive: Users can't temporarily store arbitrary data
- Type checking overhead on every assignment
- Complexity in dotAssign implementation
- What about nested assignments? (`config.a.b.c = @sin`)

### Option B: Validate at Write Time (Late Validation)

```matlab
config.value = @sin;  % OK
writeyaml(config, 'file.yaml');  % ERROR thrown here
```

**Pros:**
- More flexible: Users can work with data freely
- No performance overhead during data manipulation
- Simpler assignment logic

**Cons:**
- Errors are distant from the cause
- Confusing error messages (current state)
- User may build large structure before discovering issue
- Writer code must handle all edge cases

### Option C: Hybrid Approach

- **Soft validation at assignment**: Warning, not error
- **Strict validation at write**: Error with helpful message

```matlab
config.value = @sin;  % Warning: function_handle cannot be serialized to YAML
writeyaml(config, 'file.yaml');  % Error with clear message pointing to 'value'
```

## Type Conversion Considerations

### The Retyping Problem

Some types COULD be serialized if converted:

| Type | Possible Conversion | Lossless? |
|------|--------------------|----|
| datetime | ISO 8601 string | Yes, if format standardized |
| duration | Numeric seconds or ISO 8601 duration | Mostly |
| categorical | String array of labels | No (loses category order/levels) |
| table | Nested structure or array of structs | Mostly |
| int8/16/32/64, uint* | double | No (precision loss for large ints) |
| single | double | Minor precision differences |
| complex | ??? | No standard representation |

**Key Question**: Should we auto-convert or require explicit conversion?

### Auto-Conversion Risks

```matlab
config.timestamp = datetime('now');
writeyaml(config, 'file.yaml');  % Writes "2026-01-29T11:53:58"
config2 = readyaml('file.yaml');
% config2.timestamp is a STRING, not datetime!
```

This is the JSON problem all over again. Users expect round-trip fidelity but don't get it.

### Explicit Conversion Approach

```matlab
config.timestamp = string(datetime('now'), 'yyyy-MM-dd''T''HH:mm:ss');
% User explicitly chose the format
```

This is more work but makes the conversion visible.

## Recommended Approach

### 1. Define Clear Allow-List

**Core types (YAML 1.1 compatible):**
- `double` (including Inf, NaN)
- `logical`
- `char`
- `string`
- `cell` (of allowed types)
- `struct` (with allowed types)
- `ConfigurationData` subclasses

**Extended types (with explicit format):**
- `datetime` → require explicit conversion OR standardize on ISO 8601

**Disallowed:**
- `function_handle`
- `table`, `timetable`
- `categorical`
- `complex` (imaginary numbers)
- Custom objects (unless they implement conversion)

### 2. Validate at Assignment with Clear Messages

```matlab
function obj = setData(obj, key, value)
    obj.validateType(value, key);  % New validation
    key = string(key);
    obj.Data(key) = {value};
end

function validateType(~, value, key)
    if isa(value, 'function_handle')
        error('ConfigurationData:InvalidType', ...
            'Cannot assign function_handle to key "%s". Convert to string first.', key);
    end
    % ... other checks
end
```

### 3. Handle Nested Validation

For `config.a.b.c = value`, the validation happens when the leaf value is assigned, which is fine. The intermediate objects are ConfigurationData which are allowed.

### 4. Special Case: datetime

**Option A**: Disallow, require explicit conversion
```matlab
config.time = string(datetime('now'), 'yyyy-MM-dd''T''HH:mm:ss');
```

**Option B**: Auto-convert with standard format
```matlab
config.time = datetime('now');  % Stored as datetime
writeyaml(config, ...);         % Written as "2026-01-29T11:53:58Z"
```

**Option C**: Format-specific handling
- TOML has native datetime support → keep as datetime
- YAML doesn't → convert to ISO 8601 string

Recommend **Option C** since we have format-specific subclasses.

## Implementation Complexity

### Low Complexity Version
- Add type check in `setData`
- Throw error for disallowed types
- ~20 lines of code

### Medium Complexity Version
- Add type check in `setData`
- Auto-convert datetime to ISO 8601 string
- Warning for borderline types
- ~50 lines of code

### High Complexity Version
- Track original types separately
- Format-specific conversion at write time
- Support custom conversion functions
- ~200+ lines, significant architecture change

**Recommendation**: Start with Low Complexity, add datetime handling as separate enhancement.

## Impact on User Workflow

### Current Workflow (no validation)
```matlab
config = YAMLData();
config.data = myTable;           % No error
config.func = @myCallback;       % No error
% ... much later ...
writeyaml(config, 'file.yaml');  % CRASH with confusing error
```

### Proposed Workflow (early validation)
```matlab
config = YAMLData();
config.data = myTable;           % ERROR: table not supported, convert with struct(myTable)
config.func = @myCallback;       % ERROR: function_handle not supported
```

### Benefits
1. Errors are immediate and actionable
2. Error messages can suggest fixes
3. Users learn the constraints early
4. No surprise failures during write

### Potential Friction
1. Users can't use ConfigurationData as general-purpose container
2. Must convert types explicitly before assignment
3. Existing code may break (if relying on current permissive behavior)

## Questions to Resolve

1. **datetime handling**: Auto-convert, disallow, or format-specific?
2. **Integer types**: Allow int32/uint64 etc., or require double?
3. **Empty values**: Allow `[]`? How does it serialize?
4. **Breaking change**: Is this a major version bump?
5. **Struct conversion**: Should we auto-convert struct to ConfigurationData?

## Next Steps

1. Decide on datetime policy
2. Implement basic type validation in `setData`
3. Add helpful error messages with conversion suggestions
4. Update documentation with type requirements
5. Add tests for type validation
