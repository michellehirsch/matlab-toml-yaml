%%
%[text] ## ConfigurationDataExample - Working with ConfigurationData, TOMLData, and YAMLData
%[text] This example demonstrates the ConfigurationData class and its subclasses (TOMLData and YAMLData), showing how to create, access, modify, and convert configuration data objects.
%%
%[text] ## ConfigurationData Overview
%[text] ConfigurationData is a handle class that provides dot notation access to configuration data with support for keys containing special characters.
%[text] Key features:
%[text] - Dot notation access: config.key
%[text] - Special character support: config.("key-with-hyphens")
%[text] - Automatic aliasing for hyphenated keys
%[text] - Preserved key order
%[text] - Handle class behavior (pass by reference)\
%%
%[text] ## Creating ConfigurationData Objects
%[text] Create a new ConfigurationData object
config = ConfigurationData();
%[text] Empty ConfigurationData object:
config
%%
%[text] Add fields using dot notation
config.name = "MyApp";
config.version = "1.0.0";
config.port = 8080;
config.debug = true;
%[text] ConfigurationData with fields:
config
%%
%[text] ## Accessing Data with Dot Notation
%[text] Access values using standard dot notation
"Application name: " + config.name
"Version: " + config.version
"Port: " + string(config.port)
"Debug mode: " + string(config.debug)
%%
%[text] ## Working with Special Characters in Keys
%[text] Keys with hyphens, dots, or spaces require special syntax
config.("app-name") = "MyApplication";
config.("max-connections") = 100;
config.("build-version") = "2.0.0";
%[text] Access with special character syntax
"App name: " + config.("app-name")
"Max connections: " + string(config.("max-connections"))
%%
%[text] Automatic aliasing for hyphenated keys
%[text] ConfigurationData creates camelCase aliases for hyphenated keys
config.("my-special-key") = "value";
%[text] Can access with either the original key or the alias
"Original key: " + config.("my-special-key")
%[text] Note: Aliases are automatically created where possible
%%
%[text] ## Nested Structures
%[text] Create nested configuration structures
config.database.host = "localhost";
config.database.port = 5432;
config.database.credentials.username = "admin";
config.database.credentials.password = "secret";
%[text] Nested structure:
config.database
%%
%[text] Navigate nested structures
"Database host: " + config.database.host
"Database username: " + config.database.credentials.username
%%
%[text] ## Exploring Configuration Structure
%[text] Use keys() to list all top-level keys
allKeys = config.keys();
%[text] All top-level keys:
allKeys
%%
%[text] Check if specific fields exist
if isfield(config, "database")
    disp("Database configuration exists")
end
if ~isfield(config, "nonexistent")
    disp("Nonexistent field does not exist")
end
%%
%[text] Alternative syntax: iskey()
if iskey(config, "name")
    disp("Name field exists")
end
%%
%[text] ## Handle Class Behavior
%[text] ConfigurationData is a handle class - assignments create references
config1 = ConfigurationData();
config1.value = 42;
%[text] This creates a reference, not a copy
config2 = config1;
config2.value = 100;
%[text] Original is modified because config2 is a reference
"config1.value after modifying config2: " + string(config1.value)
%%
%[text] Use copy() to create an independent copy
config3 = copy(config1);
config3.value = 200;
%[text] Original is NOT modified
"config1.value after modifying copy: " + string(config1.value)
"config3.value (independent copy): " + string(config3.value)
%%
%[text] ## Converting to Struct
%[text] Convert ConfigurationData to a standard MATLAB struct
configStruct = struct(config);
%[text] Converted to struct:
configStruct
%%
%[text] Struct conversion is useful for:
%[text] - Interfacing with code that expects structs
%[text] - Serialization
%[text] - Comparison operations\
%%
%[text] ## TOMLData - Specialized for TOML Files
%[text] TOMLData extends ConfigurationData for TOML-specific features
tomlData = TOMLData();
tomlData.project.name = "my-package";
tomlData.project.version = "1.0.0";
tomlData.("build-system").requires = ["setuptools>=61.0", "wheel"];
%[text] TOMLData object:
tomlData
%%
%[text] Write to TOML file
writetoml(tomlData, "sample.toml");
%[text] Written TOML file:
type("sample.toml")
%%
%[text] Read back from TOML file
readTomlData = readtoml("sample.toml");
%[text] Read back from TOML:
readTomlData
"Class: " + class(readTomlData)
%%
%[text] ## YAMLData - Specialized for YAML Files
%[text] YAMLData extends ConfigurationData for YAML-specific features
yamlData = YAMLData();
yamlData.name = "CI";
yamlData.on.push.branches = ["main", "develop"];
yamlData.jobs.build.("runs-on") = "ubuntu-latest";
%[text] YAMLData object:
yamlData
%%
%[text] Write to YAML file
writeyaml(yamlData, "sample.yaml");
%[text] Written YAML file:
type("sample.yaml")
%%
%[text] Read back from YAML file
readYamlData = readyaml("sample.yaml");
%[text] Read back from YAML:
readYamlData
"Class: " + class(readYamlData)
%%
%[text] ## Working with Arrays of ConfigurationData
%[text] Create arrays of configuration objects
steps = YAMLData.empty;
steps(1) = YAMLData();
steps(1).name = "Checkout";
steps(1).uses = "actions/checkout@v4";
steps(2) = YAMLData();
steps(2).name = "Build";
steps(2).run = "make build";
steps(3) = YAMLData();
steps(3).name = "Test";
steps(3).run = "make test";
%[text] Access array elements
%[text] Step array:
for i = 1:numel(steps)
    fprintf("Step %d: %s\n", i, steps(i).name);
