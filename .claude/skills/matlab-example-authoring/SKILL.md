# Skill: matlab-example-authoring

**Purpose:** Author high-quality examples for MATLAB documentation using Live Scripts. This skill works in conjunction with the `matlab-live-script` skill to create properly formatted, comprehensive examples.

**Scope:** Content structure, wording, code standards, accessibility, and integration with Doc Center. Uses Live Script format exclusively.

---

## When to Use This Skill

Use this skill when:
- Creating **reference page examples** (all examples for a function/class)
- Writing **published code examples** for documentation
- The user explicitly requests "example" or "documentation example"
- Creating comprehensive example scripts for toolbox documentation

**This skill works WITH `matlab-live-script`:**
- This skill provides content guidance, structure, and best practices
- `matlab-live-script` handles the technical formatting (`%[text]`, appendix, etc.)
- Always use Live Script format for all examples

**Do NOT use for:**
- Quick code snippets or prototypes
- Internal testing code
- One-off demonstrations

---

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
- **Purpose:** Support reference documentation with comprehensive, runnable examples
- **Title format:** `<functionname>Example - Brief description`

### 2. Published Code Examples
- **Standalone tutorial or workflow** Live Scripts for broader topics
- **Naming Convention:** `MixedCaseFullDescriptiveName` + "Example.m"
  - Always end with "Example"
  - Use descriptive names that indicate the topic/workflow
  - `ReadWriteConfigurationFilesExample.m` - Tutorial on reading/writing configs
  - `ManageApplicationConfigExample.m` - Complete app configuration workflow
  - `ConvertBetweenFormatsExample.m` - Format conversion tutorial
- **Structure:** Narrative flow with logical progression through a complete workflow
- **Purpose:** Teach broader concepts or end-to-end workflows spanning multiple functions
- **Title format:** Descriptive title (e.g., "Read and Write Configuration Files")

### Naming Quick Reference

| Type | Pattern | Example |
|------|---------|---------|
| Function reference | `functionNameExample.m` | `readtomlExample.m` |
| Class reference | `ClassNameExample.m` | `ConfigurationDataExample.m` |
| Published workflow | `DescriptiveNameExample.m` | `ReadWriteConfigurationFilesExample.m` |

**All examples use Live Script format** (`.m` files with `%[text]` markup and required appendix)

---

## 1) Core Principles

1. **User goal first.** State a clear outcome and show how the user achieves it. Minimize cognitive load.
2. **Every Page is Page One (EPPO).** Make the example self-contained enough that users can start here, with links to deeper topics as needed.
3. **Two example types:**
   - **Descriptive (learning-point focused):** What/why, concepts, result interpretation.
   - **Procedural (task-focused):** Steps (Goal → Action → Result), screenshots where they teach.
4. **Reference-page context.** Examples *support* the reference page: show correct usage, common workflows, and disambiguate similar functionalities.
5. **Runnable, minimal, and PRISM-compliant.** Code must run, follow customer-facing code standards, and avoid unnecessary complexity.
6. **Discoverability.** Titles/short descriptions include key phrases users search for; avoid jargon; prefer canonical terminology.
7. **Accessibility.** Use alt text for images, readable color contrast, narrative descriptions for plots or UIs, and non-idiomatic English suitable for global readers.

---

## 2) Example Structure Templates

Choose **Descriptive** or **Procedural**. Keep the structure tight and repeatable across examples.

### A. Descriptive Example (Template)

- **Title**: Concise, task/result oriented (≤7 words when feasible)
- **Short Description (1-2 sentences)**: What the user will learn + the context
- **Setup (optional)**: Prerequisites (toolboxes, data), one-click resources
- **Main Event (learning points)**: Ordered subsections that explain the workflow and *why it matters*
- **Result/Interpretation**: What success looks like; expected outputs/plots
- **Next Steps / Related Links**: Point to reference page sections and deeper topics

