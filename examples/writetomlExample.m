%[text] # WriteTOMLExample - Comprehensive guide to writing TOML files
%[text] This example demonstrates all formatting options available in writetoml, showing how to control the appearance and style of your TOML output files.
%%
%[text] ## Setup: Create Sample Data
%[text] Create a sample TOMLData object for our demonstrations.
project = TOMLData();
project.name = "my-package";
project.version = "1.0.0";
project.description = "A demonstration project";
project.authors = ["Alice <alice@example.com>", "Bob <bob@example.com>"];
project.dependencies = ["numpy>=1.20", "pandas>=1.3", "matplotlib>=3.4"];
project.paths.data = "C:\Users\Data";
project.paths.output = "C:\Users\Output";
%%
%[text] ## Basic Writing
%[text] Write TOML file with default settings.
writetoml(project, "output_default.toml");
type("output_default.toml")
%%
%[text] ## ArrayStyle Option - Flow
%[text] Control how arrays are formatted. Flow style uses inline arrays `[item1, item2, item3]`. Best for short arrays and compact output.
writetoml(project, "output_array_flow.toml", ArrayStyle="flow");
type("output_array_flow.toml")
%%
%[text] ## ArrayStyle Option - Block
%[text] Block style uses multi-line arrays with one item per line. Best for long arrays and better readability.
writetoml(project, "output_array_block.toml", ArrayStyle="block");
type("output_array_block.toml")
%%
%[text] ## SectionSpacing Option - Loose
%[text] Control spacing between top-level tables. Loose spacing adds blank lines between sections (default). Best for better readability in complex files.
writetoml(project, "output_loose.toml", SectionSpacing="loose");
type("output_loose.toml")
%%
%[text] ## SectionSpacing Option - Compact
%[text] Compact spacing removes blank lines between sections. Best for smaller files and minimalist style.
writetoml(project, "output_compact.toml", SectionSpacing="compact");
type("output_compact.toml")
%%
%[text] ## StringEscapeStyle Option - Auto
%[text] Control how strings with special characters are formatted. Auto mode automatically chooses based on content (default), using literal strings for paths with backslashes.
writetoml(project, "output_string_auto.toml", StringEscapeStyle="auto");
type("output_string_auto.toml")
%%
%[text] ## StringEscapeStyle Option - Literal
%[text] Literal mode uses single quotes with no escape processing. Best for Windows paths, regex patterns, and strings with backslashes.
writetoml(project, "output_string_literal.toml", StringEscapeStyle="literal");
type("output_string_literal.toml")
%%
%[text] ## StringEscapeStyle Option - Escaped
%[text] Escaped mode uses double quotes with escape sequences. Best for strings that need escape processing.
project2 = TOMLData();
project2.message = sprintf("Line 1\nLine 2\tTabbed");
project2.path = "C:\Users\Data";
writetoml(project2, "output_string_escaped.toml", StringEscapeStyle="escaped");
type("output_string_escaped.toml")
%%
%[text] ## StringLayout Option - Auto
%[text] Control single-line vs multi-line string formatting. Auto mode uses multiline for strings with newlines (default).
project3 = TOMLData();
project3.shortText = "Single line text";
project3.longText = sprintf("This is a long text\nwith multiple lines\nfor demonstration");
writetoml(project3, "output_layout_auto.toml", StringLayout="auto");
type("output_layout_auto.toml")
%%
%[text] ## StringLayout Option - Singleline
%[text] Singleline mode always uses single-line strings.
writetoml(project3, "output_layout_single.toml", StringLayout="singleline");
type("output_layout_single.toml")
%%
%[text] ## StringLayout Option - Multiline
%[text] Multiline mode uses multiline delimiters.
writetoml(project3, "output_layout_multi.toml", StringLayout="multiline");
type("output_layout_multi.toml")
%%
%[text] ## NumIndentationSpaces Option - 2 Spaces
%[text] Control indentation for block-style arrays. Default is 2 spaces.
writetoml(project, "output_indent_2.toml", ArrayStyle="block", NumIndentationSpaces=2);
type("output_indent_2.toml")
%%
%[text] ## NumIndentationSpaces Option - 4 Spaces
%[text] 4 spaces is common in Python projects.
writetoml(project, "output_indent_4.toml", ArrayStyle="block", NumIndentationSpaces=4);
type("output_indent_4.toml")
%%
%[text] ## Precision Option - 6 Digits
%[text] Control numeric precision for floating-point values. Default is 6 significant digits.
data = TOMLData();
data.pi = pi;
data.euler = exp(1);
data.values = [1.23456789, 2.34567890, 3.45678901];
writetoml(data, "output_precision_6.toml", Precision=6);
type("output_precision_6.toml")
%%
%[text] ## Precision Option - 15 Digits
%[text] High precision with 15 digits.
writetoml(data, "output_precision_15.toml", Precision=15);
type("output_precision_15.toml")
%%
%[text] ## Precision Option - 3 Digits
%[text] Low precision with 3 digits.
writetoml(data, "output_precision_3.toml", Precision=3);
type("output_precision_3.toml")
%%
%[text] ## TableArrayStyle Option - Expanded
%[text] Control formatting of arrays of tables. Expanded mode uses `[[table]]` syntax (default, most readable). Best for GitHub Actions and complex configurations.
config = TOMLData();
step1 = TOMLData();
step1.name = "Checkout";
step1.uses = "actions/checkout@v4";
step2 = TOMLData();
step2.name = "Build";
step2.run = "make build";
step3 = TOMLData();
step3.name = "Test";
step3.run = "make test";
config.steps = [step1; step2; step3];
writetoml(config, "output_tablearray_expanded.toml", TableArrayStyle="expanded");
type("output_tablearray_expanded.toml")
%%
%[text] ## TableArrayStyle Option - Inline
%[text] Inline mode uses array of inline tables `[{x=1}, {x=2}]`. Best for simple, short tables.
config2 = TOMLData();
point1 = TOMLData();
point1.x = 1;
point1.y = 2;
point2 = TOMLData();
point2.x = 3;
point2.y = 4;
config2.points = [point1; point2];
writetoml(config2, "output_tablearray_inline.toml", TableArrayStyle="inline");
type("output_tablearray_inline.toml")
%%
%[text] ## TableArrayStyle Option - Auto
%[text] Auto mode chooses based on complexity using heuristics.
writetoml(config2, "output_tablearray_auto.toml", TableArrayStyle="auto");
type("output_tablearray_auto.toml")
%%
%[text] ## Combining Options - Python Project Style
%[text] Combine multiple options for custom formatting. Python project style uses block arrays, 4-space indent, and loose spacing.
writetoml(project, "pyproject.toml", ...
    ArrayStyle="block", ...
    NumIndentationSpaces=4, ...
    SectionSpacing="loose", ...
    StringEscapeStyle="auto");
