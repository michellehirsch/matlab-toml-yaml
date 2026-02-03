---
name: matlab-modernizer
description: Reviews and modernizes MATLAB code to use R2024a+ syntax patterns. Auto-activates during MATLAB code review or via `/matlab-modernize` command.
allowed-tools:
  - Read
  - Edit
  - Glob
  - Grep
  - Task
---

# MATLAB Modernizer

## Instructions

When reviewing MATLAB code, apply these R2024a+ patterns.

## Subagent Code Review

For comprehensive modernization reviews, use a subagent to analyze the codebase. This is especially useful for:
- Reviewing multiple files or an entire package/folder
- Deep analysis of modernization opportunities across a codebase
- When user runs `/matlab-modernize` without specifying a single file

### How to Use Subagent

Spawn an Explore agent with the Task tool:

```
Task tool with subagent_type="Explore"
prompt: |
  Analyze MATLAB files in [path] for modernization opportunities.

  Look for these outdated patterns and suggest modern R2024a+ replacements:

  HIGH PRIORITY:
  - varargin/inputParser/nargin → arguments blocks
  - Positional args with 'Name', value → Name=value syntax

  MEDIUM PRIORITY:
  - sprintf/fprintf for strings → compose
  - cell arrays for text → string arrays
  - strcmp/strcmpi → matches
  - containers.Map → dictionary

  ALSO CHECK:
  - exist(..., 'file') for files → isfile (but keep for function checks)
  - exist(..., 'dir') → isfolder
  - fopen/fread/fclose for text → readlines/writelines
  - bsxfun → implicit expansion
  - subplot → tiledlayout/nexttile

  CAUTIONS (do NOT flag these as issues):
  - char() before unicode2native/native2unicode (required)
  - exist('funcName', 'file') for checking function existence (valid)
  - Complex fopen/fclose patterns for binary/random access (keep as-is)
  - cellstr() for webread/webwrite array parameters (required for repeated query params)
  - disp/fprintf in Live Scripts for explanatory text (suggest rich text blocks instead)

  For each finding, report:
  1. File and line number
  2. Current pattern
  3. Suggested modern replacement
  4. Priority (High/Medium/Low)

  Group findings by file, then by priority within each file.
```

### When to Use Direct Review vs Subagent

| Scenario | Approach |
|----------|----------|
| Single file specified | Read file directly, review inline |
| `/matlab-modernize path/to/file.m` | Read file directly |
| `/matlab-modernize` (no path) | Ask user for scope, then use subagent if multiple files |
| `/matlab-modernize path/to/folder` | Use subagent |
| "Review this package for modernization" | Use subagent |
| "Modernize my codebase" | Use subagent |

## Quick Reference Table

| Outdated | Modern (R2024a+) |
|----------|------------------|
| char or cell arrays for text | String arrays (`"text"`) |
| `varargin`, `inputParser`, `nargin` | `arguments` blocks |
| struct for tabular data | `table` or `timetable` |
| `containers.Map` | `dictionary` (R2022b+) |
| `struct` for key-value lookup | `dictionary` (R2022b+) |
| `sprintf` for strings | `compose` |
| `fprintf` for logging | `disp` + string concatenation* |
| Manual date arithmetic | `dateshift` or `+ days()` |
| `fwrite` for text files | `writelines` |
| `fread`, `textscan` for text | `readlines` |
| `fileread` + `string()` | `join(readlines(...), newline)` |
| `exist(..., 'file')` for files | `isfile` |
| `exist(..., 'dir')` | `isfolder` |
| `strcmp`, `strcmpi` | `matches` |
| `strfind`, `regexp` (simple) | `contains`, `startsWith`, `endsWith` |
| `bsxfun` | Implicit expansion |
| `subplot` | `tiledlayout` / `nexttile` |
| `print` for saving figures | `exportgraphics` |
| Positional function args | Name=value syntax |
| `weboptions('Name', val)` | `weboptions(Name=val)` |
| `datetime('now', 'TimeZone', 'UTC')` | `datetime("now", TimeZone="UTC")` |
| `native2unicode(x, 'UTF-8')` | `native2unicode(x, "UTF-8")` |
| `isfield(s, 'name')` | `isfield(s, "name")` |
| `error('id', 'msg')` | `error("id", "msg")` |
| `cell(n, 1)` for text | `strings(n, 1)` |
| Loop over cell array | `cellfun(@(x) x.field, cells)` |
| Manual ISO 8601 parsing | `datetime(str, TimeZone="UTC")` |

