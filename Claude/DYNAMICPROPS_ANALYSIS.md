# ConfigurationData Design: dynamicprops vs. RedefinesDot Analysis

**Date:** 2026-01-13  
**Question:** Should `ConfigurationData` use `dynamicprops` instead of `RedefinesDot` + `containers.Map`?

---

## Quick Answer

**No, the current approach is better for TOML/YAML configuration data.** While `dynamicprops` solves the array indexing issues, it introduces worse problems for the configuration file use case, particularly around special characters and key ordering.

However, a **hybrid approach** might be worth exploring for future iterations.

---

## Experimental Results

I tested `dynamicprops` behavior to understand what we'd gain and lose:

### ✅ What Works with dynamicprops

```matlab
% Test 2: Assignment to array element works perfectly!
arr(2).name = "Suzie"  % ✅ SUCCESS

% Test 6: Nested objects work
obj.permissions.read = true  % ✅ Works
```

### ❌ What Fails with dynamicprops

```matlab
% Test 1: Array field access fails
arr.name  % ❌ FAILED: "Unrecognized method, property, or field 'name'"
% (Even though both elements have 'name' property!)

% Test 3: Cannot use special characters
addprop(obj, 'build-system')  % ❌ FAILED: Not a valid identifier
% TOML/YAML commonly use kebab-case keys!

% Test 4: Property ordering is alphabetical, not insertion order
addprop(obj, 'z_field');
addprop(obj, 'a_field');
addprop(obj, 'm_field');
properties(obj)  % Returns: [a_field, m_field, z_field]
% Original order lost!

% Test 5: Heterogeneous arrays fail completely
arr(1) has 'email' property, arr(2) doesn't
arr.email  % ❌ FAILED: "Unrecognized method, property, or field 'email'"
```

---

## Detailed Comparison

### Current Approach: RedefinesDot + containers.Map

#### ✅ Pros
1. **Special characters fully supported**
   - Keys like `"build-system"`, `"my-key"`, `"2024-config"` work perfectly
   - Critical for TOML/YAML which commonly use kebab-case
   
2. **Preserves key insertion order**
   - `OriginalKeys` array maintains exact order from file
   - Essential for configuration files where order may matter
   
3. **Heterogeneous arrays work**
   - Different array elements can have different keys
   - Common in TOML arrays-of-tables
   
4. **Complete control over behavior**
   - Can customize display, serialization, comparison
   - Can implement exactly what we need

#### ❌ Cons
1. **Array indexing limitations** (documented in ARRAY_INDEXING_LIMITATIONS.md)
   - Cannot do `obj.field(index).subfield = value`
   - Requires custom `subsasgn` override to fix
   
2. **More complex implementation**
   - Need to implement `dotReference`/`dotAssign`
   - Custom display methods
   - More code to maintain
   
3. **Potential performance overhead**
   - Extra indirection through `containers.Map`
   - Additional method calls for every access

---

### Alternative: dynamicprops

#### ✅ Pros
1. **Array indexing works naturally**
   - `arr(2).field = value` works out of the box! ✅
   - `arr(1).nested.field = value` works! ✅
   - This solves our HIGH priority issues from ARRAY_INDEXING_LIMITATIONS.md
   
2. **Simpler implementation**
   - Less custom code needed
   - Built-in MATLAB behavior
   
3. **Better performance** (potentially)
   - Native MATLAB properties
   - Less method call overhead

#### ❌ Cons
1. **Cannot handle special characters** ⚠️ CRITICAL
   - Properties must be valid MATLAB identifiers
   - TOML/YAML use `"build-system"`, `"my-key"`, etc.
   - Would need alias system anyway, losing the benefit
   
2. **Loses key ordering** ⚠️ IMPORTANT
   - `properties()` returns alphabetically sorted list
   - Original order from config file is lost
   - Would need separate tracking (e.g., `OriginalKeys` array)
   
3. **Heterogeneous arrays fail completely** ⚠️ CRITICAL
   - If `arr(1).email` exists but `arr(2).email` doesn't
   - Then `arr.email` fails entirely
   - This is a showstopper for TOML arrays-of-tables
   
