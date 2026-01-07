%% WriteYAMLExample - Comprehensive guide to writing YAML files
% This example demonstrates all formatting options available in writeyaml,
% showing how to control the appearance and style of your YAML output files.

%% Setup: Create Sample Data
% Create a sample YAMLData object for demonstrations
config = YAMLData();
config.name = "my-application";
config.version = "1.0.0";
config.debug = true;
config.ports = [8080, 8443, 9000];
config.hosts = ["localhost", "api.example.com", "db.example.com"];
config.database.host = "localhost";
config.database.port = 5432;
config.database.ssl = true;

%% Basic Writing
% Write YAML file with default settings (block style, loose spacing)
writeyaml(config, "output_default.yaml");
disp("Default output (block style, loose spacing):")
type("output_default.yaml")

%% ArrayStyle Option
% Control how arrays are formatted

% Block style: multi-line with dashes (default)
% Best for: better readability, traditional YAML style
writeyaml(config, "output_array_block.yaml", ArrayStyle="block");
disp("Block style arrays (- item per line):")
type("output_array_block.yaml")

%%
% Flow style: inline arrays [item1, item2, item3]
% Best for: compact output, short arrays
writeyaml(config, "output_array_flow.yaml", ArrayStyle="flow");
disp("Flow style arrays ([item1, item2, item3]):")
type("output_array_flow.yaml")

%% SectionSpacing Option
% Control spacing between top-level keys

% Loose spacing: blank lines between sections (default)
% Best for: better readability, separating major sections
writeyaml(config, "output_loose.yaml", SectionSpacing="loose");
disp("Loose section spacing:")
type("output_loose.yaml")

%%
% Compact spacing: no blank lines
% Best for: smaller files, minimalist style
writeyaml(config, "output_compact.yaml", SectionSpacing="compact");
disp("Compact section spacing:")
type("output_compact.yaml")

%% NumIndentationSpaces Option
% Control indentation depth for nested structures

% Default: 2 spaces (standard YAML convention)
writeyaml(config, "output_indent_2.yaml", NumIndentationSpaces=2);
disp("2-space indentation (default):")
type("output_indent_2.yaml")

%%
% 4 spaces (common in some projects)
writeyaml(config, "output_indent_4.yaml", NumIndentationSpaces=4);
disp("4-space indentation:")
type("output_indent_4.yaml")

%% Precision Option
% Control numeric precision for floating-point values

numericData = YAMLData();
numericData.pi = pi;
numericData.euler = exp(1);
numericData.values = [1.23456789, 2.34567890, 3.45678901];

% Default: 6 decimal places
writeyaml(numericData, "output_precision_6.yaml", Precision=6);
disp("6 decimal places (default):")
type("output_precision_6.yaml")

%%
% High precision: 15 decimal places
writeyaml(numericData, "output_precision_15.yaml", Precision=15);
disp("15 decimal places:")
type("output_precision_15.yaml")

%%
% Low precision: 3 decimal places
writeyaml(numericData, "output_precision_3.yaml", Precision=3);
disp("3 decimal places:")
type("output_precision_3.yaml")

%% Writing Arrays of Mappings (GitHub Actions Style)
% Create GitHub Actions workflow structure

workflow = YAMLData();
workflow.name = "CI";
workflow.on.push.branches = ["main", "develop"];
workflow.on.("pull_request").branches = ["main"];

% Create array of step objects
workflow.jobs.build.("runs-on") = "ubuntu-latest";
workflow.jobs.build.steps(1).name = "Checkout";
workflow.jobs.build.steps(1).uses = "actions/checkout@v4";
workflow.jobs.build.steps(2).name = "Build";
workflow.jobs.build.steps(2).run = "make build";
workflow.jobs.build.steps(3).name = "Test";
workflow.jobs.build.steps(3).run = "make test";

% Write with block style (best for workflows)
writeyaml(workflow, "github_workflow.yaml", ...
    ArrayStyle="block", ...
    SectionSpacing="loose", ...
    NumIndentationSpaces=2);
disp("GitHub Actions workflow:")
type("github_workflow.yaml")

%% Working with Special Characters in Keys
% Demonstrate handling of keys with hyphens, dots, and spaces

specialKeys = YAMLData();
specialKeys.("app-name") = "MyApp";
specialKeys.("build-version") = "2.0.0";
specialKeys.("max-connections") = 100;
specialKeys.simple_key = "value";

writeyaml(specialKeys, "special_keys.yaml");
disp("Keys with special characters:")
type("special_keys.yaml")

%% Docker Compose Style Configuration
% Create a Docker Compose-style YAML configuration

dockerCompose = YAMLData();
dockerCompose.version = "3.8";

dockerCompose.services.web.image = "nginx:latest";
dockerCompose.services.web.ports = ["8080:80", "8443:443"];
dockerCompose.services.web.environment = ["NGINX_HOST=example.com", "NGINX_PORT=80"];

dockerCompose.services.db.image = "postgres:15";
dockerCompose.services.db.ports = ["5432:5432"];
dockerCompose.services.db.environment = ["POSTGRES_PASSWORD=secret", "POSTGRES_DB=myapp"];

