# YAML Implementation Limitations and Design Decisions

The `readyaml` and `writeyaml` utilities in this toolbox provide a lightweight, pure-MATLAB implementation of a YAML parser and emitter. This implementation is **not** a fully compliant YAML 1.2 parser. It is designed to support the subset of YAML most commonly used for configuration files in engineering workflows.

## Known Limitations

### 1. Structure and Hierarchy
- **No Multi-Document Support**: The parser does not support multiple documents in a single file separated by `---`. It treats the entire file as a single document.
- **No Complex Keys**: Mapping keys must be scalars (strings). YAML allows keys to be sequences or mappings (e.g., `[1, 2]: value`), but this toolkit assumes all keys are strings.
- **Flow Maps**: Flow-style mappings (e.g., `{name: value, count: 1}`) are not fully supported or robustly parsed. Block style (indentation-based) is preferred and expected.
- **Nested Flow Sequences**: While `[a, b, c]` works, nested flow sequences like `[[a, b], [c, d]]` may not be definitively parsed in all edge cases.

### 2. Advanced YAML Features
- **Anchors and Aliases (`&`, `*`)**: References to other parts of the document are **not supported**. The parser will likely treat them as literal strings or fail to parse.
- **Tags (`!!`)**: Explicit type tags (e.g., `!!str`, `!!float`) are not supported. Type inference is performed automatically based on content.
- **Directives**: Directives like `%YAML 1.2` or `%TAG` are ignored or may cause parsing errors if not at the top of the file (where they might be skipped).

### 3. Data Types
- **Null Values**: `null`, `~`, and empty values are converted to empty MATLAB arrays (`[]`). MATLAB does not have a native `null` type distinct from empty.
- **Timestamps**: Timestamp detection is regex-based and limited. ISO 8601 subset is supported (`YYYY-MM-DD` etc.), but complex time zone handling or alternative formats may be treated as strings.
- **Multiline Strings**: 
    - Block scalars (`|` and `>`) are **not explicitly supported**. They may be parsed incorrectly or require manual handling.
    - Quoted strings can contain newlines if escaped properly, but unescaped newlines in quotes might break the line-based parser.

### 4. Comments
- **Preservation**: Comments (`#`) are stripped during parsing. They are **not preserved** when writing data back to YAML.

## Rationale for Design Choices

This toolbox prioritizes **portability**, **usability**, and **native integration** over full specification compliance.

1.  **Zero Dependencies (Pure MATLAB)**
    - *Why:* Full YAML compliance typically requires complex C/C++ libraries (`libyaml`) or Java bindings (`SnakeYAML`). These introduce installation headaches (compilers, Java version mismatches, classpath issues).
    - *Benefit:* This toolbox works out-of-the-box on any machine with MATLAB installed, with no setup.

2.  **Configuration over Serialization**
    - *Why:* The primary use case is reading `config.yaml` files for algorithms, hyperparameters, or simple app settings. These files rarely use anchors, complex keys, or multi-documents.
    - *Benefit:* A simpler parser is easier to maintain and faster for small, standard config files.

3.  **Readability Focus**
    - *Why:* We enforce Block Style by default in writing because it is more human-readable.
    - *Benefit:* Generated files are git-friendly (diffable) and easy for humans to edit.

## Suggestions for Users

1.  **Validation**: If you are generating YAML from another source that uses advanced features (like Kubernetes manifests with anchors), preprocessing might be required before reading with this tool.
2.  **Arrays**: Prefer Block Style lists (`- item`) for complex data structures. Use Flow Style (`[...]`) only for simple lists of scalars.
3.  **Strings**: Quote strings that contain special characters (like `:`, `#`, `[`, `]`) to ensure the parser handles them correctly. The `writeyaml` function does this automatically.

## Future Considerations

While full YAML 1.2 compliance is out of scope, the following features are candidates for future implementation if requested:
- Basic support for Block Strings (`|`) to handle multi-line text configuration.
- Improved warning system when encountering unsupported syntax (e.g., detecting `&` and warning that anchors are ignored).
