# TOML Writer Formatting Options — Tables & Table Arrays

This section specifies named inputs that control how tables and arrays of tables are written in generated TOML output.

These options follow MATLAB PRISM naming standards:
- Property names are **MixedCase full**
- Option string values are **lowercase short**
- Multiword option strings use **hyphenated lowercase** only when unavoidable
- Default behavior favors **automatic, human-readable formatting**

---

## `TableStyle`

**Purpose**  
Controls whether TOML tables are written using expanded table headers (`[table]`) or inline table syntax (`{}`).

**Name**  
`TableStyle` (Property name, MixedCase full)

**Accepted Values** (option strings)  
- `"auto"` *(default)*  
- `"expanded"`  
- `"inline"`

**Behavior**
- `"expanded"`  
  Always write tables using expanded table headers.
- `"inline"`  
  Always write tables using inline table syntax.
- `"auto"`  
  Choose inline or expanded form automatically using internal heuristics.

**Design Rationale**
- `"auto"` aligns with MATLAB’s philosophy of *useful automatic behavior*.
- No thresholds are user-exposed; heuristics are intentionally opaque and may evolve.
- Avoids overfitting the API to edge cases or document-width assumptions.
- Mirrors established MATLAB patterns (`DatetimeType="auto"`, `Normalization="auto"`).
- Keeps the interface stable even if heuristics change.

**Notes**
- Inline tables selected by `"auto"` are guaranteed to be spec-compliant and visually compact.
- Inline tables are never extended across multiple lines.

---

## `TableArrayStyle`

**Purpose**  
Controls how **arrays of tables** (`[[table]]`) are written.

**Name**  
`TableArrayStyle` (Property name, MixedCase full)

**Accepted Values**  
- `"expanded"` *(default)*  
- `"inline"`  
- `"auto"`

**Behavior**
- `"expanded"`  
  Always write arrays of tables using repeated `[[table]]` headers.
- `"inline"`  
  Always write arrays of tables as inline arrays of inline tables.
- `"auto"`  
  Choose representation automatically using internal heuristics.

**Design Rationale (Default = `"expanded"`)**
- Expanded form is:
  - The most common representation in real-world TOML
  - The most readable for humans
  - The least surprising for diffs and version control
- Many tools (Poetry, packaging workflows) effectively behave as `"expanded"` even if undocumented.
- Inline arrays of tables, while valid TOML, become unreadable quickly and are rarely authored by hand.
- Defaulting to `"expanded"` matches conservative MATLAB defaults: correct, readable, predictable.

**Why allow `"auto"` at all?**
- Enables compact representations in tightly constrained contexts (e.g., generated metadata).
- Allows future heuristic improvements without expanding the public API.
- Consistent with `TableStyle`.

---

## Naming Rationale: `TableArrayStyle`

PRISM discourages names with prepositions like **Of**.

### Considered alternatives

| Candidate | Evaluation |
|--------|-----------|
| `ArrayOfTablesStyle` | ❌ Contains “Of”; verbose |
| `TableListStyle` | ❌ TOML uses “array”, not “list” |
| `TableSequenceStyle` | ❌ Not TOML terminology |
| `RepeatedTableStyle` | ❌ Obscure, indirect |
| `TableArrayStyle` | ✅ Clear, concise, TOML-native |

**Why `TableArrayStyle` works**
- Uses TOML’s own conceptual language (“array of tables”)
- Reads naturally in MATLAB syntax  
  `writeTOML(data, TableArrayStyle="expanded")`
- Avoids prepositions
- Avoids abbreviations
- Consistent with existing MATLAB property naming patterns

---

## Design Summary (Tables)

| Property | Default | Values |
|------|------|------|
| `TableStyle` | `"auto"` | `"auto"`, `"expanded"`, `"inline"` |
| `TableArrayStyle` | `"expanded"` | `"expanded"`, `"inline"`, `"auto"` |

---

## Guiding Principles Reinforced

- **Automatic behavior first**
- **Minimal user-visible complexity**
- **No exposed heuristics or thresholds**
- **Readable output by default**
- **Terminology aligned with TOML, not implementation**