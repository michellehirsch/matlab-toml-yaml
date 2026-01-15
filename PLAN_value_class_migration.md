# Migration Plan: ConfigurationData to Value Class

## Goal
Convert `ConfigurationData` and subclasses from handle classes to value classes for intuitive MATLAB semantics.

## Key Enabler
MATLAB's `dictionary` type (R2022b+) has **value semantics**, unlike `containers.Map` which is a handle class.

## Minimum MATLAB Version
R2022b or newer (for `dictionary` support)

---

## Phase 1: Convert ConfigurationData Base Class

### 1.1 Change Class Declaration
Remove `handle` from inheritance:
```matlab
% FROM:
classdef ConfigurationData < handle & matlab.mixin.indexing.RedefinesDot & matlab.mixin.CustomDisplay

% TO:
classdef ConfigurationData < matlab.mixin.indexing.RedefinesDot & matlab.mixin.CustomDisplay
```

### 1.2 Replace containers.Map with dictionary
```matlab
% FROM:
properties (Access = public, Hidden = true)
    Data containers.Map
    KeyAliases containers.Map
    OriginalKeys string
end

% TO:
properties (Access = public, Hidden = true)
    Data dictionary = configureDictionary("string", "cell")
    KeyAliases dictionary = configureDictionary("string", "string")
    OriginalKeys string = string.empty
end
```

### 1.3 Update Constructor
```matlab
function obj = ConfigurationData
    obj.Data = configureDictionary("string", "cell");
    obj.KeyAliases = configureDictionary("string", "string");
    obj.OriginalKeys = string.empty;
end
```

### 1.4 Dictionary Access Pattern Changes
| Operation | containers.Map | dictionary (cell values) |
|-----------|---------------|-------------------------|
| Get value | `obj.Data(key)` | `obj.Data(key){1}` |
| Set value | `obj.Data(key) = val` | `obj.Data(key) = {val}` |
| Check key | `isKey(obj.Data, key)` | `isKey(obj.Data, key)` ✓ |
| Get keys | `keys(obj.Data)` → cell | `keys(obj.Data)` → string |
| Remove | `remove(obj.Data, key)` | `obj.Data = remove(obj.Data, key)` |

### 1.5 Simplify copy() Method
```matlab
function newObj = copy(obj)
    newObj = obj;  % Value semantics = automatic deep copy
end
```

### 1.6 Update rmfield() - must capture return from remove()
```matlab
obj.Data = remove(obj.Data, resolvedKey);
```

---

## Phase 2: Update Reader Functions

### 2.1 readyaml.m (Low Impact)
- Update dictionary access syntax
- Builds objects fresh, returns them - minimal changes needed

### 2.2 readini.m (Medium Impact)
- Current pattern gets reference to nested section, modifies in place
- New pattern: get copy, modify, write back
- Or use dot notation which handles nesting via dotAssign

### 2.3 readtoml.m (High Impact)
- Remove handle optimization check (lines 433-435)
- Apply write-back pattern consistently throughout
- Update handleTable(), handleArrayOfTables(), parseKeyValue()

---

## Phase 3: Update Subclasses

### 3.1 INIData.m, YAMLData.m, TOMLData.m
- Update wrapNested() to use dictionary
- Simplify copy() override
- Handle conversion from containers.Map if needed

---

## Phase 4: Update Tests

### 4.1 Modify Existing Tests
- Copy independence tests should still pass
- Update any tests relying on handle behavior

### 4.2 Add New Tests
- Test that assignment creates independent copies
- Test value semantics throughout

---

## Implementation Order

1. ConfigurationData.m - base class
2. Run tests (expect failures)
3. readyaml.m + YAMLData.m
4. Run YAML tests
5. readini.m + INIData.m
6. Run INI tests
7. readtoml.m + TOMLData.m
8. Run all tests
9. Add value semantics tests
10. Delete this plan file

---

## Files to Modify

- [ ] toolbox/ConfigurationData.m
- [ ] toolbox/INIData.m
- [ ] toolbox/YAMLData.m
- [ ] toolbox/TOMLData.m
- [ ] toolbox/readini.m
- [ ] toolbox/readyaml.m
- [ ] toolbox/readtoml.m
- [ ] tests/*.m (as needed)
