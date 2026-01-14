# Design Decision: Array Dot-Reference Behavior

**Date:** 2026-01-14
**Status:** Decided - Provide helpful error message instead of comma-separated list

---

## Context

When a user has an array of `ConfigurationData` objects and attempts to access a field on the entire array:

```matlab
data = readtoml("tests/SampleFiles/array_of_tables.toml");
data.users.name  % users is a 1x3 TOMLData array
```

MATLAB structs would return a comma-separated list: `[s(1).name, s(2).name, s(3).name]`.

The question: Should `ConfigurationData` mimic this behavior?

---

## Decision

**No.** We provide a clear error message with workarounds instead:

```
Cannot access field 'name' on a [1 3] array of TOMLData objects.
Index into the array first, e.g., obj(1).name or use:
  arrayfun(@(x) x.name, obj)
```

---

## Rationale

### 1. Heterogeneous Data Problem

Unlike structs, `ConfigurationData` arrays can have different keys per element:

```matlab
data.users(1)  % has keys: name, email, permissions
data.users(2)  % has keys: name, email, role  (no permissions!)
```

With structs, all elements must have identical fields. With `ConfigurationData`, elements can vary. This creates several problems:

- `data.users.name` might work (all have `name`)
- `data.users.permissions` would fail unpredictably (only some have it)
- The behavior depends on runtime data content, not code structure

### 2. Fragile Code

Code that relies on comma-separated list behavior would be fragile:

```matlab
% This would work sometimes, fail at runtime other times
[names{:}] = data.users.name;
```

Debugging such failures is difficult because the error depends on what data happened to be loaded.

### 3. Implementation Complexity

Supporting comma-separated lists would require:

1. Detecting non-scalar `obj` in `dotReference`
2. Looping over elements and collecting results
3. Modifying `dotListLength` to return `numel(obj)` dynamically
4. Deciding what to do when some elements lack the key (error? skip? empty?)
5. Handling nested arrays (`data.users.permissions.read` where each level might be arrays)

This is significant complexity for a feature that would be unreliable due to heterogeneous data.

### 4. Simple Workarounds Exist

Users can easily achieve the same result with explicit, predictable code:

```matlab
% Using arrayfun (returns array)
names = arrayfun(@(x) x.name, data.users);

% Using a loop (most flexible)
for i = 1:length(data.users)
    names{i} = data.users(i).name;
end

% Cell array collection
names = cell(1, length(data.users));
for i = 1:length(data.users)
    names{i} = data.users(i).name;
end
```

These approaches are explicit about what they do and fail predictably if a key is missing.

---

## Alternative Considered

We considered implementing comma-separated list behavior with the constraint that all array elements must have the requested key. However:

- Users would get inconsistent behavior: works for some fields, fails for others
- Error messages would be confusing ("field exists in element 1 but not element 2")
- The implicit behavior makes code harder to reason about
- It's better to be consistently explicit than inconsistently implicit

---

## Implementation

Added a check at the start of `dotReference` in `ConfigurationData.m`:

```matlab
if ~isscalar(obj)
    fieldName = indexOp(1).Name;
    error('ConfigurationData:ArrayDotReference', ...
        ['Cannot access field ''%s'' on a %s array of %s objects.\n' ...
         'Index into the array first, e.g., obj(1).%s or use:\n' ...
         '  arrayfun(@(x) x.%s, obj)'], ...
        fieldName, mat2str(size(obj)), class(obj), fieldName, fieldName);
end
```

---

## References

- Issue documented in: `Claude/ARRAY_INDEXING_LIMITATIONS.md` (Issue #1)
- Implementation: `toolbox/ConfigurationData.m`, `dotReference` method