% Write with block style and loose spacing
writeyaml(dockerCompose, "docker-compose.yaml", ...
    ArrayStyle="block", ...
    SectionSpacing="loose", ...
    NumIndentationSpaces=2);
disp("Docker Compose configuration:")
type("docker-compose.yaml")

%% Combining Options for Different Styles

% GitHub Actions style: block arrays, 2-space indent, loose spacing
writeyaml(workflow, "style_github.yaml", ...
    ArrayStyle="block", ...
    NumIndentationSpaces=2, ...
    SectionSpacing="loose");
disp("GitHub Actions style:")
type("style_github.yaml")

%%
% Compact minimalist style: flow arrays, compact spacing
writeyaml(config, "style_minimal.yaml", ...
    ArrayStyle="flow", ...
    SectionSpacing="compact");
disp("Compact minimalist style:")
type("style_minimal.yaml")

%%
% Traditional YAML style: block arrays, 4-space indent
writeyaml(config, "style_traditional.yaml", ...
    ArrayStyle="block", ...
    NumIndentationSpaces=4, ...
    SectionSpacing="loose");
disp("Traditional YAML style:")
type("style_traditional.yaml")

%% Writing Different Data Types
% Demonstrate how different MATLAB types are converted to YAML

dataTypes = YAMLData();
dataTypes.string = "Hello, World!";
dataTypes.number = 42;
dataTypes.float = 3.14159;
dataTypes.boolean_true = true;
dataTypes.boolean_false = false;
dataTypes.numeric_array = [1, 2, 3, 4, 5];
dataTypes.string_array = ["apple", "banana", "cherry"];
dataTypes.empty = [];

writeyaml(dataTypes, "data_types.yaml", ArrayStyle="flow");
disp("Various data types:")
type("data_types.yaml")

%% Nested Structures with Mixed Arrays
% Create complex nested configuration

complexConfig = YAMLData();
complexConfig.application.name = "ComplexApp";
complexConfig.application.version = "2.0.0";

complexConfig.server.host = "localhost";
complexConfig.server.port = 8080;
complexConfig.server.ssl.enabled = true;
complexConfig.server.ssl.certificate = "/path/to/cert.pem";

complexConfig.logging.level = "info";
complexConfig.logging.outputs = ["console", "file", "syslog"];

complexConfig.features.authentication = true;
complexConfig.features.caching = true;
complexConfig.features.("rate-limiting") = false;

writeyaml(complexConfig, "complex_config.yaml", ...
    ArrayStyle="block", ...
    SectionSpacing="loose");
disp("Complex nested configuration:")
type("complex_config.yaml")

%% Round-Trip: Read, Modify, Write
% Demonstrate reading, modifying, and writing back

% Create initial config
original = YAMLData();
original.server.host = "localhost";
original.server.port = 8080;
original.features = ["feature1", "feature2"];

writeyaml(original, "original_config.yaml");
disp("Original configuration:")
type("original_config.yaml")

%%
% Read it back
modified = readyaml("original_config.yaml");

% Modify values
modified.server.port = 9000;
modified.server.ssl = true;
modified.features = [modified.features; "feature3"];

% Write back with same formatting
writeyaml(modified, "modified_config.yaml", ArrayStyle="block");
disp("Modified configuration:")
type("modified_config.yaml")

%% Writing Default Filename
% When no filename is provided, writes to 'untitled.yaml'

tempData = YAMLData();
tempData.test = "value";

writeyaml(tempData);
disp("Default filename (untitled.yaml):")
type("untitled.yaml")

%% Best Practices
disp("Best practices for writing YAML files:")
disp("  ")
disp("GitHub Actions workflows:")
disp("  ArrayStyle='block', NumIndentationSpaces=2, SectionSpacing='loose'")
disp("  ")
disp("Docker Compose files:")
disp("  ArrayStyle='block', NumIndentationSpaces=2, SectionSpacing='loose'")
disp("  ")
disp("Compact configuration files:")
disp("  ArrayStyle='flow', SectionSpacing='compact'")
disp("  ")
disp("Traditional YAML documents:")
disp("  ArrayStyle='block', NumIndentationSpaces=4, SectionSpacing='loose'")
disp("  ")
disp("When to use flow vs block arrays:")
disp("  - Flow: short arrays, compact output (ports: [80, 443])")
disp("  - Block: better readability, long arrays, traditional style")
disp("  ")

%% Cleanup
% Delete temporary output files
delete("output_default.yaml", "output_array_block.yaml", "output_array_flow.yaml", ...
    "output_loose.yaml", "output_compact.yaml", ...
    "output_indent_2.yaml", "output_indent_4.yaml", ...
    "output_precision_6.yaml", "output_precision_15.yaml", "output_precision_3.yaml", ...
    "github_workflow.yaml", "special_keys.yaml", "docker-compose.yaml", ...
    "style_github.yaml", "style_minimal.yaml", "style_traditional.yaml", ...
    "data_types.yaml", "complex_config.yaml", ...
    "original_config.yaml", "modified_config.yaml", "untitled.yaml");
