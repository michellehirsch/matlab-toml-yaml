# Bug: New keys added to YAMLData/TOMLData create ConfigurationData instead of preserving class type

**Issue Type:** Bug  
**Priority:** Medium  
**Labels:** bug, ConfigurationData  
**Created:** 2026-01-14

---

## Bug Description

When adding a new key to a `YAMLData` or `TOMLData` object via dot notation, the nested object is created as `ConfigurationData` instead of preserving the parent object's class type.

## Steps to Reproduce

```matlab
server = readyaml("examples/server_config.yaml");
server.cache.enabled = true;
disp(server);
```

## Expected Behavior

```
server = 

  YAMLData with keys:

    application: [1×1 YAMLData with 3 keys]
    database: [1×1 YAMLData with 4 keys]
    logging: [1×1 YAMLData with 2 keys]
    cache: [1×1 YAMLData with 1 key]  ✓ Should be YAMLData
```

## Actual Behavior

```
server = 

  YAMLData with keys:

    application: [1×1 YAMLData with 3 keys]
    database: [1×1 YAMLData with 4 keys]
    logging: [1×1 YAMLData with 2 keys]
    cache: [1×1 ConfigurationData with 1 key]  ✗ Wrong class!
```

## Root Cause

In [`ConfigurationData.m`](../toolbox/ConfigurationData.m) method `dotAssign`, lines 395 and 400 create new objects using:

```matlab
nested = ConfigurationData;
```

This hardcodes the class to `ConfigurationData` instead of preserving the actual class of the parent object (`YAMLData` or `TOMLData`).

**Problematic code locations:**
- Line 395: `nested = ConfigurationData;`
- Line 400: `nested = ConfigurationData;`

## Proposed Fix

Replace hardcoded class instantiation with dynamic class construction:

```matlab
% Instead of:
nested = ConfigurationData;
nested.SourceFormat = obj.SourceFormat;

% Use:
nested = feval(class(obj));  % Creates object of same class as parent
nested.SourceFormat = obj.SourceFormat;
```

This ensures that:
- `YAMLData` objects create `YAMLData` children
- `TOMLData` objects create `TOMLData` children  
- `ConfigurationData` objects create `ConfigurationData` children

## Impact

**Severity:** Medium

**Affects:**
1. **User experience** - Inconsistent class names in display
2. **Type checking** - `isa(server.cache, 'YAMLData')` would unexpectedly return `false`
3. **Serialization** - Writing back to file might lose format information
4. **Class-specific behavior** - Any YAMLData/TOMLData-specific methods won't work on nested objects

**Workaround:**  
Manually create nested objects before assignment:
```matlab
server.cache = YAMLData();
server.cache.enabled = true;
```

## Additional Context

- Affects both `YAMLData` and `TOMLData` classes (both inherit from `ConfigurationData`)
- Found in: `toolbox/ConfigurationData.m`, `dotAssign` method, lines 395, 400-401
- Example reference: `toolbox/GettingStarted.m`, line 34

## Testing Checklist

After fixing, verify:
- [ ] `server.cache` is `YAMLData` when parent is `YAMLData`
- [ ] Multi-level nesting preserves class: `server.a.b.c` all same class
- [ ] `TOMLData` objects also preserve class correctly
- [ ] Direct `ConfigurationData` usage still works
- [ ] Existing tests still pass (especially `tomltest` and `yamltest`)
