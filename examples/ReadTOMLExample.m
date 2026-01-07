%% ReadTOMLExample - Comprehensive guide to reading TOML files
% This example demonstrates readtoml functionality, showing how to work
% with TOML configuration files, access data with dot notation, handle
% special characters, and work with complex nested structures.

%% Basic TOML Reading
% Read a simple TOML file and access its contents

% First, create a sample TOML file
tomlContent = [...
    'name = "my-package"', newline, ...
    'version = "1.0.0"', newline, ...
    'description = "A sample project"', newline, ...
    'enabled = true'];

fid = fopen("simple.toml", 'w');
fprintf(fid, '%s', tomlContent);
fclose(fid);

% Read the TOML file
config = readtoml("simple.toml");
disp("TOMLData object:")
disp(config)

%%
% Access values using dot notation
disp("Project name: " + config.name)
disp("Version: " + config.version)
disp("Enabled: " + string(config.enabled))

%% Working with Nested Tables
% TOML tables create nested structures

tomlNested = [...
    '[project]', newline, ...
    'name = "my-package"', newline, ...
    'version = "2.0.0"', newline, ...
    '', newline, ...
    '[project.urls]', newline, ...
    'homepage = "https://github.com/user/project"', newline, ...
    'repository = "https://github.com/user/project.git"'];

fid = fopen("nested.toml", 'w');
fprintf(fid, '%s', tomlNested);
fclose(fid);

project = readtoml("nested.toml");
disp("Nested structure:")
disp(project)

%%
% Navigate nested tables with dot notation
disp("Project name: " + project.project.name)
disp("Homepage: " + project.project.urls.homepage)

%% Keys with Special Characters
% Use dynamic field access for keys with hyphens, dots, or spaces

tomlSpecial = [...
    '[build-system]', newline, ...
    'requires = ["setuptools>=61.0", "wheel"]', newline, ...
    'build-backend = "setuptools.build_meta"', newline, ...
    '', newline, ...
    '"another.key" = "value with literal dot"', newline, ...
    '"spaces in key" = "value"'];

fid = fopen("special.toml", 'w');
fprintf(fid, '%s', tomlSpecial);
fclose(fid);

data = readtoml("special.toml");

% Access keys with special characters using quoted syntax
buildSystem = data.("build-system");
disp("Build system requires:")
disp(buildSystem.requires)

% Keys with embedded dots (quoted in TOML)
disp("Key with literal dot: " + data.("another.key"))
disp("Key with spaces: " + data.("spaces in key"))

%% Working with Arrays
% TOML supports both inline and multi-line arrays

tomlArrays = [...
    'numbers = [1, 2, 3, 4, 5]', newline, ...
    'strings = ["apple", "banana", "cherry"]', newline, ...
    '', newline, ...
    'multiline = [', newline, ...
    '  "first",', newline, ...
    '  "second",', newline, ...
    '  "third"', newline, ...
    ']'];

fid = fopen("arrays.toml", 'w');
fprintf(fid, '%s', tomlArrays);
fclose(fid);

arrays = readtoml("arrays.toml");
disp("Arrays:")
disp("Numbers: " + mat2str(arrays.numbers))
disp("Strings: " + strjoin(arrays.strings, ", "))
disp("Multiline: " + strjoin(arrays.multiline, ", "))

%% Array of Tables - GitHub Actions Style
% Arrays of tables are common in configuration files

tomlArrayOfTables = [...
    '[[steps]]', newline, ...
    'name = "Checkout"', newline, ...
    'uses = "actions/checkout@v4"', newline, ...
    '', newline, ...
    '[[steps]]', newline, ...
    'name = "Build"', newline, ...
    'run = "make build"', newline, ...
    '', newline, ...
    '[[steps]]', newline, ...
    'name = "Test"', newline, ...
    'run = "make test"'];

fid = fopen("workflow.toml", 'w');
fprintf(fid, '%s', tomlArrayOfTables);
fclose(fid);

workflow = readtoml("workflow.toml");
disp("Workflow steps:")

% Access array of tables with indexing
for i = 1:numel(workflow.steps)
    fprintf("Step %d: %s\n", i, workflow.steps(i).name);
end

%%
% Access individual step properties
disp("First step uses: " + workflow.steps(1).uses)
disp("Second step run: " + workflow.steps(2).run)

%% Nested Array of Tables
% Arrays of tables can contain nested structures

tomlNestedArray = [...
    '[[jobs]]', newline, ...
    'name = "build"', newline, ...
    '', newline, ...
    '[[jobs.steps]]', newline, ...
    'name = "Checkout"', newline, ...
    'uses = "actions/checkout@v4"', newline, ...
    '', newline, ...
    '[[jobs.steps]]', newline, ...
    'name = "Build"', newline, ...
    'run = "make build"', newline, ...
    '', newline, ...
    '[[jobs]]', newline, ...
    'name = "test"', newline, ...
    '', newline, ...
    '[[jobs.steps]]', newline, ...
    'name = "Test"', newline, ...
    'run = "make test"'];

fid = fopen("complex_workflow.toml", 'w');
fprintf(fid, '%s', tomlNestedArray);
fclose(fid);

jobs = readtoml("complex_workflow.toml");
disp("Complex workflow with nested arrays:")

