%% ConfigurationDataExample - Working with ConfigurationData, TOMLData, and YAMLData
% This example demonstrates the ConfigurationData class and its subclasses
% (TOMLData and YAMLData), showing how to create, access, modify, and
% convert configuration data objects.

%% ConfigurationData Overview
% ConfigurationData is a handle class that provides dot notation access
% to configuration data with support for keys containing special characters.
%
% Key features:
% - Dot notation access: config.key
% - Special character support: config.("key-with-hyphens")
% - Automatic aliasing for hyphenated keys
% - Preserved key order
% - Handle class behavior (pass by reference)

%% Creating ConfigurationData Objects
% Create a new ConfigurationData object

config = ConfigurationData();
disp("Empty ConfigurationData object:")
disp(config)

%%
% Add fields using dot notation
config.name = "MyApp";
config.version = "1.0.0";
config.port = 8080;
config.debug = true;

disp("ConfigurationData with fields:")
disp(config)

%% Accessing Data with Dot Notation
% Access values using standard dot notation

disp("Application name: " + config.name)
disp("Version: " + config.version)
disp("Port: " + string(config.port))
disp("Debug mode: " + string(config.debug))

%% Working with Special Characters in Keys
% Keys with hyphens, dots, or spaces require special syntax

config.("app-name") = "MyApplication";
config.("max-connections") = 100;
config.("build-version") = "2.0.0";

% Access with special character syntax
disp("App name: " + config.("app-name"))
disp("Max connections: " + string(config.("max-connections")))

%%
% Automatic aliasing for hyphenated keys
% ConfigurationData creates camelCase aliases for hyphenated keys
config.("my-special-key") = "value";

% Can access with either the original key or the alias
disp("Original key: " + config.("my-special-key"))
% Note: Aliases are automatically created where possible

%% Nested Structures
% Create nested configuration structures

config.database.host = "localhost";
config.database.port = 5432;
config.database.credentials.username = "admin";
config.database.credentials.password = "secret";

disp("Nested structure:")
disp(config.database)

%%
% Navigate nested structures
disp("Database host: " + config.database.host)
disp("Database username: " + config.database.credentials.username)

%% Exploring Configuration Structure
% Use keys() to list all top-level keys

allKeys = config.keys();
disp("All top-level keys:")
disp(allKeys)

%%
% Check if specific fields exist
if isfield(config, "database")
    disp("Database configuration exists")
end

if ~isfield(config, "nonexistent")
    disp("Nonexistent field does not exist")
end

%%
% Alternative syntax: iskey()
if iskey(config, "name")
    disp("Name field exists")
end

%% Handle Class Behavior
% ConfigurationData is a handle class - assignments create references

config1 = ConfigurationData();
config1.value = 42;

% This creates a reference, not a copy
config2 = config1;
config2.value = 100;

% Original is modified because config2 is a reference
disp("config1.value after modifying config2: " + string(config1.value))

%%
% Use copy() to create an independent copy
config3 = copy(config1);
config3.value = 200;

% Original is NOT modified
disp("config1.value after modifying copy: " + string(config1.value))
disp("config3.value (independent copy): " + string(config3.value))

%% Converting to Struct
% Convert ConfigurationData to a standard MATLAB struct

configStruct = struct(config);
disp("Converted to struct:")
disp(configStruct)

%%
% Struct conversion is useful for:
% - Interfacing with code that expects structs
% - Serialization
% - Comparison operations

%% TOMLData - Specialized for TOML Files
% TOMLData extends ConfigurationData for TOML-specific features

tomlData = TOMLData();
tomlData.project.name = "my-package";
tomlData.project.version = "1.0.0";
tomlData.("build-system").requires = ["setuptools>=61.0", "wheel"];

disp("TOMLData object:")
disp(tomlData)

%%
% Write to TOML file
writetoml(tomlData, "sample.toml");
disp("Written TOML file:")
type("sample.toml")

%%
% Read back from TOML file
readTomlData = readtoml("sample.toml");
disp("Read back from TOML:")
disp(readTomlData)
disp("Class: " + class(readTomlData))

%% YAMLData - Specialized for YAML Files
% YAMLData extends ConfigurationData for YAML-specific features

yamlData = YAMLData();
yamlData.name = "CI";
yamlData.on.push.branches = ["main", "develop"];
yamlData.jobs.build.("runs-on") = "ubuntu-latest";

disp("YAMLData object:")
disp(yamlData)

%%
% Write to YAML file
writeyaml(yamlData, "sample.yaml");
disp("Written YAML file:")
type("sample.yaml")