*In Live Scripts, use rich text `%[text]` blocks instead of `disp` for explanatory text.

## Priority Guide

Prioritize modernization by impact:

### High Priority
- **`arguments` blocks**: Improves readability, validation, and IDE support
- **Name=value syntax**: Cleaner function calls, better code completion

### Medium Priority
- **`sprintf` → `compose`**: Native string support, cleaner syntax
- **`cell` → `strings`**: Better performance and string operations
- **`strcmp` → `matches`**: More readable, supports arrays

### Low Priority
- Single char literal conversions (`'text'` → `"text"`): Still valid, modernize when touching the code

## Cautions & Exceptions

Real-world lessons from production codebases:

### webread/webwrite
Be careful modernizing HTTP code. Test thoroughly after changes - complex HTTP interactions may have subtle behavior differences. Revert if tests fail.

### writetable
Parameter was renamed from `FileEncoding` to `Encoding` in modern MATLAB. Also note: `'UTF-8-BOM'` is not a valid encoding value.

### unicode2native/native2unicode
These functions require `char` input. Don't remove necessary `char()` conversions when modernizing surrounding code:
```matlab
% This is correct - char() is required
bytes = unicode2native(char(str), "UTF-8");
```

### exist(..., 'file') for functions
Keep `exist('funcName', 'file')` when checking if a function exists on the path. Only replace with `isfile()` when checking for actual files with paths.

### fopen/fclose patterns
Only replace with `writelines`/`readlines` for simple text operations. Complex file I/O (binary, random access, partial reads) still needs traditional file handles.

### cellstr() for webread array parameters
Keep `cellstr()` when passing array parameters to `webread()`. MATLAB's `webread` handles cell arrays as repeated query parameters (`?key=val1&key=val2`), but string arrays become comma-separated (`?key=val1,val2`), which many REST APIs reject:
```matlab
% Correct - generates ?actors=did1&actors=did2
params = struct("actors", cellstr(["did1", "did2"]));

% WRONG - generates ?actors=did1,did2 (API error)
params = struct("actors", ["did1", "did2"]);
```

### Live Scripts: disp/fprintf for text output
In Live Scripts (.m files with `%[text]` markers), do NOT recommend converting `fprintf` to `disp` for text meant for readers. Live Scripts use rich text blocks for explanatory text, not Command Window output. Flag these as opportunities to move content to rich text instead:

```matlab
% In Live Scripts, this is wrong:
disp("Now we will analyze the data");
fprintf("The results show significant improvement\n");

% Should be rich text instead:
%[text] Now we will analyze the data
%[text] The results show significant improvement
```

Note: `disp` is still valid for displaying computed results (variable values, calculation outputs) that should appear inline with code.

## Review Process

1. Determine scope (single file vs multiple files/folder)
2. For multiple files: use subagent for thorough analysis
3. Identify outdated patterns in the code
4. Check **Cautions & Exceptions** before applying changes
5. Suggest modern replacements with brief rationale
6. Preserve original functionality
7. Prioritize readability and maintainability
8. Run tests to verify behavior is unchanged

## Output Format

After subagent completes analysis, present findings to user as:

```markdown
## MATLAB Modernization Report

### Summary
- Files analyzed: N
- High priority findings: N
- Medium priority findings: N
- Low priority findings: N

### Findings by File

#### `path/to/file.m`

**High Priority**
- Line 45: `inputParser` → `arguments` block

**Medium Priority**
- Line 23: `sprintf('Value: %d', x)` → `compose("Value: %d", x)`

...
```

## References

See [examples.md](references/examples.md) for before/after code snippets.
