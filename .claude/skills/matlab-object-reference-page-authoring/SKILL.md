---
title: "Object Reference Page — SKILL"
intent: "Author concise MATLAB object reference pages in Markdown"
scope:
  - object_reference
  - authoring
required_sections:
  - Title
  - Purpose
  - Description
  - Creation
  - Properties
  - Object Functions
  - Examples
optional_sections:
  - Usage
  - Tips
  - Limitations
  - Algorithms
  - More About
  - Alternative Functionality
  - Extended Capabilities
  - References
  - Version History
  - See Also
examples: 2
quality_checks:
  - headings_present
  - code_fences_labeled_matlab
  - examples_runnable
  - accessibility_compliant
---

 # SKILL.md — Authoring Informal Object Reference Pages in Markdown

### 2. Purpose Line (required)
- Short summary phrase describing what the object represents.
```markdown
**Histogram chart object**
```

### 3. Description (required)
- Brief description of what the object represents and its role in workflows.
```markdown
The `Histogram` object represents a histogram chart for visualizing data distribution.
```

### 4. Creation (required)
- How users create the object.
- If the creation function has the same name, include a mini-function section with syntax, inputs, and outputs.
```markdown
## Creation
```matlab
h = histogram(data)
```
Creates a histogram object from `data`.
```

### 5. Properties (required when applicable)
- List and describe object properties.
```markdown
## Properties
- **BinEdges**  
  Edges of histogram bins. *Type:* numeric vector.
```

### 6. Object Functions (required when applicable)
- Curated list of functions that accept the object.
```markdown
## Object Functions
- [`morebins`](#) — Increase number of bins
- [`normalize`](#) — Normalize histogram data
```

### 7. Usage (optional)
- Additional syntaxes for using the object.
```markdown
## Usage
```matlab
normalize(h,'probability')
```
Normalizes histogram to probability.
```

### 8. Examples (required)
- Show common workflows.
```markdown
## Examples
```matlab
data = randn(1000,1);
h = histogram(data)
```
Creates a histogram of random data.
```

### 9. Tips (optional)
- Helpful best practices.
```markdown
## Tips
- Use `BinWidth` to control bin size.
```

### 10. Limitations (optional)
- Known constraints.
```markdown
## Limitations
- Does not support categorical data.
```

### 11. Algorithms (optional)
- Brief description of underlying algorithms.
```markdown
## Algorithms
---
---
title: "Object Reference Page — SKILL"
intent: "Author concise MATLAB object reference pages in Markdown"
required_sections:
  - Title
  - Purpose
  - Description
  - Creation
  - Properties
  - Object Functions
  - Examples
optional_sections:
  - Usage
  - Tips
  - Limitations
  - Algorithms
  - More About
  - Alternative Functionality
  - Extended Capabilities
  - References
  - Version History
  - See Also
examples: 2

# histogram

**Histogram chart object**

## Creation
```matlab
h = histogram(data)
```

## Properties
- **BinEdges**  
  Edges of histogram bins. *Type:* numeric vector.

## Object Functions
- `normalize(h,'probability')` — Normalize histogram values

## Examples
```matlab
data = randn(1000,1);
h = histogram(data);
```
```

## Automation hooks

Ask Claude to return, after generating Markdown, a single JSON object (on a separate line) with the schema:

```json
{
  "title": "histogram",
  "sections": ["Creation","Properties","Object Functions","Examples"],
  "examples": 1,
  "lint_errors": []
}
```

## Edge cases & guidance

- Creation functions separate from object names: include a `Creation` mini-syntax section.
- Properties that are function handles or callbacks: document expected signatures.
- If an object has many properties, group them: Common, Appearance, Behavior, Performance.

## Quality rubric (concise)

- Pass: required headings present, properties documented with types, examples runnable, and `lint_errors` empty.
- Partial: minor lint issues (grouping, minor missing types) — list in `lint_errors`.
- Fail: missing `Creation` or `Properties` sections or examples with non-MATLAB code.

---

