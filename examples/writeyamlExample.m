%[text] # WriteYAMLExample - Comprehensive guide to writing YAML files
%[text] This example demonstrates all formatting options available in writeyaml, showing how to control the appearance and style of your YAML output files.
%%
%[text] ## Setup: Create Sample Data
%[text] Create a sample YAMLData object for demonstrations
config = YAMLData();
config.name = "my-application";
config.version = "1.0.0";
config.debug = true;
config.ports = [8080, 8443, 9000];
config.hosts = ["localhost", "api.example.com", "db.example.com"];
config.database.host = "localhost";
config.database.port = 5432;
config.database.ssl = true;
%%
%[text] ## Basic Writing
%[text] Write YAML file with default settings (block style, loose spacing)
writeyaml(config, "output_default.yaml");
%[text] Default output (block style, loose spacing):
type("output_default.yaml") %[output:10489688]
%%
%[text] ## ArrayStyle Option
%[text] Control how arrays are formatted
%[text] Block style: multi-line with dashes (default)
%[text] Best for: better readability, traditional YAML style
writeyaml(config, "output_array_block.yaml", ArrayStyle="block");
%[text] Block style arrays (- item per line):
type("output_array_block.yaml") %[output:3407d27a]
%%
%[text] Flow style: inline arrays \[item1, item2, item3\]
%[text] Best for: compact output, short arrays
writeyaml(config, "output_array_flow.yaml", ArrayStyle="flow");
%[text] Flow style arrays (\[item1, item2, item3\]):
type("output_array_flow.yaml")
%%
%[text] ## SectionSpacing Option
%[text] Control spacing between top-level keys
%[text] Loose spacing: blank lines between sections (default)
%[text] Best for: better readability, separating major sections
writeyaml(config, "output_loose.yaml", SectionSpacing="loose");
%[text] Loose section spacing:
type("output_loose.yaml")
%%
%[text] Compact spacing: no blank lines
%[text] Best for: smaller files, minimalist style
writeyaml(config, "output_compact.yaml", SectionSpacing="compact");
%[text] Compact section spacing:
type("output_compact.yaml")
%%
%[text] ## NumIndentationSpaces Option
%[text] Control indentation depth for nested structures
%[text] Default: 2 spaces (standard YAML convention)
writeyaml(config, "output_indent_2.yaml", NumIndentationSpaces=2);
%[text] 2-space indentation (default):
type("output_indent_2.yaml")
%%
%[text] 4 spaces (common in some projects)
writeyaml(config, "output_indent_4.yaml", NumIndentationSpaces=4);
%[text] 4-space indentation:
type("output_indent_4.yaml")
%%
%[text] ## Precision Option
%[text] Control numeric precision for floating-point values
numericData = YAMLData();
numericData.pi = pi;
numericData.euler = exp(1);
numericData.values = [1.23456789, 2.34567890, 3.45678901];
%[text] Default: 6 decimal places
writeyaml(numericData, "output_precision_6.yaml", Precision=6);
%[text] 6 decimal places (default):
type("output_precision_6.yaml")
%%
%[text] High precision: 15 decimal places
writeyaml(numericData, "output_precision_15.yaml", Precision=15);
%[text] 15 decimal places:
type("output_precision_15.yaml")
%%
%[text] Low precision: 3 decimal places
writeyaml(numericData, "output_precision_3.yaml", Precision=3);
%[text] 3 decimal places:
type("output_precision_3.yaml")
%%
%[text] ## Writing Arrays of Mappings (GitHub Actions Style)
%[text] Create GitHub Actions workflow structure
workflow = YAMLData();
workflow.name = "CI";
workflow.on.push.branches = ["main", "develop"];
workflow.on.("pull_request").branches = ["main"];
%[text] Create array of step objects
workflow.jobs.build.("runs-on") = "ubuntu-latest";
workflow.jobs.build.steps(1).name = "Checkout";
workflow.jobs.build.steps(1).uses = "actions/checkout@v4";
workflow.jobs.build.steps(2).name = "Build";
workflow.jobs.build.steps(2).run = "make build";
workflow.jobs.build.steps(3).name = "Test";
workflow.jobs.build.steps(3).run = "make test";
%[text] Write with block style (best for workflows)
writeyaml(workflow, "github_workflow.yaml", ...
    ArrayStyle="block", ...
    SectionSpacing="loose", ...
    NumIndentationSpaces=2);
%[text] GitHub Actions workflow:
type("github_workflow.yaml")
%%
%[text] ## Working with Special Characters in Keys
%[text] Demonstrate handling of keys with hyphens, dots, and spaces
specialKeys = YAMLData();
specialKeys.("app-name") = "MyApp";
specialKeys.("build-version") = "2.0.0";
specialKeys.("max-connections") = 100;
specialKeys.simple_key = "value";
writeyaml(specialKeys, "special_keys.yaml");
%[text] Keys with special characters:
type("special_keys.yaml")
%%
%[text] ## Docker Compose Style Configuration
%[text] Create a Docker Compose-style YAML configuration
dockerCompose = YAMLData();
dockerCompose.version = "3.8";
dockerCompose.services.web.image = "nginx:latest";
dockerCompose.services.web.ports = ["8080:80", "8443:443"];
dockerCompose.services.web.environment = ["NGINX_HOST=example.com", "NGINX_PORT=80"];
dockerCompose.services.db.image = "postgres:15";
dockerCompose.services.db.ports = ["5432:5432"];
dockerCompose.services.db.environment = ["POSTGRES_PASSWORD=secret", "POSTGRES_DB=myapp"];
%[text] Write with block style and loose spacing
writeyaml(dockerCompose, "docker-compose.yaml", ...
    ArrayStyle="block", ...
    SectionSpacing="loose", ...
    NumIndentationSpaces=2);
