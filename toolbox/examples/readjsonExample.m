%[text] # ReadJSONExample - Comprehensive guide to reading JSON files
%[text] This example demonstrates readjson functionality, showing how to work with JSON configuration files, access data with dot notation, handle special characters, and work with complex nested structures.
%%
%[text] ## Basic JSON Reading
%[text] Read a simple JSON file and access its contents.
%[text] First, create a sample JSON file.
jsonContent = sprintf('{\n  "name": "my-package",\n  "version": "1.0.0",\n  "description": "A sample project",\n  "enabled": true\n}');
writelines(jsonContent, "simple.json");
%[text] Read the JSON file. The output is returned as JSONData, which is a struct-like object specialized for working with JSON data.
config = readjson("simple.json")
%%
%[text] Access values using dot notation.
config.name
%%
%[text] ## Working with Nested Objects
%[text] JSON objects create nested structures.
jsonNested = sprintf('{\n  "project": {\n    "name": "my-package",\n    "version": "2.0.0",\n    "urls": {\n      "homepage": "https://github.com/user/project",\n      "repository": "https://github.com/user/project.git"\n    }\n  }\n}');
writelines(jsonNested, "nested.json");
project = readjson("nested.json");
%[text] Nested structure:
project
%%
%[text] Navigate nested objects with dot notation.
project.project.urls.homepage
%%
%[text] ## Keys with Special Characters
%[text] Use dynamic field access for keys with hyphens, dots, or spaces.
jsonSpecial = sprintf('{\n  "build-system": {\n    "requires": ["setuptools>=61.0", "wheel"],\n    "build-backend": "setuptools.build_meta"\n  }\n}');
writelines(jsonSpecial, "special.json");
data = readjson("special.json");
%[text] Access keys with special characters using quoted syntax.
buildSystem = data.("build-system");
%[text] Build system requires:
buildSystem.requires
%[text] Build backend:
buildSystem.("build-backend")
%%
%[text] ## Working with Arrays
%[text] JSON arrays are converted to MATLAB arrays.
jsonArrays = sprintf('{\n  "numbers": [1, 2, 3, 4, 5],\n  "strings": ["apple", "banana", "cherry"],\n  "mixed": [1, "two", true, null]\n}');
writelines(jsonArrays, "arrays.json");
arrays = readjson("arrays.json");
%[text] Numeric arrays stay numeric:
arrays.numbers
%%
%[text] String arrays stay as strings:
arrays.strings
%%
%[text] Mixed arrays become cell arrays:
arrays.mixed
%%
%[text] ## SequenceRule Option
%[text] Control how arrays are converted to MATLAB types.
%[text] With 'auto' (default), homogeneous arrays stay native:
arraysAuto = readjson("arrays.json", SequenceRule="auto");
class(arraysAuto.numbers)
%%
%[text] With 'cell', all arrays become cell arrays:
arraysCell = readjson("arrays.json", SequenceRule="cell");
class(arraysCell.numbers)
%%
%[text] ## Array of Objects
%[text] Arrays of objects are common in JSON configuration files.
jsonArrayOfObjects = sprintf('{\n  "steps": [\n    {"name": "Checkout", "uses": "actions/checkout@v4"},\n    {"name": "Build", "run": "make build"},\n    {"name": "Test", "run": "make test"}\n  ]\n}');
writelines(jsonArrayOfObjects, "workflow.json");
workflow = readjson("workflow.json");
%[text] Workflow steps:
%[text] Arrays of objects are returned as JSONData arrays. Access elements with indexing.
steps = workflow.steps;
for i = 1:numel(steps)
    fprintf("Step %d: %s\n", i, steps(i).name);
end
%%
%[text] Access individual object properties.
steps(1).uses
%%
%[text] Extract all values from an array using arrayfun.
%[text] To get all names from the array at once:
allNames = arrayfun(@(s) s.name, steps)
%%
%[text] ## Exploring Unknown JSON Files
%[text] Use keys and isfield to explore JSON structure.
%[text] Keys in project:
keys(project)
%%
%[text] Check if specific fields exist.
if isfield(project, "project")
    disp("Project section exists")
    if isfield(project.project, "urls")
        disp("URLs section exists")
    end
