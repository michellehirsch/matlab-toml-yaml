%[text] # Getting Started with YAML Toolbox
%[text] Welcome to the YAML Toolbox for MATLAB! This guide will help you get started with reading and writing YAML files.
%[text] ## What is YAML?
%[text] YAML (YAML Ain't Markup Language) is a human-readable data serialization format commonly used for configuration files and data exchange. This toolbox provides two main functions:
%[text] - `readyaml` - Read YAML files into MATLAB
%[text] - `yamlwrite` - Write MATLAB data to YAML files \
%[text] ## Reading YAML Files
%[text] Let's start by creating a simple YAML file and reading it into MATLAB.
tempDir = tempname;
mkdir(tempDir);
yamlFile = fullfile(tempDir, 'config.yaml');
%%
%[text] ### Create a Sample YAML File
%[text] First, we'll create a simple configuration file using `yamlwrite`:
config.application = 'MyApp';
config.version = 1.5;
config.settings.debug = true;
config.settings.timeout = 30;
yamlwrite(yamlFile, config);
%[text] Now let's look at what the YAML file contains:
type(yamlFile)
%%
%[text] ### Read the YAML File
%[text] Use `readyaml` to load the data back into MATLAB:
data = readyaml(yamlFile)
%%
%[text] ### Access the Data
%[text] The data is returned as a MATLAB structure, so you can access fields using dot notation:
appName = data.application
isDebug = data.settings.debug
%%
%[text] ## Writing YAML Files
%[text] Now let's create more complex data and write it to a YAML file.
%[text] ### Create Nested Structures
database.host = 'localhost';
database.port = 5432;
database.name = 'mydb';
database.credentials.username = 'admin';
database.credentials.password = 'secret123';
database.options.poolSize = 10;
database.options.timeout = 60;
%%
%[text] ### Write to YAML
yamlFile2 = fullfile(tempDir, 'database.yaml');
yamlwrite(yamlFile2, database);
%[text] View the generated YAML:
type(yamlFile2)
%%
%[text] ## Working with Arrays
%[text] YAML supports both arrays and lists. Let's see how to work with them.
%[text] ### Numeric Arrays
data2.measurements = [1.2, 3.4, 5.6, 7.8, 9.0];
data2.threshold = 5.0;
yamlFile3 = fullfile(tempDir, 'arrays.yaml');
yamlwrite(yamlFile3, data2);
type(yamlFile3)
%%
%[text] ### Cell Arrays
%[text] Cell arrays can contain mixed types:
data3.features = {'authentication', 'logging', 'caching'};
data3.priorities = [1, 2, 3];
yamlFile4 = fullfile(tempDir, 'lists.yaml');
yamlwrite(yamlFile4, data3);
type(yamlFile4)
%%
%[text] ## Customizing Output Format
%[text] You can customize how YAML files are written using optional parameters.
%[text] ### Custom Indentation
%[text] Use the `Indent` option to control spacing:
data4.level1.level2.level3.value = 'nested';
yamlFile5 = fullfile(tempDir, 'indent4.yaml');
yamlwrite(yamlFile5, data4, 'Indent', 4);
disp('With 4-space indentation:')
type(yamlFile5)
%%
%[text] ### Flow Style Arrays
%[text] Use `FlowStyle` for compact array representation:
data5.numbers = [10, 20, 30, 40, 50];
yamlFile6 = fullfile(tempDir, 'flow.yaml');
yamlwrite(yamlFile6, data5, 'FlowStyle', true);
disp('Flow style output:')
type(yamlFile6)
%%
%[text] ### Numeric Precision
%[text] Control decimal precision with the `Precision` option:
data6.pi_approx = pi;
data6.euler = exp(1);
yamlFile7 = fullfile(tempDir, 'precision.yaml');
yamlwrite(yamlFile7, data6, 'Precision', 10);
disp('High precision output:')
type(yamlFile7)
%%
%[text] ## Reading Options
%[text] The `readyaml` function also supports options for customizing how data is loaded.
%[text] ### Preserve Variable Names
%[text] By default, YAML keys are converted to valid MATLAB field names. Use `PreserveVariableNames` to keep original names:
specialYaml = fullfile(tempDir, 'special.yaml');
fid = fopen(specialYaml, 'w');
fprintf(fid, 'special-key: value1\nanother-key: value2');
fclose(fid);
data7 = readyaml(specialYaml, 'PreserveVariableNames', true)
%%
%[text] ### Convert to Map Instead of Struct
%[text] You can read data as a `containers.Map` instead of a structure:
data8 = readyaml(yamlFile, 'ConvertToStruct', false)
class(data8)
%%
%[text] ## Practical Example: Configuration Management
%[text] Here's a complete example of using YAML for application configuration.
%[text] ### Create Application Config
appConfig.app.name = 'DataProcessor';
appConfig.app.version = '2.1.0';
appConfig.app.author = 'Engineering Team';
appConfig.database.type = 'PostgreSQL';
appConfig.database.host = 'db.example.com';
appConfig.database.port = 5432;
appConfig.logging.level = 'INFO';
appConfig.logging.file = 'app.log';
appConfig.logging.maxSize = 10485760;
appConfig.features.enableCache = true;
appConfig.features.enableMetrics = true;
appConfig.features.debugMode = false;
%%
%[text] ### Save Configuration
configFile = fullfile(tempDir, 'app_config.yaml');
yamlwrite(configFile, appConfig, 'Indent', 2);
disp('Application configuration:')
type(configFile)
%%
%[text] ### Load and Use Configuration
loadedConfig = readyaml(configFile);
fprintf('Application: %s v%s\n', loadedConfig.app.name, loadedConfig.app.version);
fprintf('Database: %s at %s:%d\n', loadedConfig.database.type, ...
    loadedConfig.database.host, loadedConfig.database.port);
fprintf('Logging: %s level to %s\n', loadedConfig.logging.level, ...
    loadedConfig.logging.file);
%%
%[text] ## Roundtrip Testing
%[text] Verify that data survives a write-read cycle:
original.name = 'TestData';
original.value = 123.456;
original.flag = true;
original.nested.item1 = 'alpha';
original.nested.item2 = 'beta';
roundtripFile = fullfile(tempDir, 'roundtrip.yaml');
yamlwrite(roundtripFile, original);
recovered = readyaml(roundtripFile);
disp('Original data:')
disp(original)
disp('Recovered data:')
disp(recovered)
%%
%[text] ## Supported Data Types
%[text] The YAML Toolbox supports these MATLAB-YAML type mappings:
%[text] - Strings (char/string) ↔ YAML scalars
%[text] - Numbers (double/integer) ↔ YAML numbers
%[text] - Booleans (logical) ↔ YAML booleans (true/false)
%[text] - Empty arrays ([]) ↔ YAML null
%[text] - Structures ↔ YAML mappings
%[text] - Cell arrays ↔ YAML sequences
%[text] - Numeric arrays ↔ YAML sequences
%[text] - containers.Map ↔ YAML mappings \
%%
%[text] ## Cleanup
%[text] Remove the temporary files created in this example:
rmdir(tempDir, 's');
disp('Temporary files cleaned up.')
%%
%[text] ## Next Steps
%[text] Now that you've learned the basics, try:
%[text] - Reading and writing your own YAML configuration files
%[text] - Exploring the example scripts in the `toolbox/examples/` folder
%[text] - Checking the function documentation with `help readyaml` and `help yamlwrite`
%[text] - Reviewing the comprehensive test suite in the `tests/` folder \
%[text] For more information, see the README.md file in the toolbox root directory.
%[text]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
