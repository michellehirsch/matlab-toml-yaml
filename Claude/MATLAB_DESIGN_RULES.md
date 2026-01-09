
# MATLAB Design Rules (PRISM Quick Reference)

*Last updated: March 2025*

> This document distills MATLAB design standards from the PRISM Quick Reference to help large language models (LLMs) like Claude and GitHub Copilot generate consistent, idiomatic MATLAB APIs and code.

---

## 1. Name Styles

PRISM defines three name styles determined by capitalization:

- **lowercase short** — single short word or abbreviated multi-word phrase; all lowercase; ≤12 chars in MATLAB (exceptions up to 16), ≤16 in toolboxes/products; abbreviations encouraged. Examples: `cellplot`, `rmmissing`. citeturn1search1
- **camelCase full** — starts lowercase; subsequent words capitalized; *no abbreviations* except widely recognized domain acronyms/initialisms and five allowed abbreviations; no length limit. Examples: `griddedInterpolant`, `openProject`. citeturn1search1
- **MixedCase full** — each word starts uppercase; same abbreviation rules as camelCase; no length limit. Examples: `ImageAdapter`, `OuterPosition`. citeturn1search1

### Avoid Empty Words
Remove non-informative terms:
- **Functions:** avoid empty verbs like `compute`, `retrieve`, `get`, `return`, `do`. citeturn1search1
- **Classes:** avoid `Class`, `Object`, `Abstract`, `Base`, `Mixin`. citeturn1search1
- **Properties:** avoid `List` (use plural noun), and avoid embedding class/datatype (use `Label` not `LabelString`). citeturn1search1

### Abbreviations
- **Allowed in lowercase short** names. Not allowed in **camelCase full** or **MixedCase full**, except for acronyms/initialisms and **five specific allowed abbreviations** in full names: **Num** (number of), **Min**, **Max**, **Auto**, **Fcn** (function; typically for callbacks and function-handle named parameters). citeturn1search1

### Acronyms and Initialisms
- Recognized domain acronyms/initialisms are permitted in all styles; capitalization depends on style:
  - **lowercase short:** all lowercase (e.g., `jsondecode`). citeturn1search1
  - **camelCase full:** leading acronym lowercased if first word (e.g., `kmlFile`); otherwise typical capitalization (often ALLCAPS) in later words (e.g., `trainRCNNObjectDetector`). citeturn1search1
  - **MixedCase full:** use typical capitalization (often ALLCAPS), e.g., `KMLFile`, `ServerURL`. citeturn1search1

---

## 2. Interface Element Naming

Use grammatical form + style based on interface type and namespace:

### Functions / Methods
- **Form:** action verb/verb phrase describing the performed action; nouns for creators/returners; `is`/`has` verbs for logical returns; topic noun (uncommon). Examples: `close`, `traverseGraph`, `eig`, `chebwin`, `isnumeric`, `hascycles`, `rng`. citeturn1search1
- **Style by context:**
  - **Informal (not in namespace):** prefer **lowercase short** (e.g., `eig`, `cellplot`, `bdroot`, `delete`, `fft`, `rmmissing`). citeturn1search1
  - **Formal (in namespace):** use **camelCase full**, e.g., `matlab.system.isSystemObject`, `matlab.desktop.editor.openAndGoToLine`. citeturn1search1

### Classes
- **Form:** noun/noun phrase; **mixin behaviors** may use adjective/verb phrase (e.g., `matlab.graphics.mixin.Selectable`). citeturn1search1
- **Style:**
  - Informal classes: **lowercase short** (e.g., `strel`, `pattern`). citeturn1search1
  - Formal classes: **camelCase full** (e.g., `griddedInterpolant`) or **MixedCase full** when in namespaces (e.g., `matlab.ui.eventdata.MouseData`). citeturn1search1

### Properties & Named Arguments
- **Form:** noun/noun phrase (logical-valued may be verb/adjective phrase). Examples: `Connectivity`, `CornerThreshold`, `Visible`, `HasOutputPort`, `IsEditable`, `NumOutputPorts`, `ServerURL`. citeturn1search1
- **Style:** **MixedCase full** for properties/named args. citeturn1search1

### Option Strings / Status Flags
- Prefer **lowercase short** (e.g., `original`, `optimized`, `linear`, `log`), or **lowercase short hyphenated** for multiword (e.g., `trust-region`, `hilbert-huang`) unless implemented as an enumeration (then hyphenation not supported). citeturn1search1

### Namespaces
- Nouns are singular; examples: `matlab.graphics.chart`, `optim.algorithm`, `matlabshared.material`. Product root folders evoke product names (`optim`, `sldv`, `database`, `rptgen`). citeturn1search1

---

## 3. Interface Styles: Informal vs. Formal

