%[text] # Configuration File I/O - Getting Started
%[text] Learn how to read and write YAML and TOML configuration files in MATLAB with intuitive dot notation access. The example files are provided with the toolbox. `cd` MATLAB to the toolbox root (the location of this file) to access the examples.
%[text:tableOfContents]{"heading":"**Table of Contents**"}
%[text] ## Reading YAML Files
%%
%[text] ### Reading a Basic YAML File
%[text] Start by reading a simple configuration file with no hierarchy.
config = readyaml("examples/basic_config.yaml") %[output:43646e19]
%%
%[text] ### Understanding YAMLData
%[text] The data is returned as a `YAMLData` object - a custom type designed to work naturally with YAML files. It works mostly like a struct, but preserves key order and handles special characters in field names.
%[text] Access individual values using dot notation:
port = config.port %[output:2e9a802b]
%%
%[text] ### Modifying Values
%[text] Change values just like you would with a struct:
config.port = 9000;
config.debug = false;
config %[output:03a217ec]
%%
%[text] ### Dynamic Indexing
%[text] Just like a struct, use dynamic field access when the field name is in a variable:
fieldName = "version";
currentVersion = config.(fieldName) %[output:05d2e5a9]
%%
%[text] ### Handling Keys with Hyphens
%[text] Unlike MATLAB names, YAML names might include a hyphen. You can access these using the same syntax that table uses for referencing variables that aren"t valid MATLAB names:
appName = config.("app-name") %[output:9c315967]
%[text] As a convenience, you can also refer to these names using undescore (\_) instead of hyphen (-):
appName = config.app_name %[output:5efc4fe0]
%%
%[text] ### Reading Hierarchical YAML
%[text] Most configuration files have nested structure. Let's read a more complex example:
server = readyaml("examples/server_config.yaml") %[output:0ac3e6f6]
%%
%[text] ### Multi-Level Dot Indexing
%[text] Just like struct, read nested values with dot:
creds = server.database.credentials %[output:4fdcf276]
%[text] Write with dot:
server.database.credentials.username = "Michelle";
server.database.credentials %[output:0880e28f]
%%
%[text] ### Formatted display
%[text] Especially for deeply nested data, it can be convenient to see the all of the data at once. Either click on the "Show all values" hyperlink, or call `show`.
show(server) %[output:6194d526]
%%
%[text] ### Introspection
%[text] Get all top-level keys:
topKeys = keys(server) %[output:061450cc]
%[text] Check if a key is defined:
tf = iskey(server.application,"name") %[output:65de7449]
%[text] 
%%
%[text] ### Add and remove keys
%[text] Add new keys or remove existing ones:
server.cache.enabled = true;
server.cache.size = 1000;
server = remove(server, "logging");
keys(server) %[output:5c17a1d0]
%%
%[text] ### Using familiar MATLAB struct functions
%[text] Familiar MATLAB struct functions `fieldnames` and `isfield` are also supported. These functions behave identically to `keys` and `iskey`.
fieldnames(server) %[output:9e5b4327]
%%
%[text] ### Data Type Conversion
%[text] YAML data types automatically map to corresponding MATLAB types:
%[text:table]
%[text] | **YAML Type** | **MATLAB Type** |
%[text] | --- | --- |
%[text] | String | string |
%[text] | Integer | double |
%[text] | Float | double |
%[text] | Boolean (true/false) | logical |
%[text] | Null | missing |
%[text] | Sequence of numbers | double array |
%[text] | Sequence of strings | string array |
%[text] | Sequence of mixed types | cell array |
%[text] | Sequence of mappings | YAMLData array |
%[text:table]
%[text] Read a file with various array types:
arrays = readyaml("examples/arrays_config.yaml") %[output:3ea25a44]
%%
%[text] Numeric arrays convert to MATLAB numeric arrays:
ports = arrays.web.ports %[output:84bf9bab]
class(ports) %[output:06890f6d]
%%
%[text] String arrays convert to MATLAB string arrays:
hosts = arrays.web.hosts %[output:53c93965]
class(hosts) %[output:38d77b1e]
%%
%[text] Mixed-type arrays become cell arrays:
settings = arrays.web.settings %[output:061fbefb]
class(settings) %[output:6ae027a2]
%%
%[text] ### Force YAML arrays to convert to cell arrays with SequenceRule
%[text] By default, arrays are converted based on their content (auto mode). If you want consistent behavior regardless of content, set `SequenceRule` `=` "`cell"` to always get cell arrays
arraysCell = readyaml("examples/arrays_config.yaml", SequenceRule="cell");
portsCell = arraysCell.web.ports %[output:77533ed3]
class(portsCell) %[output:4f03c25e]
%%
%[text] ## Writing YAML Files
%[text] After modifying configuration, write it back. Let"s read, modify, and save:
config = readyaml("examples/basic_config.yaml");
config.port = 9000;
config.("max-connections") = 100;
writeyaml(config, "examples/modified_config.yaml");
disp("Configuration saved!") %[output:542d98a1]
%%
%[text] View what was written:
type("examples/modified_config.yaml") %[output:6d15ce2b]
%%
%[text] ### Controlling YAML Output Format
%[text] YAML supports two styles of arrays: flow (inline) and block. Use `ArrayStyle` to control how arrays are formatted:
yml = YAMLData;
yml.ports = [8080, 8443, 9000];
%[text] Flow style (inline):
writeyaml(yml, "examples/flow_style.yaml", ArrayStyle="flow");
type("examples/flow_style.yaml") %[output:45af47d4]
%%
%[text] Block style (vertical list; default):
writeyaml(yml, "examples/block_style.yaml", ArrayStyle="block");
type("examples/block_style.yaml") %[output:2fed753d]
%%
%[text] Remove spacing between sections:
writeyaml(config, "examples/compact.yaml", SectionSpacing="compact");
type("examples/compact.yaml") %[output:61241ad7]
%%
%[text] ## Working with TOML Files
%[text] TOML files work similarly. Data is returned as `TOMLData`, which is like `YAMLData` but specialized for TOML.
%[text] Read a simple TOML file:
project = readtoml("examples/simple_project.toml") %[output:48320ebd]
%%
%[text] Access nested values:
projectName = project.project.name %[output:98afe2dd]
%%
%[text] TOML also handles keys with hyphens:
buildSystem = project.("build-system") %[output:1e600743]
requires = project.("build-system").requires %[output:6d96ee23]
%%
%[text] Modify and write back:
project.project.version = "2.0.0";
project.project.("new-field") = "new value";
writetoml(project, "examples/modified_project.toml");
type("examples/modified_project.toml") %[output:537125a6]
%%
%[text] ### TOML Formatting Options
%[text] `writetoml` offers extensive formatting control. Here are common options:
%[text] TOML also supports flow and block array styles. The default for `ArrayStyle` is `auto`, which users heuristics to write small arrays with flow style and larger arrays with block. Use `ArrayStyle` `"flow"` or `"block"` to force one style.
%[text] Control array style:
project = TOMLData;
project.dependencies = ["export_fig", "guilayout", "fsda"];
writetoml(project, "examples/array_flow.toml", ArrayStyle="flow")
type("examples/array_flow.toml") %[output:2b0c4e57]
writetoml(project, "examples/array_block.toml", ArrayStyle="block")
type("examples/array_block.toml") %[output:0755fd5a]
%[text] TOML has multiple string styles. Use literal strings (`''`) to avoid the need to escape special characters. Control string formatting for paths (useful for Windows paths):
project.paths.data = 'C:\Users\Data';
writetoml(project, "examples/literal_strings.toml", StringEscapeStyle="literal")
type("examples/literal_strings.toml") %[output:57ecfa34]
%%
%[text] ## Summary
%[text] You've learned how to:
%[text] - Read YAML and TOML files into intuitive data objects
%[text] - Access values with dot notation, including keys with special characters
%[text] - Use automatic aliasing for hyphenated keys
%[text] - Explore configuration files with `keys` and `isfield`
%[text] - Modify configurations programmatically
%[text] - Understand how arrays are converted (`SequenceRule`)
%[text] - Write files with formatting control (`ArrayStyle`, `SectionSpacing`, `StringEscapeStyle`) \
%[text] For more focused examples, see:
%[text] - `examples/readtomlExample.m` - Advanced TOML reading features
%[text] - `examples/writetomlExample.m` - Complete TOML formatting options
%[text] - `examples/readyamlExample.m` - YAML reading and array handling
%[text] - `examples/writeyamlExample.m` - YAML formatting options \
%%
%[text] ## Cleanup
delete("examples/modified_config.yaml", "examples/flow_style.yaml", ...
       "examples/block_style.yaml", "examples/compact.yaml", ...
       "examples/modified_project.toml", "examples/array_flow.toml", ...
       "examples/array_block.toml", "examples/literal_strings.toml");

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
%[output:43646e19]
%   data: {"dataType":"textualVariable","outputData":{"name":"config","value":"  <a href=\"matlab:helpPopup('YAMLData')\" style=\"font-weight:bold\">YAMLData<\/a> with keys:\n\n    app-name: \"MyApplication\"\n    version: \"1.2.0\"\n    port: 8080\n    debug: true\n    author: \"Jane Doe\"\n"}}
%---
%[output:2e9a802b]
%   data: {"dataType":"textualVariable","outputData":{"name":"port","value":"8080"}}
%---
%[output:03a217ec]
%   data: {"dataType":"textualVariable","outputData":{"name":"config","value":"  <a href=\"matlab:helpPopup('YAMLData')\" style=\"font-weight:bold\">YAMLData<\/a> with keys:\n\n    app-name: \"MyApplication\"\n    version: \"1.2.0\"\n    port: 9000\n    debug: false\n    author: \"Jane Doe\"\n"}}
%---
%[output:05d2e5a9]
%   data: {"dataType":"textualVariable","outputData":{"name":"currentVersion","value":"\"1.2.0\""}}
%---
%[output:9c315967]
%   data: {"dataType":"textualVariable","outputData":{"name":"appName","value":"\"MyApplication\""}}
%---
%[output:5efc4fe0]
%   data: {"dataType":"textualVariable","outputData":{"name":"appName","value":"\"MyApplication\""}}
%---
%[output:0ac3e6f6]
%   data: {"dataType":"textualVariable","outputData":{"name":"server","value":"  <a href=\"matlab:helpPopup('YAMLData')\" style=\"font-weight:bold\">YAMLData<\/a> with keys:\n\n    application: [1×1 YAMLData with 3 keys]\n    database: [1×1 YAMLData with 4 keys]\n    logging: [1×1 YAMLData with 2 keys]\n\n    <a href=\"matlab:show(server)\">Show all values<\/a>\n"}}
%---
%[output:4fdcf276]
%   data: {"dataType":"textualVariable","outputData":{"name":"creds","value":"  <a href=\"matlab:helpPopup('YAMLData')\" style=\"font-weight:bold\">YAMLData<\/a> with keys:\n\n    username: \"admin\"\n    password: \"secret123\"\n"}}
%---
%[output:0880e28f]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"  <a href=\"matlab:helpPopup('YAMLData')\" style=\"font-weight:bold\">YAMLData<\/a> with keys:\n\n    username: \"Michelle\"\n    password: \"secret123\"\n"}}
%---
%[output:6194d526]
%   data: {"dataType":"text","outputData":{"text":"application:\n  name: WebServer\n  version: 2.0.0\n  environment: production\n\ndatabase:\n  host: localhost\n  port: 5432\n  name: mydb\n  credentials:\n    username: Michelle\n    password: secret123\n\nlogging:\n  level: info\n  file: \/var\/log\/app.log\n","truncated":false}}
%---
%[output:061450cc]
%   data: {"dataType":"matrix","outputData":{"columns":3,"header":"1×3 string array","name":"topKeys","rows":1,"type":"string","value":[["application","database","logging"]]}}
%---
%[output:65de7449]
%   data: {"dataType":"textualVariable","outputData":{"header":"logical","name":"tf","value":"   1\n"}}
%---
%[output:5c17a1d0]
%   data: {"dataType":"matrix","outputData":{"columns":3,"header":"1×3 string array","name":"ans","rows":1,"type":"string","value":[["application","database","cache"]]}}
%---
%[output:9e5b4327]
%   data: {"dataType":"matrix","outputData":{"columns":3,"header":"1×3 string array","name":"ans","rows":1,"type":"string","value":[["application","database","cache"]]}}
%---
%[output:3ea25a44]
%   data: {"dataType":"textualVariable","outputData":{"name":"arrays","value":"  <a href=\"matlab:helpPopup('YAMLData')\" style=\"font-weight:bold\">YAMLData<\/a> with keys:\n\n    web: [1×1 YAMLData with 3 keys]\n    services: [3x1 string]\n    mixed: [1x2 YAMLData]\n\n    <a href=\"matlab:show(arrays)\">Show all values<\/a>\n"}}
%---
%[output:84bf9bab]
%   data: {"dataType":"matrix","outputData":{"columns":1,"name":"ports","rows":3,"type":"double","value":[["8080"],["8443"],["9000"]]}}
%---
%[output:06890f6d]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"'double'"}}
%---
%[output:53c93965]
%   data: {"dataType":"matrix","outputData":{"columns":1,"header":"3×1 string array","name":"hosts","rows":3,"type":"string","value":[["alpha"],["beta"],["gamma"]]}}
%---
%[output:38d77b1e]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"'string'"}}
%---
%[output:061fbefb]
%   data: {"dataType":"tabular","outputData":{"columns":1,"header":"3×1 cell array","name":"settings","rows":3,"type":"cell","value":[["\"production\""],["8080"],["1"]]}}
%---
%[output:6ae027a2]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"'cell'"}}
%---
%[output:77533ed3]
%   data: {"dataType":"tabular","outputData":{"columns":1,"header":"3×1 cell array","name":"portsCell","rows":3,"type":"cell","value":[["8080"],["8443"],["9000"]]}}
%---
%[output:4f03c25e]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"'cell'"}}
%---
%[output:542d98a1]
%   data: {"dataType":"text","outputData":{"text":"Configuration saved!\n","truncated":false}}
%---
%[output:6d15ce2b]
%   data: {"dataType":"text","outputData":{"text":"\napp-name: MyApplication\n\nversion: 1.2.0\n\nport: 9000\n\ndebug: true\n\nauthor: Jane Doe\n\nmax-connections: 100\n","truncated":false}}
%---
%[output:45af47d4]
%   data: {"dataType":"text","outputData":{"text":"\nports: [8080, 8443, 9000]\n","truncated":false}}
%---
%[output:2fed753d]
%   data: {"dataType":"text","outputData":{"text":"\nports:\n  - 8080\n  - 8443\n  - 9000\n","truncated":false}}
%---
%[output:61241ad7]
%   data: {"dataType":"text","outputData":{"text":"\napp-name: MyApplication\nversion: 1.2.0\nport: 9000\ndebug: true\nauthor: Jane Doe\nmax-connections: 100\n","truncated":false}}
%---
%[output:48320ebd]
%   data: {"dataType":"textualVariable","outputData":{"name":"project","value":"  <a href=\"matlab:helpPopup('TOMLData')\" style=\"font-weight:bold\">TOMLData<\/a> with keys:\n\n    project: [1×1 TOMLData with 4 keys]\n    build-system: [1×1 TOMLData with 2 keys]\n\n    <a href=\"matlab:show(project)\">Show all values<\/a>\n"}}
%---
%[output:98afe2dd]
%   data: {"dataType":"textualVariable","outputData":{"name":"projectName","value":"\"example-package\""}}
%---
%[output:1e600743]
%   data: {"dataType":"textualVariable","outputData":{"name":"buildSystem","value":"  <a href=\"matlab:helpPopup('TOMLData')\" style=\"font-weight:bold\">TOMLData<\/a> with keys:\n\n    requires: [1x2 string]\n    build-backend: \"setuptools.build_meta\"\n"}}
%---
%[output:6d96ee23]
%   data: {"dataType":"matrix","outputData":{"columns":2,"header":"1×2 string array","name":"requires","rows":1,"type":"string","value":[["setuptools>=61.0","wheel"]]}}
%---
%[output:537125a6]
%   data: {"dataType":"text","outputData":{"text":"\n[project]\nname = \"example-package\"\nversion = \"2.0.0\"\ndescription = \"An example project\"\nnew-field = \"new value\"\n\n[project.urls]\nhomepage = \"https:\/\/github.com\/example\/project\"\nrepository = \"https:\/\/github.com\/example\/project.git\"\n\n[build-system]\nrequires = [\"setuptools>=61.0\", \"wheel\"]\nbuild-backend = \"setuptools.build_meta\"\n","truncated":false}}
%---
%[output:2b0c4e57]
%   data: {"dataType":"text","outputData":{"text":"\ndependencies = [\"export_fig\", \"guilayout\", \"fsda\"]\n","truncated":false}}
%---
%[output:0755fd5a]
%   data: {"dataType":"text","outputData":{"text":"\ndependencies = [\n  \"export_fig\",\n  \"guilayout\",\n  \"fsda\"\n]\n","truncated":false}}
%---
%[output:57ecfa34]
%   data: {"dataType":"text","outputData":{"text":"\ndependencies = ['export_fig', 'guilayout', 'fsda']\n\n[paths]\ndata = 'C:\\Users\\Data'\n","truncated":false}}
%---
