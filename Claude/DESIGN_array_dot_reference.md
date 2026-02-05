# Design Decision: Array Dot-Reference Behavior

**Date:** 2026-01-14 (original), 2026-02-05 (updated)
**Status:** Implemented - Return concatenated typed arrays with strict requirements

---

## Context

When a user has an array of `ConfigurationData` objects and attempts to access a field on the entire array:

```matlab
data = readtoml("tests/SampleFiles/array_of_tables.toml");
data.products.name  % products is a 1x3 TOMLData array
```

MATLAB structs would return a comma-separated list: `[s(1).name, s(2).name, s(3).name]`.

The question: Should `ConfigurationData` support this behavior?

---

## Decision (Updated 2026-02-05)

**Yes, with strict requirements.** Array dot reference now returns concatenated typed arrays when:
1. All elements have the requested key
2. All values have the same type (can be concatenated)

```matlab
data.products.name    % Returns: ["Hammer" "Nail" "Screwdriver"]
data.products.sku     % Returns: [738594937 284758393 847520193]
data.products.in_stock % Returns: [true true false]
```

If requirements aren't met, helpful errors are thrown:
- Missing key: `"Key 'x' is missing in elements [2, 4]."`
- Type mismatch: `"Types differ: element 1 is string, element 3 is double."`

---

## Behavior Summary

| Scenario | All Have Key? | Types Match? | Result |
|----------|--------------|--------------|--------|
| All strings | Yes | Yes | string array |
| All numbers | Yes | Yes | double array |
| All logical | Yes | Yes | logical array |
| All ConfigurationData | Yes | Yes | ConfigurationData array |
| Mixed types | Yes | No | **ERROR** |
| Missing in some | No | N/A | **ERROR** |

---

## Design Decisions

### D1: Missing Keys - Error

We require all elements to have the requested key. This:
- Matches struct behavior (all elements must have field)
- Catches data errors early
- Provides predictable behavior

Users can pre-filter using `iskey`:
```matlab
hasEmail = iskey(data.users, "email");
emails = data.users(hasEmail).email;
```

### D2: Type Mismatch - Error (Strict)

We require all values to have the same concatenatable type. This:
- Ensures predictable return types (no surprise cell arrays)
- Avoids code that needs to handle both typed arrays and cells
- Encourages clean data

Users can use `arrayfun` for heterogeneous data:
```matlab
values = arrayfun(@(x) x.value, arr, 'UniformOutput', false);
```

**Future consideration:** A `pluck` method could provide explicit cell output.

### D3: Vectorized `iskey`

The `iskey` method now returns a logical array for array inputs:
```matlab
iskey(data.users, "email")  % Returns: [true false true]
all(iskey(data.users, "name"))  % Check if ALL have key
```

This enables filtering patterns and is a breaking change from the previous behavior (which only checked the first element).

### D4: Logical Index Pre-Filtering

When accessing `arr.field(logicalMask)` where `logicalMask` matches the size of `arr`, the array is pre-filtered before checking if all elements have the key. This enables the ergonomic pattern:

```matlab
% Direct shorthand - pre-filters before key check
scores = arr.score(iskey(arr, "score"))

% Equivalent to the longer form:
hasScore = iskey(arr, "score");
scores = arr(hasScore).score
```

This is detected when:
1. `indexOp(2)` is a Paren operation
2. It contains a single logical index
3. The logical index has the same size as `obj`

---

## Rationale

### Why Not Comma-Separated Lists?

We chose to return a single concatenated result rather than comma-separated lists because:
1. `dotListLength` would need to return `numel(obj)` dynamically
2. Capturing comma-separated lists requires special syntax: `[a, b, c] = ...`
3. A single array is more convenient for most use cases

### Why Not Always Return Cell Arrays?

Returning cells for heterogeneous types would create unpredictable APIs:
- Sometimes `arr.field` returns `["a", "b"]`
- Sometimes `arr.field` returns `{1, "two", true}`
- Calling code would need to handle both cases

The strict approach ensures predictable types.

### Why Error on Missing Keys?

Optional fields in config files are common, but accessing them across an array should be explicit:
```matlab
% Check first, then access
if all(iskey(arr, "optional"))
    values = arr.optional;
end

% Or filter to elements that have it
values = arr(iskey(arr, "optional")).optional;
```

This prevents silent failures when data structure changes.

---

## Implementation

### `iskey` Method (vectorized)
```matlab
function tf = iskey(obj, key)
    tf = false(size(obj));
    for i = 1:numel(obj)
        resolvedKey = obj(i).resolveKey(key);
        tf(i) = ~isempty(resolvedKey);
    end
end
```

### `dotReference` (array handling)
```matlab
if ~isscalar(obj)
    % Check all elements have the key
    hasKey = iskey(obj, fieldName);
    if ~all(hasKey)
        % Error with missing element indices
    end

    % Collect values
    values = cell(size(obj));
    for i = 1:numel(obj)
        values{i} = obj(i).getData(resolvedKey);
    end

    % Concatenate (errors if types differ)
    result = tryConcatenate(values, fieldName);
end
```

### `parenDotAssign` (array element assignment)
Now handles `arr(idx).field = value` pattern correctly.

---

## Examples

```matlab
% Read TOML with array of tables
data = readtoml("tests/SampleFiles/array_of_tables.toml");

% Array dot reference - returns typed arrays
names = data.products.name      % ["Hammer" "Nail" "Screwdriver"]
prices = data.products.price    % [19.99 0.05 24.99]
active = data.products.in_stock % [true true false]

% Chained access through nested objects
admins = data.users.permissions.admin  % [false false true]

% Filtering with iskey (two equivalent approaches)
hasEmail = iskey(data.users, "email");
emails = data.users(hasEmail).email;        % Filter array, then access
emails = data.users.email(hasEmail);        % Access with logical pre-filter (shorthand)

% Type mismatch error
j1 = jsondata(); j1.v = 1;
j2 = jsondata(); j2.v = "two";
[j1 j2].v  % ERROR: Types differ

% Missing key error
j1 = jsondata(); j1.name = "Alice";
j2 = jsondata();  % no name
[j1 j2].name  % ERROR: Key missing in elements [2]
```

---

## References

- Implementation: `toolbox/+matlab/+io/+config/ConfigurationData.m`
- Tests: `tests/subsasgnTest.m` (array dot reference section)
- Related: `Claude/ARRAY_INDEXING_LIMITATIONS.md`
