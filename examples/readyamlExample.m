%%
%[text] ## ReadYAMLExample - Comprehensive guide to reading YAML files
%[text] This example demonstrates readyaml functionality, showing how to work with YAML configuration files, handle different array types, use the SequenceRule option, and work with GitHub Actions-style configurations.
%%
%[text] ## Basic YAML Reading
%[text] Read a simple YAML file and access its contents
%[text] Create a sample YAML file
yamlContent = [...
    'app-name: MyApplication', newline, ...
    'version: 1.2.0', newline, ...
    'port: 8080', newline, ...
    'debug: true'];
fid = fopen("basic_config.yaml", 'w');
fprintf(fid, '%s', yamlContent);
fclose(fid);
%[text] Read the YAML file
config = readyaml("basic_config.yaml");
%[text] YAMLData object:
config
%%
%[text] Access values using dot notation
"App name: " + config.("app-name")
"Version: " + string(config.version)
"Port: " + string(config.port)
"Debug mode: " + string(config.debug)
%%
%[text] ## Nested YAML Structures
%[text] YAML supports nested mappings (dictionaries)
yamlNested = [...
    'database:', newline, ...
    '  host: localhost', newline, ...
    '  port: 5432', newline, ...
    '  credentials:', newline, ...
    '    username: admin', newline, ...
    '    password: secret'];
fid = fopen("nested_config.yaml", 'w');
fprintf(fid, '%s', yamlNested);
fclose(fid);
dbConfig = readyaml("nested_config.yaml");
%[text] Navigate nested structures
%[text] Database configuration:
"  Host: " + dbConfig.database.host
"  Port: " + string(dbConfig.database.port)
"  Username: " + dbConfig.database.credentials.username
%%
%[text] ## YAML Arrays - Flow Style
%[text] Flow-style arrays use [item1, item2, item3] syntax
yamlFlowArrays = [...
    'ports: [8080, 8443, 9000]', newline, ...
    'hosts: [localhost, api.example.com, db.example.com]'];
fid = fopen("flow_arrays.yaml", 'w');
fprintf(fid, '%s', yamlFlowArrays);
fclose(fid);
flowData = readyaml("flow_arrays.yaml");
%[text] Arrays are converted to MATLAB arrays based on type
%[text] Flow-style arrays:
%[text] Ports (numeric array):
flowData.ports
"Class: " + class(flowData.ports)
%[text] Hosts (string array):
flowData.hosts
"Class: " + class(flowData.hosts)
%%
%[text] ## YAML Arrays - Block Style
%[text] Block-style arrays use dash notation
yamlBlockArrays = [...
    'ports:', newline, ...
    '  - 8080', newline, ...
    '  - 8443', newline, ...
    '  - 9000', newline, ...
    'hosts:', newline, ...
    '  - localhost', newline, ...
    '  - api.example.com', newline, ...
    '  - db.example.com'];
fid = fopen("block_arrays.yaml", 'w');
fprintf(fid, '%s', yamlBlockArrays);
fclose(fid);
blockData = readyaml("block_arrays.yaml");
%[text] Block-style arrays work the same as flow-style
%[text] Block-style arrays:
%[text] Ports:
blockData.ports
%[text] Hosts:
blockData.hosts
%%
%[text] ## Mixed-Type Arrays
%[text] Arrays with mixed types become cell arrays
yamlMixed = [...
    'mixed:', newline, ...
    '  - 42', newline, ...
    '  - "text"', newline, ...
    '  - true', newline, ...
    '  - 3.14'];
fid = fopen("mixed_array.yaml", 'w');
fprintf(fid, '%s', yamlMixed);
fclose(fid);
mixedData = readyaml("mixed_array.yaml");
%[text] Mixed-type arrays become cell arrays
%[text] Mixed-type array:
mixedData.mixed
"Class: " + class(mixedData.mixed)
%%
%[text] ## SequenceRule Option - Auto vs Cell
%[text] Control how arrays are converted
yamlArrayTypes = [...
    'numbers: [1, 2, 3]', newline, ...
    'strings: [apple, banana, cherry]', newline, ...
    'single: [value]'];
fid = fopen("array_types.yaml", 'w');
fprintf(fid, '%s', yamlArrayTypes);
fclose(fid);
%[text] Default: SequenceRule="auto" - use specialized arrays when possible
autoData = readyaml("array_types.yaml");
%[text] With SequenceRule='auto' (default):
"Numbers: " + class(autoData.numbers)
autoData.numbers
"Strings: " + class(autoData.strings)
autoData.strings
%%
%[text] SequenceRule="cell" - always use cell arrays for consistency
cellData = readyaml("array_types.yaml", SequenceRule="cell");
%[text] With SequenceRule='cell':
"Numbers: " + class(cellData.numbers)
cellData.numbers
"Strings: " + class(cellData.strings)
cellData.strings
%%
%[text] Why use SequenceRule="cell"?
%[text] Use SequenceRule='cell' when:
%[text] - You need consistent types regardless of content
%[text] - A file might change from single value to multiple values
%[text] - You want predictable behavior for dynamic configurations\
%%
%[text] ## Sequence of Mappings - GitHub Actions Style
%[text] Arrays where each item is a mapping (dictionary)
yamlSteps = [...
    'steps:', newline, ...
    '  - name: Checkout', newline, ...
    '    uses: actions/checkout@v4', newline, ...
    '  - name: Setup MATLAB', newline, ...
    '    uses: matlab-actions/setup-matlab@v2', newline, ...
    '  - name: Run tests', newline, ...
    '    uses: matlab-actions/run-tests@v2'];
