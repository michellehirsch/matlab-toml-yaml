%[text] # ConfigurationDataExample - Working with ConfigurationData, TOMLData, and YAMLData
%[text] This example demonstrates the ConfigurationData class and its subclasses (TOMLData and YAMLData), showing how to create, access, modify, and convert configuration data objects.
%%
%[text] ## ConfigurationData Overview
%[text] ConfigurationData is a handle class that provides dot notation access to configuration data with support for keys containing special characters.
%[text] Key features:
%[text] - Dot notation access: config.key
%[text] - Special character support: config.("key-with-hyphens")
%[text] - Automatic aliasing for hyphenated keys
%[text] - Preserved key order
%[text] - Handle class behavior (pass by reference)\\ \
%%
%[text] ## Creating ConfigurationData Objects
%[text] Create a new ConfigurationData object
config = ConfigurationData;
%[text] Empty ConfigurationData object:
config %[output:78054ccd]
%%
%[text] Add fields using dot notation
config.name = "MyApp";
config.version = "1.0.0";
config.port = 8080;
config.debug = true;
%[text] ConfigurationData with fields:
config %[output:8c90c38a]
%%
%[text] ## Accessing Data with Dot Notation
config.name
%%
%[text] ## Working with Special Characters in Keys
%[text] Keys with hyphens, dots, or spaces require special syntax
config.("app-name") = "MyApplication";
config.("max-connections") = 100;
config.("build-version") = "2.0.0";
%[text] Access with dynamic field name referencing syntax
config.("app-name") %[output:699558d7]
%%
%[text] Keys with hyphens can also be accessed through an alias using an underscore:
config.app_name
%[text] The name with underscore is simply an alias. Only the original name is included in the list of keys:
keys(config) %[output:1eda3551]
%%
%[text] ## Nested Structures
%[text] Create nested configuration structures
config.database.host = "localhost";
config.database.port = 5432;
config.database.credentials.username = "admin";
config.database.credentials.password = "secret";
%[text] Nested structure:
config.database %[output:8e67bf86]
%%
%[text] Navigate nested structures
config.database.host
%%
%[text] ## Exploring Configuration Structure
%[text] Use keys to list all top-level keys
allKeys = keys(config);
%[text] All top-level keys:
allKeys %[output:16387c3a]
%%
%[text] Check if specific fields exist
if isfield(config, "database") %[output:group:3d4fe2b2]
    disp("Database configuration exists") %[output:10d5dd44]
end %[output:group:3d4fe2b2]
if ~isfield(config, "nonexistent") %[output:group:5c2178e7]
    disp("Nonexistent field does not exist") %[output:05c71578]
end %[output:group:5c2178e7]
%%
%[text] Alternative syntax: iskey
if iskey(config, "name") %[output:group:9f860c58]
    disp("Name field exists") %[output:5a8b9627]
