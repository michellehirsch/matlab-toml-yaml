# MATLAB Modernization Audit Report

**Date:** January 29, 2026
**Scope:** All `.m` files in `toolbox/` and `tests/` directories
**Minimum MATLAB Version:** R2022b (current project requirement)

## Executive Summary

This audit identifies outdated MATLAB programming practices that could be modernized. The codebase is generally well-maintained, with the primary opportunities being:

1. **strcmp/strcmpi usage** → Use `==` operator for string comparison
2. **char() overuse** → Standardize on `string` type
3. **Single-quoted strings** → Use double-quoted strings where appropriate

### Statistics
| Category | Instances | Priority |
|----------|-----------|----------|
| strcmp/strcmpi | 25+ | HIGH |
| char() conversions | 40+ | MEDIUM-HIGH |
| cellstr() | 1 | MEDIUM |
| strfind() | 1 | LOW |
| sprintf() | 60+ | ACCEPTABLE |
| num2str() | 10 | ACCEPTABLE |

---

## 1. strcmp/strcmpi Usage (HIGH PRIORITY)

**Issue:** Using `strcmp()` for string comparison when the `==` operator works with string type.

**Modern replacement:** `==` operator with strings, or `matches()` for pattern matching.

### writeini.m
| Line | Current Code | Modern Replacement |
|------|--------------|-------------------|
| 91 | `strcmpi(sectionSpacing, 'loose')` | `lower(sectionSpacing) == "loose"` |

### writeyaml.m
| Line | Current Code | Modern Replacement |
|------|--------------|-------------------|
| 61 | `strcmp(options.ArrayStyle, 'flow')` | `options.ArrayStyle == "flow"` |
| 64 | `strcmp(options.SectionSpacing, 'loose')` | `options.SectionSpacing == "loose"` |

### writetoml.m
| Line | Current Code | Modern Replacement |
|------|--------------|-------------------|
| 112 | `strcmp(options.SectionSpacing, 'loose')` | `options.SectionSpacing == "loose"` |
| 166 | `~strcmp(fieldName, key)` | `fieldName ~= key` |
| 498 | `strcmp(opts.arrayStyle, 'flow')` | `opts.arrayStyle == "flow"` |
| 500 | `strcmp(opts.arrayStyle, 'block')` | `opts.arrayStyle == "block"` |
| 577-579 | Multiple `strcmp()` for style | Use `==` operator |
| 636-638 | Multiple `strcmp()` for style | Use `==` operator |
| 682-694 | `strcmp()` for escape/layout styles | Use `==` operator |

### ConfigurationData.m
| Line | Current Code | Modern Replacement |
|------|--------------|-------------------|
| 384 | `strcmp(indexOp(1).Type, "Dot")` | `indexOp(1).Type == "Dot"` |
| 395 | `strcmp(indexOp(1).Type, "Paren")` | `indexOp(1).Type == "Paren"` |
| 409 | `strcmp(indexOp(1).Type, "Dot")` | `indexOp(1).Type == "Dot"` |
| 423 | `strcmp(indexOp(1).Type, "Dot")` | `indexOp(1).Type == "Dot"` |
| 453 | `strcmp(indexOp(1).Type, "Dot")` | `indexOp(1).Type == "Dot"` |
| 528 | `~strcmp(validKey, key)` | `validKey ~= key` |
| 537 | `~strcmp(validKey, key)` | `validKey ~= key` |
| 569 | `~strcmp(validKey, key)` | `validKey ~= key` |

### readini.m
| Line | Current Code | Modern Replacement |
|------|--------------|-------------------|
| 109 | `strcmp(valueChar, 'true') \|\| strcmp(valueChar, 'yes')` | `ismember(valueChar, ["true", "yes"])` |
| 112 | `strcmp(valueChar, 'false') \|\| strcmp(valueChar, 'no')` | `ismember(valueChar, ["false", "no"])` |

### readtoml.m
| Line | Current Code | Modern Replacement |
|------|--------------|-------------------|
| 480 | `~strcmp(validKey, char(key))` | `validKey ~= string(key)` |
| 489 | `strcmp(tablePath, arrayPath)` | `tablePath == arrayPath` |
| 497 | `strcmp(tablePath, arrayPath)` | `tablePath == arrayPath` |
| 764 | `~strcmp(class(parsedElements{i}), firstType)` | Consider using `isa()` instead |

---

## 2. char() Function Overuse (MEDIUM-HIGH PRIORITY)

**Issue:** Excessive use of `char()` conversions when strings could be used directly.

**Modern approach:** Use `string` type throughout; only use `char()` when interfacing with legacy APIs that require it.

### ConfigurationData.m
| Line | Current Code | Issue |
|------|--------------|-------|
| 95 | `matlab.lang.makeValidName(char(key))` | Unnecessary char conversion |
| 111 | `char(key)` for containers.Map | Consider string-keyed dictionary |
| 178, 608 | Same pattern | Same issue |
| 314 | `ischar(value)` only | Should check `ischar(value) \|\| isstring(value)` |

### readini.m
| Line | Current Code | Modern Replacement |
|------|--------------|-------------------|
| 46 | `char(line)` | Use string methods directly |
| 106 | `lower(char(valueStr))` | `lower(valueStr)` works on strings |
| 143 | `char(valueStr)` return | Return string for consistency |

### readtoml.m (Most Extensive - 30+ instances)
This file has the most `char()` conversions, primarily for:
- Struct field access using dynamic field names
- String comparisons
- Pattern matching with regexp

