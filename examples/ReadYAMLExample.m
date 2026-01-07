%% ReadYAMLExample - Comprehensive guide to reading YAML files
% This example demonstrates readyaml functionality, showing how to work
% with YAML configuration files, handle different array types, use the
% SequenceRule option, and work with GitHub Actions-style configurations.

%% Basic YAML Reading
% Read a simple YAML file and access its contents

% Create a sample YAML file
yamlContent = [...
    'app-name: MyApplication', newline, ...
    'version: 1.2.0', newline, ...
    'port: 8080', newline, ...
    'debug: true'];

fid = fopen("basic_config.yaml", 'w');
fprintf(fid, '%s', yamlContent);
fclose(fid);

% Read the YAML file
config = readyaml("basic_config.yaml");
disp("YAMLData object:")
disp(config)

%%
% Access values using dot notation
disp("App name: " + config.("app-name"))
disp("Version: " + string(config.version))
disp("Port: " + string(config.port))
disp("Debug mode: " + string(config.debug))

%% Nested YAML Structures
% YAML supports nested mappings (dictionaries)

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

% Navigate nested structures
disp("Database configuration:")
disp("  Host: " + dbConfig.database.host)
disp("  Port: " + string(dbConfig.database.port))
disp("  Username: " + dbConfig.database.credentials.username)

%% YAML Arrays - Flow Style
% Flow-style arrays use [item1, item2, item3] syntax

yamlFlowArrays = [...
    'ports: [8080, 8443, 9000]', newline, ...
    'hosts: [localhost, api.example.com, db.example.com]'];

fid = fopen("flow_arrays.yaml", 'w');
fprintf(fid, '%s', yamlFlowArrays);
fclose(fid);

flowData = readyaml("flow_arrays.yaml");

% Arrays are converted to MATLAB arrays based on type
disp("Flow-style arrays:")
disp("Ports (numeric array):")
disp(flowData.ports)
disp("Class: " + class(flowData.ports))

disp("Hosts (string array):")
disp(flowData.hosts)
disp("Class: " + class(flowData.hosts))

%% YAML Arrays - Block Style
% Block-style arrays use dash notation

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

% Block-style arrays work the same as flow-style
disp("Block-style arrays:")
disp("Ports:")
disp(blockData.ports)
disp("Hosts:")
disp(blockData.hosts)

%% Mixed-Type Arrays
% Arrays with mixed types become cell arrays

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

% Mixed-type arrays become cell arrays
disp("Mixed-type array:")
disp(mixedData.mixed)
disp("Class: " + class(mixedData.mixed))

%% SequenceRule Option - Auto vs Cell
% Control how arrays are converted

yamlArrayTypes = [...
    'numbers: [1, 2, 3]', newline, ...
    'strings: [apple, banana, cherry]', newline, ...
    'single: [value]'];

fid = fopen("array_types.yaml", 'w');
fprintf(fid, '%s', yamlArrayTypes);
fclose(fid);

% Default: SequenceRule="auto" - use specialized arrays when possible
autoData = readyaml("array_types.yaml");
disp("With SequenceRule='auto' (default):")
disp("Numbers: " + class(autoData.numbers))
disp(autoData.numbers)
disp("Strings: " + class(autoData.strings))
disp(autoData.strings)

%%
% SequenceRule="cell" - always use cell arrays for consistency
cellData = readyaml("array_types.yaml", SequenceRule="cell");
disp("With SequenceRule='cell':")
disp("Numbers: " + class(cellData.numbers))
disp(cellData.numbers)
disp("Strings: " + class(cellData.strings))
disp(cellData.strings)

%%
% Why use SequenceRule="cell"?
disp("Use SequenceRule='cell' when:")
disp("  - You need consistent types regardless of content")
disp("  - A file might change from single value to multiple values")
disp("  - You want predictable behavior for dynamic configurations")

%% Sequence of Mappings - GitHub Actions Style
% Arrays where each item is a mapping (dictionary)

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

% Access array of mappings with indexing
disp("GitHub Actions workflow steps:")
for i = 1:numel(workflow.steps)
    fprintf("Step %d: %s\n", i, workflow.steps(i).name);
    fprintf("  Uses: %s\n", workflow.steps(i).uses);
end

