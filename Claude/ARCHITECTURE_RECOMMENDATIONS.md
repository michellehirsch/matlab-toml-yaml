# Architecture Recommendations

This document provides an analysis of the current toolbox architecture and recommendations for improvement.

## Current Architecture Summary

### Class Hierarchy
```
ConfigurationData (574 lines)
├── YAMLData (61 lines)
├── TOMLData (62 lines)
└── INIData (101 lines)
```

The base class `ConfigurationData` handles:
- Dictionary-based storage with cell wrapping
- Key aliasing (hyphen → underscore mapping)
- Order preservation via `OriginalKeys`
- Custom dot notation via `RedefinesDot`
- Method priority override via `OverridesPublicDotMethodCall`
- Custom display via `CustomDisplay`

### I/O Functions
| Function | Lines | Complexity |
|----------|-------|------------|
| readyaml.m | ~420 | Medium |
| readtoml.m | ~1,250 | High |
| readini.m | ~145 | Low |
| writeyaml.m | ~455 | Medium |
| writetoml.m | ~750 | High |
| writeini.m | ~185 | Low |

Total: ~3,200 lines across 6 files

---

## Architectural Strengths

### 1. Clean Class Design
The `ConfigurationData` base class is well-architected:
- **Value semantics**: Correct choice for configuration data (immutable-style, predictable)
- **OverridesPublicDotMethodCall**: Allows data keys named "keys", "isfield", etc.
- **Key aliasing**: Elegant solution for hyphenated keys
- **Order preservation**: Important for round-trip fidelity

### 2. Consistent API
All formats share the same access patterns:
```matlab
data = readyaml('file.yaml');
data = readtoml('file.toml');
data = readini('file.ini');
data.section.key  % Same access pattern
```

### 3. Good Separation of Concerns
- Classes handle storage/access
- Functions handle parsing/serialization
- Documentation is thorough (Claude/, doc/, examples/)

---

## Recommendations

### 1. Extract Shared Parsing Utilities (Priority: Medium)

**Current Issue**: The parsers duplicate logic for:
- Quote handling and escape sequences
- Value type detection (numbers, booleans, dates)
- Multi-line string accumulation
- Array element splitting

**Recommendation**: Create a private `+internal` package:
```
toolbox/
├── +internal/
│   ├── parseQuotedString.m
│   ├── detectValueType.m
│   ├── splitPreservingQuotes.m
│   ├── escapeString.m
│   └── unescapeString.m
```

**Benefits**:
- Reduces code duplication by ~200-300 lines
- Centralizes bug fixes for string handling
- Improves testability of edge cases

### 2. Refactor Monolithic Parsers (Priority: Low)

**Current Issue**: `readtoml.m` is 1,250 lines with 30+ nested functions, making it hard to:
- Navigate and understand
- Test individual components
- Maintain and debug

**Recommendation**: Split into logical units:
```
toolbox/
├── +internal/+toml/
│   ├── parseValue.m
│   ├── parseTable.m
│   ├── parseArrayOfTables.m
│   ├── parseInlineTable.m
│   └── parseString.m
```

**Trade-off**: MATLAB's package import syntax is verbose. Consider whether the improved organization justifies the added complexity.

### 3. Add Streaming/Incremental API (Priority: Low)

**Current Issue**: All files are read entirely into memory before parsing.

**Recommendation**: For very large files, consider a line-by-line parser:
```matlab
parser = internal.toml.StreamParser('large.toml');
while parser.hasNext()
    [key, value] = parser.next();
end
```

**Trade-off**: Likely overkill for configuration files, which are typically small. Only implement if users report memory issues.

### 4. Formalize Error Handling Strategy (Priority: Medium)

**Current Issue**: Error identifiers are inconsistent:
- `yamlToolbox:readyaml:ParseError`
- `tomlToolbox:readtoml:InvalidSyntax`
- `readini:ReadFailed`

**Recommendation**: Standardize error identifiers:
```matlab
% Pattern: <toolbox>:<function>:<ErrorType>
error('ConfigurationFileIO:readyaml:ParseError', ...)
error('ConfigurationFileIO:readtoml:SyntaxError', ...)
error('ConfigurationFileIO:readini:FileNotFound', ...)
```

### 5. Add Round-Trip Fidelity Options (Priority: Medium)

**Current Issue**: Comments are discarded during parsing. Some users may want to preserve them.

**Recommendation**: Add a `PreserveComments` option:
```matlab
data = readyaml('config.yaml', PreserveComments=true);
writeyaml(data, 'config.yaml');  % Comments preserved
```

**Implementation**: Store comments as metadata in `ConfigurationData`:
```matlab
properties (Access = protected)
    Comments dictionary  % key -> comment text
end
```

**Trade-off**: Significant complexity for a niche use case. Consider user demand before implementing.

### 6. Consider Builder Pattern for Writers (Priority: Low)

**Current Issue**: Writer functions have many options, leading to long argument blocks.

**Recommendation**: Add a fluent builder interface:
```matlab
TOMLWriter(data) ...
    .withArrayStyle('flow') ...
    .withTableStyle('expanded') ...
    .withPrecision(4) ...
    .writeTo('config.toml');
```

**Trade-off**: MATLAB's lack of method chaining sugar makes this awkward. Current name-value arguments are idiomatic MATLAB.

### 7. Add Schema Validation (Priority: Low)

**Recommendation**: Allow users to validate configuration against a schema:
```matlab
schema = ConfigSchema;
schema.addRequired('database.host', 'string');
schema.addOptional('database.port', 'numeric', 5432);

data = readtoml('config.toml');
validate(data, schema);  % Throws if invalid
```

**Trade-off**: Adds complexity. May be better as a separate toolbox.

---

## Quick Wins

### 1. Consolidate Helper Functions
Move duplicated helpers to shared location:
- `needsQuoting()` exists in both `writetoml.m` and `writeyaml.m`
- `looksLikeNumber()` / `looksLikeDate()` could be shared

### 2. Add Type Hints to Function Signatures
Use `arguments` blocks consistently (already done in most places, but some edge cases remain).

### 3. Improve Array-of-Tables Parsing
The CLAUDE.md notes that array-of-tables reading has bugs. This should be a priority fix.

---

## Not Recommended

### 1. Switching to Handle Classes
Value semantics are correct for configuration data. Don't change.

### 2. Adding External Dependencies
The "no external toolboxes" constraint is valuable. Maintain it.

### 3. Auto-generating Parsers
Tools like ANTLR or PEG.js could generate parsers, but:
- Adds build complexity
- MATLAB integration is awkward
- Current hand-written parsers are adequate

---

## Summary

The architecture is fundamentally sound. The main opportunities are:

| Priority | Recommendation | Effort | Impact |
|----------|---------------|--------|--------|
| Medium | Extract shared parsing utilities | Medium | Code quality |
| Medium | Standardize error identifiers | Low | Consistency |
| Medium | Add comment preservation | High | User feature |
| Low | Refactor monolithic parsers | High | Maintainability |
| Low | Add streaming API | High | Performance |
| Low | Add schema validation | High | User feature |

The codebase is well-organized for its current scope. Most recommendations should be driven by user feedback rather than speculative refactoring.
