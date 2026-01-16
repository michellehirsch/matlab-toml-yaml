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
config %[output:9d2914d0]
%%
%[text] Access values using dot notation
config.("app-name") %[output:870f5a7b]
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
dbConfig.database.credentials.username %[output:878829ce]
%%
%[text] ## YAML Arrays - Flow Style
%[text] Flow-style arrays use \[item1, item2, item3\] syntax
yamlFlowArrays = [
    "ports: [8080, 8443, 9000]"
    "hosts: [localhost, api.example.com, db.example.com]"];
writelines(yamlFlowArrays,"flow_arrays.yaml");
flowData = readyaml("flow_arrays.yaml");
%[text] Arrays are converted to MATLAB arrays based on type
flowData.ports %[output:7d48cbf4]
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
blockData.ports %[output:6396fa3d]
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
autoData.numbers %[output:948071b5]
%%
%[text] SequenceRule="cell" - always use cell arrays for consistency
cellData = readyaml("array_types.yaml", SequenceRule="cell");
%[text] With SequenceRule="cell":
cellData.numbers %[output:89327b5e]
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
for i = 1:numel(workflow.steps) %[output:group:1cdb82b5]
    fprintf("Step %d: %s\n", i, workflow.steps(i).name); %[output:9efc0758] %[output:83292f4d] %[output:772f2ecb]
    fprintf("  Uses: %s\n", workflow.steps(i).uses); %[output:9717da0e] %[output:4b24b677] %[output:15015521]
end %[output:group:1cdb82b5]
%%
%[text] Access individual step properties
workflow.steps(1).name %[output:1a3af68f]
%%
%[text] Extract all values from an array using arrayfun
%[text] To get all names from the array at once:
allNames = arrayfun(@(x) x.name, workflow.steps) %[output:59183ee0]
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
fprintf("Workflow name: %s\n", ghActions.name); %[output:53a439e4]
disp("Trigger on push branches:") %[output:15be4dcb]
for i = 1:numel(ghActions.on.push.branches) %[output:group:5849a603]
    fprintf("  - %s\n", ghActions.on.push.branches(i)); %[output:3c3c2a08]
end %[output:group:5849a603]
disp("Jobs:") %[output:905779f4]
disp("  Build job runs on: " + ghActions.jobs.build.("runs-on")) %[output:8606f38b]
disp("  Test job runs on: " + ghActions.jobs.test.("runs-on")) %[output:9370f1f1]
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
special.("pull-request").("target-branch") %[output:72ed3579]
%%
%[text] ## Exploring Unknown YAML Files
%[text] Use keys, isfield, and show to explore structure
%[text] Top-level keys in GitHub Actions workflow:
keys(ghActions) %[output:8097bbab]
%%
%[text] Check for specific fields
if isfield(ghActions, "jobs") %[output:group:03c2fbcb]
    disp("Workflow contains jobs") %[output:970c9e3f]
    if isfield(ghActions.jobs, "build")
        disp("  Build job exists") %[output:78813401]
    end
    if isfield(ghActions.jobs, "test")
        disp("  Test job exists") %[output:451da295]
    end
