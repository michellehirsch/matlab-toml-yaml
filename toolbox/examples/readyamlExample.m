%[text] # ReadYAMLExample - Comprehensive guide to reading YAML files
%[text] This example demonstrates readyaml functionality, showing how to work with YAML configuration files, handle different array types, use the SequenceRule option, and work with GitHub Actions-style configurations.
%%
%[text] ## Basic YAML Reading
%[text] Read a simple YAML file and access its contents
%[text] Create a sample YAML file
yamlContent = [
    "app-name: MyApplication"
    "version: 1.2.0"
    "port: 8080"
    "debug: true"];
writelines(yamlContent,"basic_config.yaml");
%[text] Read the YAML file
config = readyaml("basic_config.yaml");
%[text] YAMLData object:
config
%%
%[text] Access values using dot notation
config.("app-name")
%%
%[text] ## Nested YAML Structures
%[text] YAML supports nested mappings (dictionaries)
yamlNested = [
    "database:"
    "  host: localhost"
    "  port: 5432"
    "  credentials:"
    "    username: admin"
    "    password: secret"];
writelines(yamlNested,"nested_config.yaml");
dbConfig = readyaml("nested_config.yaml");
%[text] Navigate nested structures
dbConfig.database.credentials.username
%%
%[text] ## YAML Arrays - Flow Style
%[text] Flow-style arrays use \[item1, item2, item3\] syntax
yamlFlowArrays = [
    "ports: [8080, 8443, 9000]"
    "hosts: [localhost, api.example.com, db.example.com]"];
writelines(yamlFlowArrays,"flow_arrays.yaml");
flowData = readyaml("flow_arrays.yaml");
%[text] Arrays are converted to MATLAB arrays based on type
flowData.ports
%%
%[text] ## YAML Arrays - Block Style
%[text] Block-style arrays use dash notation
yamlBlockArrays = [
    "ports:"
    "  - 8080"
    "  - 8443"
    "  - 9000"
    "hosts:"
    "  - localhost"
    "  - api.example.com"
    "  - db.example.com"];
writelines(yamlBlockArrays,"block_arrays.yaml");
blockData = readyaml("block_arrays.yaml");
%[text] Block-style arrays work the same as flow-style
blockData.ports %[output:7d48cbf4]
%%
%[text] ## Mixed-Type Arrays
%[text] Arrays with mixed types become cell arrays
yamlMixed = [
    "mixed:"
    "  - 42"
    "  - ""text"""
    "  - true"
    "  - 3.14"];
writelines(yamlMixed,"mixed_array.yaml");
mixedData = readyaml("mixed_array.yaml");
%[text] Mixed-type arrays become cell arrays
mixedData.mixed %[output:9e77c6aa]
%%
%[text] ## SequenceRule Option - Auto vs Cell
%[text] Control how arrays are converted
yamlArrayTypes = [
    "numbers: [1, 2, 3]"
    "strings: [apple, banana, cherry]"
    "single: [value]"];
writelines(yamlArrayTypes,"array_types.yaml");
%[text] Default: SequenceRule="auto" - use specialized arrays when possible
autoData = readyaml("array_types.yaml");
%[text] With SequenceRule="auto" (default):
autoData.numbers
%%
%[text] SequenceRule="cell" - always use cell arrays for consistency
cellData = readyaml("array_types.yaml", SequenceRule="cell");
%[text] With SequenceRule="cell":
cellData.numbers
%%
%[text] Why use SequenceRule="cell"?
%[text] Use SequenceRule='cell' when:
%[text] - You need consistent types regardless of content
%[text] - A file might change from single value to multiple values
%[text] - You want predictable behavior for dynamic configurations\\ \
%%
%[text] ## Sequence of Mappings - GitHub Actions Style
%[text] Arrays where each item is a mapping (dictionary)
yamlSteps = [
    "steps:"
    "  - name: Checkout"
    "    uses: actions/checkout@v4"
    "  - name: Setup MATLAB"
    "    uses: matlab-actions/setup-matlab@v2"
    "  - name: Run tests"
    "    uses: matlab-actions/run-tests@v2"];
writelines(yamlSteps,"workflow_steps.yaml");
workflow = readyaml("workflow_steps.yaml");
%[text] Access array of mappings with indexing
%[text] GitHub Actions workflow steps:
for i = 1:numel(workflow.steps)
    fprintf("Step %d: %s\n", i, workflow.steps(i).name);
    fprintf("  Uses: %s\n", workflow.steps(i).uses);
end
%%
%[text] Access individual step properties
workflow.steps(1).name
%%
%[text] ## Complex GitHub Actions Workflow
%[text] Real-world GitHub Actions YAML with nested structures
yamlGitHubActions = [
    "name: CI"
    "on:"
    "  push:"
    "    branches: [main, develop]"
    "  pull_request:"
    "    branches: [main]"
    ""
    "jobs:"
    "  build:"
    "    runs-on: ubuntu-latest"
    "    steps:"
    "      - name: Checkout"
    "        uses: actions/checkout@v4"
    "      - name: Build"
    "        run: make build"
    "  test:"
    "    runs-on: ubuntu-latest"
    "    steps:"
    "      - name: Checkout"
    "        uses: actions/checkout@v4"
    "      - name: Run tests"
    "        run: make test"];
writelines(yamlGitHubActions,"github_workflow.yaml");
ghActions = readyaml("github_workflow.yaml");
%[text] Navigate complex nested structure
%[text] GitHub Actions workflow:
fprintf("Workflow name: %s\n", ghActions.name);
disp("Trigger on push branches:")
for i = 1:numel(ghActions.on.push.branches)
    fprintf("  - %s\n", ghActions.on.push.branches(i));
