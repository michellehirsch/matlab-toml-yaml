# Array Indexing Limitations in ConfigurationData

**Date:** 2026-01-13  
**Context:** Analysis of indexing behavior for arrays of `ConfigurationData` objects in TOML parser

---

## Core Problem: `matlab.mixin.indexing.RedefinesDot` Limitations

The `ConfigurationData` class uses `matlab.mixin.indexing.RedefinesDot` which provides custom dot notation behavior via `dotReference` and `dotAssign` methods. **However, this mixin has a critical limitation**: it does NOT support assignment chains that include array indexing of the object itself.

---

## The Three Problematic Cases

### Setup for Reproduction

```matlab
% Load a TOML file with an array of tables
data = readtoml("tests/SampleFiles/array_of_tables.toml");

% This file contains [[users]] with 3 elements, each having name, email, permissions, etc.
% data.users is a 1x3 TOMLData array
```

### 1. `data.users.name` → "Too many input arguments"

**What happens:**
- `data.users` returns a 1x3 array of `TOMLData` objects
- `.name` is then applied to this array, which tries to call `dotReference` on **each element**
- This attempts to return multiple values (comma-separated list), causing the error

**Example:**
```matlab
>> data = readtoml("tests/SampleFiles/array_of_tables.toml");
>> data.users.name
Error: Too many input arguments.
```

**Why this fails:**
- `data.users` evaluates to a `[1×2 TOMLData]` array
- Accessing `.name` on this array tries to return multiple values
- `dotReference` is called on the array as a whole, not individually on each element
- The mixin doesn't know how to handle returning comma-separated lists

**Should this work?**
- **Ideally yes** - with structs, `s(1:2).name` returns `[s(1).name, s(2).name]` as a comma-separated list
- However, with `RedefinesDot`, this is very tricky because `dotReference` is called on the array as a whole, not individually on each element
- Making this work requires returning multiple outputs from `dotReference`, which `dotListLength` is supposed to control, but the implementation is complex

**Recommendation:**
- **Provide a better error message** explaining that the user needs to index first
- Suggested error: `"Cannot access field 'name' on array of ConfigurationData without indexing. Use data.users(1).name or loop over elements."`
- Making this work properly would require overriding `subsref` entirely (high complexity, medium value)
- **Priority: Low** - Document the limitation and provide clear error message

---

### 2. `data.users(2).permissions = []` → "The 'Name' property is only supported for..."

**What happens:**
- MATLAB calls `subsasgn(data, S)` where S is:
```matlab
S(1).type = '.', S(1).subs = 'users'
S(2).type = '()', S(2).subs = {2}  
S(3).type = '.', S(3).subs = 'permissions'
```
- `RedefinesDot` calls `dotAssign(obj, indexOp, value)` 
- But `dotAssign` receives `indexOp(1).Name = 'users'` and doesn't know how to handle the `()` indexing in `indexOp(2)`
- The mixin doesn't support this pattern: **`.field(index).subfield = value`**

**Example:**
```matlab
>> data = readtoml("tests/SampleFiles/array_of_tables.toml");
>> data.users(2).permissions = []
Error: The 'Name' property is only supported for indexing operations whose Type property is Dot.
```

**Should this work?**
- **Absolutely yes!** This is fundamental functionality that users expect
- This is the most critical issue to fix

**Status: FIXED** (2026-01-14) - Enhanced `dotAssign` to handle `Paren` type in indexOp chain.

---

### 3. `data.users(2).name = "Suzie"` → Same error as #2

**What happens:**
Same root cause as Issue #2 - assignment to a field within an array element.

**Example (before fix):**
```matlab
>> data = readtoml("tests/SampleFiles/array_of_tables.toml");
>> data.users(2).name = "Suzie"
Error: The 'Name' property is only supported for indexing operations whose Type property is Dot.
```

**Status: FIXED** (2026-01-14) - Same fix as Issue #2.

---

## Technical Root Cause

The `matlab.mixin.indexing.RedefinesDot` mixin only handles these patterns:

### ✅ Supported Patterns
- `obj.field` (dotReference)
- `obj.field = value` (dotAssign)
- `obj.field.subfield` (chained dotReference)
- `obj.field.subfield = value` (chained dotAssign)
- `obj.field(index)` within dotReference (handled explicitly in ConfigurationData code at line 345-358)

### ❌ Unsupported Patterns (Require Custom Implementation)
- `obj.field(index) = value` 
- `obj.field(index).subfield` (reference)
- `obj.field(index).subfield = value` (assignment)
- `obj(index).field` on array of ConfigurationData
- `obj(index).field = value` on array of ConfigurationData

These require custom `subsref`/`subsasgn` implementations that go beyond what `RedefinesDot` provides.

---

## Implementation Strategy for Fix

### For Issues #2 and #3: Override `subsasgn`

Add a `subsasgn` method to `ConfigurationData` that detects and handles the pattern:
```
S(1).type = '.'   (field access)
S(2).type = '()'  (array indexing)
S(3).type = '.'   (nested field access)
```

**Algorithm:**
```matlab
function obj = subsasgn(obj, S, value)
    % Detect pattern: obj.field(index).subfield = value
    if length(S) >= 3 && strcmp(S(1).type, '.') && strcmp(S(2).type, '()')
        % 1. Get the array using dotReference
        arr = dotReference(obj, S(1));
        
        % 2. Extract the index
        indices = S(2).subs{:};
        
        % 3. Get the specific element
        elem = arr(indices);
        
        % 4. Use subsasgn on the element for the remaining chain
        elem = subsasgn(elem, S(3:end), value);
        
        % 5. Write back to the array
        arr(indices) = elem;
        
        % 6. Store the modified array back to obj
        obj = dotAssign(obj, S(1), arr);
    else
        % Delegate to RedefinesDot's implementation
        obj = builtin('subsasgn', obj, S, value);
    end
end
```