**Key lines:** 149, 169, 189, 208, 212, 217, 236, 253, 260, 268, 417, 447, 455, 471, 475, 479-481, 499, 523, 525, 541, 564, 577, 580, 603, 609, 702, 773, 859, 923, 965, 1009, 1222

**Recommendation:** Create a helper function for struct field access that handles string-to-char conversion internally, reducing scattered `char()` calls.

### writeyaml.m
| Line | Current Code | Issue |
|------|--------------|-------|
| 113 | `ischar(data)` | Should also handle string |
| 371 | `char(data)` conversion | Use string instead |

### writeini.m
| Line | Current Code | Modern Replacement |
|------|--------------|-------------------|
| 109 | `char(value)` | `string(value)` |

### INIData.m
| Line | Current Code | Modern Replacement |
|------|--------------|-------------------|
| 89 | `char(value)` in valueToString | Return string |
| 105 | `arrayfun(@char, value, ...)` | `string(value)` |

### writetoml.m
| Line | Current Code | Issue |
|------|--------------|-------|
| 144 | `char(dataKeys(i))` | Keep as string |
| 382 | `regexp(char(key), ...)` | regexp works with strings |
| 404, 614 | `ischar(value)` checks | Check both char and string |

---

## 3. Single-Quoted Strings (MEDIUM PRIORITY)

**Issue:** Using single-quoted char arrays `'text'` instead of double-quoted strings `"text"`.

**Modern approach:** Use double-quoted strings `"text"` for string type, single quotes only for chars when explicitly needed.

### Pattern locations (widespread)
Single-quoted strings are used throughout for:
- Error messages in `error()` and `warning()` calls
- Format strings in `sprintf()`
- Literal comparisons

**Example modernizations:**
```matlab
% Current
error('Invalid input')
strcmp(value, 'true')

% Modern
error("Invalid input")
value == "true"
```

**Files with extensive single-quote usage:**
- `readtoml.m` - Error messages, format strings
- `writetoml.m` - Format strings, comparisons
- `writeyaml.m` - Format strings
- `ConfigurationData.m` - Error messages

---

## 4. Other Findings

### cellstr() Usage (1 instance)
**ConfigurationData.m, Line 150:**
```matlab
p = cellstr(obj.OriginalKeys)
```
**Modern:** Return `obj.OriginalKeys` directly as string array, or convert at call site if needed.

### strfind() Usage (1 instance)
**readtoml.m, Line 1222:**
```matlab
strfind(char(nextLine), char(delimiter))
```
**Modern:** Use `contains()` for boolean check, or string indexing for position.

### ischar() Checks Without isstring()
Multiple locations check only `ischar()` when the code should also accept `isstring()`:
- `ConfigurationData.m`: Line 314
- `writeyaml.m`: Line 113
- `writetoml.m`: Lines 404, 614

**Modern pattern:**
```matlab
% Current
if ischar(value)

% Modern
if ischar(value) || isstring(value)
% Or use isStringScalar() / isTextScalar() if available
```

---

## 5. Acceptable Practices (No Change Needed)

The following patterns are still considered acceptable modern MATLAB:

### sprintf() (60+ instances)
Used for complex string formatting. While string concatenation with `+` is available, `sprintf()` remains the standard for formatted output.

### num2str() (10 instances)
Acceptable for number-to-string conversion. Could optionally use `string()` casting.

### strrep() (4 instances)
Used for escape sequence processing. This is the appropriate function for the task.

### repmat() for indentation (15 instances)
```matlab
repmat(' ', 1, indentLevel * 2)
```
Acceptable, though could use string-based helper functions.

### feval() for dynamic instantiation (7 instances)
```matlab
feval(class(obj))
```
Used for creating objects of the same class dynamically. This is a valid use case.

---

## Modernization Priority

### Phase 1: High Priority (Breaking consistency)
1. Replace all `strcmp()`/`strcmpi()` with `==` operator
2. Replace `ismember()` patterns where appropriate

### Phase 2: Medium Priority (Code clarity)
3. Standardize on `string` type - replace `char()` conversions
4. Update `ischar()` checks to include `isstring()`
5. Remove unnecessary `cellstr()` conversions

### Phase 3: Low Priority (Polish)
6. Convert single-quoted strings to double-quoted where appropriate
7. Replace `strfind()` with modern alternatives
8. Consider helper functions for repeated patterns

---

## Files by Modernization Effort

| File | strcmp | char() | Single-Quotes | Effort |
|------|--------|--------|---------------|--------|
| readtoml.m | 4 | 30+ | Many | HIGH |
| writetoml.m | 12 | 5 | Many | HIGH |
| ConfigurationData.m | 8 | 8 | Some | MEDIUM |
| writeyaml.m | 2 | 2 | Many | MEDIUM |
| readini.m | 2 | 3 | Some | LOW |
| writeini.m | 1 | 2 | Some | LOW |
| INIData.m | 0 | 2 | Some | LOW |
| readyaml.m | 0 | 1 | Some | LOW |

---

## Recommended Approach

1. **Create a feature branch** for modernization work
2. **Start with ConfigurationData.m** - it's the base class and affects all subclasses
3. **Address strcmp() first** - straightforward changes, high impact
4. **Standardize string handling** - this may require updating function signatures
5. **Run full test suite** after each file modification
6. **Update minimum MATLAB version** if any modern features require it (current: R2022b)

---

## Test Files

The test files in `tests/` use similar patterns and should be updated alongside the toolbox code:
- `yamltest.m`
- `tomltest.m`
- `initest.m`
- `subsasgnTest.m`
- `ConfigurationPerformanceTest.m`

These tests use `strcmp()` and single-quoted strings throughout their verification code.
