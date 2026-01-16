# Design Proposal: Handling Single-Element Arrays in Round-Tripping

## The Problem
MATLAB has a fundamental impedance mismatch with YAML regarding arrays:
- **YAML**: Distinguishes between scalar `5` and list `[5]`.
- **MATLAB**: Does not distinguish. `5` is `[5]`.

This causes a round-trip failure:
`YAML input: [5]` -> `MATLAB: 5` -> `YAML output: 5` (Structure lost).

## Analysis of Options

### Option 1: "Strict Mode" (The Cell Array Solution)
*User Proposal*: Force single-element arrays (or all arrays) to be Cell Arrays in MATLAB.
- **YAML**: `[5]`
- **MATLAB**: `{5}` (Cell array of size 1)
- **YAML Out**: `[5]`

**Pros:**
- guarantees round-trip correctness.
- Predictable type mapping (YAML Sequence <-> MATLAB Cell).

**Cons:**
- **Severe Usability Impact**: Standard math operations fail. `config.ports + 1` throws an error if `config.ports` is `{8080}`.
- **Inconsistent UX**: `[8080, 8081]` might be a numeric array (auto-converted), while `[8080]` must remain a cell. Users have to write defensive code:
  ```matlab
  vals = config.ports;
  if iscell(vals), vals = [vals{:}]; end 
  result = vals + 1;
  ```
  This defeats the purpose of "intuitive dot notation".

### Option 2: Wrapper Types (Custom Classes)
Create a `YAMLArray` or `YAMLValue` class.
- **MATLAB**: `data.ports = YAMLArray([5])`

**Pros:**
- Metadata preservation without breaking standard arrays (if `double()` is overloaded).

**Cons:**
- **High Complexity**: Requires maintaining a parallel type system.
- **Leaky Abstraction**: Users will eventually have to unwrap it or encounter compatibility issues with other toolboxes.
- **Overkill** for simple config files.

### Option 3: "Attribute" / Metadata Approach
Store metadata about which fields were arrays in a hidden property or separate struct.

**Pros:**
- Keeps data as native doubles.

**Cons:**
- **Fragile**: If the user does `config.ports = [5]`, the metadata is lost or becomes stale. Very hard to keep in sync.

## Recommendation

**Focus on the Use Case:**
Most users use this toolbox for **Configuration Data**.
- *Reading*: They want to retrieve values and use them immediately (`if config.retry_count > 3`).
- *Writing*: They are generating new configs or updating values.

**Decision:**
1.  **Default to Usability (`SequenceRule: 'auto'`)**:
    - Continue converting `[5]` to `5` (double).
    - Accept that `[5]` -> `5` is a "lossy" round trip for structure, but "lossless" for data meaning in MATLAB context.
    - *Rationale*: A single port number `8080` and a list of ports `[8080]` are semantically identical to MATLAB code consuming them. Forcing the distinction hurts the 90% use case.

2.  **Add a `SequenceRule: 'strict'` (or keep `'cell'`)**:
    - For users who **strictly require** round-tripping (e.g., generating distinct YAML signatures for external tools), provide the option to force Cell Arrays.
    - Document clearly: "Use this if you need `[5]` to stay `[5]`, but be aware you must use `cell2mat` or `{}` indexing."

## Answer to "Is my design wrong?"
**No.** You are successfully mapping between two different type systems.
- The ambiguity of `5` vs `[5]` is a feature of MATLAB, not a bug in your design.
- The "Long Tail" of impedance mismatches (Null vs Empty, Map vs Struct keys, distinct Integer types) is real, but "Pragmatic Mapping" (doing what 95% of users expect) is standard practice for MATLAB toolboxes bridging to JSON/YAML.

**Conclusion:** Keep the current design. Address Issue #27 by explaining *how* to use `'SequenceRule', 'cell'` for that specific need, but warn about the usability trade-off.