**Example:**
```markdown
## Classify Faults in Sensor Data with Ensemble

Learn how to train and evaluate a bagged ensemble to separate healthy and
faulty readings in time-series data.

### Load and Prepare Data
[code showing data loading and feature extraction]

### Train Ensemble Classifier
[code showing fitcensemble usage]

### Evaluate Performance
[code showing confusion matrix and ROC curve]

The confusion matrix shows 95% accuracy, with low false-positive rate...

### Related Topics
- fitcensemble - Train ensemble of learners
- Choosing Classifiers - Compare classifier types
```

### B. Procedural Example (Template)

- **Title**: Clear task description
- **Short Description**: Context and expected outcome
- **Prerequisites**: Toolboxes, data files, model links
- **Procedure** *(repeat for each step)*:
  - **Goal:** What the user is about to accomplish
  - **Action(s):** Code snippet(s) or UI actions (use concise steps; group sub-steps logically)
  - **Result:** What the user should see or verify (figures, diagnostics, outputs)
- **Troubleshooting (optional):** Common mistakes and quick fixes
- **Conclusion:** Recap + pointer to adjacent workflows
- **Related Links:** Doc topics, API references, Example Manager entries

**Example:**
```markdown
## Tune PID Gains for Step Response Tracking

Use PID Tuner to meet rise time and overshoot targets for the Step Response block.

### Prerequisites
- Control System Toolbox
- Simulink model: `scdspeedctrl.slx`

### Step 1 — Open PID Tuner
**Goal:** Launch the tuner with the current PID parameters.

**Action:**
Open the model and click **Tune** in the PID Controller block dialog.

**Result:** PID Tuner opens showing the current step response.

### Step 2 — Set Performance Targets
**Goal:** Define rise time < 2 seconds and overshoot < 10%.

**Action:**
In the Response Time section, set Rise Time to 2. In the Transient Behavior
section, drag the Overshoot slider to 10%.

**Result:** The target response region updates on the plot.

[continue for remaining steps...]
```

---

## 3) Writing Rules (Content & Style)

1. **Titles**
   - ≤7 words when feasible; avoid repeating words across titles
   - Use task/result phrasing: *"Detect outliers in sensor data"*
   - Use title case for reference page examples

2. **Short Description**
   - 1-2 sentences; clarify purpose and context; include key search terms
   - Use sentence case; end with period

3. **Steps (procedural)**
   - Each step communicates **Goal → Action → Result**
   - Use numbered headings: "Step 1 — Load data"
   - Screenshots only when they teach a decision or show expected output

4. **Terminology**
   - Use product-approved terms (MathWorks Style Guide / Word List)
   - Define unfamiliar terms *in place*; avoid standalone glossaries
   - Use exact product/function names with correct capitalization

5. **Global English**
   - Prefer short sentences, concrete verbs, and active voice
   - Avoid culture-specific idioms, humor, or colloquialisms
   - Use "you" to address the reader directly

6. **Linking**
   - Link to doc targets using page titles as link text
   - Provide context: "For more information, see [Page Title]"
   - Link functions/classes on first mention

7. **Comments**
   - Use `%` for inline code comments (one space after `%`)
   - Keep comments brief and descriptive
   - Explain *why*, not *what* (code should be self-explanatory)

---

## 4) Code Standards (PRISM-aligned)

> Ensure examples compile/run and reflect MATLAB interface norms. Favor clarity over cleverness.

### Syntax and Style
- **Function calls:** Use functional form: `plot(x, y)` not `plot x y`
- **Properties:** Access via dot notation: `p.MarkerSize = 12;`
- **Name-value arguments:** Use Name=Value syntax: `plot(x, y, LineWidth=2)`
  - Use complete, case-correct names
  - **Correct:** `FileType="spreadsheet"`
  - **Incorrect:** `'FileType', 'spreadsheet'` (old syntax)
