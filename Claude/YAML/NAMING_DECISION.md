# Function Naming Decision

**Date:** December 31, 2025  
**Decision:** Use `read<type>` / `write<type>` pattern for all file I/O functions

## Background

Initially, the YAML and TOML toolboxes used inconsistent naming:
- YAML: `yamlread`, `yamlwrite` (format-first)
- TOML: `readtoml`, `writetoml` (type-first)

This inconsistency needed to be resolved.

## MATLAB's Two Naming Patterns

### Pattern 1: Format-first (`<format>read/write`)
**Legacy pattern, primarily for older functions:**
- `xlsread`, `xlswrite` (Excel files)
- `csvread`, `csvwrite` (CSV files)
- `jsonencode`, `jsondecode` (not exactly the same pattern)

### Pattern 2: Type-first (`read<type>/write<type>`)  
**Modern pattern for newer I/O functions:**
- `readtable`, `writetable` → reads/writes table data
- `readmatrix`, `writematrix` → reads/writes matrix data
- `readcell`, `writecell` → reads/writes cell arrays
- `readlines`, `writelines` → reads/writes text lines
- **`readstruct`, `writestruct`** → reads/writes structured data (XML, JSON)

## Key Insight: `readstruct` and `writestruct`

The critical precedent is **`readstruct`** and **`writestruct`**:
- These are MATLAB's modern functions for reading/writing **structured configuration data**
- They support multiple formats (XML, JSON)
- They use the `read<type>` / `write<type>` pattern
- **They do exactly what our toolboxes do: read/write structured config formats**

## Decision Rationale

**Chosen pattern:** `read<type>` / `write<type>`

**Final function names:**
- `readyaml`, `writeyaml` (renamed from `yamlread`, `yamlwrite`)
- `readtoml`, `writetoml` (already correct)

**Reasons:**
1. **Aligns with `readstruct`/`writestruct` precedent** - The closest MATLAB analogue uses this pattern
2. **Modern convention** - All newer MATLAB I/O functions use `read<type>`
3. **Data-centric naming** - Functions return typed objects (`YAMLData`, `TOMLData`)
4. **Consistency** - Makes both toolboxes follow the same modern pattern
5. **Future-proof** - Follows MATLAB's current direction for new I/O functions

## Implementation

**Changes made:**
- Renamed `yamlread.m` → `readyaml.m`
- Renamed `yamlwrite.m` → `writeyaml.m`
- Updated all help text and examples
- Updated cross-references in `YAMLData.m`
- Updated `See also` sections

**No changes needed:**
- `readtoml.m` and `writetoml.m` already followed the correct pattern

## Comparison with Similar Tools

Other languages also tend toward format-first (e.g., `yaml.load`, `toml.load`), but MATLAB's convention is more important for MATLAB users. The `readstruct` precedent makes this decision clear.

## Summary

By choosing `read<type>` / `write<type>`, we:
- ✅ Follow modern MATLAB conventions
- ✅ Align with `readstruct`/`writestruct` (the closest analogue)
- ✅ Use a consistent pattern across both toolboxes
- ✅ Make the toolboxes feel like native MATLAB functions

---
*This decision follows MATLAB's established naming conventions and ensures our toolboxes integrate seamlessly with the MATLAB ecosystem.*
