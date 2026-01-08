---
title: "MATLAB Example Authoring — SKILL"
intent: "Author high-quality MATLAB Live Script examples for documentation"
scope:
   - live_script
   - reference_examples
   - published_workflows
required_sections:
   - Title
   - Short Description
   - Setup
   - Examples
   - Conclusion
examples: 3
quality_checks:
   - headings_present
   - code_fences_labeled_matlab
   - examples_runnable
   - accessibility_compliant
---

# Skill: matlab-example-authoring

**Purpose:** Author high-quality examples for MATLAB documentation using Live Scripts. This skill works in conjunction with the `matlab-live-script` skill to create properly formatted, comprehensive examples.

**Scope:** Content structure, wording, code standards, accessibility, and integration with Doc Center. Uses Live Script format exclusively.

----

## Example Types and Naming Conventions

### 1. Reference Page Examples
- **One Live Script per function/class** containing all examples for that reference page
- **Naming Convention:**
  - **Functions:** `<functionname>Example.m` (exact function name + "Example")
    - Use exact function capitalization (usually lowerCamelCase)
    - `readtomlExample.m` for `readtoml` function
    - `writeyamlExample.m` for `writeyaml` function
    - `writetomlExample.m` for `writetoml` function
  - **Classes:** `<ClassName>Example.m` (exact class name + "Example")
    - `ConfigurationDataExample.m` for `ConfigurationData` class
    - `TOMLDataExample.m` for `TOMLData` class
- **Structure:** Multiple `%%` sections, each demonstrating a different aspect/feature
---
---
title: "MATLAB Example Authoring — SKILL"
intent: "Author high-quality MATLAB Live Script examples for documentation"
scope:


## Example I/O (two minimal examples)

Input metadata:

```json
{ "filename": "readtomlExample.m", "topic": "read TOML files" }
```

Expected excerpt (Markdown Live Script):

```markdown
%% readtomlExample - Read TOML files
% Learn how to read TOML files using `readtoml` and access nested fields.
%% Setup
% Prerequisites: config files in examples/data
%% Basic reading
```matlab
T = readtoml('simple_config.toml');
disp(T.server.port)
```
```

Input for procedural example:

```json
{ "filename": "ConvertBetweenFormatsExample.m", "topic": "Convert YAML to TOML" }
```

Expected notes: include sections `Prerequisites`, `Procedure` with Goal→Action→Result, and `Cleanup`.

## Automation hooks

Ask Claude to output, after the Markdown, a single JSON line with schema:

```json
{
   "filename": "readtomlExample.m",
   "sections": ["Title","Setup","Basic reading","Examples","Cleanup"],
   "example_count": 2,
   "lint_errors": []
}
```

## Edge cases & guidance

- Large datasets: generate small synthetic data for examples and document assumptions.
- Toolbox dependencies: list required toolboxes in `Prerequisites` and provide a fallback.
- Interactive UI steps: prefer code-first reproducible steps; include screenshots only when essential with alt text.

## Short checklist for authors

- Ensure the example is runnable and self-contained.
- Use `Name=Value` syntax for name-value pairs.
- Use `"string"` notation for text unless API requires char.
- Seed randomness: `rng(0)` when examples rely on random numbers.
- Include brief narrative descriptions for plots and non-text output.

---


2. **`matlab-live-script` skill** provides:
   - Technical formatting (`%%`, `%[text]`, etc.)
   - Required appendix
   - How to structure text blocks
   - Bulleted list formatting
   - Output handling

### Creating an Example (Combined Approach)

**Step 1:** Use this skill to determine:
- Example type (reference page vs. published code)
- Naming (e.g., `readtomlExample.m` vs. `ReadWriteConfigurationFilesExample.m`)
- Content structure (what sections to include)
- Code standards (Name=Value, strings, etc.)

**Step 2:** Use `matlab-live-script` skill to ensure:
- Proper Live Script formatting
- Section headers: `%%` followed by `%[text] ## Title`
- Text blocks use `%[text]` prefix
- Required appendix is included
- No blank lines in file

### Quick Reference

| Aspect | Skill to Use |
|--------|--------------|
| What to include | `matlab-example-authoring` |
| How to format it | `matlab-live-script` |
| Naming convention | `matlab-example-authoring` |
| Content organization | `matlab-example-authoring` |
| Technical markup | `matlab-live-script` |
| Code standards | `matlab-example-authoring` |
| Text formatting | `matlab-live-script` |

---

## 12) Minimal Working Example (Template)

```matlab
% [Purpose statement in 1 sentence]
% [Expected output or result]

% Load or generate data
load fisheriris.mat
X = meas;
Y = species;

% Perform main operation
[coeff, score, ~, ~, explained] = pca(X);

% Visualize results
biplot(coeff(:,1:2), 'Scores', score(:,1:2), 'VarLabels', {'SL','SW','PL','PW'});
title('PCA Biplot of Fisher Iris Data')

% Interpret
fprintf('First two components explain %.1f%% of variance\n', sum(explained(1:2)));
```

---

## Success Criteria

An example is ready when:
1. ✅ Runs end-to-end with realistic, reproducible output
2. ✅ Title and description reflect user goals and key search terms
3. ✅ Code is PRISM-compliant (Name=Value, strings, proper naming)
4. ✅ Accessible (alt text, narratives, good contrast)
5. ✅ Links resolve correctly
6. ✅ Minimal and focused (no unnecessary complexity)
7. ✅ Self-contained within stated prerequisites
