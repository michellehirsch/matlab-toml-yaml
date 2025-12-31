%[text] # ConfigurationData Test Script
%[text] This script demonstrates the ConfigurationData class features. ConfigurationData provides convenient dot notation access to configuration data, including support for keys with special characters like hyphens.
data = ConfigurationData() %[output:5dfb2cdf]
%%
%[text] ## Basic Assignment
%[text] Simple scalar values can be assigned using dot notation.
data = ConfigurationData();
data.name = "MyApp";
data.version = 2.5;
data.debug = true;
data %[output:3665f0c5]
%%
%[text] ## Hyphenated Keys and Aliases
%[text] Keys with hyphens are supported using dynamic field reference syntax. The class automatically creates valid MATLAB name aliases.
data.("app-name") = "MyApplication";
data.("is-production") = false;
data %[output:10581cd9]
%[text] Access using original hyphenated name:
data.("app-name") %[output:181207b6]
%[text] Access using underscore alias:
data.app_name %[output:0f0ecd41]
%%
%[text] ## Nested Structures
%[text] Nested structures are created automatically with clean chained access.
data.database.host = "localhost";
data.database.port = 5432;
data.database.("connection-pool").("max-size") = 20;
data.database.("connection-pool").("min-size") = 5;
data %[output:27f5ac16]
%[text] Chained access works naturally:
data.database.("connection-pool").("max-size") %[output:7f1fbd76]
%%
%[text] ## Scalar to Nested Conversion
%[text] Assigning to a sub-field of a scalar value automatically converts it to a nested structure. First set a scalar value:
config = ConfigurationData();
config.version = 2.5;
config %[output:1a7cba83]
%[text] Now assign to nested fields - the scalar is automatically converted:
config.version.major = 1;
config.version.minor = 0;
config %[output:240b5321]
%%
%[text] ## Array Display
%[text] Arrays are displayed intelligently - small arrays show values, large arrays show size/type.
data = ConfigurationData();
data.small = [1 2 3 4 5];
data.large = rand(1, 20);
data.matrix = magic(3);
data %[output:2a82e127]
%%
%[text] ## Methods and Dual Terminology
%[text] Both struct-like and key-value terminology supported. Create a simple configuration:
data = ConfigurationData();
data.a = 1;
data.("b-key") = 2;
data.c = 3;
%[text] Get all keys (both method names work):
keys(data) %[output:6bcf1e86]
fieldnames(data) %[output:61abe50d]
%[text] Check if keys exist (both method names work):
isfield(data, "a") %[output:6d468d6f]
iskey(data, "b-key") %[output:2380522f]
%[text] Remove a field:
data = rmfield(data, 'b-key');
keys(data) %[output:36888c3b]
%%
%[text] ## Conversion to Struct and Map
%[text] Convert to standard MATLAB types. Hyphenated names become valid identifiers in structs.
config = ConfigurationData();
config.("app-name") = "MyApp";
config.database.("max-connections") = 100;
s = struct(config) %[output:9a3a97e4]
%[text] Access the struct with valid field names:
s.app_name %[output:0e663f4a]
s.database.max_connections %[output:93cf8118]
%[text] Convert to containers.Map:
m = map(config);
m.Count %[output:20045fbf]
%%
%[text] ## Realistic Configuration Example
%[text] Build a complex configuration similar to YAML or TOML files.
config = ConfigurationData();
config.application.name = "WebServer";
config.application.version = "1.0.0";
config.application.("build-number") = 42;
config.logging.level = "INFO";
config.logging.("file-path") = "/var/log/app.log";
config.database.primary.host = "db1.example.com";
config.database.primary.port = 5432;
config.database.replica.host = "db2.example.com";
config.database.replica.port = 5432;
config %[output:78a499f4]
%%
%[text] ## Kubernetes-Style Configuration
%[text] Example mimicking a Kubernetes service configuration with dotted keys.
yaml = ConfigurationData();
yaml.("api-version") = "v1";
yaml.kind = "Service";
yaml.metadata.name = "my-service";
yaml.metadata.namespace = "default";
yaml.metadata.labels.("app.kubernetes.io/name") = "myapp";
yaml.metadata.labels.("app.kubernetes.io/version") = "1.0";
%[text] Access specific fields:
yaml.metadata.name %[output:53d15f72]
yaml.metadata.labels.("app.kubernetes.io/name") %[output:6f86df13]
%%
%[text] ## Handle Semantics and Copying
%[text] ConfigurationData is a handle class. Assignment creates shared references:
data = ConfigurationData();
data.name = "Original";
data2 = data;
data2.name = "Modified";
%[text] Both variables share the same data:
data.name %[output:67a92651]
data2.name %[output:30c1a88a]
%[text] Use `copy()` to create independent copies:
data3 = copy(data);
data3.name = "Independent";
%[text] Now they're independent:
data.name %[output:6c5690d4]
data3.name %[output:431c1a98]
%[text] 

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
%[output:5dfb2cdf]
%   data: {"dataType":"textualVariable","outputData":{"name":"data","value":"  <a href=\"matlab:helpPopup('ConfigurationData')\" style=\"font-weight:bold\">ConfigurationData<\/a> with properties:\n"}}
%---
%[output:3665f0c5]
%   data: {"dataType":"textualVariable","outputData":{"name":"data","value":"  <a href=\"matlab:helpPopup('ConfigurationData')\" style=\"font-weight:bold\">ConfigurationData<\/a> with properties:\n\n    name: \"MyApp\"\n    version: 2.5\n    debug: true\n"}}
%---
%[output:10581cd9]
%   data: {"dataType":"textualVariable","outputData":{"name":"data","value":"  <a href=\"matlab:helpPopup('ConfigurationData')\" style=\"font-weight:bold\">ConfigurationData<\/a> with properties:\n\n    name: \"MyApp\"\n    version: 2.5\n    debug: true\n    app-name: \"MyApplication\"\n    is-production: false\n"}}
%---
%[output:181207b6]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"MyApplication\""}}
%---
%[output:0f0ecd41]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"MyApplication\""}}
%---
%[output:27f5ac16]
%   data: {"dataType":"textualVariable","outputData":{"name":"data","value":"  <a href=\"matlab:helpPopup('ConfigurationData')\" style=\"font-weight:bold\">ConfigurationData<\/a> with properties:\n\n    name: \"MyApp\"\n    version: 2.5\n    debug: true\n    app-name: \"MyApplication\"\n    is-production: false\n    database: [1×1 ConfigurationData with 3 fields]\n"}}
%---
%[output:7f1fbd76]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"20"}}
%---
%[output:1a7cba83]
%   data: {"dataType":"textualVariable","outputData":{"name":"config","value":"  <a href=\"matlab:helpPopup('ConfigurationData')\" style=\"font-weight:bold\">ConfigurationData<\/a> with properties:\n\n    version: 2.5\n"}}
%---
%[output:240b5321]
%   data: {"dataType":"textualVariable","outputData":{"name":"config","value":"  <a href=\"matlab:helpPopup('ConfigurationData')\" style=\"font-weight:bold\">ConfigurationData<\/a> with properties:\n\n    version: [1×1 ConfigurationData with 2 fields]\n"}}
%---
%[output:2a82e127]
%   data: {"dataType":"textualVariable","outputData":{"name":"data","value":"  <a href=\"matlab:helpPopup('ConfigurationData')\" style=\"font-weight:bold\">ConfigurationData<\/a> with properties:\n\n    small: [1 2 3 4 5]\n    large: [1x20 double]\n    matrix: [3x3 double]\n"}}
%---
%[output:6bcf1e86]
%   data: {"dataType":"matrix","outputData":{"columns":3,"header":"1×3 string array","name":"ans","rows":1,"type":"string","value":[["a","b-key","c"]]}}
%---
%[output:61abe50d]
%   data: {"dataType":"matrix","outputData":{"columns":3,"header":"1×3 string array","name":"ans","rows":1,"type":"string","value":[["a","b-key","c"]]}}
%---
%[output:6d468d6f]
%   data: {"dataType":"textualVariable","outputData":{"header":"logical","name":"ans","value":"   1\n"}}
%---
%[output:2380522f]
%   data: {"dataType":"textualVariable","outputData":{"header":"logical","name":"ans","value":"   1\n"}}
%---
%[output:36888c3b]
%   data: {"dataType":"matrix","outputData":{"columns":2,"header":"1×2 string array","name":"ans","rows":1,"type":"string","value":[["a","c"]]}}
%---
%[output:9a3a97e4]
%   data: {"dataType":"textualVariable","outputData":{"header":"struct with fields:","name":"s","value":"    app_name: \"MyApp\"\n    database: [1×1 struct]\n"}}
%---
%[output:0e663f4a]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"MyApp\""}}
%---
%[output:93cf8118]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"100"}}
%---
%[output:20045fbf]
%   data: {"dataType":"textualVariable","outputData":{"header":"uint64","name":"ans","value":"2"}}
%---
%[output:78a499f4]
%   data: {"dataType":"textualVariable","outputData":{"name":"config","value":"  <a href=\"matlab:helpPopup('ConfigurationData')\" style=\"font-weight:bold\">ConfigurationData<\/a> with properties:\n\n    application: [1×1 ConfigurationData with 3 fields]\n    logging: [1×1 ConfigurationData with 2 fields]\n    database: [1×1 ConfigurationData with 2 fields]\n"}}
%---
%[output:53d15f72]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"my-service\""}}
%---
%[output:6f86df13]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"myapp\""}}
%---
%[output:67a92651]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Modified\""}}
%---
%[output:30c1a88a]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Modified\""}}
%---
%[output:6c5690d4]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Modified\""}}
%---
%[output:431c1a98]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Independent\""}}
%---
