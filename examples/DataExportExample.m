%[text] # Data Export and Import with YAML
%[text] This example shows how to export MATLAB data structures to YAML format for sharing and archiving.
%[text] ## Experimental Data Export
%[text] Create a structure containing experimental results:
experiment.metadata.experimentID = 'EXP-2025-001';
experiment.metadata.date = string(datetime('now', 'Format', 'yyyy-MM-dd'));
experiment.metadata.researcher = 'Dr. Smith';
experiment.metadata.description = 'Temperature sensitivity study';
experiment.parameters.temperature = 25.5;
experiment.parameters.pressure = 101.325;
experiment.parameters.humidity = 45;
experiment.parameters.duration = 3600;
experiment.results.mean = 42.7;
experiment.results.stdDev = 2.3;
experiment.results.minValue = 38.1;
experiment.results.maxValue = 47.9;
experiment.results.sampleCount = 1000;
disp('Experimental data structure:') %[output:5690545d]
disp(experiment) %[output:38559343]
%%
%[text] ## Export to YAML
%[text] Save the experimental data to a YAML file:
yamlFile = 'experiment_results.yaml';
yamlwrite(yamlFile, experiment, 'Indent', 2, 'Precision', 8);
disp('Data exported to YAML') %[output:9afb93e0]
%%
%[text] ## View Exported Data
type(yamlFile) %[output:3be80fd1]
%%
%[text] ## Import and Verify
%[text] Read the data back and verify integrity:
imported = readyaml(yamlFile);
fprintf('Experiment ID: %s\n', imported.metadata.experimentID); %[output:098695bf]
fprintf('Temperature: %.1f°C\n', imported.parameters.temperature); %[output:797153a1]
fprintf('Mean Result: %.1f\n', imported.results.mean); %[output:372450a8]
%%
%[text] ## Multiple Measurements Export
%[text] Create a structure with multiple measurement series:
measurements.trial1 = [23.1, 23.5, 23.8, 24.2, 24.1];
measurements.trial2 = [22.9, 23.2, 23.6, 23.9, 24.0];
measurements.trial3 = [23.0, 23.4, 23.7, 24.1, 24.2];
measurements.units = 'degrees Celsius';
measurements.timePoints = [0, 15, 30, 45, 60];
yamlFile2 = 'measurements.yaml';
yamlwrite(yamlFile2, measurements, 'FlowStyle', true);
disp('Measurements with flow style:')
type(yamlFile2)
%%
%[text] ## Structured Dataset Export
%[text] Create a more complex dataset with nested information:
dataset.info.title = 'Signal Quality Analysis';
dataset.info.version = '1.0';
dataset.info.samples = 500;
dataset.channels.ch1.name = 'Sensor A';
dataset.channels.ch1.unit = 'mV';
dataset.channels.ch1.range = [-5, 5];
dataset.channels.ch2.name = 'Sensor B';
dataset.channels.ch2.unit = 'mA';
dataset.channels.ch2.range = [0, 20];
dataset.processing.filtered = true;
dataset.processing.filterFreq = 50;
dataset.processing.downsampleFactor = 10;
yamlFile3 = 'dataset_info.yaml';
yamlwrite(yamlFile3, dataset, 'Indent', 2);
disp('Dataset metadata:')
type(yamlFile3)
%%
%[text] ## Batch Processing Example
%[text] Process multiple data files and export metadata:
batchResults = struct();
for i = 1:3
    resultName = sprintf('result%d', i);
    batchResults.(resultName).processed = true;
    batchResults.(resultName).timestamp = string(datetime('now'));
    batchResults.(resultName).fileSize = randi([1000, 5000]);
    batchResults.(resultName).quality = rand();
end
yamlFile4 = 'batch_results.yaml';
yamlwrite(yamlFile4, batchResults, 'Indent', 2, 'Precision', 4);
disp('Batch processing results:')
type(yamlFile4)
%%
%[text] ## Comparing YAML with MAT Files
%[text] Compare file sizes and readability:
testData.values = rand(10, 1);
testData.labels = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'};
testData.metadata.created = string(datetime('now'));
yamlTestFile = 'test_data.yaml';
matTestFile = 'test_data.mat';
yamlwrite(yamlTestFile, testData);
save(matTestFile, 'testData');
yamlInfo = dir(yamlTestFile);
matInfo = dir(matTestFile);
fprintf('YAML file size: %d bytes\n', yamlInfo.bytes);
fprintf('MAT file size: %d bytes\n', matInfo.bytes);
disp('YAML is human-readable:')
type(yamlTestFile)
%%
%[text] ## Cross-Platform Data Sharing
%[text] YAML files are ideal for sharing data with other programming languages:
sharedData.projectName = 'Cross-Platform Analysis';
sharedData.matlabVersion = version;
sharedData.dataFormat = 'YAML 1.2';
sharedData.compatibility = {'Python', 'R', 'Julia', 'JavaScript'};
sharedData.arrays.vector = [1, 2, 3, 4, 5];
sharedData.arrays.matrix = 'Use separate files for large matrices';
shareFile = 'shared_data.yaml';
yamlwrite(shareFile, sharedData, 'Indent', 2);
disp('Data prepared for cross-platform sharing:')
type(shareFile)
%%
%[text] ## Cleanup
%[text] Remove all example files:
delete(yamlFile);
delete(yamlFile2);
delete(yamlFile3);
delete(yamlFile4);
delete(yamlTestFile);
delete(matTestFile);
delete(shareFile);
disp('Example files cleaned up')
%[text] 

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
%[output:5690545d]
%   data: {"dataType":"text","outputData":{"text":"Experimental data structure:\n","truncated":false}}
%---
%[output:38559343]
%   data: {"dataType":"text","outputData":{"text":"      metadata: [1×1 struct]\n    parameters: [1×1 struct]\n       results: [1×1 struct]\n\n","truncated":false}}
%---
%[output:9afb93e0]
%   data: {"dataType":"text","outputData":{"text":"Data exported to YAML\n","truncated":false}}
%---
%[output:3be80fd1]
%   data: {"dataType":"text","outputData":{"text":"\nmetadata:\n  experimentID: EXP-2025-001\n  date: 2025-12-31\n  researcher: Dr. Smith\n  description: Temperature sensitivity study\nparameters:\n  temperature: 25.5\n  pressure: 101.325\n  humidity: 45\n  duration: 3600\nresults:\n  mean: 42.7\n  stdDev: 2.3\n  minValue: 38.1\n  maxValue: 47.9\n  sampleCount: 1000\n","truncated":false}}
%---
%[output:098695bf]
%   data: {"dataType":"text","outputData":{"text":"Experiment ID: EXP-2025-001\n","truncated":false}}
%---
%[output:797153a1]
%   data: {"dataType":"text","outputData":{"text":"Temperature: 25.5°C\n","truncated":false}}
%---
%[output:372450a8]
%   data: {"dataType":"text","outputData":{"text":"Mean Result: 42.7\n","truncated":false}}
%---
