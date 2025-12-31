# Development Notes

## Array Behavior - Uncanny Valley Issue

**Status**: Treading on thin ice ⚠️

**Issue**: YAMLData object arrays are in the uncanny valley - they don't behave quite like normal MATLAB object arrays.

**Example**: GitHub Actions workflow
```matlab
g = yamlread('github-actions.yaml');
steps = g.jobs.test.steps;  % [1x5 YAMLData]

% This works:
steps(1).name

% This doesn't work (would require complex subsref):
g.jobs.test.steps(1).name
```

**Why it's problematic**:
- Each element can have different fields (heterogeneous)
- Can't use `steps.name` to get all names (no comma-separated list)
- Chained indexing like `obj.field(i).subfield` doesn't work without custom subsref
- Using `matlab.mixin.indexing.RedefinesDot` limits what we can override

**Workaround**:
Users must extract arrays before indexing:
```matlab
steps = g.jobs.test.steps;
name = steps(1).name;
```

**Future considerations**:
- Could switch back to cell arrays (more predictable)
- Could implement full custom subsref (complex, fragile)
- Could live with current limitations (document well)

**Decision**: Keep object arrays for now because:
1. More natural MATLAB syntax for most operations
2. Consistent with how struct arrays work
3. Enables future enhancements (custom display, array methods)
4. The workaround is simple and well-documented

---
*Last updated: 2025-12-31*