% Navigate nested array of tables
for i = 1:numel(jobs.jobs)
    fprintf("\nJob: %s\n", jobs.jobs(i).name);
    for j = 1:numel(jobs.jobs(i).steps)
        fprintf("  Step %d: %s\n", j, jobs.jobs(i).steps(j).name);
    end
end

%% Exploring Unknown TOML Files
% Use keys() and isfield() to explore TOML structure

disp("Keys in project:")
disp(project.keys())

%%
% Check if specific fields exist
if isfield(project, "project")
    disp("Project section exists")
    if isfield(project.project, "urls")
        disp("URLs section exists")
    end
end

%%
% Use show() for formatted display
disp("Project structure:")
project.show()

%% Data Types in TOML
% TOML supports various data types

tomlTypes = [...
    'string_val = "Hello, World!"', newline, ...
    'integer_val = 42', newline, ...
    'float_val = 3.14159', newline, ...
    'boolean_true = true', newline, ...
    'boolean_false = false', newline, ...
    'date_val = 2024-01-15T10:30:00Z'];

fid = fopen("types.toml", 'w');
fprintf(fid, '%s', tomlTypes);
fclose(fid);

types = readtoml("types.toml");
disp("Data types:")
fprintf("String: %s (class: %s)\n", types.string_val, class(types.string_val));
fprintf("Integer: %d (class: %s)\n", types.integer_val, class(types.integer_val));
fprintf("Float: %.5f (class: %s)\n", types.float_val, class(types.float_val));
fprintf("Boolean true: %d (class: %s)\n", types.boolean_true, class(types.boolean_true));
fprintf("Boolean false: %d (class: %s)\n", types.boolean_false, class(types.boolean_false));
fprintf("Date: %s (class: %s)\n", string(types.date_val), class(types.date_val));

%% Converting to Struct
% Convert TOMLData to standard MATLAB struct when needed

tomlSimple = [...
    '[server]', newline, ...
    'host = "localhost"', newline, ...
    'port = 8080'];

fid = fopen("server.toml", 'w');
fprintf(fid, '%s', tomlSimple);
fclose(fid);

serverConfig = readtoml("server.toml");

% Convert to struct
serverStruct = struct(serverConfig);
disp("Converted to struct:")
disp(serverStruct)

%% Real-World Example: Python pyproject.toml
% Read a realistic Python project configuration

pyprojectContent = [...
    '[project]', newline, ...
    'name = "example-package"', newline, ...
    'version = "1.0.0"', newline, ...
    'description = "An example Python package"', newline, ...
    'authors = [', newline, ...
    '    "Alice Smith <alice@example.com>",', newline, ...
    '    "Bob Jones <bob@example.com>"', newline, ...
    ']', newline, ...
    'dependencies = [', newline, ...
    '    "numpy>=1.20",', newline, ...
    '    "pandas>=1.3",', newline, ...
    '    "matplotlib>=3.4"', newline, ...
    ']', newline, ...
    '', newline, ...
    '[project.urls]', newline, ...
    'homepage = "https://github.com/example/package"', newline, ...
    'repository = "https://github.com/example/package.git"', newline, ...
    'documentation = "https://example-package.readthedocs.io"', newline, ...
    '', newline, ...
    '[build-system]', newline, ...
    'requires = ["setuptools>=61.0", "wheel"]', newline, ...
    'build-backend = "setuptools.build_meta"'];

fid = fopen("pyproject.toml", 'w');
fprintf(fid, '%s', pyprojectContent);
fclose(fid);

pyproject = readtoml("pyproject.toml");

% Access project metadata
disp("Python Project Configuration:")
fprintf("Name: %s\n", pyproject.project.name);
fprintf("Version: %s\n", pyproject.project.version);
fprintf("Description: %s\n", pyproject.project.description);

%%
% Work with arrays
disp("Authors:")
for i = 1:numel(pyproject.project.authors)
    fprintf("  - %s\n", pyproject.project.authors(i));
end

disp("Dependencies:")
for i = 1:numel(pyproject.project.dependencies)
    fprintf("  - %s\n", pyproject.project.dependencies(i));
end

%%
% Access nested configuration
disp("Project URLs:")
fprintf("  Homepage: %s\n", pyproject.project.urls.homepage);
fprintf("  Repository: %s\n", pyproject.project.urls.repository);
fprintf("  Documentation: %s\n", pyproject.project.urls.documentation);

%%
% Build system configuration
buildSys = pyproject.("build-system");
disp("Build System:")
fprintf("  Backend: %s\n", buildSys.("build-backend"));
fprintf("  Requires: %s\n", strjoin(buildSys.requires, ", "));

%% Best Practices
disp("Best practices for reading TOML files:")
disp("  ")
disp("1. Use dot notation for simple keys: config.name")
disp("2. Use quoted syntax for special characters: config.(""build-system"")")
disp("3. Use keys() to explore unknown structures")
disp("4. Use isfield() to check for optional fields")
disp("5. Use show() for formatted display during debugging")
disp("6. Convert to struct when interfacing with code expecting structs")
disp("  ")

%% Cleanup
% Delete temporary TOML files
delete("simple.toml", "nested.toml", "special.toml", "arrays.toml", ...
    "workflow.toml", "complex_workflow.toml", "types.toml", ...
    "server.toml", "pyproject.toml");
