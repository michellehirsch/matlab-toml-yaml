classdef ConfigurationPerformanceTest < matlab.perftest.TestCase
    
    properties
        TempFolder
        LargeTomlFile
        LargeYamlFile
        LargeIniFile
    end
    
    properties(Constant)
        NumArrayItems = 10000;
        NumTableKeys = 2000;
    end
    
    methods(TestClassSetup)
        function setupFiles(testCase)
            import matlab.unittest.fixtures.TemporaryFolderFixture
            import matlab.unittest.fixtures.PathFixture
            
            % Add toolbox to path
            toolboxPath = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'toolbox');
            testCase.applyFixture(PathFixture(toolboxPath));
            
            fixture = testCase.applyFixture(TemporaryFolderFixture);
            testCase.TempFolder = fixture.Folder;
            
            testCase.LargeTomlFile = fullfile(testCase.TempFolder, 'large.toml');
            generateLargeTomlFile(testCase.LargeTomlFile, testCase.NumArrayItems, testCase.NumTableKeys);
            
            testCase.LargeYamlFile = fullfile(testCase.TempFolder, 'large.yaml');
            generateLargeYamlFile(testCase.LargeYamlFile, testCase.NumArrayItems, testCase.NumTableKeys);
            
            testCase.LargeIniFile = fullfile(testCase.TempFolder, 'large.ini');
            generateLargeIniFile(testCase.LargeIniFile, testCase.NumTableKeys);
        end
    end
    
    methods(Test)
        function testReadLargeTOML(testCase)
            testCase.startMeasuring();
            readtoml(testCase.LargeTomlFile);
            testCase.stopMeasuring(); 
        end
        
        function testReadLargeYAML(testCase)
            testCase.startMeasuring();
            readyaml(testCase.LargeYamlFile);
            testCase.stopMeasuring();
        end
        
        function testReadLargeINI(testCase)
            testCase.startMeasuring();
            readini(testCase.LargeIniFile);
            testCase.stopMeasuring();
        end
        
        function testAccessTOML(testCase)
            data = readtoml(testCase.LargeTomlFile);
            testCase.startMeasuring();
            val1 = data.array_section.data(end); 
            keyName = "key" + round(testCase.NumTableKeys/2);
            val2 = data.key_section.(keyName);
            testCase.stopMeasuring();
        end
        
        function testAccessYAML(testCase)
            data = readyaml(testCase.LargeYamlFile);
            testCase.startMeasuring();
            if isstruct(data.array_section.data)
                 val1 = data.array_section.data(end);
            elseif iscell(data.array_section.data)
                 val1 = data.array_section.data{end};
            else
                 val1 = data.array_section.data(end);
            end
            keyName = "key" + round(testCase.NumTableKeys/2);
            val2 = data.key_section.(keyName);
            testCase.stopMeasuring();
        end

        function testWriteLargeTOML(testCase)
            data = readtoml(testCase.LargeTomlFile);
            outFile = fullfile(testCase.TempFolder, 'output.toml');
            testCase.startMeasuring();
            writetoml(data, outFile);
            testCase.stopMeasuring();
        end
        
        function testWriteLargeYAML(testCase)
            data = readyaml(testCase.LargeYamlFile);
            outFile = fullfile(testCase.TempFolder, 'output.yaml');
            testCase.startMeasuring();
            writeyaml(data, outFile);
            testCase.stopMeasuring();
        end
        
        function testWriteLargeINI(testCase)
            data = readini(testCase.LargeIniFile);
            outFile = fullfile(testCase.TempFolder, 'output.ini');
            testCase.startMeasuring();
            writeini(data, outFile);
            testCase.stopMeasuring();
        end
    end
end

function generateLargeTomlFile(filename, numArray, numKeys)
    fid = fopen(filename, 'w');
    fprintf(fid, 'title = "Large TOML Performance Test"\n\n');
    fprintf(fid, '[array_section]\n');
    fprintf(fid, 'data = [\n');
    chunkSize = 100;
    for i = 1:chunkSize:numArray
        endIdx = min(i + chunkSize - 1, numArray);
        fprintf(fid, '%d, ', i:endIdx);
        fprintf(fid, '\n');
    end
    fprintf(fid, ']\n\n');
    fprintf(fid, '[key_section]\n');
    for i = 1:numKeys
        fprintf(fid, 'key%d = "value_%d"\n', i, i);
    end
    fclose(fid);
end

function generateLargeYamlFile(filename, numArray, numKeys)
    fid = fopen(filename, 'w');
    fprintf(fid, 'title: "Large YAML Performance Test"\n');
    fprintf(fid, 'array_section:\n');
    fprintf(fid, '  data:\n');
    for i = 1:numArray
        fprintf(fid, '    - %d\n', i);
    end
    fprintf(fid, 'key_section:\n');
    for i = 1:numKeys
        fprintf(fid, '  key%d: "value_%d"\n', i, i);
    end
    fclose(fid);
end

function generateLargeIniFile(filename, numKeys)
    fid = fopen(filename, 'w');
    fprintf(fid, '; Large INI Performance Test\n\n');
    fprintf(fid, '[key_section]\n');
    for i = 1:numKeys
        fprintf(fid, 'key%d = value_%d\n', i, i);
    end
    fclose(fid);
end
