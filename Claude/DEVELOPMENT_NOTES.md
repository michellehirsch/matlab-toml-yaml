# Development Notes

**Last Updated:** January 5, 2026

Implementation details, known issues, and future work for the Configuration File I/O toolbox.

---

## Table of Contents

1. [YAML Implementation](#yaml-implementation)
2. [TOML Implementation](#toml-implementation)
3. [Known Issues](#known-issues)
4. [Future Work](#future-work)

---

## YAML Implementation

### Overview

The YAML implementation is a **subset parser** - it handles the most common YAML patterns but does not support the full YAML 1.2 specification.

### Supported Features

**Data Types:**
- Strings (quoted and unquoted)
- Numbers (integers, floats, scientific notation)
- Booleans (`true`, `false`)
- Null values (`null`, `~`)
- Arrays (flow: `[...]`, block: `- item`)
- Objects/mappings (nested key-value pairs)

**Structures:**
- Nested objects (unlimited depth)
- Flow sequences: `[1, 2, 3]`
- Block sequences:
  ```yaml
  - item1
   - item2
  ```
- Mixed structures (objects in arrays, arrays in objects)

**Special Features:**
- Keys with hyphens, spaces, special characters
- Automatic aliasing (hyphen → underscore)
- GitHub Actions workflow support
- Docker Compose file support

### Not Supported

**YAML Advanced Features:**
- Anchors and aliases (`&anchor`, `*alias`)
- Multi-document files (`---` separators)
- Tags (`!!str`, `!!int`)
- Multi-line strings (folded `>`, literal `|`)
- Complex keys
- Merge keys (`<<`)

**Rationale:** These features are rarely used in typical configuration files. Supporting them would significantly complicate the parser without much practical benefit.

### Array Conversion Logic

The `SequenceRule` parameter controls how YAML sequences become MATLAB arrays:

**`"auto"` mode** (default):
```matlab
[1, 2, 3]           → double([1, 2, 3])      % All numeric
["a", "b"]          → string(["a", "b"])     % All strings
[1, "two"]          → {1, "two"}             % Mixed → cell
```

**`"cell"` mode:**
```matlab
[1, 2, 3]           → {1, 2, 3}              % Always cell
["a", "b"]          → {"a", "b"}             % Always cell
```

**Detection logic:**
1. Check if all elements are numeric → double array
2. Check if all elements are strings → string array
3. Otherwise → cell array

### Writing YAML

**Formatting options:**

`ArrayStyle`:
- `"block"` (default): Vertical lists with dashes
  ```yaml
  items:
    - one
    - two
  ```
- `"flow"`: Inline brackets
  ```yaml
  items: [one, two]
  ```

`SectionSpacing`:
- `"loose"` (default): Blank lines between top-level keys
- `"compact"`: No blank lines

`NumIndentationSpaces`:
- Default: 2
- Controls nesting indentation

### Round-Trip Fidelity

**Preserved:**
- Data values and types
- Nesting structure
- Key names (including special characters)
- Array contents

**Not preserved:**
- Comments
- Key order (may change)
- Formatting choices
- Blank line patterns

---

## TOML Implementation

### Overview

The TOML implementation supports TOML v1.0.0 with a few limitations.

### Supported Features

**Data Types:**
- Strings (basic: `"..."`, literal: `'...'`)
- Integers (decimal, hex, octal, binary)
- Floats (including infinity, NaN)
- Booleans (`true`, `false`)
- Datetime (offset date-time, local date-time, local date, local time)
- Arrays: `[1, 2, 3]`

**Structures:**
- Tables: `[section]`
- Nested tables: `[section.subsection]`
- Inline tables: `{key = "value", count = 42}`
- Array of tables: `[[items]]`

**Special Features:**
- Keys with hyphens: `build-system`
- Dotted keys: `database.host = "localhost"`
- Automatic quoting of special keys

### Known Issues

**⚠️ Array of Tables Bug:**

When reading TOML files with array of tables (`[[items]]`), only the last element is stored:

```toml
[[items]]
name = "first"

[[items]]
name = "second"

[[items]]
name = "third"
```

Result: Only `items(3)` with `name = "third"` is stored.

**Status:** 
- ❌ Reading: Broken
- ✅ Writing: Works correctly
- **Cause:** Handle reference issue in `handleArrayOfTables` function
- **Workaround:** None currently
- **Priority:** High

**⚠️ Multi-line Arrays:**

Multi-line array syntax not supported:

```toml
items = [
  "one",
  "two",
  "three"
]
```

**Status:** Not implemented
**Workaround:** Use single-line arrays
**Priority:** Medium

### Writing TOML

**Features:**
- Handles all TOML data types
- Preserves nested table structure
- Automatically quotes keys when needed
- Supports ConfigurationData, TOMLData, and struct inputs
- Full round-trip support (write → read → identical structure)

**Formatting:**
- Tables use `[section]` notation
- Nested tables use dotted notation: `[section.subsection]`
- Array of tables use `[[items]]` notation
- Keys with special characters are quoted: `"build-system"`

---

## Known Issues

### Critical

None currently.

### High Priority

**1. TOML Array of Tables (readtoml)**
- **Issue:** Only last element stored when reading `[[items]]` sections
- **Impact:** Data loss when reading certain TOML files
- **Status:** Under investigation
- **Location:** `handleArrayOfTables` in readtoml.m
- **Theory:** Handle reference not properly tracking array elements

### Medium Priority

**1. TOML Multi-line Arrays**
- **Issue:** Arrays spanning multiple lines not parsed
- **Impact:** Can't read certain TOML files
- **Workaround:** Use single-line arrays
- **Status:** Not implemented

**2. YAML Multi-line Strings**
- **Issue:** Folded (`>`) and literal (`|`) blocks not supported
- **Impact:** Can't read YAML with multi-line strings
- **Workaround:** Use quoted strings
- **Status:** Not implemented

### Low Priority

**1. Chained Indexing**
- **Issue:** `obj.field(i).subfield` doesn't work directly
- **Workaround:** Extract array first: `item = obj.field(i); item.subfield`
- **Reason:** MATLAB limitation with custom indexing
- **Status:** Known limitation

**2. Comment Preservation**
- **Issue:** Comments are lost during read → write cycle
- **Impact:** Can't maintain annotated config files
- **Status:** By design (would complicate implementation significantly)

---

## Future Work

### Short Term

1. **Fix TOML array of tables bug**
   - Debug handle reference issue
   - Add comprehensive tests
   - Verify all array of tables patterns

2. **Add multi-line array support (TOML)**
   - Detect line continuations
   - Parse arrays across multiple lines
   - Handle nested structures

3. **Improve test coverage**
   - Update tests for new unified structure
   - Add edge case tests
   - Test round-trip scenarios

### Medium Term

1. **Performance optimization**
   - Profile parser performance
   - Optimize string operations
   - Cache repeated operations

2. **Error messages**
   - More helpful parse error messages
   - Line number reporting
   - Suggest fixes for common mistakes

3. **Documentation**
   - Add more examples
   - Create troubleshooting guide
   - Document limitations clearly

### Long Term

1. **Extended YAML support**
   - Multi-line strings (folded `>`, literal `|`)
   - Consider anchors/aliases (if practical)
   - Custom tags (if needed)

2. **Additional formats**
   - JSON support (using ConfigurationData)
   - INI file support
   - XML support

3. **Advanced features**
   - Schema validation
   - Format conversion (YAML ↔ TOML)
   - Diff/merge capabilities

---

## Testing Strategy

### Current Approach

- Manual testing during development
- Example files in `examples/` folder
- Basic round-trip tests

### Needed

1. **Unit tests** for all functions
2. **Integration tests** for file I/O
3. **Edge case tests** for special characters, nested structures
4. **Performance tests** for large files
5. **Compatibility tests** across MATLAB versions

### Test Files

Organize test files by category:
```
tests/
├── yaml/
│   ├── basic.yaml
│   ├── nested.yaml
│   ├── arrays.yaml
│   └── special_chars.yaml
├── toml/
│   ├── basic.toml
│   ├── nested.toml
│   ├── array_of_tables.toml
│   └── special_keys.toml
└── round_trip/
    ├── test_yaml_roundtrip.m
    └── test_toml_roundtrip.m
```

---

## Performance Considerations

### YAML Parsing

- String operations are the bottleneck
- Large files (>1MB) may be slow
- Nested structures have linear performance

### TOML Parsing

- Regular expressions used heavily
- Inline tables require careful parsing
- DateTime parsing adds overhead

### Optimization Opportunities

1. Pre-compile regular expressions
2. Use strtok instead of regexp where possible
3. Minimize string allocations
4. Cache makeValidName results

---

## Design Patterns

### Parser Structure

Both parsers follow similar patterns:

1. **Tokenization** - Break file into lines/tokens
2. **State tracking** - Track current nesting level
3. **Type detection** - Identify data types
4. **Object building** - Construct ConfigurationData tree

### Error Handling

- Fail gracefully with informative messages
- Never lose user data
- Validate inputs early
- Provide helpful suggestions

### Extensibility

The architecture supports:
- Adding new formats (JSON, INI, XML)
- Format-specific features in subclasses
- Shared functionality in base class
- Plugin architecture (future)

---

## References

### Specifications
- YAML 1.2: https://yaml.org/spec/1.2/spec.html
- TOML v1.0.0: https://toml.io/en/v1.0.0

### Similar Tools
- Python: PyYAML, toml
- Ruby: psych (YAML), toml-rb
- JavaScript: js-yaml, @iarna/toml

### MATLAB File Exchange
- Various YAML/TOML parsers (comparison needed)

---

*These notes capture implementation details and known issues. For design rationale, see DESIGN_DECISIONS.md.*
