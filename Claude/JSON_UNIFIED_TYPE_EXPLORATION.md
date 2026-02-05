# JSON Unified Type System Exploration

**Date:** 2026-02-05

**Question:** Can we design JSONData where ALL values (scalars, arrays, objects) are JSONData, while still feeling natural for config file use cases?

---

## Table of Contents

1. [The Vision](#the-vision)
2. [Current Design (for comparison)](#current-design-for-comparison)
3. [Proposed Unified Design](#proposed-unified-design)
4. [Implementation Challenges](#implementation-challenges)
5. [Use Case Analysis](#use-case-analysis)
6. [Comparison with MATLAB Patterns](#comparison-with-matlab-patterns)
7. [Feasibility Assessment](#feasibility-assessment)
8. [Recommendation](#recommendation)

---

## The Vision

**Goal:** A consistent type system where:
1. Everything is JSONData (scalars, arrays, objects)
2. JSONData is smart enough to "feel like" primitives when appropriate
3. Scales from config files to general JSON data to tool building

**Core Principle:** Type consistency + Natural usage

```matlab
% Everything returns JSONData
data = readjson('file.json');

% Scalars are JSONData
data.port  % JSONData wrapping 8080
data.port > 8000  % Works naturally (operator overload)
data.port + 1000  % Returns JSONData wrapping 9080

% Arrays are JSONData arrays
data.ports  % [1x2 JSONData] wrapping [8080, 8443]
sum(data.ports)  % Works naturally (overloaded sum)

% Objects are JSONData (as today)
data.database  % JSONData with keys
data.database.host  % JSONData wrapping "localhost"

% Arrays of objects are JSONData arrays
data.authors  % [1x2 JSONData] wrapping author objects
data.authors(1).name  % JSONData wrapping "Alice"
```

**Key insight:** JSONData becomes a "transparent wrapper" that preserves JSON types while feeling like MATLAB types.

---

## Current Design (for comparison)

### Type Mapping (SequenceRule='auto')

| JSON | MATLAB | Type |
|------|--------|------|
| `5` | `5` | double |
| `[5, 6]` | `[5; 6]` | double array |
| `"text"` | `"text"` | string |
| `["a", "b"]` | `["a"; "b"]` | string array |
| `{"key": "val"}` | nested object | JSONData |
| `[{"a": 1}, {"b": 2}]` | array of objects | [1x2 JSONData] |
| `[1, "two"]` | mixed array | {1, "two"} cell |

**Inconsistency:** Primitives → native types, Objects → JSONData

### Usage Pattern

```matlab
data = readjson('file.json');

% Type checking required for generic code
if isa(data.value, 'matlab.io.config.JSONData')
    % Handle object
elseif iscell(data.value)
    % Handle mixed array
elseif isnumeric(data.value)
    % Handle number
elseif isstring(data.value)
    % Handle string
end
```

---

## Proposed Unified Design

### Core Concept: JSONData Wraps Everything

```matlab
classdef JSONData
    properties (Access = private)
        ValueType  % 'object', 'array', 'number', 'string', 'boolean', 'null'
        Value      % The actual MATLAB value
        % ... existing xInternal__ for object type
    end
end
```

### Type Mapping (Unified)

| JSON | MATLAB | Type |
|------|--------|------|
| `5` | scalar JSONData | JSONData (wraps double) |
| `[5, 6]` | `[1x2 JSONData]` | JSONData array |
| `"text"` | scalar JSONData | JSONData (wraps string) |
| `["a", "b"]` | `[1x2 JSONData]` | JSONData array |
| `{"key": "val"}` | scalar JSONData | JSONData (object) |
| `[{"a": 1}]` | `[1x1 JSONData]` | JSONData array |
| `[1, "two"]` | `[1x2 JSONData]` | JSONData array (heterogeneous) |

**Consistency:** Everything is JSONData, always.

### Usage Examples

```matlab
data = readjson('config.json');

% Example 1: Scalar values
port = data.port;  % JSONData wrapping 8080
if port > 8000     % Overloaded comparison
    disp("High port")
end

% Example 2: Arrays
ports = data.ports;  % [1x2 JSONData]
for port = ports     % Natural iteration
    disp(port)       % JSONData, displays like "8080"
end

% Example 3: Math operations
newPort = data.port + 1000;  % JSONData wrapping 9080
total = sum(data.ports);      % JSONData wrapping sum

% Example 4: String operations
name = data.name;  % JSONData wrapping "MyApp"
if contains(name, "App")  % Overloaded contains
    disp("Found!")
end

% Example 5: Extraction when needed
portNum = double(data.port);   % Extract: 8080 (double)
portStr = string(data.port);   % Convert: "8080" (string)
allPorts = double(data.ports); % Extract: [8080; 8443] (double array)

% Example 6: Tool building
function processJSON(jsonData)
    % Always JSONData - no type checking!
    if isscalar(jsonData) && jsonData.isObject()
        % Handle object
        for key = keys(jsonData)
            processJSON(jsonData.(key));  % Recurse
        end
    elseif ~isscalar(jsonData)
        % Handle array
        for item = jsonData
            processJSON(item);  % Recurse
        end
    else
        % Handle primitive (number, string, boolean)
        disp(jsonData)  % Works via overloaded disp
    end
end
```

---

## Implementation Challenges

### Challenge 1: Operator Overloading

**Need to overload ~40 operators for transparency:**

```matlab
classdef JSONData
    methods
        % Relational
        function result = gt(a, b)  % >
            result = extractValue(a) > extractValue(b);
        end
        function result = lt(a, b)  % <
        function result = eq(a, b)  % ==
        % ... etc for ge, le, ne

        % Arithmetic
        function result = plus(a, b)  % +
            val = extractValue(a) + extractValue(b);
            result = JSONData.fromValue(val);  % Wrap result
        end
        function result = minus(a, b)  % -
        function result = times(a, b)  % .*
        function result = rdivide(a, b)  % ./
        % ... etc for all math ops

        % Logical
        function result = and(a, b)  % &
        function result = or(a, b)   % |
        function result = not(a)     % ~

        % Indexing (already have from RedefinesDot)
        function result = parenReference(obj, indexOp)
            % Handle both array indexing and extraction
        end

        % Concatenation
        function result = horzcat(varargin)  % [a, b]
        function result = vertcat(varargin)  % [a; b]

        % Display
        function disp(obj)
            if obj.isObject()
                % Current display
            else
                disp(extractValue(obj));
            end
        end
    end
end
```

**Complexity:** ~200-300 lines of operator overloads

**Risk:** Easy to miss edge cases. Need comprehensive tests.

### Challenge 2: Built-in Function Overloading

Many built-ins won't automatically work with JSONData:

```matlab
% Need explicit overloads for:
sum(jsonData)     % Works on JSONData array
mean(jsonData)
max(jsonData)
min(jsonData)
sort(jsonData)
unique(jsonData)
contains(jsonData, pattern)  % For string JSONData
sprintf('%d', jsonData)
fprintf('%s', jsonData)
% ... dozens more
```

**Problem:** Can't override all built-ins. Some require double/string input.

**Partial solution:**
```matlab
% Provide conversion methods
methods
    function val = double(obj)
        if isscalar(obj)
            val = extractValue(obj);
        else
            val = arrayfun(@(x) double(x), obj);
        end
    end

    function val = string(obj)
        % Similar
    end

    function val = char(obj)
        % Similar
    end
end
```

**Users would need:** `sum(double(jsonData.values))`

This is **better** than cell arrays (`sum([cellData{:}])`), but still not transparent.

### Challenge 3: Array of JSONData Semantics

**Issue:** MATLAB arrays must be homogeneous in class.

```matlab
% All elements are JSONData
arr = [JSONData(5), JSONData("text"), JSONData(true)];
% ^This works - same class

% But extracting values is ambiguous
double(arr)  % What happens?
% - Convert each element? → [5, NaN, 1]? (coercion issues)
% - Error? (less surprising)
```

**Design decision needed:**
- **Option A:** Conversion functions only work on scalar JSONData
  ```matlab
  double(jsonData)  % OK if scalar
  double(jsonData)  % Error if array - use arrayfun
  ```

- **Option B:** Conversion unwraps entire array, errors if heterogeneous
  ```matlab
  double([JSONData(5), JSONData(6)])  % → [5, 6]
  double([JSONData(5), JSONData("x")])  % Error: heterogeneous
  ```

**Recommendation:** Option B - more intuitive, errors are clear.

### Challenge 4: Nested Access Syntax

**Current design:**
```matlab
data.authors(1).name  % Works (authors is JSONData array)
```

**With scalar JSONData wrapper:**
```matlab
data.name  % JSONData wrapping "Alice"
data.name + " Smith"  % Works via operator overload? Returns JSONData?

% But what about:
str = data.name;
str(1:3)  % Substring? But str is JSONData, not string!
```

**Problem:** Once wrapped, loses string/array semantics for indexing.

**Solutions:**

**Option A:** Make JSONData indexable like its content
```matlab
function result = parenReference(obj, indexOp)
    if obj.isArray()
        % Index into array of JSONData
        result = builtin('subsref', obj, indexOp);
    elseif obj.isPrimitive()
        % Index into wrapped value
        val = obj.Value;
        result = val(indexOp.Indices{:});
        result = JSONData.fromValue(result);
    else
        error('Cannot index object');
    end
end
```

This makes `data.name(1:3)` work for substring! But complex.

**Option B:** Require explicit extraction for indexing
```matlab
str = string(data.name);  % Extract
substr = str(1:3);        % Now you can index
```

Clearer but less transparent.

### Challenge 5: Performance Overhead

**Every primitive value becomes an object:**

```matlab
% Current: 8-byte double
x = 8080;

% Proposed: Object with properties
x = JSONData wrapping 8080
% - ValueType property
% - Value property
% - Possibly other metadata
% Likely ~100+ bytes per scalar
```

**For large JSON datasets:**
```json
{"data": [1, 2, 3, ..., 1000000]}  // 1M numbers
```

- **Current:** 8MB (1M doubles)
- **Proposed:** ~100MB+ (1M JSONData objects)

**Mitigation:** Lazy unwrapping? Cache primitive arrays?

### Challenge 6: Struct Compatibility

**Current design works with struct:**
```matlab
s = struct(jsonData);  % Converts to plain struct
```

**Proposed:** Everything is JSONData
```matlab
s = struct(jsonData);  % What do nested values become?
s.port  % JSONData or double?
```

Need to recursively unwrap. But then:
```matlab
writetoml(struct(jsonData))  % Would work
```

But round-trip breaks:
```matlab
json1 = readjson('file.json');  % All JSONData
s = struct(json1);              % Unwrap everything
json2 = jsondata(s);            % Re-wrap... but scalar vs array info lost
```

---

## Use Case Analysis

### Use Case 1: Config File Reading (90% case)

**Current (auto):**
```matlab
config = readjson('app.json');
if config.timeout > 10
    connect(config.host, config.port)
end
```
✅ Natural, no unwrapping needed

**Proposed (unified):**
```matlab
config = readjson('app.json');
if config.timeout > 10  % Overloaded >
    connect(config.host, config.port)  % Functions need overloads or extraction
end
```

**Problem:** `connect()` expects string/double, gets JSONData.

**Solutions:**
1. User extracts: `connect(string(config.host), double(config.port))`
2. `connect()` overloaded to accept JSONData
3. Auto-extract when passing to functions (not possible in MATLAB)

**Verdict:** Proposed is MORE verbose for this use case.

### Use Case 2: Generic JSON Processing (Tool Building)

**Current (auto):**
```matlab
function processJSON(data)
    if isa(data, 'matlab.io.config.JSONData')
        % Object
        for key = keys(data)
            processJSON(data.(key));
        end
    elseif iscell(data)
        for item = data(:)'
            processJSON(item{1});
        end
    elseif isnumeric(data) || isstring(data)
        % Leaf
        disp(data)
    end
end
```
❌ Complex type checking

**Proposed (unified):**
```matlab
function processJSON(data)
    if isscalar(data) && data.isObject()
        % Object
        for key = keys(data)
            processJSON(data.(key));
        end
    elseif ~isscalar(data)
        % Array
        for item = data
            processJSON(item);
        end
    else
        % Leaf (number, string, boolean)
        disp(data)
    end
end
```
✅ Cleaner, consistent

**Verdict:** Proposed is BETTER for this use case.

### Use Case 3: JSON as Data (not config)

**Example:** Processing API responses with arrays of data

```json
{
  "users": [
    {"id": 1, "score": 95},
    {"id": 2, "score": 87},
    {"id": 3, "score": 92}
  ]
}
```

**Current (auto):**
```matlab
data = readjson('users.json');
scores = arrayfun(@(u) u.score, data.users);
avgScore = mean(scores);
```
✅ Works, somewhat verbose

**Proposed (unified):**
```matlab
data = readjson('users.json');
scores = [data.users.score];  % Array of JSONData wrapping scores
avgScore = mean(double(scores));  % Need explicit conversion
% OR if mean is overloaded:
avgScore = mean(scores);  % Returns JSONData wrapping mean
```

**Verdict:** Similar complexity, proposed needs more overloads.

### Use Case 4: Round-trip Editing

**Current (auto):**
```matlab
config = readjson('file.json');
config.port = 9000;  % Scalar - loses array info if was [9000]
writejson(config, 'out.json');
```
❌ Loses array vs scalar distinction

**Proposed (unified):**
```matlab
config = readjson('file.json');
% config.port is JSONData with type info
config.port = JSONData.fromValue(9000);  % Explicit, preserves scalar
% OR
config.port = 9000;  % Setter wraps? Need to decide type...
writejson(config, 'out.json');
```

**Problem:** When assigning plain value, how to know if scalar or array?
```matlab
config.ports = 8080;  % Scalar or [8080]?
```

**Solution:** Assignment detection at write time (current approach) or explicit construction:
```matlab
config.ports = JSONData.number(8080);      % Scalar
config.ports = JSONData.numberArray(8080); % Array
```

**Verdict:** Proposed COULD be better, but requires explicit type construction.

---

## Comparison with MATLAB Patterns

### Pattern 1: Table with Wrapped Types

MATLAB's `table` wraps columns but extracts naturally:

```matlab
t = table([1;2;3], ["a";"b";"c"], 'VariableNames', {'num', 'str'});

% Extraction is explicit
nums = t.num;  % Returns [1;2;3] - unwrapped!

% But comparison works on table
t(t.num > 1, :)  % Filtering works
```

**Key insight:** Table doesn't wrap scalars, only columns. Extraction is automatic in some contexts.

### Pattern 2: Duration/Datetime

MATLAB's `duration` and `datetime` are wrapper types with operator overloading:

```matlab
d = duration(1, 30, 0);  % 1 hour 30 mins
d > duration(1, 0, 0)    % Works (overloaded)
d + duration(0, 30, 0)   % Works (overloaded)

% But passing to functions sometimes requires conversion
fprintf('%f', seconds(d))  % Need explicit extraction
```

**Key insight:** Wrapper types work for math/comparison, but functions often need extraction.

**This is analogous to proposed JSONData.**

### Pattern 3: Categorical

Categorical wraps strings with levels:

```matlab
c = categorical(["A", "B", "A"]);
c == "A"  % Works (overloaded)

% But extraction needed for string functions
string(c)  % Convert back to string
```

**Key insight:** Wrappers work in their domain, but need extraction for other operations.

---

## Feasibility Assessment

### Technical Feasibility: ⚠️ Possible but Complex

**Doable:**
- ✅ Operator overloading (~40 operators, ~300 lines)
- ✅ Basic built-in overloads (sum, mean, etc.)
- ✅ Unified type checking in tools
- ✅ Custom display methods

**Challenging:**
- ⚠️ Can't override ALL built-ins (sprintf, fprintf, etc.)
- ⚠️ Performance overhead (10-20x memory for large arrays)
- ⚠️ Nested indexing ambiguity (`data.name(1:3)`)
- ⚠️ Interaction with existing MATLAB code expecting primitives

**Blockers:**
- ❌ Can't make truly transparent - extraction still needed for many operations
- ❌ Breaking change - all existing code using readjson breaks

### User Experience: ⚠️ Mixed

**Better for:**
- Generic JSON processing (tool builders)
- Type consistency (everything is JSONData)
- Round-trip preservation (with explicit type construction)

**Worse for:**
- Config file reading (need extraction for function calls)
- Integration with existing code
- Learning curve (need to understand JSONData.number() vs JSONData.numberArray())
- Performance (large datasets)

### Migration Path: ❌ Breaking Change

**Current users would break:**
```matlab
% Old code (works today)
config = readjson('file.json');
port = config.port;  % double
if port > 8000       % Works

% New code (would break)
config = readjson('file.json');
port = config.port;  % JSONData, not double!
if port > 8000       % Might work (overloaded) or might break
```

**Would require:**
- Major version bump (v2.0)
- Migration guide for all users
- Deprecation period for old behavior

---

## Recommendation

### Short Answer: Not Worth It

**The unified design has merit but doesn't justify the cost.**

### Detailed Analysis

#### Pros of Unified Design
1. ✅ Type consistency (everything is JSONData)
2. ✅ Better for tool builders (generic processing)
3. ✅ Could preserve array vs scalar (with explicit constructors)
4. ✅ Scales to "JSON as data" use cases

#### Cons of Unified Design
1. ❌ **Breaking change** - all existing code breaks
2. ❌ **Worse for primary use case** (config files) - need extraction
3. ❌ **Performance overhead** (10-20x memory for primitives)
4. ❌ **Can't be truly transparent** - still need extraction for many operations
5. ❌ **High complexity** (~500+ lines of overloads, testing burden)
6. ❌ **Poor MATLAB integration** - most code expects primitives

#### The Key Insight

**The unified design optimizes for the 10% (tool builders, generic processors) at the expense of the 90% (config file readers).**

This is backwards.

### Alternative: Hybrid Approach

Instead of going all-in on unified types, consider **targeted improvements** for the 10%:

#### 1. Add Helper Functions for Tool Builders

```matlab
% File: +json/+util/forEach.m
function forEach(data, func)
    % Iterate over JSON data regardless of type
    if isa(data, 'matlab.io.config.JSONData')
        if isscalar(data)
            for key = keys(data)
                func(key, data.(key));
            end
        else
            for item = data
                func([], item);
            end
        end
    elseif iscell(data)
        for i = 1:numel(data)
            func([], data{i});
        end
    else
        func([], data);
    end
end

% Usage:
json.util.forEach(data, @(key, val) disp(val));
```

#### 2. Add Type Checking Utilities

```matlab
% File: +json/+util/isArray.m
function tf = isArray(data)
    tf = iscell(data) || (isa(data, 'matlab.io.config.JSONData') && ~isscalar(data));
end

% File: +json/+util/isObject.m
function tf = isObject(data)
    tf = isa(data, 'matlab.io.config.JSONData') && isscalar(data);
end

% File: +json/+util/isPrimitive.m
function tf = isPrimitive(data)
    tf = isnumeric(data) || isstring(data) || islogical(data) || ischar(data);
end
```

#### 3. Add `ArrayFields` Option to writejson

**(From previous analysis)**

```matlab
data = JSONData();
data.ports = 8080;  % Scalar in MATLAB

% Force array output
writejson(data, 'out.json', 'ArrayFields', ["ports"]);
% Output: "ports": [8080]
```

This solves the write-side problem without changing the type system.

#### 4. Provide Tool Builder Examples

```matlab
% File: examples/tool_builder_pattern.m
% Example: Generic JSON processor

function processJSON(data, depth)
    if nargin < 2, depth = 0; end
    indent = repmat('  ', 1, depth);

    if json.util.isObject(data)
        fprintf('%s{\n', indent);
        for key = keys(data)
            fprintf('%s  %s: ', indent, key);
            processJSON(data.(key), depth + 1);
        end
        fprintf('%s}\n', indent);
    elseif json.util.isArray(data)
        fprintf('%s[\n', indent);
        if iscell(data)
            for item = data(:)'
                processJSON(item{1}, depth + 1);
            end
        else
            for item = data
                processJSON(item, depth + 1);
            end
        end
        fprintf('%s]\n', indent);
    else
        fprintf('%s\n', string(data));
    end
end
```

### Implementation Cost Comparison

| Approach | Lines of Code | Breaking? | Benefits Primary Use Case? |
|----------|---------------|-----------|---------------------------|
| Unified type system | ~2000 | ✅ Yes | ❌ No (worse) |
| Current + utilities | ~200 | ❌ No | ✅ Yes (slightly better) |

**Utilities approach:**
- 10x less code
- No breaking changes
- Helps tool builders without hurting config users
- Can be added incrementally

---

## Conclusion

### Don't Pursue Unified Type System

**Reasons:**
1. Breaking change for marginal benefit
2. Hurts primary use case (config file reading)
3. Can't achieve true transparency anyway
4. High implementation and maintenance cost

### Instead: Enhance Current Design

**Recommendations:**
1. **Add utility functions** for tool builders (`json.util.isArray`, etc.)
2. **Add `ArrayFields` option** to writejson for write-side control
3. **Provide tool builder examples** showing patterns for generic processing
4. **Improve documentation** explaining type patterns and trade-offs
5. **Consider `readjson(..., 'Typed', true)`** option that returns metadata:
   ```matlab
   [data, meta] = readjson('file.json', 'Typed', true);
   meta.ports.wasArray  % true/false
   ```
   This preserves type info without changing the value representation.

### For Future Major Version (v2.0)

If you eventually decide a breaking change is acceptable, consider:
- Unified type system as explored here
- But only if you can solve the transparency problem better
- And only if user research shows demand from tool builders

For now, **stick with the current design + targeted improvements**.

---

## Appendix: Code Sketch for Unified Design

If you want to prototype this, here's a starting point:

```matlab
classdef JSONData
    properties (Access = private)
        ValueType  % 'object', 'array', 'number', 'string', 'boolean', 'null'
        Value      % Actual MATLAB value
        % Keep existing xInternal__ for object type
    end

    methods (Static)
        function obj = fromValue(val)
            obj = matlab.io.config.JSONData();
            if isnumeric(val)
                obj.ValueType = 'number';
                obj.Value = val;
            elseif isstring(val) || ischar(val)
                obj.ValueType = 'string';
                obj.Value = string(val);
            elseif islogical(val)
                obj.ValueType = 'boolean';
                obj.Value = val;
            % ... etc
            end
        end
    end

    methods
        % Extraction
        function val = double(obj)
            if isscalar(obj)
                mustBe(obj.ValueType, 'number');
                val = obj.Value;
            else
                val = arrayfun(@(x) double(x), obj);
            end
        end

        % Comparison
        function result = gt(a, b)
            result = extractPrimitive(a) > extractPrimitive(b);
        end

        % Arithmetic
        function result = plus(a, b)
            val = extractPrimitive(a) + extractPrimitive(b);
            result = JSONData.fromValue(val);
        end

        % Type checking
        function tf = isObject(obj)
            tf = isscalar(obj) && obj.ValueType == "object";
        end
    end

    methods (Access = private, Static)
        function val = extractPrimitive(obj)
            if isa(obj, 'matlab.io.config.JSONData')
                val = obj.Value;
            else
                val = obj;
            end
        end
    end
end
```

**Estimated full implementation:** ~2000 lines, 2-3 weeks of work, extensive testing needed.

---

**Status:** Analysis complete. Recommend enhancing current design rather than pursuing unified type system.