- **Command syntax:** Use for simple cases: `hold on`, `grid on`
- **Text:** Use strings (`"string"`) not char (`'char'`) unless required
- **Spacing:**
  - One space after `%` in comments
  - Spaces around `=` for assignment: `x = 5;`
  - No spaces in Name=Value: `LineWidth=2`

### Naming Conventions
- **Functions/methods:**
  - `lowercaseShort` if <12 chars
  - `camelCaseFull` otherwise
  - Avoid empty verbs (*get*, *set*, *do*)
- **Classes:** `MixedCaseFull` (e.g., `ConfigurationData`)
- **Variables:**
  - Descriptive: `sensorData` not `sd`
  - Use full words: `temperature` not `temp`

### Best Practices
- **Minimalism:** Remove extraneous lines; use small, focused datasets
- **Reproducibility:** Seed randomness: `rng(0)` or `rng('default')`
- **Error handling:** Keep simple; demonstrate only when teaching
- **Data:** Use built-in datasets or generate data; document assumptions
- **Organization:** Group related code; add blank lines between sections

### Example (PRISM-compliant)
```matlab
% Load sample data
load patients.mat

% Create a table with key variables
T = table(Age, Weight, Systolic, Diastolic);

% Fit linear model predicting systolic pressure from age and weight
mdl = fitlm(T, "Systolic ~ Age + Weight");

% Display model summary
disp(mdl)

% Visualize residuals
plotResiduals(mdl)
```

---

## 5) Accessibility Requirements

- **Alt text:** Provide for all images/screenshots; describe essential insight
- **Color contrast:** Use sufficient contrast in plots; include legends/labels
- **No color-only encoding:** Use markers, line styles, or text labels
- **Readable text:** No tiny fonts in screenshots
- **Narrative descriptions:** Describe visual results
  - **Good:** "The ROC curve rises steeply to 0.9 AUC, indicating strong classifier performance."
  - **Bad:** "See the plot."
- **Avoid directional references:** Don't rely on "above", "below", "left", "right"

---

## 6) Toolbox-Specific Guidance

### When to Show vs. Tell
- **Show with code:** Syntax, workflows, common patterns
- **Tell with text:** Conceptual background, interpretation, decision rationale

### Toolbox Dependencies
- List all required toolboxes in prerequisites
- Use `ver` to check: `ver('statistics')`
- Provide fallback or note if optional

### Integration Points
- Link to related toolbox functions
- Reference Example Manager entries
- Connect to relevant documentation topics

---

## 7) Common Anti-Patterns to Avoid

**Don't:**
- ❌ Dump large, undifferentiated scripts ("wall of code")
- ❌ Use old Name-Value syntax: `plot(x, y, 'LineWidth', 2)`
- ❌ Mix char and string unnecessarily
- ❌ Over-optimize or micro-benchmark
- ❌ Use internal/private APIs
- ❌ Rely on color alone in plots
- ❌ Include screen-by-screen UI tours
- ❌ Use cryptic variable names: `tmp`, `x1`, `data2`
- ❌ Skip error checking when it matters
- ❌ Create multiple similar examples (pick one strong example)
- ❌ Use deprecated functions
- ❌ Assume specific working directory
- ❌ Use absolute file paths

**Do:**
- ✓ Show end-to-end workflow with clear objective
- ✓ Use small, shareable datasets or generated data
- ✓ Highlight outcomes and interpretation
- ✓ Use Goal → Action → Result structure
- ✓ Make code self-contained and reproducible
- ✓ Follow current MATLAB best practices
- ✓ Use Name=Value syntax for all name-value arguments
- ✓ Provide context for each code block

---

## 8) Quality Checklist

Before submitting, verify:

- [ ] **Runs completely:** Example executes without errors
- [ ] **PRISM-compliant:** Follows code standards
- [ ] **Reproducible:** Uses seeded randomness if needed
- [ ] **Self-contained:** No external dependencies beyond stated prerequisites
- [ ] **Title/description:** Includes key search terms
- [ ] **Name=Value syntax:** All name-value arguments use `Name=Value`
- [ ] **Strings not char:** Uses `"strings"` except where required
- [ ] **Accessible:** Alt text, narratives, good contrast
- [ ] **Links valid:** All references point to correct pages
- [ ] **Minimal:** No unnecessary code or complexity
- [ ] **Descriptive names:** Variables and functions clearly named