**Testing:**
- Verify `data.users(2).permissions = []` works
- Verify `data.users(2).name = "Suzie"` works
- Verify chained assignment `data.users(1).permissions.admin = true` works
- Ensure regular patterns still work: `data.field = value`, `data.field.subfield = value`

---

## Additional Considerations

### Heterogeneous Arrays
Arrays of `ConfigurationData` can have different keys per element:
```matlab
data.users(1) has keys: ["name", "email", "permissions"]
data.users(2) has keys: ["name", "email", "role"]
```

This is why comma-separated list behavior from Issue #1 is problematic:
- `data.users.name` would work (both have "name")
- `data.users.permissions` would fail (only element 1 has it)

**Recommendation:** Good error messages are critical when keys don't match across array elements.

### MATLAB Struct Comparison
For reference, standard MATLAB struct behavior:
```matlab
>> s(1).a = 1; s(2).a = 2;
>> s.a
ans = 1
ans = 2       % Returns comma-separated list

>> s(2).b = 5;  % Works fine
>> s.b
Error: Reference to non-existent field 'b'.  % Only fails for missing fields
```

ConfigurationData should aim for similar behavior where practical, but can deviate where heterogeneous data makes it infeasible.

---

## Summary and Resolution Status

| Issue | Pattern | Priority | Status |
|-------|---------|----------|--------|
| #1 | `data.users.name` | **Low** | Open - Better error message needed |
| #2 | `data.users(2).permissions = value` | **HIGH** | **FIXED** (2026-01-14) |
| #3 | `data.users(2).name = value` | **HIGH** | **FIXED** (2026-01-14) |

### Resolution for Issues #2 and #3

**Date:** 2026-01-14

Issues #2 and #3 were fixed by enhancing `dotAssign` in `ConfigurationData.m` to handle `Paren` type operations in the `indexOp` chain.

**Key insight:** We discovered that `dotAssign` actually receives the full indexing chain including `Paren` operations (not just `Dot` operations). The fix detects when `indexOp(2).Type == Paren` and handles it by:
1. Getting the array from `obj.Data(key)`
2. Indexing into it with `indexOp(2).Indices`
3. Recursively applying the remaining chain to that element
4. Writing the modified element back to the array

**Note:** We initially attempted to override `subsasgn`, but discovered that `RedefinesDot` explicitly forbids this. The `dotAssign` enhancement was the correct solution.

**Tests:** See `tests/subsasgnTest.m` for validation tests.

---

## Test Cases to Validate Fix

```matlab
% Setup
tomlContent = ['[[users]]' newline ...
              'name = "Alice"' newline ...
              '[users.permissions]' newline ...
              'read = true' newline ...
              '[[users]]' newline ...
              'name = "Bob"'];
data = readtoml('test.toml');

% Test 1: Assignment to array element field (Issue #3)
data.users(2).name = "Suzie";
assert(data.users(2).name == "Suzie");

% Test 2: Assignment to nested field in array element (Issue #2)
data.users(2).permissions = struct('read', false);
assert(data.users(2).permissions.read == false);

% Test 3: Creating new nested structure
data.users(1).settings.theme = "dark";
assert(data.users(1).settings.theme == "dark");

% Test 4: Regular patterns still work
data.title = "Test";
assert(data.title == "Test");

data.config.nested.field = 42;
assert(data.config.nested.field == 42);

% Test 5: Edge case - chained assignment through array
data.users(1).permissions.admin = true;
assert(data.users(1).permissions.admin == true);
```

---

## Investigation: `parenDotAssign` Built-in Method

**Date:** 2026-01-14

The `RedefinesDot` mixin provides two concrete methods—`parenDotAssign` and `parenDotListLength`—that handle assignment statements with built-in parentheses indexing immediately followed by customized dot indexing, such as `obj(idx).prop = val`.

### Testing `parenDotAssign`

We created a minimal test class (`research/TestParenDot.m`) to explore this capability:

```matlab
% Test 1: Direct array indexing - WORKS
arr = [TestParenDot(), TestParenDot()];
arr(2).name = 'Suzie';  % SUCCESS - parenDotAssign handles this

% Test 2: Through a parent object - FAILS
parent = TestParenDot();
parent.users(2).name = 'Charlie';  % FAILED: "The 'Name' property is only supported..."
```

### Key Finding

**`parenDotAssign` only works for direct array indexing**, i.e., when the `RedefinesDot` object itself is indexed:
- ✅ `arr(2).name = value` — Works because `arr` is the `RedefinesDot` object
- ❌ `parent.users(2).name = value` — Fails because `parent` is the `RedefinesDot` object, not `users`

The pattern `parent.users(2).name = value` routes through `parent`'s `dotAssign`, which receives the full chain but doesn't know how to handle the `()` indexing in the middle.

### Conclusion

**`parenDotAssign` does not solve Issues #2 and #3.** A custom `subsasgn` override is still required. The `subsasgn` approach will be **complementary** to `RedefinesDot`, not a replacement:

1. `RedefinesDot` continues to handle: `obj.field`, `obj.field = value`, `obj.field.subfield = value`
2. `subsasgn` intercepts specifically: `obj.field(idx).subfield = value` pattern
3. All other patterns delegate back to the default behavior

---

## References

- [MATLAB Documentation: matlab.mixin.indexing.RedefinesDot](https://www.mathworks.com/help/matlab/matlab_oop/customize-object-indexing.html)
- ConfigurationData implementation: `toolbox/ConfigurationData.m`
- Test file: `tests/tomltest.m::testNestedTablesInArrays`
- Research files: `research/TestParenDot.m`, `research/testTestParenDot.m`
