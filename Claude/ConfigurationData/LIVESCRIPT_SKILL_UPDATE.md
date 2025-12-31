# MATLAB Live Script Skill Update

## Requested Change

**Avoid using `fprintf` in Live Scripts**

## Rationale

Live Scripts are designed to show natural MATLAB output. Using `fprintf` for output is unnecessary and goes against the Live Script paradigm.

## Updated Guidance

### ❌ DON'T use fprintf for output:
```matlab
fprintf('Value: %g\n', x)
fprintf('Result: %s\n', result)
```

### ✅ DO use natural output (leave off semicolon):
```matlab
%[text] The value is:
x

%[text] The result is:
result
```

### When to use fprintf

`fprintf` is acceptable ONLY when:
- Creating formatted strings that will be used elsewhere (not displayed)
- Writing to files with `fid` argument
- Specific formatting requirements that can't be achieved otherwise

## Examples

### Before (with fprintf):
```matlab
%%
%[text] ## Test Results
data = ConfigurationData();
data.name = "MyApp";
fprintf('Name: %s\n', data.name)
fprintf('Keys: %s\n', strjoin(string(keys(data)), ', '))
```

### After (natural output):
```matlab
%%
%[text] ## Test Results
data = ConfigurationData();
data.name = "MyApp";
%[text] The name is:
data.name
%[text] All keys:
keys(data)
```

## Update to SKILL.md

Add to "Code Guidelines" section:

```markdown
### Output Display
**DO NOT** use fprintf for displaying output in Live Scripts:
```matlab
fprintf('Result: %g\n', x)  % WRONG
```

**Instead use natural output (omit semicolon):**
```matlab
%[text] The result is:
x  % CORRECT
```

Only use fprintf when:
- Writing to files (with fid argument)
- Creating formatted strings for later use
- Specific formatting that can't be achieved with natural output
```

---

This creates cleaner, more readable Live Scripts that feel natural in MATLAB.