end %[output:group:9f860c58]
%%
%[text] ## Handle Class Behavior
%[text] ConfigurationData is a handle class - assignments create references
config1 = ConfigurationData;
config1.value = 42;
%[text] This creates a reference, not a copy
config2 = config1;
config2.value = 100;
%[text] Original is modified because config2 is a reference
config1.value
%%
%[text] Use copy to create an independent copy
config3 = copy(config1);
config3.value = 200;
%[text] Original is NOT modified - config1 still has value 100
config1.value
%%
%[text] ## Converting to Struct
%[text] Convert ConfigurationData to a standard MATLAB struct
configStruct = struct(config);
%[text] Converted to struct:
configStruct %[output:80771474]
%%
%[text] Struct conversion is useful for:
%[text] - Interfacing with code that expects structs
%[text] - Serialization
%[text] - Comparison operations\\ \
%%
%[text] ## TOMLData - Specialized for TOML Files
%[text] TOMLData extends ConfigurationData for TOML-specific features
tomlData = TOMLData;
tomlData.project.name = "my-package";
tomlData.project.version = "1.0.0";
tomlData.("build-system").requires = ["setuptools>=61.0", "wheel"];
%[text] TOMLData object:
tomlData %[output:39f411e5]
%%
%[text] Write to TOML file
writetoml(tomlData, "sample.toml");
%[text] Written TOML file:
type("sample.toml") %[output:6fc9d96e]
%%
%[text] Read back from TOML file
readTomlData = readtoml("sample.toml");
%[text] Read back from TOML:
readTomlData
%%
%[text] ## YAMLData - Specialized for YAML Files
%[text] YAMLData extends ConfigurationData for YAML-specific features
yamlData = YAMLData;
yamlData.name = "CI";
yamlData.on.push.branches = ["main", "develop"];
yamlData.jobs.build.("runs-on") = "ubuntu-latest";
%[text] YAMLData object:
yamlData %[output:2c8d6421]
%%
%[text] Write to YAML file
writeyaml(yamlData, "sample.yaml");
%[text] Written YAML file:
type("sample.yaml") %[output:22e83765]
%%
%[text] Read back from YAML file
readYamlData = readyaml("sample.yaml");
%[text] Read back from YAML:
readYamlData
%%
%[text] ## Working with Arrays of ConfigurationData
%[text] Create arrays of configuration objects
steps = YAMLData.empty;
steps(1) = YAMLData;
steps(1).name = "Checkout";
steps(1).uses = "actions/checkout@v4";
steps(2) = YAMLData;
steps(2).name = "Build";
steps(2).run = "make build";
steps(3) = YAMLData;
steps(3).name = "Test";
steps(3).run = "make test";
%[text] Access array elements
%[text] Step array:
for i = 1:numel(steps) %[output:group:45771f09]
    fprintf("Step %d: %s\n", i, steps(i).name); %[output:754f286f]
end %[output:group:45771f09]
%%
%[text] Access using array indexing
steps(1).name
%%
%[text] ## Formatted Display with show
%[text] Use show for a formatted display of the configuration
workflow = YAMLData;
workflow.name = "CI Pipeline";
step1 = YAMLData;
step1.name = "Checkout";
step1.uses = "actions/checkout@v4";
step2 = YAMLData;
step2.name = "Build";
step2.run = "make build";
workflow.jobs.build.steps = [step1; step2];
%[text] Formatted display:
workflow.show %[output:4bc748d8]
%%
%[text] ## Removing Fields
%[text] Remove fields from configuration
removeExample = ConfigurationData;
removeExample.keep1 = "value1";
removeExample.remove_me = "value2";
removeExample.keep2 = "value3";
%[text] Before removal:
keys(removeExample) %[output:399668a6]
%[text] Remove a field
removeExample = rmfield(removeExample, "remove_me");
%[text] After removal:
keys(removeExample) %[output:5dc4ce6f]
%%
%[text] Alternative syntax: remove
removeExample.temporary = "temp value";
removeExample = remove(removeExample, "temporary");
%%
%[text] ## Modifying Nested Structures
%[text] Add and modify nested configuration
app = ConfigurationData;
app.server.host = "localhost";
app.server.port = 8080;
%[text] Initial server config:
app.server %[output:52c10bbd]
%%
%[text] Modify existing nested values
app.server.port = 9000;
app.server.ssl = true;
app.server.ssl_cert = "/path/to/cert.pem";
%[text] Modified server config:
app.server %[output:700a871f]
%%
%[text] ## SourceFormat Property
%[text] Track the original format of the data
tomlFromFile = readtoml("sample.toml");
tomlFromFile.SourceFormat
%%
%[text] ## Converting Between Formats
%[text] Read from one format, write to another
%[text] Read TOML
tomlConfig = readtoml("sample.toml");
%[text] Original TOML:
type("sample.toml") %[output:4d65c9f1]
%%
%[text] Write as YAML
writeyaml(tomlConfig, "converted.yaml");
%[text] Converted to YAML:
type("converted.yaml") %[output:977c07f1]
%%
%[text] Read YAML
yamlConfig = readyaml("sample.yaml");
%[text] Original YAML:
type("sample.yaml") %[output:66daeafd]
%%
%[text] Write as TOML
writetoml(yamlConfig, "converted.toml");
%[text] Converted to TOML:
type("converted.toml") %[output:53e5cc41]
%%
%[text] ## Practical Example: Managing Application Configuration
%[text] Complete example of application configuration management
%[text] Create application configuration
appConfig = ConfigurationData;
appConfig.application.name = "WebService";
appConfig.application.version = "2.0.0";
appConfig.application.environment = "production";
appConfig.server.host = "0.0.0.0";
appConfig.server.port = 8080;
appConfig.server.("worker-threads") = 4;
appConfig.database.host = "db.example.com";
appConfig.database.port = 5432;
appConfig.database.name = "myapp_prod";
appConfig.database.("connection-pool").("min-size") = 5;
appConfig.database.("connection-pool").("max-size") = 20;
appConfig.logging.level = "info";
appConfig.logging.outputs = ["console", "file"];
appConfig.logging.("file-path") = "/var/log/app.log";
appConfig.features.("rate-limiting") = true;
appConfig.features.caching = true;
appConfig.features.("metrics-collection") = true;
%[text] Application configuration structure:
appConfig %[output:6cfd09d2]
%%
%[text] Save as TOML for Python services
writetoml(appConfig, "app_config.toml", ...
    ArrayStyle="block", ...
    SectionSpacing="loose");