fid = fopen("workflow_steps.yaml", 'w');
fprintf(fid, '%s', yamlSteps);
fclose(fid);
workflow = readyaml("workflow_steps.yaml");
%[text] Access array of mappings with indexing
%[text] GitHub Actions workflow steps:
for i = 1:numel(workflow.steps)
    fprintf("Step %d: %s\n", i, workflow.steps(i).name);
    fprintf("  Uses: %s\n", workflow.steps(i).uses);
end
%%
%[text] Access individual step properties
"First step name: " + workflow.steps(1).name
"Last step uses: " + workflow.steps(end).uses
%%
%[text] ## Complex GitHub Actions Workflow
%[text] Real-world GitHub Actions YAML with nested structures
yamlGitHubActions = [...
    'name: CI', newline, ...
    'on:', newline, ...
    '  push:', newline, ...
    '    branches: [main, develop]', newline, ...
    '  pull_request:', newline, ...
    '    branches: [main]', newline, ...
    '', newline, ...
    'jobs:', newline, ...
    '  build:', newline, ...
    '    runs-on: ubuntu-latest', newline, ...
    '    steps:', newline, ...
    '      - name: Checkout', newline, ...
    '        uses: actions/checkout@v4', newline, ...
    '      - name: Build', newline, ...
    '        run: make build', newline, ...
    '  test:', newline, ...
    '    runs-on: ubuntu-latest', newline, ...
    '    steps:', newline, ...
    '      - name: Checkout', newline, ...
    '        uses: actions/checkout@v4', newline, ...
    '      - name: Run tests', newline, ...
    '        run: make test'];
fid = fopen("github_workflow.yaml", 'w');
fprintf(fid, '%s', yamlGitHubActions);
fclose(fid);
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
yamlSpecialKeys = [...
    'pull-request:', newline, ...
    '  target-branch: main', newline, ...
    '  auto-merge: true', newline, ...
    'push_event:', newline, ...
    '  enabled: false'];
fid = fopen("special_keys.yaml", 'w');
fprintf(fid, '%s', yamlSpecialKeys);
fclose(fid);
special = readyaml("special_keys.yaml");
%[text] Access keys with special characters using quoted syntax
%[text] Keys with hyphens and underscores:
"Pull request target: " + special.("pull-request").("target-branch")
"Auto merge: " + string(special.("pull-request").("auto-merge"))
"Push event enabled: " + string(special.push_event.enabled)
%%
%[text] ## Exploring Unknown YAML Files
%[text] Use keys, isfield, and show to explore structure
%[text] Top-level keys in GitHub Actions workflow:
ghActions.keys()
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
dbConfig.show()
%%
%[text] ## Data Types in YAML
%[text] YAML supports various data types
yamlTypes = [...
    'string_val: Hello, World!', newline, ...
    'quoted_string: "Quoted text"', newline, ...
    'integer_val: 42', newline, ...
    'float_val: 3.14159', newline, ...
    'boolean_true: true', newline, ...
    'boolean_false: false', newline, ...
    'yes_val: yes', newline, ...
    'no_val: no', newline, ...
    'null_val: null'];
fid = fopen("types.yaml", 'w');
fprintf(fid, '%s', yamlTypes);
fclose(fid);
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
serverYaml = [...
    'server:', newline, ...
    '  host: localhost', newline, ...
    '  port: 8080', newline, ...
    '  ssl: true'];
fid = fopen("server.yaml", 'w');
fprintf(fid, '%s', serverYaml);
fclose(fid);
serverConfig = readyaml("server.yaml");
%[text] Convert to struct
serverStruct = struct(serverConfig);
%[text] Converted to struct:
serverStruct
%%
%[text] ## Real-World Example: Docker Compose
%[text] Read a realistic Docker Compose YAML configuration
dockerComposeYaml = [...
    'version: "3.8"', newline, ...
    '', newline, ...
    'services:', newline, ...
    '  web:', newline, ...
    '    image: nginx:latest', newline, ...
    '    ports:', newline, ...
    '      - "8080:80"', newline, ...
    '      - "8443:443"', newline, ...
    '    environment:', newline, ...
    '      - NGINX_HOST=example.com', newline, ...
    '      - NGINX_PORT=80', newline, ...
    '', newline, ...
    '  db:', newline, ...
    '    image: postgres:15', newline, ...
    '    ports:', newline, ...
    '      - "5432:5432"', newline, ...
    '    environment:', newline, ...
    '      - POSTGRES_PASSWORD=secret', newline, ...
    '      - POSTGRES_DB=myapp'];
fid = fopen("docker-compose.yaml", 'w');
fprintf(fid, '%s', dockerComposeYaml);
fclose(fid);
dockerCompose = readyaml("docker-compose.yaml");
%[text] Access Docker Compose configuration
%[text] Docker Compose configuration:
fprintf("Version: %s\n", dockerCompose.version);
disp("Web service:")
fprintf("  Image: %s\n", dockerCompose.services.web.image);
fprintf("  Ports: %s\n", strjoin(dockerCompose.services.web.ports, ", "));
disp("Database service:")
fprintf("  Image: %s\n", dockerCompose.services.db.image);
fprintf("  Ports: %s\n", strjoin(dockerCompose.services.db.ports, ", "));
%%
%[text] ## Best Practices
%[text] Best practices for reading YAML files:
%[text] - Use dot notation for simple keys: config.name
%[text] - Use quoted syntax for special characters: config.("app-name")
%[text] - Use SequenceRule='cell' for dynamic configurations
%[text] - Use keys to explore unknown structures
%[text] - Use isfield to check for optional fields
%[text] - Use show for formatted display during debugging
%[text] - Remember: arrays are column vectors by default\
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