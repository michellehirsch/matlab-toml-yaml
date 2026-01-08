%%
%[text] ## ReadTOMLExample - Comprehensive guide to reading TOML files
%[text] This example demonstrates readtoml functionality, showing how to work with TOML configuration files, access data with dot notation, handle special characters, and work with complex nested structures.
%%
%[text] ## Basic TOML Reading
%[text] Read a simple TOML file and access its contents
%[text] First, create a sample TOML file
tomlContent = [...
    'name = "my-package"', newline, ...
    'version = "1.0.0"', newline, ...
    'description = "A sample project"', newline, ...
    'enabled = true'];
fid = fopen("simple.toml", 'w');
fprintf(fid, '%s', tomlContent);
fclose(fid);
%[text] Read the TOML file
config = readtoml("simple.toml");
%[text] TOMLData object:
config
%%
%[text] Access values using dot notation
"Project name: " + config.name
"Version: " + config.version
"Enabled: " + string(config.enabled)
%%
%[text] ## Working with Nested Tables
%[text] TOML tables create nested structures
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
%[text] Nested structure:
project
%%
%[text] Navigate nested tables with dot notation
"Project name: " + project.project.name
"Homepage: " + project.project.urls.homepage
%%
%[text] ## Keys with Special Characters
%[text] Use dynamic field access for keys with hyphens, dots, or spaces
tomlSpecial = [...
    '[build-system]', newline, ...
    'requires = ["setuptools>=61.0", "wheel"]', newline, ...
    'build-backend = "setuptools.build_meta"'];
fid = fopen("special.toml", 'w');
fprintf(fid, '%s', tomlSpecial);
fclose(fid);
data = readtoml("special.toml");
%[text] Access keys with special characters using quoted syntax
buildSystem = data.("build-system");
%[text] Build system requires:
buildSystem.requires
%[text] Build backend:
buildSystem.("build-backend")
%%
%[text] ## Working with Arrays
%[text] TOML supports both inline and multi-line arrays
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
%[text] Arrays:
"Numbers: " + mat2str(arrays.numbers)
"Strings: " + strjoin(arrays.strings, ", ")
"Multiline: " + strjoin(arrays.multiline, ", ")
%%
%[text] ## Array of Tables - GitHub Actions Style
%[text] Arrays of tables are common in configuration files
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
%[text] Workflow steps:
%[text] Access array of tables with indexing
for i = 1:numel(workflow.steps)
    fprintf("Step %d: %s\n", i, workflow.steps(i).name);
end
%%
%[text] Access individual step properties
"First step uses: " + workflow.steps(1).uses
"Second step run: " + workflow.steps(2).run
%%
%[text] ## Exploring Unknown TOML Files
%[text] Use keys and isfield to explore TOML structure
%[text] Keys in project:
project.keys()
%%
%[text] Check if specific fields exist
if isfield(project, "project")
    disp("Project section exists")
    if isfield(project.project, "urls")
        disp("URLs section exists")
    end
end
%%
%[text] Use show for formatted display
%[text] Project structure:
project.show()
%%
%[text] ## Data Types in TOML
%[text] TOML supports various data types
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
%[text] Data types:
fprintf("String: %s (class: %s)\n", types.string_val, class(types.string_val));
fprintf("Integer: %d (class: %s)\n", types.integer_val, class(types.integer_val));
fprintf("Float: %.5f (class: %s)\n", types.float_val, class(types.float_val));
fprintf("Boolean true: %d (class: %s)\n", types.boolean_true, class(types.boolean_true));
fprintf("Boolean false: %d (class: %s)\n", types.boolean_false, class(types.boolean_false));
fprintf("Date: %s (class: %s)\n", string(types.date_val), class(types.date_val));
%%
%[text] ## Converting to Struct
%[text] Convert TOMLData to standard MATLAB struct when needed
tomlSimple = [...
    '[server]', newline, ...
    'host = "localhost"', newline, ...
    'port = 8080'];
fid = fopen("server.toml", 'w');
fprintf(fid, '%s', tomlSimple);
fclose(fid);
serverConfig = readtoml("server.toml");
%[text] Convert to struct
serverStruct = struct(serverConfig);
%[text] Converted to struct:
serverStruct
%%
%[text] ## Real-World Example: Python pyproject.toml
%[text] Read a realistic Python project configuration
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
%[text] Access project metadata
%[text] Python Project Configuration:
fprintf("Name: %s\n", pyproject.project.name);
fprintf("Version: %s\n", pyproject.project.version);
fprintf("Description: %s\n", pyproject.project.description);
%%
%[text] Work with arrays
disp("Authors:")
for i = 1:numel(pyproject.project.authors)
    fprintf("  - %s\n", pyproject.project.authors(i));
end
disp("Dependencies:")
for i = 1:numel(pyproject.project.dependencies)
    fprintf("  - %s\n", pyproject.project.dependencies(i));
end
%%
%[text] Access nested configuration
disp("Project URLs:")
fprintf("  Homepage: %s\n", pyproject.project.urls.homepage);
fprintf("  Repository: %s\n", pyproject.project.urls.repository);
fprintf("  Documentation: %s\n", pyproject.project.urls.documentation);
%%
%[text] Build system configuration
buildSys = pyproject.("build-system");
disp("Build System:")
fprintf("  Backend: %s\n", buildSys.("build-backend"));
fprintf("  Requires: %s\n", strjoin(buildSys.requires, ", "));
%%
%[text] ## Best Practices
%[text] Best practices for reading TOML files:
%[text] - Use dot notation for simple keys: config.name
%[text] - Use quoted syntax for special characters: config.("build-system")
%[text] - Use keys to explore unknown structures
%[text] - Use isfield to check for optional fields
%[text] - Use show for formatted display during debugging
%[text] - Convert to struct when interfacing with code expecting structs\
%%
%[text] ## Cleanup
%[text] Delete temporary TOML files
delete("simple.toml", "nested.toml", "special.toml", "arrays.toml", ...
    "workflow.toml", "types.toml", "server.toml", "pyproject.toml");
%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---