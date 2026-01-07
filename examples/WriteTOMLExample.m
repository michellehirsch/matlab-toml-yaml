%% WriteTOMLExample - Comprehensive guide to TOML writing and formatting
% This example demonstrates all formatting options available in writetoml,
% showing how to control the appearance and style of your TOML output files.

%% Setup: Create Sample Data
% Create a sample TOMLData object for our demonstrations
project = TOMLData();
project.name = "my-package";
project.version = "1.0.0";
project.description = "A demonstration project";
project.authors = ["Alice <alice@example.com>", "Bob <bob@example.com>"];
project.dependencies = ["numpy>=1.20", "pandas>=1.3", "matplotlib>=3.4"];
project.paths.data = 'C:\Users\Data';
project.paths.output = 'C:\Users\Output';

%% Basic Writing
% Write TOML file with default settings
writetoml(project, "output_default.toml");
disp("Default output:")
type("output_default.toml")

%% ArrayStyle Option
% Control how arrays are formatted

% Flow style: inline arrays [item1, item2, item3]
% Best for: short arrays, compact output
writetoml(project, "output_array_flow.toml", ArrayStyle="flow");
disp("Flow style arrays:")
type("output_array_flow.toml")

%%
% Block style: multi-line arrays with one item per line
% Best for: long arrays, better readability for many items
writetoml(project, "output_array_block.toml", ArrayStyle="block");
disp("Block style arrays:")
type("output_array_block.toml")

%% SectionSpacing Option
% Control spacing between top-level tables

% Loose spacing: blank lines between sections (default)
% Best for: better readability in complex files
writetoml(project, "output_loose.toml", SectionSpacing="loose");
disp("Loose section spacing:")
type("output_loose.toml")

%%
% Compact spacing: no blank lines between sections
% Best for: smaller files, minimalist style
writetoml(project, "output_compact.toml", SectionSpacing="compact");
disp("Compact section spacing:")
type("output_compact.toml")

%% StringEscapeStyle Option
% Control how strings with special characters are formatted

% Auto: automatically choose based on content (default)
% Literal strings for paths with backslashes, escaped for others
writetoml(project, "output_string_auto.toml", StringEscapeStyle="auto");
disp("Auto string escape style (paths use literal strings):")
type("output_string_auto.toml")

%%
% Literal: use single quotes, no escape processing
% Best for: Windows paths, regex patterns, strings with backslashes
writetoml(project, "output_string_literal.toml", StringEscapeStyle="literal");
disp("Literal strings (single quotes, no escape processing):")
type("output_string_literal.toml")

%%
% Escaped: use double quotes with escape sequences
% Best for: strings that need escape processing
project2 = TOMLData();
project2.message = sprintf("Line 1\nLine 2\tTabbed");
project2.path = 'C:\Users\Data';
writetoml(project2, "output_string_escaped.toml", StringEscapeStyle="escaped");
disp("Escaped strings (double quotes with \n, \t, etc.):")
type("output_string_escaped.toml")

%% StringLayout Option
% Control single-line vs multi-line string formatting

% Auto: use multiline for strings with newlines (default)
project3 = TOMLData();
project3.shortText = "Single line text";
project3.longText = sprintf("This is a long text\nwith multiple lines\nfor demonstration");
writetoml(project3, "output_layout_auto.toml", StringLayout="auto");
disp("Auto string layout:")
type("output_layout_auto.toml")

%%
% Singleline: always use single-line strings
writetoml(project3, "output_layout_single.toml", StringLayout="singleline");
disp("Single-line strings only:")
type("output_layout_single.toml")

%%
% Multiline: use multiline delimiters
writetoml(project3, "output_layout_multi.toml", StringLayout="multiline");
disp("Multiline strings:")
type("output_layout_multi.toml")

%% NumIndentationSpaces Option
% Control indentation for block-style arrays

% Default: 2 spaces
writetoml(project, "output_indent_2.toml", ArrayStyle="block", NumIndentationSpaces=2);
disp("2-space indentation:")
type("output_indent_2.toml")

%%
% 4 spaces (common in Python projects)
writetoml(project, "output_indent_4.toml", ArrayStyle="block", NumIndentationSpaces=4);
disp("4-space indentation:")
type("output_indent_4.toml")

%% Precision Option
% Control numeric precision for floating-point values

data = TOMLData();
data.pi = pi;
data.euler = exp(1);
data.values = [1.23456789, 2.34567890, 3.45678901];

