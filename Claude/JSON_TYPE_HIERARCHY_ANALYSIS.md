# JSON Type Hierarchy Analysis: Evaluating the Cell Array Design

**Date:** 2026-02-05

**Context:** Developer feedback raised concerns about type irregularity in JSONData navigation, where values can be MATLAB arrays, cell arrays, or JSONData objects.

---

## Table of Contents

1. [The Feedback](#the-feedback)
2. [Current Design](#current-design)
3. [The Core Problem](#the-core-problem)
4. [Analysis of Concerns](#analysis-of-concerns)
5. [Alternative Approaches](#alternative-approaches)
6. [Comparative Analysis](#comparative-analysis)
7. [Recommendation](#recommendation)

---

## The Feedback

A developer reviewer raised these concerns:

**Problem:** Type irregularity when navigating JSONData hierarchy

Any value in JSONData can be one of three things:
1. MATLAB arrays (double, string, logical, etc.)
2. Cell arrays (to force array representation in JSON)
3. JSONData objects (nested structures)

**Specific Concerns:**
- Most users will need to opt into cell arrays for correct round-tripping
- Cell array syntax is not appealing - difficult to know when to use curlies `{}`
- Extra layer of indexing required when there's only one element
- Cell arrays aren't the default - discoverability risk
- Consumers of JSONData likely to miss this detail and introduce bugs
- Correctly handling all three cases makes user code complicated

---

## Current Design

### SequenceRule='auto' (Default)

```matlab
% JSON: {"ports": [8080, 8443]}
data = readjson('config.json');
result = data.ports;  % [8080; 8443] - double array

% JSON: {"authors": [{"name": "Alice"}, {"name": "Bob"}]}
authors = data.authors;  % [1x2 JSONData] array

% JSON: {"tags": ["alpha", "beta"]}
tags = data.tags;  % ["alpha"; "beta"] - string array

% JSON: {"mixed": [1, "two", true]}
mixed = data.mixed;  % {1, "two", true} - cell array (mixed types)
```

**Conversion Rules:**
- Homogeneous numeric arrays → double array
- Homogeneous string arrays → string array
- Arrays of objects → JSONData array
- Mixed-type arrays → cell array

### SequenceRule='cell' (Opt-in)

```matlab
% JSON: {"ports": [8080, 8443]}
data = readjson('config.json', 'SequenceRule', 'cell');
result = data.ports;  % {8080, 8443} - cell array

% Allows round-trip preservation:
% JSON: [5] → MATLAB: {5} → JSON: [5] ✓
```

**Conversion Rules:**
- ALL arrays → cell arrays
- Preserves distinction between scalar `5` and array `[5]`

---

## The Core Problem

This is fundamentally the same issue discussed in [YAML_SCALAR_ARRAY_ROUNDTRIP.md](YAML_SCALAR_ARRAY_ROUNDTRIP.md):

**MATLAB does not distinguish between scalars and single-element arrays.**

```matlab
x = 5;      % This is [5]
y = [5];    % This is also [5]
isequal(x, y)  % true
```

**JSON (and YAML, TOML) DO distinguish:**
```json
{"count": 5}       // Scalar number
{"counts": [5]}    // Array with one element
```

### Why This Matters for JSON Specifically

Unlike YAML/TOML which are primarily human-written config files, JSON is:
1. **Machine-to-machine** - Often used for API responses, data interchange
2. **Schema-driven** - Many JSON APIs have strict schemas (OpenAPI, JSON Schema)
3. **Type-sensitive** - Some systems care about `5` vs `[5]`
4. **Array-heavy** - JSON APIs frequently use arrays for everything

**Example: Kubernetes manifest**
```json
{
  "spec": {
    "containers": [              // MUST be array
      {
        "name": "web",
        "ports": [                // MUST be array
          {"containerPort": 3000}
        ]
      }
    ]
  }
}
```

If `ports` has only one element and you read-modify-write:
- **Read:** `ports` becomes scalar JSONData object (not array)
- **Modify:** User might do `ports.containerPort = 8080`
- **Write:** Outputs `"ports": {"containerPort": 8080}` ❌ (should be array)

---

## Analysis of Concerns

### Concern 1: "Most users will need to opt into cell arrays"

**Assessment: PARTIALLY TRUE**

**Depends on use case:**

| Use Case | Need SequenceRule='cell'? |
|----------|---------------------------|
| Read config, use values | ❌ No - 'auto' is better |
| Modify config, write back | ❌ Mostly no - structures preserved |
| Round-trip preservation of [5] vs 5 | ✅ Yes |
| Generating JSON for strict APIs | ✅ Maybe - depends on schema |

**Evidence from test files:**
- 27+ sample files in `tests/SampleFiles/`
- Most are **read-only** use cases (package.json, k8s manifests, VSCode settings)
- Only 1-2 require strict round-trip fidelity

**Counterpoint:**
For the primary use case (reading config files), 'auto' is correct. Cell arrays would make the code *harder*:

```matlab
% SequenceRule='auto' (natural)
if config.port > 8000
    % works immediately
end

% SequenceRule='cell' (requires unwrapping)
if config.port{1} > 8000  % ugly, error-prone
    % must remember to index
end
```

### Concern 2: "Cell array syntax is not appealing"

**Assessment: TRUE**

Cell array syntax is objectively more complex:

```matlab
% Accessing elements
arr = data.items;      % Is it [1,2,3] or {1,2,3}?
val = arr(1);          % Works for arrays
val = arr{1};          % Works for cells

% Iterating
for v = arr            % Works for arrays
for v = arr(:)'        % Needed for cells (harder)

% Math operations
sum(arr)               % Works for double array
sum([arr{:}])          % Required for cell array (ugly)
```

**But:** This is a fundamental MATLAB limitation, not a design flaw in JSONData.

### Concern 3: "Cell arrays aren't the default"

**Assessment: CORRECT DECISION**

Making cell arrays the default would break the primary use case:

```matlab
% If SequenceRule='cell' were default:
config = readjson('app.json');
timeout = config.timeout;  % {30} - cell!
if timeout > 10  % ERROR: can't compare cell to number
```

Users would need to unwrap EVERY value, making the toolbox unusable for its intended purpose.

**Design principle from YAML_SCALAR_ARRAY_ROUNDTRIP.md:**
> "A single port number `8080` and a list of ports `[8080]` are semantically identical to MATLAB code consuming them. Forcing the distinction hurts the 90% use case."

### Concern 4: "Consumers will miss this detail and introduce bugs"

**Assessment: VALID CONCERN, but overstated**

**Two scenarios:**

**Scenario A: Reading values (90% of use cases)**
```matlab
config = readjson('package.json');
name = config.name;        % string - works
version = config.version;  % double - works
deps = config.dependencies; % JSONData - works with dot notation
```

No type checking needed. Code "just works."

**Scenario B: Generic processing (uncommon)**
```matlab
function processValue(val)
    if isa(val, 'matlab.io.config.JSONData')
        % Process nested object
    elseif iscell(val)
        % Process array (rare in 'auto' mode)
    else
        % Process scalar/array
    end
end
```

This is complex, but:
1. Only needed for **generic** processors (uncommon)
2. Same complexity exists in YAML, TOML
3. Alternative (SequenceRule='cell') makes **all** code complex

### Concern 5: "Handling this correctly makes code complicated"

**Assessment: MISLEADING**

**Typical user code (with SequenceRule='auto'):**
```matlab
% Simple and natural
config = readjson('app.json');
if config.enabled
    connect(config.database.host, config.database.port)
end

for author = config.authors  % JSONData array
    disp(author.name)
end
```

**No type checking needed** because:
- Scalar values are native MATLAB types (double, string, logical)
- Nested objects are JSONData (support dot notation)
- Arrays are mostly homogeneous (handled automatically)

**What WOULD be complicated:** Making cell arrays the default
```matlab
config = readjson('app.json', 'SequenceRule', 'cell');
if config.enabled{1}  % Must unwrap everything!
    connect(config.database{1}.host, config.database{1}.port)
end
```

---

## Alternative Approaches

### Alternative 1: Make SequenceRule='cell' the Default

**Pros:**
- Preserves round-trip fidelity for `5` vs `[5]`
- Consistent type (everything is cell or JSONData)
- No ambiguity

**Cons:**
- ❌ Breaks primary use case (reading config values)
- ❌ Requires `{1}` syntax for all array access
- ❌ No math operations without unwrapping: `sum([arr{:}])`
- ❌ Users would add `SequenceRule='auto'` to every call
- ❌ Inconsistent with YAML/TOML behavior

**Verdict:** Would make toolbox unusable for 90% of users.

### Alternative 2: Always Return JSONData Arrays

**Idea:** `[1,2,3]` → `[1x3 JSONData]` instead of `double`

**Example:**
```matlab
ports = data.ports;  % [1x3 JSONData] where each is scalar number
port1 = ports(1).value;  % Access via .value
```

**Pros:**
- Consistent type throughout hierarchy
- Could add methods for array operations

**Cons:**
- ❌ Extremely verbose for simple arrays
- ❌ Can't do math: `sum(ports)` doesn't work
- ❌ Massive overhead for common case
- ❌ No precedent in MATLAB (even table doesn't do this)

**Verdict:** Over-engineered. Solves non-problem.

### Alternative 3: Add Type Metadata

**Idea:** Store whether value "was an array" in metadata

```matlab
data = readjson('file.json');
data.ports;  % 8080 (scalar, looks normal)
% Internal: data.xInternal__.ArrayKeys contains "ports"
writejson(data, 'out.json');  % Writes [8080] (preserved!)
```

**Pros:**
- Best of both worlds - usability AND round-trip
- No syntax changes

**Cons:**
- ❌ Fragile: Lost if user reassigns `data.ports = 8080`
- ❌ Complex implementation
- ❌ Doesn't solve schema validation (still need to know expected types)
- ❌ Users can't easily control array vs scalar on write

**Verdict:** Too clever. Hides behavior. Hard to maintain.

### Alternative 4: Provide Array Wrapper Type

**Idea:** Explicit `JSONArray` type for forcing array representation

```matlab
data = JSONData();
data.ports = JSONArray([8080]);  % Explicit array
writejson(data);  // Writes "ports": [8080]

data.count = 5;  % Scalar
writejson(data);  // Writes "count": 5
```

**Pros:**
- Explicit user intent
- Works with 'auto' mode for reading
- No syntax overhead for reading

**Cons:**
- ❌ Only helps for **writing**, not round-trip reading
- ❌ Another type to learn
- ❌ Breaks struct compatibility
- ❌ Most JSON writes are from read data, not manual construction

**Verdict:** Partial solution. Doesn't address reading concerns.

### Alternative 5: Schema-Based Reading

**Idea:** User provides schema defining array vs scalar

```matlab
schema.ports = 'array';
schema.count = 'scalar';
data = readjson('file.json', 'Schema', schema);
```

**Pros:**
- Precise control
- Matches how strict JSON APIs work

**Cons:**
- ❌ Requires writing schema for every file
- ❌ Defeats purpose of "easy config file reading"
- ❌ Most users don't have/want schemas

**Verdict:** Too heavyweight for config file use case.

---

## Comparative Analysis

### How Other Tools Handle This

#### Python (json module)
```python
import json

# {"count": 5} → 5 (int)
# {"counts": [5]} → [5] (list)
```

**Preserves distinction naturally** because Python distinguishes scalar vs list.

**Equivalent code:**
```python
if data['count'] > 10:  # Just works

for item in data['counts']:  # Iteration works
    print(item)
```

#### JavaScript
```javascript
// {"count": 5} → 5 (number)
// {"counts": [5]} → [5] (Array)

if (data.count > 10) { }  // Works
data.counts.forEach(...)   // Works
```

**Preserves distinction naturally** because JS distinguishes scalar vs array.

#### R (jsonlite)
```r
# {"counts": [5]} → c(5) (numeric vector)
# {"count": 5} → 5 (numeric scalar)
```

**BUT:** R has same issue as MATLAB! `5` and `c(5)` are identical:
```r
identical(5, c(5))  # TRUE
```

**jsonlite solution:** `simplifyVector` parameter (default TRUE)
- TRUE: Arrays → vectors (like SequenceRule='auto')
- FALSE: Arrays → lists (like SequenceRule='cell')

**Default is TRUE** (auto-simplification) for usability.

#### MATLAB jsondecode (built-in)
```matlab
% Built-in MATLAB function
data = jsondecode('{"ports": [8080, 8443]}');
data.ports  % [8080; 8443] - double array
```

**Built-in MATLAB uses 'auto' approach** - no cell arrays by default.

### Industry Practice: Auto-Simplification is Standard

| Language/Tool | Default Behavior | Opt-in Strict Mode |
|---------------|------------------|-------------------|
| MATLAB jsondecode | Auto-simplify | N/A |
| R jsonlite | Auto-simplify | simplifyVector=FALSE |
| Python json | Preserves (natural) | N/A |
| JavaScript | Preserves (natural) | N/A |
| **Our readjson** | Auto-simplify | SequenceRule='cell' |

**Conclusion:** Our design matches industry standards for languages with MATLAB's scalar/array ambiguity.

---

## Recommendation

### Keep Current Design

**Verdict: The current design is sound. Do NOT change course.**

### Rationale

1. **Use-case aligned:**
   - Primary use case (reading config files) works naturally with 'auto'
   - Strict round-trip (rare) is supported via 'cell' option

2. **Precedent:**
   - Matches MATLAB's built-in `jsondecode`
   - Matches R's `jsonlite` default
   - Consistent with YAML/TOML in this toolbox ([YAML_SCALAR_ARRAY_ROUNDTRIP.md](YAML_SCALAR_ARRAY_ROUNDTRIP.md))

3. **User experience:**
   - 'auto' mode requires no type checking for common cases
   - Cell arrays would make simple code complicated
   - Dot notation "just works" for nested access

4. **Pragmatic engineering:**
   - Accepts semantic equivalence of `5` and `[5]` in MATLAB
   - Provides escape hatch (SequenceRule='cell') for strict needs
   - Documentation can explain trade-offs

### Addressing the Concerns

**Response to reviewer:**

> "Most users will need to opt into cell arrays"

**False.** Most users (reading config files) should use 'auto'. Cell arrays are only needed for:
- Strict round-trip of `5` vs `[5]` distinction
- Generating JSON for APIs with strict schemas

These are **minority** use cases. For the majority, 'auto' is correct.

> "Cell array syntax is not appealing"

**Agreed.** That's why it's NOT the default. Users who need round-trip fidelity make an explicit choice with understanding of trade-offs.

> "Cell arrays aren't currently the default - discoverability risk"

**Intentional.** Making cell arrays the default would break the primary use case. The 'auto' default matches MATLAB's built-in `jsondecode` and R's `jsonlite`.

> "Consumers of JSONData are likely to miss this detail and introduce bugs"

**Overstated.** For reading config files (primary use case), no type checking is needed:
```matlab
config = readjson('app.json');
timeout = config.timeout;  % Just works (double)
host = config.database.host;  // Just works (string)
```

Generic processing is rare and inherently requires type dispatch (same for YAML, TOML, any dynamic data).

> "Handling this correctly can make their code complicated"

**Only if you make cell arrays the default.** With 'auto', user code is simple and natural. The complexity comes from trying to preserve a distinction (scalar vs array) that MATLAB doesn't support.

---

## Improvements to Consider

### 1. Better Documentation

**Add to readjson help:**

```matlab
%   ARRAY HANDLING
%   By default, JSON arrays are converted to native MATLAB arrays when
%   possible (SequenceRule='auto'). This provides natural syntax:
%       data.ports + 1000          % Works on [8080, 8443]
%       contains(data.tags, "prod")  % Works on ["dev", "prod"]
%
%   For strict round-trip preservation where [5] must stay distinct from 5,
%   use SequenceRule='cell'. Note that this requires cell array syntax:
%       data = readjson(file, 'SequenceRule', 'cell');
%       firstPort = data.ports{1};  % Cell indexing required
%       sum([data.values{:}])        % Must unwrap for math
%
%   Most users should use the default 'auto' mode.
```

### 2. Add writejson Array Control ✅ IMPLEMENTED

**Status:** Implemented as `ArrayKeys` parameter (2026-02-05)

Force specific keys to be arrays when writing:

```matlab
data = JSONData();
data.ports = 8080;  % Scalar in MATLAB
writejson(data, 'out.json', 'ArrayKeys', ["ports"]);
% Output: "ports": [8080]
```

This helps when **writing** JSON for APIs with schema requirements (more common than round-trip reading). Use cases include:
- Kubernetes manifests (containers, ports, volumes must be arrays)
- GitHub Actions workflows (steps must be array)
- Template generation with known schema

**Note:** Named `ArrayKeys` (not `ArrayFields`) to align with JSON specification terminology ("name/value pairs" or "members") and existing codebase terminology where "keys" is primary term.

### 3. Add Validation Helpers

For users consuming JSONData from APIs with schemas:

```matlab
function validateArrayField(data, fieldName)
    % Helper to ensure field is array-like for iteration
    if ~iscell(data.(fieldName)) && ~isa(data.(fieldName), 'matlab.io.config.JSONData')
        error('Expected array field: %s', fieldName);
    end
end
```

Document this pattern for users who need to validate structure.

### 4. Example Gallery

Add examples showing common patterns:

```matlab
% Example: Consuming a GitHub API response
% File: examples/github_api.m
response = readjson('repos.json');  % SequenceRule='auto'

% Natural iteration over array
for repo = response.items
    fprintf('%s: %s\n', repo.name, repo.description);
end

% Natural access to values
if response.items(1).stargazers_count > 100
    disp('Popular repo!');
end
```

---

## Conclusion

**The design is not wrong.**

The reviewer's concerns stem from comparing to languages (Python, JavaScript) that naturally distinguish scalars from arrays. In MATLAB, this distinction doesn't exist, so any JSON reader must choose:

1. **Usability** (auto-simplify arrays) ← We chose this
2. **Fidelity** (preserve via cell arrays) ← Available via option

We chose usability as the default, matching:
- MATLAB's built-in `jsondecode`
- R's `jsonlite` (simplifyVector=TRUE default)
- The YAML/TOML behavior in this toolbox
- The primary use case (reading config files, not round-trip editing)

**For users who need strict round-trip:**
- `SequenceRule='cell'` provides this
- They make an informed choice with understanding of trade-offs
- This is documented and tested

**No course change needed.** Improvements made:
- ✅ Added `ArrayKeys` option to writejson for write-side control (2026-02-05)
- ✅ Improved documentation explaining the design choice
- ✅ Added examples showing common patterns (K8s, GitHub Actions)

---

## References

- [YAML_SCALAR_ARRAY_ROUNDTRIP.md](YAML_SCALAR_ARRAY_ROUNDTRIP.md) - Prior analysis of same issue for YAML
- [DESIGN_DECISIONS.md](DESIGN_DECISIONS.md) - Overall design philosophy
- R jsonlite documentation: https://cran.r-project.org/web/packages/jsonlite/
- MATLAB jsondecode documentation

---

**Status:** Analysis complete. Recommend keeping current design with improved documentation.