%%
% Read back from YAML file
readYamlData = readyaml("sample.yaml");
disp("Read back from YAML:")
disp(readYamlData)
disp("Class: " + class(readYamlData))

%% Working with Arrays of ConfigurationData
% Create arrays of configuration objects

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

% Access array elements
disp("Step array:")
for i = 1:numel(steps)
    fprintf("Step %d: %s\n", i, steps(i).name);
end

%%
% Access using array indexing
disp("First step name: " + steps(1).name)
disp("Last step name: " + steps(end).name)

%% show() Method - Formatted Display
% Use show() for a formatted display of the configuration

workflow = YAMLData();
workflow.name = "CI Pipeline";
workflow.jobs.build.steps(1).name = "Checkout";
workflow.jobs.build.steps(1).uses = "actions/checkout@v4";
workflow.jobs.build.steps(2).name = "Build";
workflow.jobs.build.steps(2).run = "make build";

disp("Using show() method for formatted display:")
workflow.show()

%% Removing Fields
% Remove fields from configuration

removeExample = ConfigurationData();
removeExample.keep1 = "value1";
removeExample.remove_me = "value2";
removeExample.keep2 = "value3";

disp("Before removal:")
disp(removeExample.keys())

% Remove a field
removeExample = rmfield(removeExample, "remove_me");

disp("After removal:")
disp(removeExample.keys())

%%
% Alternative syntax: remove()
removeExample.temporary = "temp value";
removeExample = remove(removeExample, "temporary");

%% Modifying Nested Structures
% Add and modify nested configuration

app = ConfigurationData();
app.server.host = "localhost";
app.server.port = 8080;

disp("Initial server config:")
disp(app.server)

%%
% Modify existing nested values
app.server.port = 9000;
app.server.ssl = true;
app.server.ssl_cert = "/path/to/cert.pem";

disp("Modified server config:")
disp(app.server)

%% SourceFormat Property
% Track the original format of the data

tomlFromFile = readtoml("sample.toml");
disp("TOML data source format: " + tomlFromFile.SourceFormat)

yamlFromFile = readyaml("sample.yaml");
disp("YAML data source format: " + yamlFromFile.SourceFormat)

manualConfig = ConfigurationData();
disp("Manual ConfigurationData source format: " + manualConfig.SourceFormat)

%% Converting Between Formats
% Read from one format, write to another

% Read TOML
tomlConfig = readtoml("sample.toml");
disp("Original TOML:")
type("sample.toml")

%%
% Write as YAML
writeyaml(tomlConfig, "converted.yaml");
disp("Converted to YAML:")
type("converted.yaml")

%%
% Read YAML
yamlConfig = readyaml("sample.yaml");
disp("Original YAML:")
type("sample.yaml")

%%
% Write as TOML
writetoml(yamlConfig, "converted.toml");
disp("Converted to TOML:")
type("converted.toml")

%% Practical Example: Managing Application Configuration
% Complete example of application configuration management

% Create application configuration
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

disp("Application configuration structure:")
appConfig.show()

%%
% Save as TOML for Python services
writetoml(appConfig, "app_config.toml", ...
    ArrayStyle="block", ...
    SectionSpacing="loose");
disp("Saved as TOML (app_config.toml):")
type("app_config.toml")

%%
% Save as YAML for Kubernetes/Docker
writeyaml(appConfig, "app_config.yaml", ...
    ArrayStyle="block", ...
    SectionSpacing="loose");
disp("Saved as YAML (app_config.yaml):")
type("app_config.yaml")

%% Best Practices
disp("Best practices for ConfigurationData:")
disp("  ")
disp("1. Handle class behavior:")
disp("   - Remember that assignments create references")
disp("   - Use copy() to create independent copies")
disp("  ")
disp("2. Special character keys:")
disp('   - Use config.("key-with-special-chars") syntax')
disp("   - Be consistent with key naming conventions")
disp("  ")
disp("3. Exploring unknown configurations:")
disp("   - Use keys() to list available fields")
disp("   - Use isfield() to check for optional fields")
disp("   - Use show() during debugging")
disp("  ")
disp("4. Converting between formats:")
disp("   - Read with readtoml() or readyaml()")
disp("   - Write with writetoml() or writeyaml()")
disp("   - Convert to struct when needed for other code")
disp("  ")
disp("5. Nested structures:")
disp("   - Access with chained dot notation: config.a.b.c")
disp("   - Can mix regular and special-character keys")
disp("  ")

%% Cleanup
% Delete temporary files
delete("sample.toml", "sample.yaml", "converted.yaml", "converted.toml", ...
    "app_config.toml", "app_config.yaml");