% Default: 6 significant digits
writetoml(data, "output_precision_6.toml", Precision=6);
disp("6 digits precision (default):")
type("output_precision_6.toml")

%%
% High precision: 15 digits
writetoml(data, "output_precision_15.toml", Precision=15);
disp("15 digits precision:")
type("output_precision_15.toml")

%%
% Low precision: 3 digits
writetoml(data, "output_precision_3.toml", Precision=3);
disp("3 digits precision:")
type("output_precision_3.toml")

%% TableArrayStyle Option
% Control formatting of arrays of tables (common in configuration files)

% Create data with array of tables
config = TOMLData();
config.steps(1).name = "Checkout";
config.steps(1).uses = "actions/checkout@v4";
config.steps(2).name = "Build";
config.steps(2).run = "make build";
config.steps(3).name = "Test";
config.steps(3).run = "make test";

% Expanded: use [[table]] syntax (default, most readable)
% Best for: GitHub Actions, complex configurations
writetoml(config, "output_tablearray_expanded.toml", TableArrayStyle="expanded");
disp("Expanded table arrays ([[table]] syntax):")
type("output_tablearray_expanded.toml")

%%
% Inline: use array of inline tables [{x=1}, {x=2}]
% Best for: simple, short tables
config2 = TOMLData();
config2.points(1).x = 1;
config2.points(1).y = 2;
config2.points(2).x = 3;
config2.points(2).y = 4;
writetoml(config2, "output_tablearray_inline.toml", TableArrayStyle="inline");
disp("Inline table arrays:")
type("output_tablearray_inline.toml")

%%
% Auto: choose based on complexity
writetoml(config2, "output_tablearray_auto.toml", TableArrayStyle="auto");
disp("Auto table arrays (uses heuristics):")
type("output_tablearray_auto.toml")

%% Combining Options
% Combine multiple options for custom formatting

% Python project style: block arrays, 4-space indent, loose spacing
writetoml(project, "pyproject.toml", ...
    ArrayStyle="block", ...
    NumIndentationSpaces=4, ...
    SectionSpacing="loose", ...
    StringEscapeStyle="auto");
disp("Python project style (pyproject.toml):")
type("pyproject.toml")

%%
% Compact minimalist style
writetoml(project, "config_minimal.toml", ...
    ArrayStyle="flow", ...
    SectionSpacing="compact", ...
    StringEscapeStyle="literal");
disp("Compact minimalist style:")
type("config_minimal.toml")

%%
% GitHub Actions style
writetoml(config, "workflow.toml", ...
    ArrayStyle="block", ...
    TableArrayStyle="expanded", ...
    SectionSpacing="loose", ...
    NumIndentationSpaces=2);
disp("GitHub Actions style:")
type("workflow.toml")

%% Working with Special Characters
% Demonstrate handling of keys with special characters

special = TOMLData();
special.("simple-key") = "value1";
special.("another.key") = "value2";  % Quoted key with dot
special.("with spaces") = "value3";
special.normal_key = "value4";

writetoml(special, "output_special_keys.toml");
disp("Keys with special characters:")
type("output_special_keys.toml")

%% Best Practices
% Recommended settings for common use cases

disp("Recommended settings by use case:")
disp("  ")
disp("Python projects (pyproject.toml):")
disp("  ArrayStyle='block', NumIndentationSpaces=4, SectionSpacing='loose'")
disp("  ")
disp("GitHub Actions workflows:")
disp("  ArrayStyle='block', TableArrayStyle='expanded', SectionSpacing='loose'")
disp("  ")
disp("Compact configuration files:")
disp("  ArrayStyle='flow', SectionSpacing='compact'")
disp("  ")
disp("Windows path handling:")
disp("  StringEscapeStyle='literal' (avoids double-backslash escaping)")
disp("  ")

%% Cleanup
% Delete temporary output files
delete("output_default.toml", "output_array_flow.toml", "output_array_block.toml", ...
    "output_loose.toml", "output_compact.toml", "output_string_auto.toml", ...
    "output_string_literal.toml", "output_string_escaped.toml", ...
    "output_layout_auto.toml", "output_layout_single.toml", "output_layout_multi.toml", ...
    "output_indent_2.toml", "output_indent_4.toml", ...
    "output_precision_6.toml", "output_precision_15.toml", "output_precision_3.toml", ...
    "output_tablearray_expanded.toml", "output_tablearray_inline.toml", ...
    "output_tablearray_auto.toml", "pyproject.toml", "config_minimal.toml", ...
    "workflow.toml", "output_special_keys.toml");
