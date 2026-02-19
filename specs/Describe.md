# Spec: Structural overview for ConfigurationData

**Author:** Michelle Hirsch
**Date:** February 6, 2026
**Status:** Draft

---

## Requirements

### Problem statement

ConfigurationData objects can be deeply nested — k8s manifests, package.json, GitHub Actions workflows — but the current tools only let you explore one level at a time, or dump everything.

**Current tools and their gaps:**

| Tool | What it shows | Gap |
|---|---|---|
| `disp(config)` | One level of keys. Nested objects shown as `[1x1 JSONData with 3 keys]`. | Must drill down key by key to explore deeper. |
| `show(config)` | Full content serialized in native format (JSON/YAML/TOML) with all values. | Good for reading values, but noisy for understanding structure. For large files, hard to see the forest for the trees. |
| `keys(config)` | Top-level key names only. | No type info, no nesting. |

### Use cases

**UC1: "What's in this file?"** (visual exploration)
A user loads an unfamiliar config file (e.g., a coworker's k8s deployment YAML). They want to quickly understand the overall structure — what sections exist, how deep the nesting goes, and what types of data are at each level — before deciding what to access.

*Pain point:* Today requires repeatedly typing `config.spec`, `config.spec.template`, `config.spec.template.spec`, etc. to discover the tree structure one level at a time.

**UC2: "Is this what I expect?"** (visual verification)
A user has built up a ConfigurationData object programmatically and wants to verify the structure looks right before writing it to a file — correct nesting, right types, nothing missing.

*Pain point:* `show()` dumps all values which obscures the structural shape. `disp()` only shows the first level.

**UC3: "What type is that field?"** (visual or programmatic)
A user is writing code to process a config file and needs to know whether a particular field is a string, a number, a nested object, or an array, so they can handle it correctly.

*Pain point:* Must access each field individually and inspect it. No overview of types across the structure.

**UC4: "How big is this?"** (visual)
A user loads a large config file and wants to understand the scope — how many keys at each level, where the arrays are, how deep it goes — before diving in.

*Pain point:* `show()` can produce hundreds of lines of output. `disp()` hides all sub-structure behind `[1x1 JSONData with N keys]`.

**UC5: "Are my arrays cells or native types?"** (programmatic)
A user reads a JSON file with `SequenceRule='cell'` vs default and wants to programmatically check which keys ended up as cell arrays vs. native MATLAB arrays. This matters for writing downstream code that handles the data correctly.

*Pain point:* No way to get type information across the full structure without manually accessing every field. `class()` only works on individual values.

**UC6: "Which elements in this array are different?"** (programmatic)
A user has a ConfigurationData array (e.g., a list of servers from a config file). Most elements have the same schema, but some have extra keys or different types for the same key. They want to find the inconsistencies.

*Pain point:* Must loop through elements and compare `keys()` and types manually. No built-in way to see the schema across an array.

**UC7: "Find all keys matching a pattern"** (programmatic)
A user wants to find all keys named "port" or "host" anywhere in a deeply nested config, regardless of where they appear in the hierarchy.

*Pain point:* Must manually walk the tree. No search or query capability.

### Requirements summary

| ID | Requirement |
|---|---|
| R1 | Show the full recursive key hierarchy in a single output |
| R2 | Show MATLAB type and size for each value |
| R3 | Show actual values for scalar leaf nodes (strings, numbers, booleans) with type annotation |
| R4 | Allow limiting recursion depth |
| R5 | Work for all ConfigurationData subclasses (JSONData, YAMLData, TOMLData, INIData) |
| R6 | Handle ConfigurationData arrays (e.g., JSON arrays of objects) |
| R7 | Provide a programmatic output that can be queried/filtered (UC5-UC7) |

---

## Approach A: `describe` method

A new method on ConfigurationData focused on structural overview.

### Signature

```matlab
describe(config)              % prints visual tree to command window
describe(config, Depth=2)     % limit recursion depth

info = describe(config)       % returns table for programmatic use
```

Called with function syntax (consistent with `keys()`, `show()`, `isfield()`).

### Visual output (no output argument)

Each key shows its name, its value (for scalar leaves) or structural annotation (for nested/array data), and a type annotation in parentheses. Nested ConfigurationData objects are recursed with increased indentation. Keys within a nesting level are left-aligned.

#### Key display rules

**Scalar leaf values** — show value with type annotation:
```
    name:               "acme-webapp" (string)
    port:               3000 (double)
    private:            false (logical)
```

**Non-scalar leaf values** — show size and type:
```
    rulers:             1x2 double
    browserslist:       3x1 string
    items:              3x1 cell
```

**Nested ConfigurationData (expanded)** — just the key name as a header, children indented below. No `JSONData (N keys)` annotation since the keys are visible:
```
    engines:
        node:               ">=18.0.0" (string)
```

**Nested ConfigurationData (depth-limited)** — show key count since children are not displayed. No class name — the key count tells you it's a nested structure:
```
    engines:            (1 key)
```

**ConfigurationData arrays (expanded)** — show dimensions + "array", then recurse with union of keys:
```
    env:                2x1 array
        name:               string
        value:              string
```

**ConfigurationData arrays (depth-limited)** — show dimensions + "array" and key count:
```
    env:                2x1 array (2 keys each)
```

#### Example — `readjson('01_package.json')`

```
>> describe(pkg)

  JSONData with 14 keys

    name:               "acme-webapp" (string)
    version:            "1.0.0" (string)
    description:        "Synthetic example of a Node.js..." (string)
    type:               "module" (string)
    license:            "MIT" (string)
    private:            false (logical)
    engines:
        node:               ">=18.0.0" (string)
    main:               "dist/index.js" (string)
    exports:
        .:
            import:             "./dist/index.js" (string)
            require:            "./dist/index.cjs" (string)
        ./feature:          "./dist/feature.js" (string)
    scripts:
        build:              "tsc -p tsconfig.json" (string)
        dev:                "vite" (string)
        test:               "vitest run" (string)
        lint:               "eslint ." (string)
        start:              "node dist/index.js" (string)
    dependencies:
        express:            "^4.19.0" (string)
        zod:                "^3.23.0" (string)
        axios:              "^1.7.0" (string)
        dotenv:             "^16.4.0" (string)
    devDependencies:
        typescript:         "^5.4.0" (string)
        eslint:             "^9.0.0" (string)
        vite:               "^5.0.0" (string)
        vitest:             "^1.3.1" (string)
    peerDependencies:
        react:              ">=18" (string)
    browserslist:       3x1 string
```

#### Example — k8s deployment (deeply nested)

```
>> describe(k8s)

  JSONData with 4 keys

    apiVersion:         "apps/v1" (string)
    kind:               "Deployment" (string)
    metadata:
        name:               "acme-web" (string)
        labels:
            app:                "acme-web" (string)
    spec:
        replicas:           3 (double)
        selector:
            matchLabels:
                app:                "acme-web" (string)
        template:
            metadata:
                labels:
                    app:                "acme-web" (string)
            spec:
                containers:
                    name:               "web" (string)
                    image:              "ghcr.io/acme/web:1.0.0" (string)
                    ports:
                        containerPort:      3000 (double)
                    env:                2x1 array
                        name:               string
                        value:              string
                    resources:
                        requests:
                            cpu:                "100m" (string)
                            memory:             "128Mi" (string)
                        limits:
                            cpu:                "500m" (string)
                            memory:             "512Mi" (string)
                    livenessProbe:
                        httpGet:
                            path:               "/health" (string)
                            port:               3000 (double)
                        initialDelaySeconds: 10 (double)
                        periodSeconds:       15 (double)
```

#### Example — `Depth=1` (top level only)

When depth-limited, nested objects show just the key count since their children aren't displayed:

```
>> describe(pkg, Depth=1)

  JSONData with 14 keys

    name:               "acme-webapp" (string)
    version:            "1.0.0" (string)
    description:        "Synthetic example of a Node.js..." (string)
    type:               "module" (string)
    license:            "MIT" (string)
    private:            false (logical)
    engines:            (1 key)
    main:               "dist/index.js" (string)
    exports:            (2 keys)
    scripts:            (5 keys)
    dependencies:       (4 keys)
    devDependencies:    (4 keys)
    peerDependencies:   (1 key)
    browserslist:       3x1 string
```

#### Example — non-scalar array as root

```
>> arr = [jsondata(s1); jsondata(s2)];
>> describe(arr)

  2x1 array

    name:    string
    host:    string
    port:    double
```

Note: for ConfigurationData arrays, values vary across elements, so only types are shown (no value previews).

### Programmatic output (with output argument)

When called with an output argument, `describe` returns a table with one row per key path in the structure. This flattened view enables querying, filtering, and programmatic inspection.

#### Table columns

| Column | Type | Description |
|---|---|---|
| `Path` | string | Dot-separated key path from root (e.g., `"spec.template.spec.containers.name"`) |
| `Type` | string | MATLAB class name (e.g., `"string"`, `"double"`, `"JSONData"`) |
| `Size` | string | Size as text (e.g., `"1x1"`, `"2x1"`, `"3x4"`) |

#### Example — package.json

```matlab
>> info = describe(pkg);
>> info(1:8, :)

    Path                    Type         Size
    ____________________    _________    ____
    "name"                  "string"     "1x1"
    "version"               "string"     "1x1"
    "description"           "string"     "1x1"
    "type"                  "string"     "1x1"
    "license"               "string"     "1x1"
    "private"               "logical"    "1x1"
    "engines"               "JSONData"   "1x1"
    "engines.node"          "string"     "1x1"
```

#### Example — programmatic queries

```matlab
info = describe(config);

% UC5: Find all cell arrays
info(info.Type == "cell", :)

% UC7: Find all keys named "port" anywhere in the tree
info(endsWith(info.Path, "port") | endsWith(info.Path, "Port"), :)

% Find all leaf values under "dependencies"
info(startsWith(info.Path, "dependencies."), :)

% Find all non-scalar values
info(info.Size ~= "1x1", :)
```

#### ConfigurationData arrays in the table

For a key that holds a ConfigurationData array (e.g., `env: 2x1 array`), the table shows:
- A row for the array itself: Path=`"env"`, Type=`"JSONData"`, Size=`"2x1"` (table uses MATLAB class names for programmatic use)
- Rows for the union of keys across all elements: Path=`"env.name"`, Path=`"env.value"`, etc.
- Type for child keys is taken from the first element that has each key

**Open question:** When types differ across array elements (e.g., element 1 has `value: "hello"`, element 2 has `value: 42`), what should the Type column show?
- Option A: First element's type — simple, but hides the mismatch
- Option B: All unique types joined — `"string | double"` — reveals the issue
- Option C: Add a `Uniform` column — `true`/`false` flag

### Type display rules (visual output)

| Value type | Expanded (keys visible) | Depth-limited (keys hidden) |
|---|---|---|
| Scalar string | `"value" (string)` | `"value" (string)` |
| Scalar double | `42 (double)` | `42 (double)` |
| Scalar logical | `true (logical)` | `true (logical)` |
| String array | `MxN string` | `MxN string` |
| Numeric array | `MxN double` | `MxN double` |
| Logical array | `MxN logical` | `MxN logical` |
| Char array | `'text' (char)` | `'text' (char)` |
| Cell array | `MxN cell` | `MxN cell` |
| Scalar ConfigurationData | *(just key name, recurse)* | `(N keys)` |
| ConfigurationData array | `MxN array` then recurse | `MxN array (N keys each)` |
| Missing | `missing` | `missing` |
| Empty | `0x0 double` | `0x0 double` |

- Long strings (>40 chars) are truncated with `"..."`
- For scalar leaf values, show the value with type in parentheses
- For non-scalar leaf values, show `MxN type` (no value preview)
- For ConfigurationData that will be expanded: no annotation, children speak for themselves
- For ConfigurationData that won't be expanded (depth limit): show key count only (no class name)

### Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `Depth` | positive integer | `Inf` | Maximum nesting depth to display. `1` shows top-level only. |

---

## Approach B: Extend `show` with structure/type modes

Rather than a new method, extend the existing `show` with options that modify what's displayed. This builds on users' existing familiarity with `show` and the native file formats.

### B1: Types mode — replace values with type placeholders

`show(config, Mode="types")` outputs the native format but with MATLAB type annotations instead of values.

**JSON:**
```
>> show(pkg, Mode="types")
{
  "name": <string>,
  "version": <string>,
  "description": <string>,
  "type": <string>,
  "license": <string>,
  "private": <logical>,
  "engines": {
    "node": <string>
  },
  "main": <string>,
  "exports": {
    ".": {
      "import": <string>,
      "require": <string>
    },
    "./feature": <string>
  },
  "scripts": {
    "build": <string>,
    "dev": <string>,
    "test": <string>,
    "lint": <string>,
    "start": <string>
  },
  "dependencies": {
    "express": <string>,
    "zod": <string>,
    "axios": <string>,
    "dotenv": <string>
  },
  "devDependencies": { ... 4 keys },
  "peerDependencies": {
    "react": <string>
  },
  "browserslist": <3x1 string>
}
```

**YAML (same data):**
```
>> show(yamlConfig, Mode="types")
name: <string>
version: <string>
description: <string>
type: <string>
license: <string>
private: <logical>
engines:
  node: <string>
main: <string>
exports:
  .:
    import: <string>
    require: <string>
  ./feature: <string>
scripts:
  build: <string>
  dev: <string>
  test: <string>
  lint: <string>
  start: <string>
dependencies:
  express: <string>
  zod: <string>
  axios: <string>
  dotenv: <string>
devDependencies: { ... 4 keys }
peerDependencies:
  react: <string>
browserslist: <3x1 string>
```

**K8s deployment as YAML (shows structure advantage with deeper nesting):**
```
>> show(k8s, Mode="types")
apiVersion: <string>
kind: <string>
metadata:
  name: <string>
  labels:
    app: <string>
spec:
  replicas: <double>
  selector:
    matchLabels:
      app: <string>
  template:
    metadata:
      labels:
        app: <string>
    spec:
      containers:
        name: <string>
        image: <string>
        ports:
          containerPort: <double>
        env:    # 2x1 array
          - name: <string>
            value: <string>
        resources:
          requests:
            cpu: <string>
            memory: <string>
          limits:
            cpu: <string>
            memory: <string>
        livenessProbe:
          httpGet:
            path: <string>
            port: <double>
          initialDelaySeconds: <double>
          periodSeconds: <double>
```

**Pros:** Users see exactly the file format they'll be writing. Structure is shown in the notation they already know. Leverages existing `show`/writer infrastructure.

**Cons:** `<type>` notation is invented; need to modify writers or build a parallel rendering path. Non-scalar leaf arrays (like `browserslist: <3x1 string>`) don't map cleanly to native format syntax.

### B2: Annotated mode — values with type comments

`show(config, Mode="annotated")` outputs the normal `show` output but with type annotations added as comments. Works naturally for YAML and TOML (which support `#` comments). JSON would use `//` (non-standard but widely recognized).

**YAML:**
```
>> show(k8s, Mode="annotated")
apiVersion: apps/v1                    # string
kind: Deployment                       # string
metadata:
  name: acme-web                       # string
  labels:
    app: acme-web                      # string
spec:
  replicas: 3                          # double
  selector:
    matchLabels:
      app: acme-web                    # string
  template:
    metadata:
      labels:
        app: acme-web                  # string
    spec:
      containers:
        name: web                      # string
        image: ghcr.io/acme/web:1.0.0  # string
        ports:
          containerPort: 3000          # double
        env:                           # 2x1 array
          - name: NODE_ENV             # string
            value: production          # string
          - name: API_BASE_URL         # string
            value: https://api.acme-payments.example  # string
        resources:
          requests:
            cpu: 100m                  # string
            memory: 128Mi              # string
          limits:
            cpu: 500m                  # string
            memory: 512Mi              # string
        livenessProbe:
          httpGet:
            path: /health              # string
            port: 3000                 # double
          initialDelaySeconds: 10      # double
          periodSeconds: 15            # double
```

**JSON:**
```
>> show(pkg, Mode="annotated")
{
  "name": "acme-webapp",                  // string
  "version": "1.0.0",                     // string
  "private": false,                        // logical
  "engines": {
    "node": ">=18.0.0"                    // string
  },
  "browserslist": [                        // 3x1 string
    ">0.5%",
    "last 2 versions",
    "not dead"
  ]
}
```

**Pros:** You see the actual values AND the MATLAB types. Best of both worlds for visual inspection. YAML/TOML comments are valid syntax.

**Cons:** JSON comments are non-standard (though `//` is widely recognized). Adds visual clutter if the types are obvious. Implementation requires post-processing the writer output or a parallel path.

### B3: Depth-limited show

`show(config, Depth=N)` shows the native format but collapses nested objects beyond depth N.

**JSON with Depth=1:**
```
>> show(pkg, Depth=1)
{
  "name": "acme-webapp",
  "version": "1.0.0",
  "description": "Synthetic example of a Node.js package manifest",
  "type": "module",
  "license": "MIT",
  "private": false,
  "engines": { ... 1 key },
  "main": "dist/index.js",
  "exports": { ... 2 keys },
  "scripts": { ... 5 keys },
  "dependencies": { ... 4 keys },
  "devDependencies": { ... 4 keys },
  "peerDependencies": { ... 1 key },
  "browserslist": [">0.5%", "last 2 versions", "not dead"]
}
```

**YAML with Depth=2 (k8s deployment):**
```
>> show(k8s, Depth=2)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: acme-web
  labels: { ... 1 key }
spec:
  replicas: 3
  selector: { ... 1 key }
  template: { ... 2 keys }
```

**Pros:** Directly addresses UC4 ("how big is this?"). Users see real values at the top level. Natural way to "peel back the onion" layer by layer.

**Cons:** The `{ ... N keys }` notation isn't valid JSON/YAML. Doesn't help with type inspection (UC3, UC5).

### B4: Combining modes

These modes could be combined:
```matlab
show(config, Mode="types", Depth=2)   % types view, 2 levels deep
show(config, Mode="annotated")         % full depth with type comments
```

### Implementation considerations for show modes

The current `show` works by writing to a temp file with `writejson`/`writeyaml`/`writetoml`, then reading and printing the result. The show modes could be implemented by either:

1. **Pre-processing:** Create a modified copy of the ConfigurationData where leaf values are replaced with type-descriptor strings, then pass through the normal writer. Simple but angle brackets would appear as `"<string>"` (quoted) in JSON.

2. **Post-processing:** Run the normal writer, then annotate the output text with type comments. Feasible for the annotated mode; fragile for the types mode.

3. **Writer modification:** Add a `Mode` parameter to the writers that controls value rendering. Most flexible but highest implementation cost — touches all four writers.

4. **Direct rendering:** Build the format-specific output directly in the `show` method without using the writer. Avoids modifying writers but duplicates formatting logic.

---

## Comparison: `describe` vs. `show` extensions

| Capability | `describe` | `show` extensions |
|---|---|---|
| Visual structural overview | Yes (indented tree) | Yes (native format) |
| Type information | Yes (type annotations) | Yes (modes: types, annotated) |
| Depth limiting | Yes (`Depth=N`) | Yes (`Depth=N`) |
| Format-native display | No (own format) | Yes (JSON/YAML/TOML) |
| Programmatic output (table) | Yes (`info = describe(...)`) | No |
| Implementation scope | One method + helper | Modify `show` + possibly writers |

These are complementary rather than competing:
- **`show` extensions** are best for visual inspection in the format you'll actually write — "show me this data as YAML, but with types" or "show me just the top 2 levels"
- **`describe`** is best for structural overview and programmatic querying — "what types are everywhere?" and "find all keys named port"

A reasonable approach: start with one, see how it feels in practice, add the other later if needed.

---

## Implementation plan

### Files to modify

| File | Change |
|---|---|
| `toolbox/+matlab/+io/+config/ConfigurationData.m` | Add public `describe` method + private helpers |

### Approach

Add a public `describe` method with private recursive helpers:

```matlab
% Public method (in public methods block)
function result = describe(obj, options)
    arguments
        obj
        options.Depth (1,1) double {mustBePositive} = Inf
    end
    if nargout == 0
        text = buildDescriptionText(obj, options.Depth);
        fprintf('%s', text);
    else
        result = buildDescriptionTable(obj, options.Depth);
    end
end
```

Two private helpers:
- `buildDescriptionText(obj, maxDepth)` — builds the visual tree string (handles indentation, alignment, recursion)
- `buildDescriptionTable(obj, maxDepth)` — builds the flat table (walks structure, collects Path/Type/Size rows)

### Existing utilities to reuse

- `shortClassName` (static, line ~1127) — strips `matlab.io.config.` prefix
- `pluralize` (static, line ~1133) — `"key"/"keys"`, `"entry"/"entries"`
- `getData` (line ~951) — unwrap cell-stored values
- `formatValue` (line ~318) — reference for value formatting patterns
- `getHeader` pattern for header line formatting

---

## Test plan

### File to create

`tests/describeTest.m`

### Test cases

1. **Simple flat structure** — all scalar types, verify values and type annotations appear
2. **Nested structure** — verify recursion and indentation; no type annotation on expanded nodes
3. **Depth limit** — `Depth=1` shows `(N keys)` for nested objects; `Depth=2` expands one level
4. **ConfigurationData array** — verify array dimensions; types shown without values
5. **Empty object** — verify "no keys" output
6. **Real file** — load `01_package.json`, verify structure matches expected output
7. **Mixed types** — numeric arrays, logicals, strings, cells, missing
8. **Non-scalar root** — `describe(arr)` for a ConfigurationData array
9. **Long string truncation** — strings >40 chars are truncated with `"..."`
10. **Works for all subclasses** — verify YAMLData, TOMLData, INIData show correct class names
11. **Table output** — `info = describe(config)` returns a table with Path, Type, Size columns
12. **Table query** — verify filtering by Type, Path patterns works as expected
13. **Table with arrays** — verify ConfigurationData arrays produce rows for array + union of child keys

### Verification commands

```matlab
addpath('toolbox')
pkg = readjson('tests/SampleFiles/01_package.json');
describe(pkg)
describe(pkg, Depth=1)
describe(pkg, Depth=2)

k8s = readjson('tests/SampleFiles/08_k8s_deployment.json');
describe(k8s)

info = describe(pkg);
info(info.Type == "string", :)

runtests('tests/describeTest.m')
```
