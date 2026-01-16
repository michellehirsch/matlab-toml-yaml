%[text] # ReadTOMLExample - Comprehensive guide to reading TOML files
%[text] This example demonstrates readtoml functionality, showing how to work with TOML configuration files, access data with dot notation, handle special characters, and work with complex nested structures.
%%
%[text] ## Basic TOML Reading
%[text] Read a simple TOML file and access its contents
%[text] First, create a sample TOML file
tomlContent = [
    "name = ""my-package"""
    "version = ""1.0.0"""
    "description = ""A sample project"""
    "enabled = true"];
writelines(tomlContent,"simple.toml");
%[text] Read the TOML file
config = readtoml("simple.toml");
%[text] TOMLData:
config %[output:8e7c40d5]
%%
%[text] Access values using dot notation
config.name
%%
%[text] ## Working with Nested Tables
%[text] TOML tables create nested structures
tomlNested = [
    "[project]"
    "name = ""my-package"""
    "version = ""2.0.0"""
    ""
    "[project.urls]"
    "homepage = ""https://github.com/user/project"""
    "repository = ""https://github.com/user/project.git"""];
writelines(tomlNested,"nested.toml");
project = readtoml("nested.toml");
%[text] Nested structure:
project
%%
%[text] Navigate nested tables with dot notation
project.project.urls.homepage
%%
%[text] ## Keys with Special Characters
%[text] Use dynamic field access for keys with hyphens, dots, or spaces
tomlSpecial = [
    "[build-system]"
    "requires = [""setuptools>=61.0"", ""wheel""]"
    "build-backend = ""setuptools.build_meta"""];
writelines(tomlSpecial,"special.toml");
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
tomlArrays = [
    "numbers = [1, 2, 3, 4, 5]"
    "strings = [""apple"", ""banana"", ""cherry""]"
    ""
    "multiline = ["
    "  ""first"","
    "  ""second"","
    "  ""third"""
    "]"];
writelines(tomlArrays,"arrays.toml");
arrays = readtoml("arrays.toml");
%[text] Arrays:
arrays.numbers
%%
%[text] ## Array of Tables - GitHub Actions Style
%[text] Arrays of tables are common in configuration files
tomlArrayOfTables = [
    "[[steps]]"
    "name = ""Checkout"""
    "uses = ""actions/checkout@v4"""
    ""
    "[[steps]]"
    "name = ""Build"""
    "run = ""make build"""
    ""
    "[[steps]]"
    "name = ""Test"""
    "run = ""make test"""];
writelines(tomlArrayOfTables,"workflow.toml");
workflow = readtoml("workflow.toml");
%[text] Workflow steps:
%[text] Access array of tables with indexing
for i = 1:numel(workflow.steps)
    fprintf("Step %d: %s\n", i, workflow.steps(i).name);
end
%%
%[text] Access individual step properties
workflow.steps(1).uses
%%
%[text] Extract all values from an array using arrayfun
%[text] To get all names from the array at once:
allNames = arrayfun(@(x) x.name, workflow.steps)
%%
%[text] ## Exploring Unknown TOML Files
%[text] Use keys and isfield to explore TOML structure
%[text] Keys in project:
keys(project)
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
project.show
%%
%[text] ## Data Types in TOML
%[text] TOML supports various data types
tomlTypes = [
    "string_val = ""Hello, World!"""
    "integer_val = 42"
    "float_val = 3.14159"
    "boolean_true = true"
    "boolean_false = false"
    "date_val = 2024-01-15T10:30:00Z"];
writelines(tomlTypes,"types.toml");
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
tomlSimple = [
    "[server]"
    "host = ""localhost"""
    "port = 8080"];
writelines(tomlSimple,"server.toml");
serverConfig = readtoml("server.toml");
%[text] Convert to struct
serverStruct = struct(serverConfig);
%[text] Converted to struct:
serverStruct
%%
%[text] ## Real-World Example: Python pyproject.toml
%[text] Read a realistic Python project configuration
pyprojectContent = [
    "[project]"
    "name = ""example-package"""
    "version = ""1.0.0"""
    "description = ""An example Python package"""
    "authors = ["
    "    ""Alice Smith <alice@example.com>"","
    "    ""Bob Jones <bob@example.com>"""
    "]"
    "dependencies = ["
    "    ""numpy>=1.20"","
    "    ""pandas>=1.3"","
    "    ""matplotlib>=3.4"""
    "]"
    ""
    "[project.urls]"
    "homepage = ""https://github.com/example/package"""
    "repository = ""https://github.com/example/package.git"""
    "documentation = ""https://example-package.readthedocs.io"""
    ""
    "[build-system]"
    "requires = [""setuptools>=61.0"", ""wheel""]"
    "build-backend = ""setuptools.build_meta"""];
writelines(pyprojectContent,"pyproject.toml");
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
%[text] - Convert to struct when interfacing with code expecting structs\\ \
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
%[output:8e7c40d5]
%   data: {"dataType":"textualVariable","outputData":{"name":"config","value":"  <a href=\"matlab:helpPopup('TOMLData')\" style=\"font-weight:bold\">TOMLData<\/a> with properties:\n\n    name: \"my-package\"\n    version: \"1.0.0\"\n    description: \"A sample project\"\n    enabled: true\n"}}
%---