end
disp("Jobs:")
disp("  Build job runs on: " + ghActions.jobs.build.("runs-on"))
disp("  Test job runs on: " + ghActions.jobs.test.("runs-on"))
%%
%[text] ## Keys with Special Characters
%[text] Use dynamic field access for keys with hyphens, underscores, or dots
yamlSpecialKeys = [
    "pull-request:"
    "  target-branch: main"
    "  auto-merge: true"
    "push_event:"
    "  enabled: false"];
writelines(yamlSpecialKeys,"special_keys.yaml");
special = readyaml("special_keys.yaml");
%[text] Access keys with special characters using quoted syntax
special.("pull-request").("target-branch")
%%
%[text] ## Exploring Unknown YAML Files
%[text] Use keys, isfield, and show to explore structure
%[text] Top-level keys in GitHub Actions workflow:
ghActions.keys
%%
%[text] Check for specific fields
if isfield(ghActions, "jobs")
    disp("Workflow contains jobs")
    if isfield(ghActions.jobs, "build")
        disp("  Build job exists")
    end
    if isfield(ghActions.jobs, "test")
        disp("  Test job exists")
    end
end
%%
%[text] Use show for formatted display
%[text] Database configuration structure:
dbConfig.show
%%
%[text] ## Data Types in YAML
%[text] YAML supports various data types
yamlTypes = [
    "string_val: Hello, World!"
    "quoted_string: ""Quoted text"""
    "integer_val: 42"
    "float_val: 3.14159"
    "boolean_true: true"
    "boolean_false: false"
    "yes_val: yes"
    "no_val: no"
    "null_val: null"];
writelines(yamlTypes,"types.yaml");
types = readyaml("types.yaml");
%[text] YAML data types:
fprintf("String: %s (class: %s)\n", types.string_val, class(types.string_val));
fprintf("Quoted string: %s (class: %s)\n", types.quoted_string, class(types.quoted_string));
fprintf("Integer: %d (class: %s)\n", types.integer_val, class(types.integer_val));
fprintf("Float: %.5f (class: %s)\n", types.float_val, class(types.float_val));
fprintf("Boolean true: %d (class: %s)\n", types.boolean_true, class(types.boolean_true));
fprintf("Boolean false: %d (class: %s)\n", types.boolean_false, class(types.boolean_false));
fprintf("Yes: %d (class: %s)\n", types.yes_val, class(types.yes_val));
fprintf("No: %d (class: %s)\n", types.no_val, class(types.no_val));
fprintf("Null: %s (class: %s)\n", string(types.null_val), class(types.null_val));
%%
%[text] ## Converting to Struct
%[text] Convert YAMLData to standard MATLAB struct when needed
serverYaml = [
    "server:"
    "  host: localhost"
    "  port: 8080"
    "  ssl: true"];
writelines(serverYaml,"server.yaml");
serverConfig = readyaml("server.yaml");
%[text] Convert to struct
serverStruct = struct(serverConfig);
%[text] Converted to struct:
serverStruct
%%
%[text] ## Real-World Example: Docker Compose
%[text] Read a realistic Docker Compose YAML configuration
dockerComposeYaml = [
    "version: ""3.8"""
    ""
    "services:"
    "  web:"
    "    image: nginx:latest"
    "    ports:"
    "      - ""8080:80"""
    "      - ""8443:443"""
    "    environment:"
    "      - NGINX_HOST=example.com"
    "      - NGINX_PORT=80"
    ""
    "  db:"
    "    image: postgres:15"
    "    ports:"
    "      - ""5432:5432"""
    "    environment:"
    "      - POSTGRES_PASSWORD=secret"
    "      - POSTGRES_DB=myapp"];
writelines(dockerComposeYaml,"docker-compose.yaml");
dockerCompose = readyaml("docker-compose.yaml");
%[text] Access Docker Compose configuration
%[text] Docker Compose configuration:
fprintf("Version: %s\n", dockerCompose.version);
disp("Web service:")
fprintf("  Image: %s\n", dockerCompose.services.web.image);
disp("  Ports:")
disp(dockerCompose.services.web.ports)
disp("Database service:")
fprintf("  Image: %s\n", dockerCompose.services.db.image);
disp("  Ports:")
disp(dockerCompose.services.db.ports)
%%
%[text] ## Best Practices
%[text] Best practices for reading YAML files:
%[text] - Use dot notation for simple keys: config.name
%[text] - Use quoted syntax for special characters: config.("app-name")
%[text] - Use SequenceRule='cell' for dynamic configurations
%[text] - Use keys to explore unknown structures
%[text] - Use isfield to check for optional fields
%[text] - Use show for formatted display during debugging
%[text] - Remember: arrays are column vectors by default\\ \
%%
%[text] ## Cleanup
%[text] Delete temporary YAML files
delete("basic_config.yaml", "nested_config.yaml", "flow_arrays.yaml", ...
    "block_arrays.yaml", "mixed_array.yaml", "array_types.yaml", ...
    "workflow_steps.yaml", "github_workflow.yaml", "special_keys.yaml", ...
    "types.yaml", "server.yaml", "docker-compose.yaml");

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
%[output:7d48cbf4]
%   data: {"dataType":"matrix","outputData":{"columns":1,"name":"ans","rows":3,"type":"double","value":[["8080"],["8443"],["9000"]]}}
%---
%[output:9e77c6aa]
%   data: {"dataType":"tabular","outputData":{"columns":1,"header":"4×1 cell array","name":"ans","rows":4,"type":"cell","value":[["42"],["\"text\""],["1"],["3.1400"]]}}
%---
