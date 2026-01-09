# Design Decisions

**Last Updated:** January 5, 2026

This document captures the key design decisions for the Configuration File I/O toolbox, explaining the rationale behind major architectural and naming choices.

---

## Table of Contents

1. [Function Naming: `read<type>` Pattern](#function-naming)
2. [Parameter Naming: SequenceRule](#parameter-naming)
3. [Architecture: ConfigurationData Base Class](#architecture)
4. [Code Style Conventions](#code-style)

---

## Function Naming

**Decision:** Use `read<type>` / `write<type>` pattern for all functions

**Functions:**
- `readyaml`, `writeyaml` (not `yamlread`, `yamlwrite`)
- `readtoml`, `writetoml`

### Background

Initially, the toolboxes used inconsistent naming:
- YAML: `yamlread`, `yamlwrite` (format-first)
- TOML: `readtoml`, `writetoml` (type-first)

### MATLAB's Two Patterns

**Pattern 1: Format-first** (`<format>read/write`) - Legacy
- `xlsread`, `xlswrite`, `csvread`, `csvwrite`

**Pattern 2: Type-first** (`read<type>/write<type>`) - Modern
- `readtable`, `writetable`
- `readmatrix`, `writematrix`
- `readcell`, `writecell`
- `readlines`, `writelines`
- **`readstruct`, `writestruct`** ← Key precedent!

### Key Insight: readstruct and writestruct

**`readstruct`** and **`writestruct`** are MATLAB's modern functions for reading/writing **structured configuration data**:
- Support multiple formats (XML, JSON)
- Use the `read<type>` / `write<type>` pattern
- **Do exactly what our toolboxes do**

This makes them the closest MATLAB analogue and establishes the precedent we should follow.

### Rationale

1. **Aligns with `readstruct`/`writestruct`** - The closest MATLAB analogue
2. **Modern convention** - All newer I/O functions use this pattern
3. **Data-centric** - Functions return typed objects (`YAMLData`, `TOMLData`)
4. **Consistency** - Both toolboxes follow the same pattern
5. **Future-proof** - Follows MATLAB's current direction

### Summary

By choosing `read<type>` / `write<type>`:
- ✅ Follow modern MATLAB conventions
- ✅ Align with `readstruct`/`writestruct` precedent
- ✅ Use consistent pattern across both toolboxes
- ✅ Make toolboxes feel like native MATLAB

---

## Parameter Naming

**Decision:** Use `SequenceRule` (not `ArrayFormat`) in `readyaml`

**Parameters:**
- `readyaml(file, "SequenceRule", "auto"|"cell")` - How to convert sequences
- `writeyaml(data, file, "ArrayStyle", "flow"|"block")` - How to format output

### The Problem

Original names were confusingly similar:
- `ArrayFormat` (read) - Convert YAML sequences
- `ArrayStyle` (write) - Format array output

Despite controlling different operations, the similar names caused confusion.

### Decision: SequenceRule

**Rationale:**
1. **MATLAB convention** - "Rule" suffix matches `VariableNamingRule` in `detectImportOptions`
2. **Correct terminology** - "Sequence" is the proper YAML term for lists
3. **Clear distinction** - `SequenceRule` vs `ArrayStyle` are obviously different
4. **Semantic clarity** - "Rule" implies "how should this be handled?"
5. **Educational** - Helps users learn YAML terminology

### Why Asymmetry is OK

- **Reading:** `SequenceRule` - Format-specific (YAML sequences → MATLAB)
- **Writing:** `ArrayStyle` - Format-agnostic (MATLAB arrays → YAML/TOML)

This makes sense because:
- When reading, you're dealing with format-specific constructs
- When writing, you're dealing with MATLAB data types

### Parameter Behavior

**`SequenceRule` options:**

`"auto"` (default) - Smart conversion:
```matlab
[1, 2, 3]        → [1, 2, 3]         % double array
[a, b, c]        → ["a", "b", "c"]   % string array
[1, "two", true] → {1, "two", true}  % cell array (mixed)
```

`"cell"` - Always cell arrays for consistency:
```matlab
[1, 2, 3]        → {1, 2, 3}         % cell array
```

### Summary

`SequenceRule` provides:
- ✅ Clear distinction from `ArrayStyle`
- ✅ MATLAB "Rule" convention
- ✅ Correct YAML terminology
- ✅ Concise and memorable

---

## Architecture

**Decision:** Create `ConfigurationData` as a shared base class for `YAMLData` and `TOMLData`

### Options Considered

**Option 1:** YAML-specific (`YAMLData` only)
- Focused, single purpose
- Would need duplicate code for TOML
- ❌ Too narrow

**Option 2:** Config file types (shared base)
- Single API for YAML, TOML, JSON, XML, INI
- Shared implementation, less duplication
- ✅ **Chosen approach**

**Option 3:** Generic hash/map (like dictionary)
- Maximum reuse beyond config files
- ❌ Too broad, would compete with built-in types

### Why ConfigurationData?

**Benefits:**
1. **Shared functionality** - Dot notation, key management work the same
2. **Consistent API** - Users learn once, use for both formats
3. **Less duplication** - Common code in base class
4. **Extensibility** - Easy to add JSON, INI, XML support
5. **Type safety** - Can check `isa(obj, 'ConfigurationData')`

### Class Hierarchy

```
ConfigurationData (abstract base)
├── YAMLData
└── TOMLData
```

**Common features (in base):**
- Dot notation access: `config.database.host`
- Key management: `keys`, `iskey`, `remove`
- Field access: `fieldnames`, `isfield`, `rmfield`
- Display methods: `show`, `disp`
- Struct compatibility: `struct`

**Format-specific (in subclasses):**
- File I/O: `readyaml`, `writetoml`
- Format-specific metadata (future)
- Format-specific validation (future)

### Special Character Handling

Keys with hyphens, spaces, or special characters:
- **Primary access:** `config.("build-system")`
- **Aliased access:** `config.build_system` (uses `makeValidName`)
- Both work, accessing the same data

### Summary

`ConfigurationData` provides:
- ✅ Natural MATLAB syntax (dot notation)
- ✅ Consistent API across formats
- ✅ Shared implementation (DRY principle)
- ✅ Extensible architecture

---

## Code Style Conventions

### Method Syntax

**Always use:** `method(obj)` **not** `obj.method`

```matlab
% Correct
keys(config)
show(data)
isfield(config, "database")

% Incorrect
config.keys
data.show
config.isfield("database")
```

**Rationale:** 
- Standard MATLAB convention
- Consistent with built-in functions (`fieldnames`, `struct`)
- Only deviate when explicitly requested

### String Literals

**Always use:** `""` **not** `''`

```matlab
% Correct
config = readyaml("file.yaml")
key = "database"

% Incorrect
config = readyaml('file.yaml')
key = 'database'
```

**Rationale:**
- Modern MATLAB convention
- Consistent with string arrays
- Better for multi-character strings

---


## Array Display for ConfigurationData Objects

**Date:** 2026-01-08

**Context:**
When displaying arrays of ConfigurationData/YAMLData/TOMLData objects (e.g., TOML arrays of tables), the current display shows only `SourceFormat` as a property, which is not useful to users. The issue is that each element in the array can have different keys, unlike standard MATLAB object arrays or struct arrays where all elements share the same properties.

**Problem Example:**
```matlab
>> p = readtoml("examples/pyproject_complex.toml");
>> a = p.project.authors

a =
  1x2 TOMLData array with properties:
    SourceFormat    % Not helpful!
    Show all values
```

In this case:
- Element 1 has keys: `{name, email}`
- Element 2 has keys: `{name}` only

**Decision:**
Implement intelligent property display for arrays:

1. **Homogeneous case** (all elements have identical keys):
   ```
   1x2 TOMLData array with properties:
       name
       email
   ```
   Display matches struct array behavior - clean and familiar.

2. **Heterogeneous case** (elements have different keys):
   ```
   1x2 TOMLData array with properties:
       name
       email
       (keys vary by element)
   ```
   Display shows union of all keys with a note indicating variation.

**Rationale:**
- Provides useful information about what keys exist in the array
- Clear distinction between homogeneous and heterogeneous cases
- Follows MATLAB conventions (similar to struct arrays) when possible
- The "(keys vary by element)" note warns users that not all elements have all keys
- More informative than showing internal properties like `SourceFormat`

**Implementation Notes:**
- Modify `displayNonScalarObject` method in ConfigurationData.m
- Check all array elements to determine if keys are identical
- If identical: display keys like properties
- If different: display union of keys with variation note
- Hide `SourceFormat` and other internal properties from array display

**Status:** Implemented (2026-01-08)

---

## Terminology: Keys vs Properties vs Fields

**Date:** 2026-01-08

**Decision:** Use "keys" as the primary terminology for ConfigurationData/YAMLData/TOMLData members, while maintaining "fields" as aliases for compatibility.

### Context

ConfigurationData objects use three overlapping terms:
- **keys** - from `keys(obj)`, `iskey(obj, key)`
- **fields** - from `fieldnames(obj)`, `isfield(obj, field)`, `rmfield(obj, field)`
- **properties** - from `properties(obj)`, used in display

This created inconsistency in documentation, display messages, and API naming.

### Decision Details

**Primary term:** "keys"
- Array display: `1x2 TOMLData array with keys:`
- Documentation: "Access keys with special characters..."
- Method names: `keys(obj)` is the canonical method

**Supported aliases:** "fields"
- Keep `isfield`, `fieldnames`, `rmfield` as aliases
- Users familiar with MATLAB structs can use these naturally
- No deprecation needed - both work equally well

### Rationale

1. **Aligns with format specifications:**
   - TOML spec uses "keys" consistently
   - YAML spec uses "keys" for mappings
   - JSON uses "keys" in key-value pairs

2. **Target audience:**
   - Users working with YAML/TOML are software developers
   - They expect "keys" from working with JSON, Python dicts, etc.
   - Using standard terminology reduces cognitive load

3. **Consistency within toolbox:**
   - Primary method is `keys(obj)`, not `fieldnames(obj)`
   - Makes sense to align display/docs with the primary API

4. **MATLAB compatibility:**
   - Maintaining `isfield`, `fieldnames`, `rmfield` preserves struct-like behavior
   - Users don't need to change existing code
   - "Just works" for users who type without thinking

### Implementation Impact

**Changes needed:**
1. Array display: Change "properties" → "keys"
   ```matlab
   % Old
   1x2 TOMLData array with properties:

   % New
   1x2 TOMLData array with keys:
   ```

2. Documentation: Update terminology consistently
   - Function reference pages
   - Class reference pages
   - Examples and tips sections

3. Code comments: Use "keys" in comments where appropriate

**No changes needed:**
- Method names (`isfield`, `fieldnames`, `rmfield` all stay)
- API behavior (everything works the same)
- User code (backward compatible)

### Summary

Using "keys" as primary terminology:
- ✅ Aligns with YAML/TOML specifications
- ✅ Matches expectations of target users
- ✅ Consistent with primary API (`keys` method)
- ✅ Maintains MATLAB compatibility (field aliases)
- ✅ No breaking changes

**Status:** Implemented (2026-01-08)

---

## References

### Related MATLAB Functions
- `readstruct`, `writestruct` - Structured data I/O (closest analogue)
- `readtable`, `writetable` - Tabular data I/O (naming pattern)
- `detectImportOptions` - Import customization (VariableNamingRule)

### External Resources
- YAML Specification: https://yaml.org/spec/
- TOML Specification: https://toml.io/

---

*These decisions were made to align with MATLAB conventions while providing an intuitive, consistent API for working with configuration files.*
