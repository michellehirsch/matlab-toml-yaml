# Tab Completion Design Decision

## Problem

Tab completion for `TOMLData`, `YAMLData`, and `INIData` objects stopped showing data keys. Users would type `config.` and press Tab expecting to see their configuration keys, but only saw methods like `keys`, `isfield`, `struct`, etc.

## Root Cause

The actual root cause was discovered through git bisect: the `properties()` method was changed to return a **string array** instead of a **cell array of char**.

```matlab
% BROKEN (commit 78d357f onwards):
function p = properties(obj)
    p = obj.OriginalKeys;  % Returns string array - IDE ignores this!
end

% WORKING:
function p = properties(obj)
    p = cellstr(obj.OriginalKeys);  % Returns cell array of char - IDE uses this
end
```

**MATLAB's IDE tab completion requires `properties()` to return a cell array of character vectors.** String arrays are silently ignored.

## Additional Change: Consolidated Property

While investigating, we also consolidated internal properties from 4 separate properties to 1 struct property (`xInternal__`). This was done to minimize reserved key names:

**Before:** 4 reserved names (`Data`, `KeyAliases`, `OriginalKeys`, `SourceFormat`)
**After:** 1 reserved name (`xInternal__`)

### Original Property Structure (commit 55f6a98)

Commit 55f6a98 changed internal properties from `public Hidden` to `private`:

```matlab
% Before: Tab completion worked
properties (Access = public, Hidden = true)
    Data dictionary
    KeyAliases dictionary
    OriginalKeys string
end

% After: Tab completion broken
properties (Access = private)
    Data dictionary
    KeyAliases dictionary
    OriginalKeys string
end
```

The change was made to allow users to have configuration keys named "Data", "KeyAliases", or "OriginalKeys" without conflicting with internal properties. However, it had the unintended consequence of breaking tab completion.

## MATLAB Limitation

According to MathWorks documentation:

> "Tab completion does not currently support properties for classes inheriting from RedefinesDot. The dot predictions would require running MATLAB code from your class's dotReference method."

There is **no** `getDotCompletionResults` method or similar API that would allow customizing tab completion for `RedefinesDot` classes. The only mechanism available is:

1. The `properties()` method override (which ConfigurationData already implements)
2. IDE introspection of public properties

Since #2 requires properties to be public (even if Hidden), making properties private breaks tab completion.

## Solution: Consolidated Internal Property

Instead of 4 separate properties, consolidate all internal state into a single `public Hidden` struct property with an unlikely name: `xInternal__`.

### Why This Works

- `public Hidden` allows IDE introspection for tab completion
- The `properties()` override returns the user's data keys (from `OriginalKeys`)
- Tab completion shows: data keys + class methods (same as before)

### The Tradeoff

| What We Gain | What We Lose |
|--------------|--------------|
| Tab completion showing data keys | One key name reserved (`xInternal__`) |
| Cleaner API (4 reserved names → 1) | Slightly more complex internal access |

### Why `xInternal__` as the Name

The name was chosen to minimize collision risk with real configuration keys:

- `x` prefix: Uncommon start for configuration keys
- `Internal`: Clearly indicates internal use
- `__` suffix: Python-style convention for private/internal, very unlikely in YAML/TOML/INI keys

Alternative names considered:
- `zzzInternal`: Sorts last alphabetically but less clear intent
- `Internal_`: Trailing underscore alone might not be distinctive enough
- `x_ConfigState_`: More defensive but longer

## Implementation

### Property Definition

```matlab
properties (Access = public, Hidden = true)
    xInternal__ struct = struct(...
        'Data', configureDictionary("string", "cell"), ...
        'KeyAliases', configureDictionary("string", "string"), ...
        'OriginalKeys', string.empty, ...
        'SourceFormat', "unknown")
end
```

### Internal Access Pattern

All internal code uses nested struct access:

```matlab
% Instead of:
obj.Data
obj.KeyAliases
obj.OriginalKeys

% Use:
obj.xInternal__.Data
obj.xInternal__.KeyAliases
obj.xInternal__.OriginalKeys
```

### Reserved Key Protection

The `dotReference` method blocks attempts to use the reserved name as a configuration key:

```matlab
if key == "xInternal__"
    error('ConfigurationData:ReservedKey', ...
        'Key "xInternal__" is reserved for internal use.');
end
```

## Alternatives Considered

### 1. Keep Properties Private
- **Rejected**: No tab completion is unacceptable for usability

### 2. Revert to 4 Public Hidden Properties
- **Rejected**: Reserves 4 key names (Data, KeyAliases, OriginalKeys, SourceFormat) instead of 1

### 3. Use dynamicprops Instead of RedefinesDot
- **Rejected**: Cannot handle special characters in keys (e.g., hyphens in `build-system`)
- See `Claude/DYNAMICPROPS_ANALYSIS.md` for full analysis

### 4. File Enhancement Request with MathWorks
- **Considered for future**: Request `getDotCompletionResults` API or similar
- Not a short-term solution

## Related Documents

- `Claude/DYNAMICPROPS_ANALYSIS.md` - Why dynamicprops approach was rejected
- `Claude/ISSUE_14_RESERVED_NAMES.md` - Reserved name handling with OverridesPublicDotMethodCall
- `Claude/DESIGN_DECISIONS.md` - Overall design philosophy

## Date

January 2026