%[text] Saved as TOML (app\_config.toml):
type("app_config.toml") %[output:09fed976]
%%
%[text] Save as YAML for Kubernetes/Docker
writeyaml(appConfig, "app_config.yaml", ...
    ArrayStyle="block", ...
    SectionSpacing="loose");
%[text] Saved as YAML (app\_config.yaml):
type("app_config.yaml") %[output:9e157205]
%%
%[text] ## Best Practices
%[text] Best practices for ConfigurationData:
%[text] 1. Handle class behavior: \
%[text] -   - Remember that assignments create references
%[text] -   - Use copy to create independent copies \
%[text] 1. Special character keys: \
%[text] -   - Use config.("key-with-special-chars") syntax
%[text] -   - Be consistent with key naming conventions \
%[text] 1. Exploring unknown configurations: \
%[text] -   - Use keys to list available fields
%[text] -   - Use isfield to check for optional fields
%[text] -   - Use show during debugging \
%[text] 1. Converting between formats: \
%[text] -   - Read with readtoml or readyaml
%[text] -   - Write with writetoml or writeyaml
%[text] -   - Convert to struct when needed for other code \
%[text] 1. Nested structures: \
%[text] -   - Access with chained dot notation: config.a.b.c
%[text] -   - Can mix regular and special-character keys\\ \
%%
%[text] ## Cleanup
%[text] Delete temporary files
delete("sample.toml", "sample.yaml", "converted.yaml", "converted.toml", ...
    "app_config.toml", "app_config.yaml");

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:78054ccd]
%   data: {"dataType":"textualVariable","outputData":{"name":"config","value":"  <a href=\"matlab:helpPopup('ConfigurationData')\" style=\"font-weight:bold\">ConfigurationData<\/a> with properties:\n"}}
%---
%[output:8c90c38a]
%   data: {"dataType":"textualVariable","outputData":{"name":"config","value":"  <a href=\"matlab:helpPopup('ConfigurationData')\" style=\"font-weight:bold\">ConfigurationData<\/a> with properties:\n\n    name: \"MyApp\"\n    version: \"1.0.0\"\n    port: 8080\n    debug: true\n"}}
%---
%[output:699558d7]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"MyApplication\""}}
%---
%[output:1eda3551]
%   data: {"dataType":"matrix","outputData":{"columns":7,"header":"1×7 string array","name":"ans","rows":1,"type":"string","value":[["name","version","port","debug","app-name","max-connections","build-version"]]}}
%---
%[output:8e67bf86]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"  <a href=\"matlab:helpPopup('ConfigurationData')\" style=\"font-weight:bold\">ConfigurationData<\/a> with keys:\n\n    host: \"localhost\"\n    port: 5432\n    credentials: [1×1 ConfigurationData with 2 keys]\n\n    <a href=\"matlab:show(ans)\">Show all values<\/a>\n"}}
%---
%[output:16387c3a]
%   data: {"dataType":"matrix","outputData":{"columns":8,"header":"1×8 string array","name":"allKeys","rows":1,"type":"string","value":[["name","version","port","debug","app-name","max-connections","build-version","database"]]}}
%---
%[output:10d5dd44]
%   data: {"dataType":"text","outputData":{"text":"Database configuration exists\n","truncated":false}}
%---
%[output:05c71578]
%   data: {"dataType":"text","outputData":{"text":"Nonexistent field does not exist\n","truncated":false}}
%---
%[output:5a8b9627]
%   data: {"dataType":"text","outputData":{"text":"Name field exists\n","truncated":false}}
%---
%[output:80771474]
%   data: {"dataType":"textualVariable","outputData":{"header":"struct with fields:","name":"configStruct","value":"               name: \"MyApp\"\n            version: \"1.0.0\"\n               port: 8080\n              debug: 1\n           app_name: \"MyApplication\"\n    max_connections: 100\n      build_version: \"2.0.0\"\n           database: [1×1 struct]\n"}}
%---
%[output:39f411e5]
%   data: {"dataType":"textualVariable","outputData":{"name":"tomlData","value":"  <a href=\"matlab:helpPopup('TOMLData')\" style=\"font-weight:bold\">TOMLData<\/a> with properties:\n\n    project: [1×1 ConfigurationData with 2 fields]\n    build-system: [1×1 ConfigurationData]\n\n    <a href=\"matlab:show(tomlData)\">Show all values<\/a>\n"}}
%---
%[output:6fc9d96e]
%   data: {"dataType":"text","outputData":{"text":"\n[project]\nname = \"my-package\"\nversion = \"1.0.0\"\n\n[build-system]\nrequires = [\"setuptools>=61.0\", \"wheel\"]\n","truncated":false}}
%---
%[output:2c8d6421]
%   data: {"dataType":"textualVariable","outputData":{"name":"yamlData","value":"  <a href=\"matlab:helpPopup('YAMLData')\" style=\"font-weight:bold\">YAMLData<\/a> with properties:\n\n    name: \"CI\"\n    on: [1×1 ConfigurationData]\n    jobs: [1×1 ConfigurationData]\n\n    <a href=\"matlab:show(yamlData)\">Show all values<\/a>\n"}}
%---
%[output:22e83765]
%   data: {"dataType":"text","outputData":{"text":"\nname: CI\n\non:\n  push:\n    branches:\n      - main\n      - develop\n\njobs:\n  build:\n    runs-on: ubuntu-latest\n","truncated":false}}
%---
%[output:754f286f]
%   data: {"dataType":"text","outputData":{"text":"Step 1: Checkout\nStep 2: Build\nStep 3: Test\n","truncated":false}}
%---
%[output:4bc748d8]
%   data: {"dataType":"text","outputData":{"text":"name: CI Pipeline\n\njobs:\n  build:\n    steps:\n      - name: Checkout\n        uses: actions\/checkout@v4\n      - name: Build\n        run: make build\n","truncated":false}}
%---
%[output:399668a6]
%   data: {"dataType":"matrix","outputData":{"columns":3,"header":"1×3 string array","name":"ans","rows":1,"type":"string","value":[["keep1","remove_me","keep2"]]}}
%---
%[output:5dc4ce6f]
%   data: {"dataType":"matrix","outputData":{"columns":2,"header":"1×2 string array","name":"ans","rows":1,"type":"string","value":[["keep1","keep2"]]}}
%---
%[output:52c10bbd]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"  <a href=\"matlab:helpPopup('ConfigurationData')\" style=\"font-weight:bold\">ConfigurationData<\/a> with properties:\n\n    host: \"localhost\"\n    port: 8080\n"}}
%---
%[output:700a871f]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"  <a href=\"matlab:helpPopup('ConfigurationData')\" style=\"font-weight:bold\">ConfigurationData<\/a> with properties:\n\n    host: \"localhost\"\n    port: 9000\n    ssl: true\n    ssl_cert: \"\/path\/to\/cert.pem\"\n"}}
%---
%[output:4d65c9f1]
%   data: {"dataType":"text","outputData":{"text":"\n[project]\nname = \"my-package\"\nversion = \"1.0.0\"\n\n[build-system]\nrequires = [\"setuptools>=61.0\", \"wheel\"]\n","truncated":false}}
%---
%[output:977c07f1]
%   data: {"dataType":"text","outputData":{"text":"\nproject:\n  name: my-package\n  version: 1.0.0\n\nbuild-system:\n  requires:\n    - setuptools>=61.0\n    - wheel\n","truncated":false}}
%---
%[output:66daeafd]
%   data: {"dataType":"text","outputData":{"text":"\nname: CI\n\non:\n  push:\n    branches:\n      - main\n      - develop\n\njobs:\n  build:\n    runs-on: ubuntu-latest\n","truncated":false}}
%---
%[output:53e5cc41]
%   data: {"dataType":"text","outputData":{"text":"\nname = \"CI\"\n\n[on.push]\nbranches = [\"main\", \"develop\"]\n\n[jobs.build]\nruns-on = \"ubuntu-latest\"\n","truncated":false}}
%---
%[output:6cfd09d2]
%   data: {"dataType":"textualVariable","outputData":{"name":"appConfig","value":"  <a href=\"matlab:helpPopup('ConfigurationData')\" style=\"font-weight:bold\">ConfigurationData<\/a> with properties:\n\n    application: [1×1 ConfigurationData with 3 fields]\n    server: [1×1 ConfigurationData with 3 fields]\n    database: [1×1 ConfigurationData with 4 fields]\n    logging: [1×1 ConfigurationData with 3 fields]\n    features: [1×1 ConfigurationData with 3 fields]\n\n    <a href=\"matlab:show(appConfig)\">Show all values<\/a>\n"}}
%---
%[output:09fed976]
%   data: {"dataType":"text","outputData":{"text":"\n[application]\nname = \"WebService\"\nversion = \"2.0.0\"\nenvironment = \"production\"\n\n[server]\nhost = \"0.0.0.0\"\nport = 8080\nworker-threads = 4\n\n[database]\nhost = \"db.example.com\"\nport = 5432\nname = \"myapp_prod\"\n\n[database.connection-pool]\nmin-size = 5\nmax-size = 20\n\n[logging]\nlevel = \"info\"\noutputs = [\n  \"console\",\n  \"file\"\n]\nfile-path = \"\/var\/log\/app.log\"\n\n[features]\nrate-limiting = true\ncaching = true\nmetrics-collection = true\n","truncated":false}}
%---
%[output:9e157205]
%   data: {"dataType":"text","outputData":{"text":"\napplication:\n  name: WebService\n  version: 2.0.0\n  environment: production\n\nserver:\n  host: 0.0.0.0\n  port: 8080\n  worker-threads: 4\n\ndatabase:\n  host: db.example.com\n  port: 5432\n  name: myapp_prod\n  connection-pool:\n    min-size: 5\n    max-size: 20\n\nlogging:\n  level: info\n  outputs:\n    - console\n    - file\n  file-path: \/var\/log\/app.log\n\nfeatures:\n  rate-limiting: true\n  caching: true\n  metrics-collection: true\n","truncated":false}}
%---