end %[output:group:03c2fbcb]
%%
%[text] Use show for formatted display
%[text] Database configuration structure:
dbConfig.show %[output:02043c92]
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
fprintf("String: %s (class: %s)\n", types.string_val, class(types.string_val)); %[output:5dcee9b5]
fprintf("Quoted string: %s (class: %s)\n", types.quoted_string, class(types.quoted_string)); %[output:1847497b]
fprintf("Integer: %d (class: %s)\n", types.integer_val, class(types.integer_val)); %[output:445d4fda]
fprintf("Float: %.5f (class: %s)\n", types.float_val, class(types.float_val)); %[output:1474d858]
fprintf("Boolean true: %d (class: %s)\n", types.boolean_true, class(types.boolean_true)); %[output:6a6bef8f]
fprintf("Boolean false: %d (class: %s)\n", types.boolean_false, class(types.boolean_false)); %[output:1f9aaa2b]
fprintf("Yes: %d (class: %s)\n", types.yes_val, class(types.yes_val)); %[output:3617ab71]
fprintf("No: %d (class: %s)\n", types.no_val, class(types.no_val)); %[output:9dce0d1b]
fprintf("Null: %s (class: %s)\n", string(types.null_val), class(types.null_val)); %[output:38f6ae76]
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
serverStruct %[output:810e1689]
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
fprintf("Version: %s\n", dockerCompose.version); %[output:624872fe]
disp("Web service:") %[output:91c4776e]
fprintf("  Image: %s\n", dockerCompose.services.web.image); %[output:94d4a265]
disp("  Ports:") %[output:7cfa29fb]
disp(dockerCompose.services.web.ports) %[output:54adbcff]
disp("Database service:") %[output:174ba041]
fprintf("  Image: %s\n", dockerCompose.services.db.image); %[output:295504df]
disp("  Ports:") %[output:69c9f471]
disp(dockerCompose.services.db.ports) %[output:530e8b50]
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
%[output:9d2914d0]
%   data: {"dataType":"textualVariable","outputData":{"name":"config","value":"  <a href=\"matlab:helpPopup('YAMLData')\" style=\"font-weight:bold\">YAMLData<\/a> with keys:\n\n    app-name: \"MyApplication\"\n    version: \"1.2.0\"\n    port: 8080\n    debug: true\n"}}
%---
%[output:870f5a7b]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"MyApplication\""}}
%---
%[output:878829ce]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"admin\""}}
%---
%[output:7d48cbf4]
%   data: {"dataType":"matrix","outputData":{"columns":1,"name":"ans","rows":3,"type":"double","value":[["8080"],["8443"],["9000"]]}}
%---
%[output:6396fa3d]
%   data: {"dataType":"matrix","outputData":{"columns":1,"name":"ans","rows":3,"type":"double","value":[["8080"],["8443"],["9000"]]}}
%---
%[output:9e77c6aa]
%   data: {"dataType":"tabular","outputData":{"columns":1,"header":"4×1 cell array","name":"ans","rows":4,"type":"cell","value":[["42"],["\"text\""],["1"],["3.1400"]]}}
%---
%[output:948071b5]
%   data: {"dataType":"matrix","outputData":{"columns":1,"name":"ans","rows":3,"type":"double","value":[["1"],["2"],["3"]]}}
%---
%[output:89327b5e]
%   data: {"dataType":"tabular","outputData":{"columns":1,"header":"3×1 cell array","name":"ans","rows":3,"type":"cell","value":[["1"],["2"],["3"]]}}
%---
%[output:9efc0758]
%   data: {"dataType":"text","outputData":{"text":"Step 1: Checkout\n","truncated":false}}
%---
%[output:9717da0e]
%   data: {"dataType":"text","outputData":{"text":"  Uses: actions\/checkout@v4\n","truncated":false}}
%---
%[output:83292f4d]
%   data: {"dataType":"text","outputData":{"text":"Step 2: Setup MATLAB\n","truncated":false}}
%---
%[output:4b24b677]
%   data: {"dataType":"text","outputData":{"text":"  Uses: matlab-actions\/setup-matlab@v2\n","truncated":false}}
%---
%[output:772f2ecb]
%   data: {"dataType":"text","outputData":{"text":"Step 3: Run tests\n","truncated":false}}
%---
%[output:15015521]
%   data: {"dataType":"text","outputData":{"text":"  Uses: matlab-actions\/run-tests@v2\n","truncated":false}}
%---
%[output:1a3af68f]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Checkout\""}}
%---
%[output:59183ee0]
%   data: {"dataType":"matrix","outputData":{"columns":3,"header":"1×3 string array","name":"allNames","rows":1,"type":"string","value":[["Checkout","Setup MATLAB","Run tests"]]}}
%---
%[output:53a439e4]
%   data: {"dataType":"text","outputData":{"text":"Workflow name: CI\n","truncated":false}}
%---
%[output:15be4dcb]
%   data: {"dataType":"text","outputData":{"text":"Trigger on push branches:\n","truncated":false}}
%---
%[output:3c3c2a08]
%   data: {"dataType":"text","outputData":{"text":"  - main\n  - develop\n","truncated":false}}
%---
%[output:905779f4]
%   data: {"dataType":"text","outputData":{"text":"Jobs:\n","truncated":false}}
%---
%[output:8606f38b]
%   data: {"dataType":"text","outputData":{"text":"  Build job runs on: ubuntu-latest\n","truncated":false}}
%---
%[output:9370f1f1]
%   data: {"dataType":"text","outputData":{"text":"  Test job runs on: ubuntu-latest\n","truncated":false}}
%---
%[output:72ed3579]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"main\""}}
%---
%[output:8097bbab]
%   data: {"dataType":"matrix","outputData":{"columns":3,"header":"1×3 string array","name":"ans","rows":1,"type":"string","value":[["name","on","jobs"]]}}
%---
%[output:970c9e3f]
%   data: {"dataType":"text","outputData":{"text":"Workflow contains jobs\n","truncated":false}}
%---
%[output:78813401]
%   data: {"dataType":"text","outputData":{"text":"  Build job exists\n","truncated":false}}
%---
%[output:451da295]
%   data: {"dataType":"text","outputData":{"text":"  Test job exists\n","truncated":false}}
%---
%[output:02043c92]
%   data: {"dataType":"text","outputData":{"text":"database:\n  host: localhost\n  port: 5432\n  credentials:\n    username: admin\n    password: secret\n","truncated":false}}
%---
%[output:5dcee9b5]
%   data: {"dataType":"text","outputData":{"text":"String: Hello, World! (class: string)\n","truncated":false}}
%---
%[output:1847497b]
%   data: {"dataType":"text","outputData":{"text":"Quoted string: Quoted text (class: string)\n","truncated":false}}
%---
%[output:445d4fda]
%   data: {"dataType":"text","outputData":{"text":"Integer: 42 (class: double)\n","truncated":false}}
%---
%[output:1474d858]
%   data: {"dataType":"text","outputData":{"text":"Float: 3.14159 (class: double)\n","truncated":false}}
%---
%[output:6a6bef8f]
%   data: {"dataType":"text","outputData":{"text":"Boolean true: 1 (class: logical)\n","truncated":false}}
%---
%[output:1f9aaa2b]
%   data: {"dataType":"text","outputData":{"text":"Boolean false: 0 (class: logical)\n","truncated":false}}
%---
%[output:3617ab71]
%   data: {"dataType":"text","outputData":{"text":"Yes: 1 (class: logical)\n","truncated":false}}
%---
%[output:9dce0d1b]
%   data: {"dataType":"text","outputData":{"text":"No: 0 (class: logical)\n","truncated":false}}
%---
%[output:38f6ae76]
%   data: {"dataType":"text","outputData":{"text":"Null:  (class: double)\n","truncated":false}}
%---
%[output:810e1689]
%   data: {"dataType":"textualVariable","outputData":{"header":"struct with fields:","name":"serverStruct","value":"    server: [1×1 struct]\n"}}
%---
%[output:624872fe]
%   data: {"dataType":"text","outputData":{"text":"Version: 3.8\n","truncated":false}}
%---
%[output:91c4776e]
%   data: {"dataType":"text","outputData":{"text":"Web service:\n","truncated":false}}
%---
%[output:94d4a265]
%   data: {"dataType":"text","outputData":{"text":"  Image: nginx:latest\n","truncated":false}}
%---
%[output:7cfa29fb]
%   data: {"dataType":"text","outputData":{"text":"  Ports:\n","truncated":false}}
%---
%[output:54adbcff]
%   data: {"dataType":"text","outputData":{"text":"    \"8080:80\"\n    \"8443:443\"\n\n","truncated":false}}
%---
%[output:174ba041]
%   data: {"dataType":"text","outputData":{"text":"Database service:\n","truncated":false}}
%---
%[output:295504df]
%   data: {"dataType":"text","outputData":{"text":"  Image: postgres:15\n","truncated":false}}
%---
%[output:69c9f471]
%   data: {"dataType":"text","outputData":{"text":"  Ports:\n","truncated":false}}
%---
%[output:530e8b50]
%   data: {"dataType":"text","outputData":{"text":"5432:5432\n","truncated":false}}
%---