end
%%
%[text] Access using array indexing
"First step name: " + steps(1).name
"Last step name: " + steps(end).name
%%
%[text] ## show() Method - Formatted Display
%[text] Use show() for a formatted display of the configuration
workflow = YAMLData();
workflow.name = "CI Pipeline";
workflow.jobs.build.steps(1).name = "Checkout";
workflow.jobs.build.steps(1).uses = "actions/checkout@v4";
workflow.jobs.build.steps(2).name = "Build";
workflow.jobs.build.steps(2).run = "make build";
%[text] Using show() method for formatted display:
workflow.show()
%%
%[text] ## Removing Fields
%[text] Remove fields from configuration
removeExample = ConfigurationData();
removeExample.keep1 = "value1";
removeExample.remove_me = "value2";
removeExample.keep2 = "value3";
%[text] Before removal:
removeExample.keys()
%[text] Remove a field
removeExample = rmfield(removeExample, "remove_me");
%[text] After removal:
removeExample.keys()
%%
%[text] Alternative syntax: remove()
removeExample.temporary = "temp value";
removeExample = remove(removeExample, "temporary");
%%
%[text] ## Modifying Nested Structures
%[text] Add and modify nested configuration
app = ConfigurationData();
app.server.host = "localhost";
app.server.port = 8080;
%[text] Initial server config:
app.server
%%
%[text] Modify existing nested values
app.server.port = 9000;
app.server.ssl = true;
app.server.ssl_cert = "/path/to/cert.pem";
%[text] Modified server config:
app.server
%%
%[text] ## SourceFormat Property
%[text] Track the original format of the data
tomlFromFile = readtoml("sample.toml");
"TOML data source format: " + tomlFromFile.SourceFormat
yamlFromFile = readyaml("sample.yaml");
"YAML data source format: " + yamlFromFile.SourceFormat
manualConfig = ConfigurationData();
"Manual ConfigurationData source format: " + manualConfig.SourceFormat
%%
%[text] ## Converting Between Formats
%[text] Read from one format, write to another
%[text] Read TOML
tomlConfig = readtoml("sample.toml");
%[text] Original TOML:
type("sample.toml")
%%
%[text] Write as YAML
writeyaml(tomlConfig, "converted.yaml");
%[text] Converted to YAML:
type("converted.yaml")
%%
%[text] Read YAML
yamlConfig = readyaml("sample.yaml");
%[text] Original YAML:
type("sample.yaml")
%%
%[text] Write as TOML
writetoml(yamlConfig, "converted.toml");
%[text] Converted to TOML:
type("converted.toml")
%%
%[text] ## Practical Example: Managing Application Configuration
%[text] Complete example of application configuration management
%[text] Create application configuration
appConfig = ConfigurationData();
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
appConfig.show()
%%
%[text] Save as TOML for Python services
writetoml(appConfig, "app_config.toml", ...
    ArrayStyle="block", ...
    SectionSpacing="loose");
%[text] Saved as TOML (app_config.toml):
type("app_config.toml")
%%
%[text] Save as YAML for Kubernetes/Docker
writeyaml(appConfig, "app_config.yaml", ...
    ArrayStyle="block", ...
    SectionSpacing="loose");
%[text] Saved as YAML (app_config.yaml):
type("app_config.yaml")
%%
%[text] ## Best Practices
%[text] Best practices for ConfigurationData:
%[text] 1. Handle class behavior:
%[text]    - Remember that assignments create references
%[text]    - Use copy() to create independent copies
%[text] 2. Special character keys:
%[text]    - Use config.("key-with-special-chars") syntax
%[text]    - Be consistent with key naming conventions
%[text] 3. Exploring unknown configurations:
%[text]    - Use keys() to list available fields
%[text]    - Use isfield() to check for optional fields
%[text]    - Use show() during debugging
%[text] 4. Converting between formats:
%[text]    - Read with readtoml() or readyaml()
%[text]    - Write with writetoml() or writeyaml()
%[text]    - Convert to struct when needed for other code
%[text] 5. Nested structures:
%[text]    - Access with chained dot notation: config.a.b.c
%[text]    - Can mix regular and special-character keys\
%%
%[text] ## Cleanup
%[text] Delete temporary files
delete("sample.toml", "sample.yaml", "converted.yaml", "converted.toml", ...
    "app_config.toml", "app_config.yaml");
%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---