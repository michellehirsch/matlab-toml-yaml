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

**Auto Heuristic (Implementation)**
When `TableArrayStyle="auto"`, the implementation uses inline formatting if ALL of the following conditions are met:
- Array has ≤2 elements
- Each element has ≤3 fields
- All field values are scalar (no nested tables or arrays of tables)

Otherwise, expanded `[[table]]` syntax is used.

**Rationale for heuristic thresholds:**
- 2 elements: Small arrays stay compact and readable inline; larger arrays become unwieldy
- 3 fields: Typical simple metadata (e.g., name/email, module/ignore_errors) fits comfortably
- Scalar values only: Nested complexity breaks inline table readability guarantees

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

## Inline Arrays of Inline Tables
When writing TOML, this implementation does not guarantee reproduction of inline arrays of inline tables. Such constructs may be normalized to the expanded [[table]] form during write operations.

This normalization:
* Preserves the full semantic meaning of the TOML document
* Improves readability and diff-friendliness
* Produces output that aligns with common, idiomatic TOML usage

### Rationale

Inline arrays of inline tables are:
* Rare in hand-authored TOML
* Difficult to scale as entries grow
* Ambiguous in intent once parsed into a semantic data model

After parsing, there is no semantic distinction between:
* An array of tables written inline
* An array of tables written using repeated [[table]] headers

Because this formatting choice conveys only stylistic intent—and not structural meaning—it is not preserved during read/write round-trips.

### Design Intent

This TOML writer is designed to produce canonical, human-readable output, not to preserve original formatting byte-for-byte. Users who require exact formatting preservation should use a formatting-preserving TOML editor or AST-based tool.
---

## Design Summary (Tables)

| Property | Default | Values |
|------|------|------|
| `TableStyle` | `"auto"` | `"auto"`, `"expanded"`, `"inline"` |
| `TableArrayStyle` | `"expanded"` | `"expanded"`, `"inline"`, `"auto"` |

---
# String Formatting

## StringEscapeStyle

**Purpose**  
Controls whether TOML strings are written using escape-processing syntax or literal syntax.

**Name**  
`StringEscapeStyle` (MixedCase full)

**Values & Behavior**

| Value       | Behavior |
|-------------|----------|
| `"auto"`    | Default. Choose escape-processing or literal syntax automatically using internal heuristics. |
| `"escaped"` | Always write strings using escape-processing syntax (TOML basic strings). |
| `"literal"` | Always write strings using literal syntax (no escape processing). |

**Design Rationale**
- Separates semantic intent ("should escapes be meaningful?") from layout.
- `"auto"` allows mixed usage within a single file.
- `"escaped"` / `"literal"` are descriptive and intuitive, unlike `basic`.
- Avoids forcing users to reason about TOML spec terminology.

**Auto Heuristic (Implementation)**
When `StringEscapeStyle="auto"`, the implementation chooses literal syntax if:
- String contains backslashes (`\`), AND
- String does NOT contain common escape sequences (`\n`, `\t`, `\r`, `\"`)

Otherwise, escaped (basic) syntax is used.

**Rationale:**
- File paths (e.g., `C:\Users\path`) benefit from literal strings—no double-backslashing needed
- Strings with actual escape sequences (newlines, tabs) require escape processing
- Heuristic is conservative: defaults to escaped when uncertain

---

## StringLayout

**Purpose**  
Controls whether TOML strings are written as single-line or multiline strings.

**Name**  
`StringLayout` (MixedCase full)

**Values & Behavior**

| Value          | Behavior |
|----------------|---------|
| `"auto"`       | Default. Choose single-line or multiline formatting automatically using internal heuristics. |
| `"singleline"` | Always write strings on a single logical line. |
| `"multiline"`  | Always write strings using multiline delimiters. |

**Design Rationale**
- Orthogonal to escaping semantics.
- `"auto"` enables readability-driven formatting decisions.
- Keeps user control coarse-grained and predictable.
- Matches MATLAB's "layout is a presentation concern" philosophy.

**Auto Heuristic (Implementation)**
When `StringLayout="auto"`, the implementation uses multiline formatting if:
- String contains newline characters (`\n` or actual line breaks)

Otherwise, single-line formatting is used.

**Rationale:**
- Natural mapping: strings with line breaks become multiline TOML strings
- Preserves readability of formatted text (descriptions, error messages, etc.)
- Single-line strings are more compact and easier to scan for short values
- Heuristic is simple and predictable: presence of newlines determines layout

---

## Guiding Principles Reinforced

- **Automatic behavior first**
- **Minimal user-visible complexity**
- **No exposed heuristics or thresholds**
- **Readable output by default**
- **Terminology aligned with TOML, not implementation**