%[text] Docker Compose configuration:
type("docker-compose.yaml")
%%
%[text] ## Combining Options for Different Styles
%[text] GitHub Actions style: block arrays, 2-space indent, loose spacing
writeyaml(workflow, "style_github.yaml", ...
    ArrayStyle="block", ...
    NumIndentationSpaces=2, ...
    SectionSpacing="loose");
%[text] GitHub Actions style:
type("style_github.yaml")
%%
%[text] Compact minimalist style: flow arrays, compact spacing
writeyaml(config, "style_minimal.yaml", ...
    ArrayStyle="flow", ...
    SectionSpacing="compact");
%[text] Compact minimalist style:
type("style_minimal.yaml")
%%
%[text] Traditional YAML style: block arrays, 4-space indent
writeyaml(config, "style_traditional.yaml", ...
    ArrayStyle="block", ...
    NumIndentationSpaces=4, ...
    SectionSpacing="loose");
%[text] Traditional YAML style:
type("style_traditional.yaml")
%%
%[text] ## Writing Different Data Types
%[text] Demonstrate how different MATLAB types are converted to YAML
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
%[text] Various data types:
type("data_types.yaml")
%%
%[text] ## Nested Structures with Mixed Arrays
%[text] Create complex nested configuration
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
%[text] Complex nested configuration:
type("complex_config.yaml")
%%
%[text] ## Round-Trip: Read, Modify, Write
%[text] Demonstrate reading, modifying, and writing back
%[text] Create initial config
original = YAMLData();
original.server.host = "localhost";
original.server.port = 8080;
original.features = ["feature1", "feature2"];
writeyaml(original, "original_config.yaml");
%[text] Original configuration:
type("original_config.yaml")
%%
%[text] Read it back
modified = readyaml("original_config.yaml");
%[text] Modify values
modified.server.port = 9000;
modified.server.ssl = true;
modified.features = [modified.features; "feature3"];
%[text] Write back with same formatting
writeyaml(modified, "modified_config.yaml", ArrayStyle="block");
%[text] Modified configuration:
type("modified_config.yaml")
%%
%[text] ## Writing Default Filename
%[text] When no filename is provided, writes to 'untitled.yaml'
tempData = YAMLData();
tempData.test = "value";
writeyaml(tempData);
%[text] Default filename (untitled.yaml):
type("untitled.yaml")
%%
%[text] ## Best Practices
%[text] Best practices for writing YAML files:
%[text] GitHub Actions workflows:
%[text]   ArrayStyle='block', NumIndentationSpaces=2, SectionSpacing='loose'
%[text] Docker Compose files:
%[text]   ArrayStyle='block', NumIndentationSpaces=2, SectionSpacing='loose'
%[text] Compact configuration files:
%[text]   ArrayStyle='flow', SectionSpacing='compact'
%[text] Traditional YAML documents:
%[text]   ArrayStyle='block', NumIndentationSpaces=4, SectionSpacing='loose'
%[text] When to use flow vs block arrays:
%[text] -  - Flow: short arrays, compact output (ports: \[80, 443\])
%[text] -  - Block: better readability, long arrays, traditional style\\ \
%%
%[text] ## Cleanup
%[text] Delete temporary output files
delete("output_default.yaml", "output_array_block.yaml", "output_array_flow.yaml", ...
    "output_loose.yaml", "output_compact.yaml", ...
    "output_indent_2.yaml", "output_indent_4.yaml", ...
    "output_precision_6.yaml", "output_precision_15.yaml", "output_precision_3.yaml", ...
    "github_workflow.yaml", "special_keys.yaml", "docker-compose.yaml", ...
    "style_github.yaml", "style_minimal.yaml", "style_traditional.yaml", ...
    "data_types.yaml", "complex_config.yaml", ...
    "original_config.yaml", "modified_config.yaml", "untitled.yaml");

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
%[output:10489688]
%   data: {"dataType":"text","outputData":{"text":"\nname: my-application\n\nversion: 1.0.0\n\ndebug: true\n\nports:\n  - 8080\n  - 8443\n  - 9000\n\nhosts:\n  - localhost\n  - api.example.com\n  - db.example.com\n\ndatabase:\n  host: localhost\n  port: 5432\n  ssl: true\n","truncated":false}}
%---
%[output:3407d27a]
%   data: {"dataType":"text","outputData":{"text":"\nname: my-application\n\nversion: 1.0.0\n\ndebug: true\n\nports:\n  - 8080\n  - 8443\n  - 9000\n\nhosts:\n  - localhost\n  - api.example.com\n  - db.example.com\n\ndatabase:\n  host: localhost\n  port: 5432\n  ssl: true\n","truncated":false}}
%---