---

## 9) Example Blueprints (Ready-to-Adapt)

### Blueprint 1: Reference Page Example (Function)

**Filename:** `readtomlExample.m`

**Title:** readtomlExample - Comprehensive guide to reading TOML files

**Structure:**
1. **Basic TOML Reading** - Simple file, dot notation access
2. **Working with Nested Tables** - Navigate nested structures
3. **Keys with Special Characters** - Dynamic field access
4. **Working with Arrays** - Inline and multi-line arrays
5. **Array of Tables** - GitHub Actions style
6. **Nested Array of Tables** - Complex configurations
7. **Exploring Unknown Files** - keys(), isfield(), show()
8. **Data Types** - String, integer, float, boolean, datetime
9. **Converting to Struct** - Interoperability
10. **Real-World Example** - Python pyproject.toml
11. **Best Practices** - Summary of key techniques
12. **Cleanup** - Delete temporary files

**Format:** Live Script with multiple `%%` sections, each focusing on one aspect of the function.

---

### Blueprint 2: Reference Page Example (Class)

**Filename:** `ConfigurationDataExample.m`

**Title:** ConfigurationDataExample - Working with ConfigurationData, TOMLData, and YAMLData

**Structure:**
1. **Overview** - Class features and capabilities
2. **Creating Objects** - Constructor and basic usage
3. **Accessing Data** - Dot notation
4. **Special Characters** - Keys with hyphens, dots, spaces
5. **Nested Structures** - Building hierarchies
6. **Exploring Structure** - keys(), isfield()
7. **Handle Class Behavior** - References vs. copies
8. **Converting to Struct** - Interoperability
9. **TOMLData** - Specialized for TOML
10. **YAMLData** - Specialized for YAML
11. **Arrays of Objects** - Working with collections
12. **Practical Example** - Real-world application config
13. **Best Practices** - Usage guidelines
14. **Cleanup** - Delete temporary files

---

### Blueprint 3: Published Code Example (Workflow)

**Filename:** `ReadWriteConfigurationFilesExample.m`

**Title:** Read and Write Configuration Files

**Short Description:** Learn how to use `readyaml`, `writeyaml`, `readtoml`, and `writetoml` to manage application configuration files.

**Structure:**
1. **Introduction** - Overview of configuration file formats
2. **Reading YAML Files** - Basic usage of `readyaml`
3. **Writing YAML Files** - Formatting options for `writeyaml`
4. **Reading TOML Files** - Basic usage of `readtoml`
5. **Writing TOML Files** - Formatting options for `writetoml`
6. **Converting Between Formats** - Read YAML, write TOML (and vice versa)
7. **Practical Workflow** - Complete application configuration example
8. **Best Practices** - When to use YAML vs. TOML
9. **Cleanup** - Delete temporary files

**Format:** Live Script with narrative flow, teaching a complete workflow from start to finish.

---

## 10) Reusable Phrases (Style-Aligned)

- "This example shows how to **[action]** to achieve **[outcome]**."
- "Use **[function]** to **[verb phrase]**, then **[follow-on step]**."
- "The **[plot/metric]** indicates **[interpretation]**."
- "For related workflows, see **[topic]** in the documentation."
- "The result shows **[observation]**, which means **[interpretation]**."
- "To **[goal]**, **[action]**."

---

## 11) Working with matlab-live-script Skill

**All examples created with this skill MUST use Live Script format.**

### Integration Workflow

1. **This skill (`matlab-example-authoring`)** provides:
   - Content structure and organization
   - Code standards and best practices
   - What to include in each section
   - Naming conventions
   - Quality criteria

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
