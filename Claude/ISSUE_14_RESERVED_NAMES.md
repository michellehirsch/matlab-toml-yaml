# Issue #14: Reserved Names Collision Resolution

**Issue:** ConfigurationData can inherit from OverridesPublicDotMethodCall to avoid naming collisions with "keys"

**Date:** January 16, 2026

**Status:** Resolved

---

## Problem Statement

Users encountered errors when trying to create configuration keys with names that matched `ConfigurationData` method names:

```matlab
>> config = readyaml("examples/basic_config.yaml");
>> config.keys = "hello"
Assignment not supported because the result of method 'keys' is a temporary value.
```

This limitation prevented users from working with configuration files that contained keys named `keys`, `isfield`, `show`, `struct`, `copy`, `empty`, etc.

## Root Cause

The `ConfigurationData` class inherited from `matlab.mixin.indexing.RedefinesDot`, which customizes dot notation for data access. However, when a key name matched a public method name, MATLAB's default behavior was to call the method instead of accessing the data key.

With `RedefinesDot` alone:
- `config.keys` → called the `keys()` method (returned `OriginalKeys`)
- `config.keys = value` → tried to assign to method result → **error**

## Solution: OverridesPublicDotMethodCall Mixin

### Approach Selected

Added `matlab.mixin.indexing.OverridesPublicDotMethodCall` to the class inheritance:

```matlab
classdef ConfigurationData < matlab.mixin.indexing.RedefinesDot & ...
                             matlab.mixin.indexing.OverridesPublicDotMethodCall & ...
                             matlab.mixin.CustomDisplay
```

### How It Works

With `OverridesPublicDotMethodCall`:
- **ALL** dot notation access from outside the class goes through `dotReference` first
- `dotReference` prioritizes data keys over methods
- Methods must be called using function syntax: `keys(config)` instead of `config.keys`

### Priority Order in dotReference

1. **Data keys first**: If a key exists in the data dictionary, return it
2. **Class properties second**: If accessing a real class property (OriginalKeys, Data, etc.)
3. **Error**: If key doesn't exist

### API Change

| Before (Issue #14) | After (Resolution) |
|-------------------|-------------------|
| `config.keys` → calls method | `config.keys` → returns data key (if exists) |
| `keys(config)` → calls method | `keys(config)` → calls method |
| `config.keys = "value"` → **ERROR** | `config.keys = "value"` → assigns data key |

## Alternatives Considered

### Alternative: Dictionary-Style Paren Syntax

The issue suggested an alternative using `parenReference`/`parenAssign`:

```matlab
config("keys")         % Instead of config.keys
config("keys") = value % Instead of config.keys = value
```

**Why Rejected:**
1. Would require reimplementing `parenReference`/`parenAssign`
2. Breaks existing code using dot notation
3. Inconsistent with the design philosophy - dot notation is a "MUST HAVE" requirement in RFA.md
4. Less natural for MATLAB users

## Implementation Details

### Files Modified

| File | Changes |
|------|---------|
| `toolbox/ConfigurationData.m` | Added mixin, updated `dotReference` priority logic |
| `toolbox/writetoml.m` | Updated `obj.keys` → `keys(obj)` (8 occurrences) |
| `toolbox/writeyaml.m` | Already used `keys(data)` correctly |
| `tests/yamltest.m` | Updated `data.keys` → `keys(data)`, `data.show` → `show(data)` |
| `tests/tomltest.m` | Updated `obj.keys` → `keys(obj)`, `obj.getData()` → `getData(obj)` |
| `tests/initest.m` | Updated `config.keys()` → `keys(config)` |
| `tests/subsasgnTest.m` | Added 9 new tests for reserved name scenarios |
| `toolbox/examples/*.m` | Updated examples to use function syntax |
| `README.md` | Updated documentation |

### New Tests Added

```matlab
% tests/subsasgnTest.m - Reserved name collision tests
testKeyNamedKeys          % User can create key named "keys"
testKeyNamedIsfield       % User can create key named "isfield"
testKeyNamedShow          % User can create key named "show"
testKeyNamedStruct        % User can create key named "struct"
testKeyNamedCopy          % User can create key named "copy"
testMultipleReservedNames % Multiple reserved names coexist
testReservedNameInYAMLData % Works in YAMLData subclass
testReservedNameInTOMLData % Works in TOMLData subclass
```

## Backward Compatibility

### Breaking Change

Code that used dot notation to call methods will need updating:

```matlab
% Old (no longer works for method calls)
allKeys = config.keys;
config.show;

% New (required for method calls)
allKeys = keys(config);
show(config);
```

### Why This Is Acceptable

1. **Consistent with MATLAB conventions**: `keys(dict)`, `fieldnames(struct)`, `isfield(struct, name)` all use function syntax
2. **Documented in DESIGN_DECISIONS.md**: The correct syntax was already documented as `keys(config)`, not `config.keys`
3. **More powerful**: Users can now have any key name without restrictions

## Test Results

All tests pass after implementation:

| Test Suite | Tests | Passed |
|------------|-------|--------|
| subsasgnTest.m | 16 | 16 |
| yamltest.m | 34 | 34 |
| tomltest.m | 40 | 40 |
| initest.m | 10 | 10 |
| **Total** | **100** | **100** |

## References

- [GitHub Issue #14](https://github.com/michellehirsch/ConfigurationFileIO/issues/14)
- [MATLAB OverridesPublicDotMethodCall Documentation](https://www.mathworks.com/help/matlab/ref/matlab.mixin.indexing.overridespublicdotmethodcall-class.html)
- [DESIGN_DECISIONS.md](DESIGN_DECISIONS.md) - Method calling conventions
