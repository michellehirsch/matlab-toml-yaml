# YAML Round-Tripping Status

## Summary

Round-tripping YAML files (read → modify → write → read again) works well with some known limitations.

## ✅ What Works

### 1. Automatic Aliasing
Both syntaxes work:
```matlab
data.("matlab-app")  % Original hyphenated key
data.matlab_app      % Auto-generated alias
```

### 2. No Metadata Pollution
- ✅ Removed `SourceFile` property  
- ✅ Removed `SourceFormat` property
- YAMLData now purely represents the data from the YAML file
- Writing back doesn't include metadata fields

### 3. Key Order Fully Preserved
Both top-level and nested keys maintain their order:
```yaml
# Input
database:
  host: localhost
  port: 5432
  username: admin

# Output (order preserved at all levels!)
database:
  host: localhost
  port: 5432
  username: admin
```

**Status**: ✅ Fixed! ConfigurationData objects are now stored directly instead of being converted to containers.Map, which preserves the OriginalKeys order.

### 4. Data Integrity
- All values round-trip correctly
- Hyphenated keys preserved
- Nested structures preserved
- Data types preserved (strings, numbers, booleans, nulls)

## ⚠️ Known Limitations

### 1. Comments Are Lost
Comments are stripped during parsing:
```yaml
# Input
name: MyApp  # This is the app name
version: 1.0

# Output
name: MyApp
version: 1.0
```

**Status**: Not yet implemented. Comments are challenging because:
- Need to associate comments with specific keys
- Need to preserve standalone comments
- Need to handle inline vs. block comments
- Would add complexity to data structure

**Future**: Could add comment preservation as opt-in feature

### 2. Nested Key Order May Change
~~Top-level keys maintain order, but nested keys may be reordered:~~

**FIXED!** Nested key order is now preserved at all levels.

### 3. Whitespace/Formatting Not Preserved
Input formatting is not preserved:
```yaml
# Input (compact)
name:MyApp
version:1.0

# Output (standard formatting)
name: MyApp
version: 1.0
```

**Status**: Acceptable. yamlwrite uses consistent formatting.

## 🔄 Whitespace Control

Currently `yamlwrite` uses fixed formatting:
- 2-space indentation
- Space after colon
- No blank lines between entries

**Possible future options**:
```matlab
yamlwrite('file.yaml', data, 'Style', 'compact')   % Minimal whitespace
yamlwrite('file.yaml', data, 'Style', 'loose')     % Extra blank lines
yamlwrite('file.yaml', data, 'Style', 'standard')  % Current default
```

## Test Results

### Basic Round-Trip
```matlab
data = yamlread('config.yaml');
yamlwrite('output.yaml', data);
data2 = yamlread('output.yaml');
% Result: data and data2 are equivalent
```

✅ **Pass** - Data integrity maintained

### Hyphenated Keys
```matlab
data.("app-name") = "MyApp";
yamlwrite('output.yaml', data);
data2 = yamlread('output.yaml');
data2.("app-name")  % "MyApp"
data2.app_name      % "MyApp" (alias works)
```

✅ **Pass** - Hyphenated keys and aliases work

### Key Order
```matlab
% Top-level: ✅ Preserved
% Nested: ✅ Preserved
```

### Comments
```matlab
% Input: name: MyApp # comment
% Output: name: MyApp
```

❌ **Not preserved** - Comments are lost

## Recommendations

### For Users

1. **Don't rely on comment preservation** - Use key names and values to document configuration
2. **Top-level organization matters** - Order of top-level keys is preserved
3. **Nested order less reliable** - Don't assume nested key order will be maintained
4. **Use explicit whitespace control** - Currently not available, but could be added if needed

### For Future Development

1. **Comment Preservation** - Add as opt-in feature with special handling
2. **Fix Nested Key Order** - Investigate why nested keys don't maintain order
3. **Whitespace Options** - Add `'Style'` parameter to `yamlwrite`
4. **Format Preservation Mode** - Advanced mode that tries to match input formatting

## Conclusion

Round-tripping works well for the common case:
- ✅ Data integrity: Perfect
- ✅ Hyphenated keys: Perfect
- ✅ Key order: Perfect (all levels)
- ✅ Nested aliasing: Perfect
- ❌ Comments: Not preserved
- ❌ Whitespace: Not preserved (but consistent)

**Good enough for most use cases**, with clear documentation of limitations.

---

Last updated: 2025-12-31