end
%%
%[text] Use show for formatted display (function syntax required).
%[text] Project structure:
show(project)
%%
%[text] ## Data Types in JSON
%[text] JSON supports various data types.
jsonTypes = sprintf('{\n  "string_val": "Hello, World!",\n  "integer_val": 42,\n  "float_val": 3.14159,\n  "boolean_true": true,\n  "boolean_false": false,\n  "null_val": null,\n  "array_val": [1, 2, 3],\n  "object_val": {"nested": "value"}\n}');
writelines(jsonTypes, "types.json");
types = readjson("types.json");
%[text] Data types:
fprintf("String: %s (class: %s)\n", types.string_val, class(types.string_val));
fprintf("Integer: %d (class: %s)\n", types.integer_val, class(types.integer_val));
fprintf("Float: %.5f (class: %s)\n", types.float_val, class(types.float_val));
fprintf("Boolean true: %d (class: %s)\n", types.boolean_true, class(types.boolean_true));
fprintf("Boolean false: %d (class: %s)\n", types.boolean_false, class(types.boolean_false));
fprintf("Null: %s (class: %s)\n", mat2str(types.null_val), class(types.null_val));
%%
%[text] ## Handling Null Values
%[text] JSON null is converted to empty double array ([]).
jsonWithNull = sprintf('{\n  "name": "test",\n  "optional": null,\n  "values": [1, null, 3]\n}');
writelines(jsonWithNull, "nulls.json");
nullData = readjson("nulls.json");
%[text] Null becomes empty []:
isempty(nullData.optional)
%%
%[text] Check for null/empty values:
if isempty(nullData.optional)
    disp("Optional field is null/empty")
end
%%
%[text] ## Converting to Struct
%[text] Convert JSONData to standard MATLAB struct when needed.
jsonSimple = sprintf('{\n  "server": {\n    "host": "localhost",\n    "port": 8080\n  }\n}');
writelines(jsonSimple, "server.json");
serverConfig = readjson("server.json");
%[text] Convert to struct:
serverStruct = struct(serverConfig);
%[text] Converted to struct:
serverStruct
%%
%[text] ## Real-World Example: package.json
%[text] Read a realistic Node.js package configuration.
packageContent = sprintf('{\n  "name": "example-package",\n  "version": "2.1.0",\n  "description": "An example package for testing JSON support",\n  "main": "index.js",\n  "scripts": {\n    "test": "jest",\n    "build": "tsc",\n    "lint": "eslint src/"\n  },\n  "keywords": ["example", "test", "json"],\n  "author": {\n    "name": "Test Author",\n    "email": "test@example.com"\n  },\n  "license": "MIT",\n  "dependencies": {\n    "lodash": "^4.17.21",\n    "express": "^4.18.2"\n  },\n  "devDependencies": {\n    "jest": "^29.0.0",\n    "typescript": "^5.0.0"\n  },\n  "repository": {\n    "type": "git",\n    "url": "https://github.com/example/package.git"\n  },\n  "private": false\n}');
writelines(packageContent, "package.json");
pkg = readjson("package.json");
%[text] Access package metadata.
%[text] Package Configuration:
fprintf("Name: %s\n", pkg.name);
fprintf("Version: %s\n", pkg.version);
fprintf("Description: %s\n", pkg.description);
fprintf("License: %s\n", pkg.license);
%%
%[text] Work with scripts object.
disp("Scripts:")
scriptKeys = keys(pkg.scripts);
for i = 1:numel(scriptKeys)
    fprintf("  %s: %s\n", scriptKeys(i), pkg.scripts.(scriptKeys(i)));
end
%%
%[text] Access nested author information.
disp("Author:")
fprintf("  Name: %s\n", pkg.author.name);
fprintf("  Email: %s\n", pkg.author.email);
%%
%[text] Work with arrays.
disp("Keywords:")
for i = 1:numel(pkg.keywords)
    fprintf("  - %s\n", pkg.keywords(i));
end
%%
%[text] Access dependencies.
disp("Dependencies:")
depKeys = keys(pkg.dependencies);
for i = 1:numel(depKeys)
    fprintf("  %s: %s\n", depKeys(i), pkg.dependencies.(depKeys(i)));
end
%%
%[text] ## Best Practices
%[text] Best practices for reading JSON files:
%[text] - Use dot notation for simple keys: config.name
%[text] - Use quoted syntax for special characters: config.("build-system")
%[text] - Use keys to explore unknown structures
%[text] - Use isfield to check for optional fields
%[text] - Use show for formatted display during debugging
%[text] - Use SequenceRule="cell" when you need consistent array handling
%[text] - Check for empty values when handling nullable fields
%[text] - Convert to struct when interfacing with code expecting structs
%%
%[text] ## Cleanup
%[text] Delete temporary JSON files.
delete("simple.json", "nested.json", "special.json", "arrays.json", ...
    "workflow.json", "types.json", "nulls.json", "server.json", "package.json");

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