%%
% Access individual step properties
disp("First step name: " + workflow.steps(1).name)
disp("Last step uses: " + workflow.steps(end).uses)

%% Complex GitHub Actions Workflow
% Real-world GitHub Actions YAML with nested structures

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

% Navigate complex nested structure
disp("GitHub Actions workflow:")
fprintf("Workflow name: %s\n", ghActions.name);

disp("Trigger on push branches:")
for i = 1:numel(ghActions.on.push.branches)
    fprintf("  - %s\n", ghActions.on.push.branches(i));
end

disp("Jobs:")
disp("  Build job runs on: " + ghActions.jobs.build.("runs-on"))
disp("  Test job runs on: " + ghActions.jobs.test.("runs-on"))

%% Keys with Special Characters
% Use dynamic field access for keys with hyphens, underscores, or dots

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

% Access keys with special characters using quoted syntax
disp("Keys with hyphens and underscores:")
disp("Pull request target: " + special.("pull-request").("target-branch"))
disp("Auto merge: " + string(special.("pull-request").("auto-merge")))
disp("Push event enabled: " + string(special.push_event.enabled))

%% Exploring Unknown YAML Files
% Use keys(), isfield(), and show() to explore structure

disp("Top-level keys in GitHub Actions workflow:")
disp(ghActions.keys())

%%
% Check for specific fields
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
% Use show() for formatted display
disp("Database configuration structure:")
dbConfig.show()

%% Data Types in YAML
% YAML supports various data types

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

disp("YAML data types:")
fprintf("String: %s (class: %s)\n", types.string_val, class(types.string_val));
fprintf("Quoted string: %s (class: %s)\n", types.quoted_string, class(types.quoted_string));
fprintf("Integer: %d (class: %s)\n", types.integer_val, class(types.integer_val));
fprintf("Float: %.5f (class: %s)\n", types.float_val, class(types.float_val));
fprintf("Boolean true: %d (class: %s)\n", types.boolean_true, class(types.boolean_true));
fprintf("Boolean false: %d (class: %s)\n", types.boolean_false, class(types.boolean_false));
fprintf("Yes: %d (class: %s)\n", types.yes_val, class(types.yes_val));
fprintf("No: %d (class: %s)\n", types.no_val, class(types.no_val));
fprintf("Null: %s (class: %s)\n", string(types.null_val), class(types.null_val));

%% Converting to Struct
% Convert YAMLData to standard MATLAB struct when needed

serverYaml = [...
    'server:', newline, ...
    '  host: localhost', newline, ...
    '  port: 8080', newline, ...
    '  ssl: true'];

fid = fopen("server.yaml", 'w');
fprintf(fid, '%s', serverYaml);
fclose(fid);

serverConfig = readyaml("server.yaml");

% Convert to struct
serverStruct = struct(serverConfig);
disp("Converted to struct:")
disp(serverStruct)

%% Real-World Example: Docker Compose
% Read a realistic Docker Compose YAML configuration

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

% Access Docker Compose configuration
disp("Docker Compose configuration:")
fprintf("Version: %s\n", dockerCompose.version);

disp("Web service:")
fprintf("  Image: %s\n", dockerCompose.services.web.image);
fprintf("  Ports: %s\n", strjoin(dockerCompose.services.web.ports, ", "));

disp("Database service:")
fprintf("  Image: %s\n", dockerCompose.services.db.image);
fprintf("  Ports: %s\n", strjoin(dockerCompose.services.db.ports, ", "));

%% Best Practices
disp("Best practices for reading YAML files:")
disp("  ")
disp("1. Use dot notation for simple keys: config.name")
disp("2. Use quoted syntax for special characters: config.(""app-name"")")
disp("3. Use SequenceRule='cell' for dynamic configurations")
disp("4. Use keys() to explore unknown structures")
disp("5. Use isfield() to check for optional fields")
disp("6. Use show() for formatted display during debugging")
disp("7. Remember: arrays are column vectors by default")
disp("  ")

%% Cleanup
% Delete temporary YAML files
delete("basic_config.yaml", "nested_config.yaml", "flow_arrays.yaml", ...
    "block_arrays.yaml", "mixed_array.yaml", "array_types.yaml", ...
    "workflow_steps.yaml", "github_workflow.yaml", "special_keys.yaml", ...
    "types.yaml", "server.yaml", "docker-compose.yaml");
