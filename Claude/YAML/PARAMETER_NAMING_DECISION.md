# Parameter Naming Decision: SequenceRule

**Date:** December 31, 2025  
**Decision:** Rename `ArrayFormat` to `SequenceRule` in `readyaml()`

## Background

The YAML and TOML toolboxes had confusingly similar parameter names:
- **YAML read:** `ArrayFormat` - controls how flow sequences are converted to MATLAB
- **YAML write:** `ArrayStyle` - controls how MATLAB arrays are written to YAML  
- **TOML write:** `ArrayStyle` - controls how MATLAB arrays are written to TOML

The similarity between `ArrayFormat` and `ArrayStyle` created confusion, despite them controlling different operations (reading vs writing).

## The Problem

**ArrayFormat** and **ArrayStyle** are too similar in name but:
1. Operate in opposite directions (read vs write)
2. Control different aspects (conversion vs formatting)
3. Don't clearly indicate their purpose

Example of confusion:
```matlab
% What's the difference between these?
data = readyaml('file.yaml', 'ArrayFormat', 'auto');   % ?
writeyaml(data, 'file.yaml', 'ArrayStyle', 'flow');    % ?
```

## Options Considered

### 1. Rule-based Names (Following MATLAB Convention)
MATLAB uses "Rule" suffixes for import options (e.g., `VariableNamingRule` in `detectImportOptions`):
- `ArrayConversionRule` - Clear but verbose
- **`SequenceRule`** - Uses correct YAML terminology, concise ✓
- `FlowSequenceRule` - Too specific
- `ArrayImportRule` - Unclear scope

### 2. Type-based Names
- `ArrayType` - What type to create
- `SequenceType` - YAML-specific

### 3. Action-based Names
- `ConvertArraysTo` - Wordy
- `ReturnArraysAs` - Unclear with 'auto' option

### 4. Format-specific Names
- `FlowSequenceFormat` - Too narrow (also affects block sequences)
- `SequenceConversion` - Less conventional

## Decision: `SequenceRule`

**Final parameter names:**
- `readyaml(file, 'SequenceRule', 'auto'|'cell')` - How to convert YAML sequences
- `writeyaml(data, file, 'ArrayStyle', 'flow'|'block')` - How to format arrays in output

### Rationale

1. **Follows MATLAB convention:** The "Rule" suffix matches `VariableNamingRule` and other import option patterns
2. **Uses correct terminology:** "Sequence" is the proper YAML term for lists/arrays
3. **Clear distinction:** `SequenceRule` (input conversion) vs `ArrayStyle` (output formatting)
4. **Concise:** Short and memorable
5. **Semantic clarity:** "Rule" implies "how should this be handled?" which matches the parameter's purpose

### Why "Sequence" not "Array"?

**YAML terminology:**
- Flow sequences: `[1, 2, 3]`
- Block sequences: 
  ```yaml
  - item1
  - item2
  ```

**TOML terminology:**
- Arrays: `[1, 2, 3]`
- Array of tables: `[[table]]`

Using the format-specific terminology makes the parameters more precise and educational for users learning the formats.

### Asymmetry is OK

The names are intentionally asymmetric:
- **Reading:** `SequenceRule` - Format-specific term (YAML sequences → MATLAB)
- **Writing:** `ArrayStyle` - Format-agnostic term (MATLAB arrays → YAML/TOML)

This makes sense because:
- When reading, you're dealing with format-specific constructs
- When writing, you're dealing with MATLAB data types

## Parameter Behavior

### SequenceRule Options

**`'auto'` (default):** Smart conversion based on content
```matlab
[1, 2, 3]        → [1, 2, 3]         % double array
[a, b, c]        → ["a", "b", "c"]   % string array  
[1, "two", true] → {1, "two", true}  % cell array (mixed)
```

**`'cell'`:** Always use cell arrays for consistency
```matlab
[1, 2, 3]        → {1, 2, 3}         % cell array
[a, b, c]        → {"a", "b", "c"}   % cell array
```

## Implementation

**Changes made:**
- Updated `readyaml.m`:
  - Help text: `ArrayFormat` → `SequenceRule`
  - Arguments block: `options.ArrayFormat` → `options.SequenceRule`
  - Function body: Uses `options.SequenceRule`
- Updated `README.md`:
  - All examples updated
  - API reference updated
  - Advanced features section updated

**No changes to:**
- `writeyaml.m` - `ArrayStyle` remains unchanged
- TOML functions - Use `ArrayStyle` (TOML uses "array" terminology)

## Comparison with Other Parameters

| Function | Parameter | Purpose | Values |
|----------|-----------|---------|---------|
| `readyaml` | `SequenceRule` | How to convert YAML sequences | `'auto'`, `'cell'` |
| `writeyaml` | `ArrayStyle` | Output format for arrays | `'flow'`, `'block'` |
| `writetoml` | `ArrayStyle` | Output format for arrays | (planned) |

## Summary

By choosing `SequenceRule`:
- ✅ Clear distinction from `ArrayStyle`
- ✅ Follows MATLAB's "Rule" convention
- ✅ Uses correct YAML terminology  
- ✅ Educational for users learning YAML
- ✅ Concise and memorable

The parameter name now clearly communicates its purpose: "What's the rule for converting YAML sequences to MATLAB?"

---

**Previous name:** `ArrayFormat`  
**New name:** `SequenceRule`  
**Reason:** Clarity, MATLAB conventions, proper terminology, distinction from `ArrayStyle`
