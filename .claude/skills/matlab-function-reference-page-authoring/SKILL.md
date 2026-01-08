---
title: "Function Reference Page — SKILL"
intent: "Author concise, consistent MATLAB function/class reference pages in Markdown"
scope:
  - function_reference
  - authoring
required_sections:
  - Title
  - Purpose
  - Syntax
  - Description
  - Input Arguments
  - Output Arguments
  - Examples
optional_sections:
  - Name-Value Arguments
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

# SKILL.md — Authoring Function Reference Pages in Markdown

---

## Reference Page Structure

### 1. Title (required)
- Use the function/class name as the page title.
```markdown
# mean
```

### 2. Purpose Line (required)
- One sentence summary under the title.
```markdown
**Average or mean value of array**
```

### 3. Reference Summary (optional)
```markdown
The `mean` function returns the average value of elements in an array, supporting various data types and dimensions.
```

### 4. Syntax and Description (required)
```markdown
## Syntax
```matlab
Y = mean(X)
Y = mean(X,dim)
```
## Description
`Y = mean(X)` returns the mean of the elements in array X.  
`Y = mean(X,dim)` returns the mean along dimension `dim` of X.
```

### 5. Input Arguments (required)
```markdown
### Input Arguments
- **X**  
  Input array.  
  *Type:* numeric, logical, etc.

- **dim**  
  Dimension to operate along.  
  *Type:* integer scalar. Default: first non-singleton dimension.
```

### 6. Name-Value Arguments (required when applicable)
```markdown
### Name-Value Arguments
- **'Color'**  
  Line color, specified as a string or RGB triplet. Default: 'blue'.
```

### 7. Output Arguments (required when applicable)
```markdown
## Version History
- Introduced in R2006a
- R2023b: Added support for string arrays
```

### 17. See Also (required)
```markdown
## See Also
[`median`](#), [`sum`](#), [`std`](#)
```

---

## General Authoring Guidelines
- Use sentence case for headings and purpose lines.
- Avoid unnecessary articles ("the", "a", "an").
- Use clear, concise language.
- Prefer code blocks for syntax and examples.

### Code Style Guidelines
- Always use `""` (string) instead of `''` (char), unless char is absolutely required. This applies in both text and code examples (e.g., `data = readyaml(filename,"SequenceRule",rule)`)
- Use the simplest, most modern functions in code examples:
  - Use `writelines` with string arrays instead of `fprintf` with char arrays
  - Use `readlines` instead of `fileread` when working with line-based text
  - Prefer string arrays over char arrays for multiline text creation
- Avoid object-oriented terminology where possible:
  - Minimize saying "object" repeatedly. Instead of "The ClassName object supports:", use "ClassName supports:"
  - You don't need to mention inheritance relationships (e.g., "subclass of") unless critical to understanding
  - It's acceptable to say "a ClassName object" when introducing it in output arguments or similar contexts
- Never use empty parentheses when referring to functions or methods in prose:
  - Write "Use `copy` to create..." not "Use `copy` to create..."
  - Write "The `show` method displays..." not "The `show` method displays..."
  - Exception: Empty parentheses are fine in code examples and syntax sections
- Always use function syntax for method calls, never dot notation:
  - Write `show(obj)` not `obj.show`
  - Write `copy(data)` not `data.copy`
  - Exception: Property access uses dot notation: `obj.PropertyName`
- Follow MATLAB coding guidelines resource for additional standards
---
---
title: "Function Reference Page — SKILL"
intent: "Author concise, consistent MATLAB function/class reference pages in Markdown"
required_sections:
  - Title
  - Purpose
  - Syntax
  - Description
  - Input Arguments
  - Output Arguments
  - Examples
optional_sections:
  - Name-Value Arguments
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
  - examples_count
  - examples_syntax_valid
---

# SKILL — Authoring MATLAB Function Reference Pages

Purpose: provide a compact, machine-friendly spec Claude can follow to generate or refine MATLAB function reference pages.

Goals:
- Produce consistent, runnable examples and canonical headings.
- Return a short JSON summary for automation.
- Run a minimal lint checklist and report failures.

**Expected output**
- Primary: Markdown document containing required sections and MATLAB code fences.
- Secondary: JSON summary with keys: `title`, `sections` (list), `examples` (count), `lint_errors` (list).

## Prompt templates

- Draft (generation):

  "Write a function reference page for `{name}`. Produce only Markdown following this SKILL: include `Purpose`, `Syntax`, `Description`, `Input Arguments`, `Output Arguments`, and at least one `Examples` block. Place MATLAB code in ```matlab fences. Return a JSON summary with `title`, `sections`, `examples`, and `lint_errors`."

- Refine (edit):

  "Edit the following reference page to be concise and complete per the SKILL. Keep examples runnable and update the Version History. Return only the updated Markdown and a JSON summary of changes (fields: `updated_sections`, `changelog`)."

## Minimal validation / lint checklist (what Claude should report)

- All required headings exist.
- All code blocks that show MATLAB syntax use triple backticks with `matlab` language tag.
- Examples count >= 1.
- No inline shell or non-MATLAB code in examples.
- Headline length <= 80 chars; Purpose <= 1 sentence.

If any check fails, include `lint_errors` items with brief descriptions.

## Example I/O (two short examples)

Input (metadata):

```json
{ "name": "mean", "brief": "Average of array elements" }
```

Expected Markdown output (excerpt):

```markdown
# mean

**Average of array elements**

## Syntax
```matlab
Y = mean(X)
Y = mean(X,dim)
```

## Description
`Y = mean(X)` returns the arithmetic mean of the elements in `X`.

## Input Arguments
- **X**  
  Input array. *Type:* numeric, logical.

## Output Arguments
- **Y**  
  Mean values.

## Examples
```matlab
X = [1 2 3;4 5 6];
Y = mean(X)
```
```

Input (name-value example):

```json
{ "name": "plot", "brief": "Create 2-D plot", "name_value": ["Color"] }
```

Expected Notes: include a `Name-Value Arguments` section listing `'Color'` with default and type.

## Automation hooks

Ask Claude to return, after generating Markdown, a single JSON object (on a separate line) with the schema:

```json
{
  "title": "mean",
  "sections": ["Purpose","Syntax",...],
  "examples": 1,
  "lint_errors": []
}
```

## Edge cases & instructions

- Overloaded functions: create a short canonical page for the common signature and link to detail pages for other signatures.
- Multiple outputs: list in `Output Arguments` and include an example that assigns all outputs.
- Long algorithm descriptions: summarize to 2–4 sentences and add a `More About` link placeholder.

## Quality rubric (concise)

- Pass: all required headings, MATLAB fenced examples, examples runnable (no obvious syntax errors), and `lint_errors` empty.
- Partial: minor lint errors (e.g., missing `Version History`) — list in `lint_errors`.
- Fail: missing required sections or examples with non-MATLAB code.

---