4. **Cannot use standard array access**
   - `arr.name` doesn't work even when all elements have `name`
   - Forces indexing: `arr(1).name`, `arr(2).name`, etc.
   - Surprising limitation!

---

## Why Current Approach is Better for Config Files

### 1. Special Characters Are Essential

TOML and YAML configuration files **routinely** use special characters:

```toml
[build-system]
requires = ["poetry-core"]

[tool.poetry]
name = "my-package"

[project.optional-dependencies]
dev = ["pytest"]
```

With `dynamicprops`, **none of these keys would work**. We'd need:
- Convert `build-system` → `build_system`
- Maintain alias mapping
- Support both access patterns

This defeats the purpose of using `dynamicprops` in the first place!

### 2. Heterogeneous Arrays Are Common

TOML arrays-of-tables often have different keys:

```toml
[[users]]
name = "Alice"
email = "alice@example.com"
permissions = { read = true }

[[users]]
name = "Bob"
role = "admin"  # Different from Alice!
```

With `dynamicprops`, accessing `arr.email` fails because Bob doesn't have `email`. This is unacceptable for configuration data.

### 3. Key Ordering Matters

Configuration files often depend on insertion order:
- Database migrations
- Plugin loading order
- Override precedence

`dynamicprops` loses this by sorting alphabetically.

---

## What We'd Gain from dynamicprops

The **only** significant advantage is solving Issues #2 and #3 from ARRAY_INDEXING_LIMITATIONS.md:

```matlab
% These would work with dynamicprops:
data.users(2).name = "Suzie"             ✅
data.users(2).permissions = []           ✅
data.users(1).permissions.admin = true   ✅
```

But we can **fix these issues** by overriding `subsasgn` in the current architecture, as outlined in ARRAY_INDEXING_LIMITATIONS.md.

---

## Hybrid Approach: Best of Both Worlds?

### Option 1: dynamicprops + Workarounds

```matlab
classdef ConfigurationData < dynamicprops
    properties (Hidden)
        KeyAliases containers.Map  % "build-system" → "build_system"
        OriginalKeys string         % Preserve order
    end
end
```

**Problems:**
- Still can't handle heterogeneous arrays
- Complex alias system still needed
- Loses most benefits of `dynamicprops`

### Option 2: Keep RedefinesDot, Override subsasgn

```matlab
classdef ConfigurationData < handle & matlab.mixin.indexing.RedefinesDot
    % Current architecture
    
    methods
        function obj = subsasgn(obj, S, value)
            % Handle: obj.field(index).subfield = value
            if length(S) >= 3 && strcmp(S(1).type, '.') && strcmp(S(2).type, '()')
                % Custom logic to make array element assignment work
            else
                % Delegate to RedefinesDot
            end
        end
    end
end
```

**This is the recommended approach** - it:
- Fixes the array indexing issues
- Keeps all current benefits
- Minimal code addition

---

## Recommendation

**Keep the current `RedefinesDot` + `containers.Map` approach** and fix the array indexing limitations by overriding `subsasgn`.

### Why?

1. **Special character support is non-negotiable** for TOML/YAML
2. **Heterogeneous arrays are essential** for flexibility
3. **Key ordering must be preserved** for correctness
4. **Array indexing can be fixed** with targeted `subsasgn` override

### Implementation Priority

1. **HIGH:** Override `subsasgn` to handle `obj.field(index).subfield = value` pattern
2. **MEDIUM:** Improve error messages for `arr.field` without indexing
3. **LOW:** Consider performance optimizations if needed

---

## Conclusion

While `dynamicprops` elegantly solves array indexing, it introduces deal-breaking limitations for configuration file data:
- ❌ No special characters in keys
- ❌ No heterogeneous arrays
- ❌ No preserved key ordering

The current architecture is the right choice. The array indexing issues are solvable with a custom `subsasgn` implementation, as documented in ARRAY_INDEXING_LIMITATIONS.md.

**Verdict: Stay with current approach, implement the `subsasgn` fix.**