- **Informal Interfaces (not namespaced):** optimized for ease—simple syntax, useful defaults, minimal required programming skill, familiar terminology, and “just enough” flexibility. Examples: `uislider` (factory that creates a figure with a slider with no arguments; many NV pairs), `movmean` (flexible syntax: 2 required args, optional trailing args, NV pairs). citeturn1search1
- **Formal Interfaces (namespaced):** flexible, powerful, unambiguous, regular syntax, controlled scope; often internal. Examples: `matlab.ui.control.Slider`, `matlab.graphics.chartcontainer.ChartContainer` (subclass for custom charts), `matlab.desktop.editor.openAndGoToLine`, `matlab.lang.internal.Memoizer`. citeturn1search1

### Namespace Use & Organization
- Namespaces **only** for Formal Interfaces; Informal factory functions may **return** namespace classes (e.g., `uislider` returns `matlab.ui.control.Slider` or `matlab.ui.control.RangeSlider`). citeturn1search1
- One **root namespace per product**; inner namespaces live within that root; support packages use corresponding product root namespace. citeturn1search1
- Put **shared functionality** in the root namespace of the shipping product; if shared across products, use `matlabshared`. citeturn1search1

### Internal & Undocumented Functionality
- Put public-scope-but-not-for-end-users functionality in an **internal** namespace and omit documentation references; communicates unsupported/changable status. Use internal namespaces for implementation details, never-for-end-users, or not-ready features. Place internal namespaces near related documented functionality within the product root (e.g., `matlab.lang.internal`), not at top-level `internal` or `matlab.internal`. Documented interfaces **must not** return classes in internal namespaces; docs/examples should **not** use internal functions. citeturn1search1

---

## 4. Permissive Name & Value Matching

Make interfaces forgiving:
- Accept **case-insensitive** names (`linestyle` vs `LineStyle`). citeturn1search1
- Accept **unambiguous partial** names (`align` for `AlignVertexCenters`). citeturn1search1
- Apply permissive matching to:
  - **Name-Value argument names** (e.g., `plot(..., LineColor="r")`). citeturn1search1
  - **Option string values** in positional args (`sort(..., "descend")`), object properties (`p.LineJoin = "round"`), and NV values (`readtable(..., DatetimeType="datetime")`). citeturn1search1
- **Implementation note:** use function argument validation and class property type validation with **enumerations** to support permissive matching for option strings. Documentation should show **full, case-correct** names and values. citeturn1search1

---

## 5. Quick Heuristics for LLMs

When proposing new APIs or refactoring:

1. **Choose style by scope:** Informal (user-facing, easy) ⇒ lowercase short; Formal (namespaced, developer-focused) ⇒ camelCase/MixedCase. citeturn1search1
2. **Use verbs for actions, nouns for things;** `is/has` for logicals. citeturn1search1
3. **Avoid empty words** and hidden type hints in names. citeturn1search1
4. **No abbreviations** in full names—except the five allowed (**Num/Min/Max/Auto/Fcn**) and domain acronyms/initialisms. citeturn1search1
5. **Acronym capitalization** depends on style (see §1). citeturn1search1
6. **Option strings are lowercase short;** support permissive matching. citeturn1search1
7. **Namespaces:** one root per product; use `matlabshared` for cross-product; internal namespaces for undocumented pieces only. citeturn1search1

---

## 6. Examples

- **Function (informal):** `movmean` with NV args: `movmean(x, k, Endpoints="discard", NanFlag="omit")` — lowercase short function + lowercase option strings. citeturn1search1
- **Class (formal):** `matlab.graphics.chartcontainer.ChartContainer` — MixedCase class name in namespace. citeturn1search1
- **Property (formal):** `CornerThreshold`, `ServerURL` — MixedCase full. citeturn1search1
- **Factory function:** `uislider` returning `matlab.ui.control.Slider`. citeturn1search1

---

## 7. LLM Prompting Tips (for Claude & GitHub Copilot)

Use this checklist in prompts:

- **"Name style":** specify **lowercase short** / **camelCase full** / **MixedCase full** based on scope. citeturn1search1
- **"Interface type":** function vs class vs property; grammar (verb vs noun) and `is/has` for logicals. citeturn1search1
- **"Abbreviation policy":** no abbreviations in full names, except **Num/Min/Max/Auto/Fcn** and domain acronyms/initialisms. citeturn1search1
- **"Permissive matching":** accept case-insensitive and unambiguous partial names; document full, case-correct names. citeturn1search1
- **"Namespace plan":** one root per product; internal for undocumented; `matlabshared` if cross-product. citeturn1search1

---

## 8. Attribution

Derived from **PRISM Quick Reference (March 2025)**. Owner: *Michelle Hirsch*. citeturn1search1

