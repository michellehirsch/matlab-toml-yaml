%[text] # Configuration File I/O - Getting Started
%[text] Learn how to read and write YAML and TOML configuration files in MATLAB with intuitive dot notation access.
%%
%[text] ## Reading a Basic YAML File
%[text] Start by reading a simple configuration file with no hierarchy.
config = readyaml("examples/basic_config.yaml") %[output:6d3abc7b]
%%
%[text] ## Understanding YAMLData
%[text] The data is returned as a `YAMLData` object - a custom type designed to work naturally with YAML files. It works mostly like a struct, but preserves key order and handles special characters in field names.
%[text] Access individual values using dot notation:
port = config.port %[output:2e9a802b]
%%
%[text] ## Modifying Values
%[text] Change values just like you would with a struct:
config.port = 9000;
config.debug = false;
config %[output:03a217ec]
%%
%[text] ## Dynamic Indexing
%[text] Just like a struct, use dynamic field access when the field name is in a variable:
fieldName = "version";
currentVersion = config.(fieldName) %[output:05d2e5a9]
%%
%[text] ## Handling Keys with Hyphens
%[text] Unlike MATLAB names, YAML names might include a hyphen. You can access these using the same syntax that table uses for referencing variables that aren"t valid MATLAB names:
appName = config.("app-name") %[output:9c315967]
%[text] As a convenience, you can also refer to these names using undescore (\_) instead of hyphen (-):
appName = config.app_name %[output:5efc4fe0]
%%
%[text] ## Reading Hierarchical YAML
%[text] Most configuration files have nested structure. Let"s read a more complex example:
server = readyaml("examples/server_config.yaml") %[output:0ac3e6f6]
%%
%[text] ## Multi-Level Dot Indexing
%[text] Access nested values naturally:
dbHost = server.database.host %[output:4fdcf276]
username = server.database.credentials.username %[output:93262560]
logLevel = server.logging.level %[output:22d1d835]
%%
%[text] ## The show() Method
%[text] For deeply nested structures, use `show()` to display the full content in YAML format. You can also just click on the "Show all values" hyperlink:
show(server) %[output:6194d526]
%%
%[text] ## Introspection
%[text] You can use `keys,` `iskey`, and `remove`, or `fieldnames,` `isfield`, and `rmfield`. These functions are the same, just supporting different terminolgy.
%[text] Get all top-level keys:
topKeys = keys(server) %[output:061450cc]
%%
%[text] The `fieldnames()` method works too:
topFields = fieldnames(server) %[output:110fedab]
%%
%[text] Check if a key exists:
hasDatabase = iskey(server, "database") %[output:3058da76]
hasCache = isfield(server, "cache") %[output:164bf4df]
%%
%[text] ## Modifying Configuration Programmatically
%[text] Add new fields or remove existing ones:
server.cache.enabled = true;
server.cache.size = 1000;
server = rmfield(server, "logging");
keys(server) %[output:5c17a1d0]
%%
%[text] ## Understanding Array Conversion
%[text] YAML arrays convert to different MATLAB types based on their content. Read a file with various array types:
arrays = readyaml("examples/arrays_config.yaml") %[output:21e81206]
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
settings = arrays.web.settings %[output:593da091]
class(settings) %[output:97db5b19]
%%
%[text] ## The SequenceRule Option
%[text] By default, arrays are converted based on their content (auto mode). If you want consistent behavior regardless of content - for example, if a file might change from a single value to multiple values - use `SequenceRule` set to "`cell"` to always get cell arrays:
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
disp("Configuration saved!") %[output:97d62e65]
%%
%[text] View what was written:
type("examples/modified_config.yaml") %[output:59c9ff08]
%%
%[text] ## Controlling Output Format
%[text] Use `ArrayStyle` to control how arrays are formatted:
config.ports = [8080, 8443, 9000];
%[text]
%[text] Flow style (inline):
writeyaml(config, "examples/flow_style.yaml", ArrayStyle="flow");
type("examples/flow_style.yaml") %[output:3801d647]
%%
%[text] Block style (vertical list):
writeyaml(config, "examples/block_style.yaml", ArrayStyle="block");
type("examples/block_style.yaml") %[output:0dd64c3c]
%%
%[text] Control spacing between sections:
writeyaml(config, "examples/compact.yaml", SectionSpacing="compact");
disp("Compact spacing removes blank lines between top-level keys") %[output:425dc22e]
%%
%[text] ## Working with TOML Files
%[text] TOML files work similarly. Data is returned as `TOMLData`, which is like `YAMLData` but specialized for TOML.
%[text] 
%[text] Read a simple TOML file:
project = readtoml("examples/simple_project.toml") %[output:0bd7ab5f]
%%
%[text] Access nested values:
projectName = project.project.name %[output:4dd56da8]
homepage = project.project.urls.homepage %[output:50a074c2]
%%
%[text] TOML also handles keys with hyphens:
buildSystem = project.("build-system") %[output:4a644df4]
requires = project.("build-system").requires %[output:20b7a578]
%%
%[text] Modify and write back:
project.project.version = "2.0.0";
project.project.("new-field") = "new value";
writetoml(project, "examples/modified_project.toml");
type("examples/modified_project.toml") %[output:8d534e59]
%%
%[text] ## TOML Formatting Options
%[text] `writetoml` offers extensive formatting control. Here are common options:
%[text]
%[text] Control array style:
project.dependencies = ["numpy", "pandas", "matplotlib"];
writetoml(project, "examples/array_flow.toml", ArrayStyle="flow");
writetoml(project, "examples/array_block.toml", ArrayStyle="block");
%[text]
%[text] Control string formatting for paths (useful for Windows paths):
project.paths.data = 'C:\Users\Data';
writetoml(project, "examples/literal_strings.toml", StringEscapeStyle="literal");
disp("Literal strings avoid double-backslash escaping") %[output:literal_msg]
%%
%[text] ## Summary
%[text] You"ve learned how to:
%[text] - Read YAML and TOML files into intuitive data objects
%[text] - Access values with dot notation, including keys with special characters
%[text] - Use automatic aliasing for hyphenated keys
%[text] - Explore configuration files with `keys()` and `isfield()`
%[text] - Modify configurations programmatically
%[text] - Understand how arrays are converted (`SequenceRule`)
%[text] - Write files with formatting control (`ArrayStyle`, `SectionSpacing`, `StringEscapeStyle`)
%[text]
%[text] For more focused examples, see:
%[text] - `examples/ReadTOMLExample.m` - Advanced TOML reading features
%[text] - `examples/WriteTOMLExample.m` - Complete TOML formatting options
%[text] - `examples/ReadYAMLExample.m` - YAML reading and array handling
%[text] - `examples/WriteYAMLExample.m` - YAML formatting options
%[text] - `examples/ConfigurationDataExample.m` - Working with the ConfigurationData class
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
%[output:6d3abc7b]
%   data: {"dataType":"textualVariable","outputData":{"name":"config","value":"  <a href=\"matlab:helpPopup('YAMLData')\" style=\"font-weight:bold\">YAMLData<\/a> with properties:\n\n    app-name: \"MyApplication\"\n    version: \"1.2.0\"\n    port: 8080\n    debug: true\n    author: \"Jane Doe\"\n"}}
%---
%[output:2e9a802b]
%   data: {"dataType":"textualVariable","outputData":{"name":"port","value":"8080"}}
%---
%[output:03a217ec]
%   data: {"dataType":"textualVariable","outputData":{"name":"config","value":"  <a href=\"matlab:helpPopup('YAMLData')\" style=\"font-weight:bold\">YAMLData<\/a> with properties:\n\n    app-name: \"MyApplication\"\n    version: \"1.2.0\"\n    port: 9000\n    debug: false\n    author: \"Jane Doe\"\n"}}
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
%   data: {"dataType":"textualVariable","outputData":{"name":"server","value":"  <a href=\"matlab:helpPopup('YAMLData')\" style=\"font-weight:bold\">YAMLData<\/a> with properties:\n\n    application: [1×1 YAMLData with 3 fields]\n    database: [1×1 YAMLData with 4 fields]\n    logging: [1×1 YAMLData with 2 fields]\n\n    <a href=\"matlab:show(server)\">Show all values<\/a>\n"}}
%---
%[output:4fdcf276]
%   data: {"dataType":"textualVariable","outputData":{"name":"dbHost","value":"\"localhost\""}}
%---
%[output:93262560]
%   data: {"dataType":"textualVariable","outputData":{"name":"username","value":"\"admin\""}}
%---
%[output:22d1d835]
%   data: {"dataType":"textualVariable","outputData":{"name":"logLevel","value":"\"info\""}}
%---
%[output:6194d526]
%   data: {"dataType":"text","outputData":{"text":"application:\n  name: WebServer\n  version: 2.0.0\n  environment: production\n\ndatabase:\n  host: localhost\n  port: 5432\n  name: mydb\n  credentials:\n    username: admin\n    password: secret123\n\nlogging:\n  level: info\n  file: \/var\/log\/app.log\n","truncated":false}}
%---
%[output:061450cc]
%   data: {"dataType":"matrix","outputData":{"columns":3,"header":"1×3 string array","name":"topKeys","rows":1,"type":"string","value":[["application","database","logging"]]}}
%---
%[output:110fedab]
%   data: {"dataType":"matrix","outputData":{"columns":3,"header":"1×3 string array","name":"topFields","rows":1,"type":"string","value":[["application","database","logging"]]}}
%---
%[output:3058da76]
%   data: {"dataType":"textualVariable","outputData":{"header":"logical","name":"hasDatabase","value":"   1\n"}}
%---
%[output:164bf4df]
%   data: {"dataType":"textualVariable","outputData":{"header":"logical","name":"hasCache","value":"   0\n"}}
%---
%[output:5c17a1d0]
%   data: {"dataType":"matrix","outputData":{"columns":3,"header":"1×3 string array","name":"ans","rows":1,"type":"string","value":[["application","database","cache"]]}}
%---
%[output:21e81206]
%   data: {"dataType":"textualVariable","outputData":{"name":"arrays","value":"  <a href=\"matlab:helpPopup('YAMLData')\" style=\"font-weight:bold\">YAMLData<\/a> with properties:\n\n    web: [1×1 YAMLData with 3 fields]\n    services: [3x1 string]\n    mixed: [1x2 YAMLData]\n\n    <a href=\"matlab:show(arrays)\">Show all values<\/a>\n"}}
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
%[output:593da091]
%   data: {"dataType":"matrix","outputData":{"columns":1,"header":"3×1 string array","name":"settings","rows":3,"type":"string","value":[["timeout: 30"],["retries: 3"],["debug: true"]]}}
%---
%[output:97db5b19]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"'string'"}}
%---
%[output:77533ed3]
%   data: {"dataType":"tabular","outputData":{"columns":1,"header":"3×1 cell array","name":"portsCell","rows":3,"type":"cell","value":[["8080"],["8443"],["9000"]]}}
%---
%[output:4f03c25e]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"'cell'"}}
%---
%[output:97d62e65]
%   data: {"dataType":"text","outputData":{"text":"Configuration saved!\n","truncated":false}}
%---
%[output:59c9ff08]
%   data: {"dataType":"text","outputData":{"text":"\napp-name: MyApplication\n\nversion: 1.2.0\n\nport: 9000\n\ndebug: true\n\nauthor: Jane Doe\n\nmax-connections: 100\n","truncated":false}}
%---
%[output:3801d647]
%   data: {"dataType":"text","outputData":{"text":"\napp-name: MyApplication\n\nversion: 1.2.0\n\nport: 9000\n\ndebug: true\n\nauthor: Jane Doe\n\nmax-connections: 100\n\nports: [8080, 8443, 9000]\n","truncated":false}}
%---
%[output:0dd64c3c]
%   data: {"dataType":"text","outputData":{"text":"\napp-name: MyApplication\n\nversion: 1.2.0\n\nport: 9000\n\ndebug: true\n\nauthor: Jane Doe\n\nmax-connections: 100\n\nports:\n  - 8080\n  - 8443\n  - 9000\n","truncated":false}}
%---
%[output:425dc22e]
%   data: {"dataType":"text","outputData":{"text":"Compact spacing removes blank lines between top-level keys\n","truncated":false}}
%---
%[output:0bd7ab5f]
%   data: {"dataType":"textualVariable","outputData":{"name":"project","value":"  <a href=\"matlab:helpPopup('TOMLData')\" style=\"font-weight:bold\">TOMLData<\/a> with properties:\n\n    project: [1×1 TOMLData with 4 fields]\n    build-system: [1×1 TOMLData with 2 fields]\n\n    <a href=\"matlab:show(project)\">Show all values<\/a>\n"}}
%---
%[output:4dd56da8]
%   data: {"dataType":"textualVariable","outputData":{"name":"projectName","value":"\"example-package\""}}
%---
%[output:50a074c2]
%   data: {"dataType":"textualVariable","outputData":{"name":"homepage","value":"\"https:\/\/github.com\/example\/project\""}}
%---
%[output:4a644df4]
%   data: {"dataType":"textualVariable","outputData":{"name":"buildSystem","value":"  <a href=\"matlab:helpPopup('TOMLData')\" style=\"font-weight:bold\">TOMLData<\/a> with properties:\n\n    requires: [1x2 string]\n    build-backend: \"setuptools.build_meta\"\n"}}
%---
%[output:20b7a578]
%   data: {"dataType":"matrix","outputData":{"columns":2,"header":"1×2 string array","name":"requires","rows":1,"type":"string","value":[["setuptools>=61.0","wheel"]]}}
%---
%[output:8d534e59]
%   data: {"dataType":"text","outputData":{"text":"\n[project]\nname = \"example-package\"\nversion = \"2.0.0\"\ndescription = \"An example project\"\nnew-field = \"new value\"\n\n[project.urls]\nhomepage = \"https:\/\/github.com\/example\/project\"\nrepository = \"https:\/\/github.com\/example\/project.git\"\n\n[build-system]\nrequires = [\"setuptools>=61.0\", \"wheel\"]\nbuild-backend = \"setuptools.build_meta\"\n","truncated":false}}
%---