type("pyproject.toml")
%%
%[text] ## Combining Options - Compact Minimalist Style
%[text] Compact minimalist style uses flow arrays, compact spacing, and literal strings.
writetoml(project, "config_minimal.toml", ...
    ArrayStyle="flow", ...
    SectionSpacing="compact", ...
    StringEscapeStyle="literal");
type("config_minimal.toml")
%%
%[text] ## Combining Options - GitHub Actions Style
%[text] GitHub Actions style uses block arrays, expanded table arrays, loose spacing, and 2-space indentation.
writetoml(config, "workflow.toml", ...
    ArrayStyle="block", ...
    TableArrayStyle="expanded", ...
    SectionSpacing="loose", ...
    NumIndentationSpaces=2);
type("workflow.toml")
%%
%[text] ## Working with Special Characters
%[text] Demonstrate handling of keys with special characters including hyphens, dots, and spaces.
special = TOMLData();
special.("simple-key") = "value1";
special.("another.key") = "value2";
special.("with spaces") = "value3";
special.normal_key = "value4";
writetoml(special, "output_special_keys.toml");
type("output_special_keys.toml")
%%
%[text] ## Best Practices
%[text] Recommended settings by use case:
%[text] - **Python projects (pyproject.toml)**: `ArrayStyle="block"`, `NumIndentationSpaces=4`, `SectionSpacing="loose"`
%[text] - **GitHub Actions workflows**: `ArrayStyle="block"`, `TableArrayStyle="expanded"`, `SectionSpacing="loose"`
%[text] - **Compact configuration files**: `ArrayStyle="flow"`, `SectionSpacing="compact"`
%[text] - **Windows path handling**: `StringEscapeStyle="literal"` (avoids double-backslash escaping) \
%%
%[text] ## Cleanup
%[text] Delete temporary output files.
delete("output_default.toml", "output_array_flow.toml", "output_array_block.toml", ...
    "output_loose.toml", "output_compact.toml", "output_string_auto.toml", ...
    "output_string_literal.toml", "output_string_escaped.toml", ...
    "output_layout_auto.toml", "output_layout_single.toml", "output_layout_multi.toml", ...
    "output_indent_2.toml", "output_indent_4.toml", ...
    "output_precision_6.toml", "output_precision_15.toml", "output_precision_3.toml", ...
    "output_tablearray_expanded.toml", "output_tablearray_inline.toml", ...
    "output_tablearray_auto.toml", "pyproject.toml", "config_minimal.toml", ...
    "workflow.toml", "output_special_keys.toml");
%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
