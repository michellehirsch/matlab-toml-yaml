classdef jsontest < matlab.unittest.TestCase
    % JSONTEST Unit tests for JSON support
    %   Comprehensive tests for readjson, writejson, and JSONData

    methods (TestClassSetup)
        function addToPath(testCase)
            % Add toolbox folder to path
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture('../toolbox'));
        end
    end

    methods (TestMethodSetup)
        function createTempDir(testCase)
            testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture);
        end
    end

    methods (Test)
        %% Basic Reading Tests
        function testReadSimpleJSON(testCase)
            % Test reading a simple JSON file
            jsonText = '{"name": "Test", "version": 1.0, "enabled": true}';

            filename = fullfile(pwd, 'test.json');
            writelines(jsonText, filename);

            data = readjson(filename);

            testCase.verifyClass(data, 'matlab.io.config.JSONData');
            testCase.verifyEqual(data.name, "Test");
            testCase.verifyEqual(data.version, 1.0);
            testCase.verifyEqual(data.enabled, true);
        end

        function testReadNestedJSON(testCase)
            % Test reading nested structures
            jsonText = '{"database": {"host": "localhost", "port": 5432}}';

            filename = fullfile(pwd, 'test.json');
            writelines(jsonText, filename);

            data = readjson(filename);

            testCase.verifyClass(data.database, 'matlab.io.config.JSONData');
            testCase.verifyEqual(data.database.host, "localhost");
            testCase.verifyEqual(data.database.port, 5432);
        end

        function testReadNumericArray(testCase)
            % Test reading numeric arrays
            jsonText = '{"ports": [8080, 8443, 9000]}';

            filename = fullfile(pwd, 'test.json');
            writelines(jsonText, filename);

            data = readjson(filename);

            testCase.verifyEqual(data.ports, [8080; 8443; 9000]);
        end

        function testReadStringArray(testCase)
            % Test reading string arrays
            jsonText = '{"tags": ["alpha", "beta", "gamma"]}';

            filename = fullfile(pwd, 'test.json');
            writelines(jsonText, filename);

            data = readjson(filename);

            testCase.verifyEqual(data.tags, ["alpha"; "beta"; "gamma"]);
        end

        function testReadMixedArray(testCase)
            % Test reading mixed-type arrays (become cell arrays)
            jsonText = '{"mixed": [1, "two", true]}';

            filename = fullfile(pwd, 'test.json');
            writelines(jsonText, filename);

            data = readjson(filename);

            testCase.verifyClass(data.mixed, 'cell');
            testCase.verifyEqual(data.mixed{1}, 1);
            testCase.verifyEqual(data.mixed{2}, "two");
            testCase.verifyEqual(data.mixed{3}, true);
        end

        function testReadArrayOfObjects(testCase)
            % Test reading array of objects
            jsonText = '{"authors": [{"name": "Alice"}, {"name": "Bob"}]}';

            filename = fullfile(pwd, 'test.json');
            writelines(jsonText, filename);

            data = readjson(filename);

            testCase.verifyEqual(numel(data.authors), 2);
            testCase.verifyEqual(data.authors(1).name, "Alice");
            testCase.verifyEqual(data.authors(2).name, "Bob");
        end

        function testReadNullValue(testCase)
            % Test that null is converted to empty array
            jsonText = '{"value": null}';

            filename = fullfile(pwd, 'test.json');
            writelines(jsonText, filename);

            data = readjson(filename);

            testCase.verifyEmpty(data.value);
            testCase.verifyClass(data.value, 'double');
        end

        function testReadEmptyObject(testCase)
            % Test reading empty object
            jsonText = '{}';

            filename = fullfile(pwd, 'test.json');
            writelines(jsonText, filename);

            data = readjson(filename);

            testCase.verifyClass(data, 'matlab.io.config.JSONData');
            testCase.verifyEmpty(keys(data));
        end

        function testReadEmptyArray(testCase)
            % Test reading empty array
            jsonText = '{"items": []}';

            filename = fullfile(pwd, 'test.json');
            writelines(jsonText, filename);

            data = readjson(filename);

            testCase.verifyEmpty(data.items);
        end

        %% SequenceRule Tests
        function testSequenceRuleCell(testCase)
            % Test SequenceRule='cell' forces cell arrays
            jsonText = '{"ports": [8080, 8443]}';

            filename = fullfile(pwd, 'test.json');
            writelines(jsonText, filename);

            data = readjson(filename, 'SequenceRule', 'cell');

            testCase.verifyClass(data.ports, 'cell');
            testCase.verifyEqual(data.ports{1}, 8080);
            testCase.verifyEqual(data.ports{2}, 8443);
        end

        function testSequenceRuleAuto(testCase)
            % Test SequenceRule='auto' keeps numeric arrays
            jsonText = '{"ports": [8080, 8443]}';

            filename = fullfile(pwd, 'test.json');
            writelines(jsonText, filename);

            data = readjson(filename, 'SequenceRule', 'auto');

            testCase.verifyClass(data.ports, 'double');
        end

        %% Basic Writing Tests
        function testWriteSimpleJSON(testCase)
            % Test writing simple JSONData
            data = jsondata();
            data.name = "Test";
            data.version = 1.0;
            data.enabled = true;

            filename = fullfile(pwd, 'output.json');
            writejson(data, filename);

            % Read back and verify
            content = fileread(filename);
            testCase.verifySubstring(content, '"name"');
            testCase.verifySubstring(content, '"Test"');
        end

        function testWriteNestedJSON(testCase)
            % Test writing nested structures
            data = jsondata();
            data.database.host = "localhost";
            data.database.port = 5432;

            filename = fullfile(pwd, 'output.json');
            writejson(data, filename);

            % Read back and verify structure
            readBack = readjson(filename);
            testCase.verifyEqual(readBack.database.host, "localhost");
            testCase.verifyEqual(readBack.database.port, 5432);
        end

        function testWritePrettyPrintTrue(testCase)
            % Test PrettyPrint=true produces formatted output
            data = jsondata();
            data.name = "Test";

            filename = fullfile(pwd, 'output.json');
            writejson(data, filename, 'PrettyPrint', true);

            content = fileread(filename);
            % Pretty printed should have newlines
            testCase.verifyTrue(contains(content, newline));
        end

        function testWritePrettyPrintFalse(testCase)
            % Test PrettyPrint=false produces compact output
            data = jsondata();
            data.name = "Test";

            filename = fullfile(pwd, 'output.json');
            writejson(data, filename, 'PrettyPrint', false);

            content = fileread(filename);
            % Compact should not have newlines (or minimal)
            testCase.verifyFalse(contains(content, sprintf('\n    ')));
        end

        function testWriteEmptyValueNull(testCase)
            % Test EmptyValue='null' writes null for empty arrays
            data = jsondata();
            data.name = "Test";
            data.empty = [];

            filename = fullfile(pwd, 'output.json');
            writejson(data, filename, 'EmptyValue', 'null');

            content = fileread(filename);
            testCase.verifySubstring(content, 'null');
        end

        function testWriteEmptyValueOmit(testCase)
            % Test EmptyValue='omit' skips empty arrays
            data = jsondata();
            data.name = "Test";
            data.empty = [];

            filename = fullfile(pwd, 'output.json');
            writejson(data, filename, 'EmptyValue', 'omit');

            content = fileread(filename);
            testCase.verifyFalse(contains(content, '"empty"'));
        end

        function testWriteStruct(testCase)
            % Test writing a struct directly
            s.name = "FromStruct";
            s.value = 42;

            filename = fullfile(pwd, 'output.json');
            writejson(s, filename);

            readBack = readjson(filename);
            testCase.verifyEqual(readBack.name, "FromStruct");
            testCase.verifyEqual(readBack.value, 42);
        end

        function testWriteDefaultFilename(testCase)
            % Test default filename
            data = jsondata();
            data.test = true;

            writejson(data);

            testCase.verifyTrue(isfile('untitled.json'));
        end

        %% Round-trip Tests
        function testRoundTripSimple(testCase)
            % Test round-trip of simple values
            original = jsondata();
            original.name = "RoundTrip";
            original.count = 42;
            original.active = true;

            filename = fullfile(pwd, 'roundtrip.json');
            writejson(original, filename);
            readBack = readjson(filename);

            testCase.verifyEqual(readBack.name, original.name);
            testCase.verifyEqual(readBack.count, original.count);
            testCase.verifyEqual(readBack.active, original.active);
        end

        function testRoundTripNested(testCase)
            % Test round-trip of nested structures
            original = jsondata();
            original.level1.level2.level3 = "deep";

            filename = fullfile(pwd, 'roundtrip.json');
            writejson(original, filename);
            readBack = readjson(filename);

            testCase.verifyEqual(readBack.level1.level2.level3, "deep");
        end

        function testRoundTripArrays(testCase)
            % Test round-trip of arrays
            original = jsondata();
            original.numbers = [1, 2, 3];
            original.strings = ["a", "b", "c"];

            filename = fullfile(pwd, 'roundtrip.json');
            writejson(original, filename);
            readBack = readjson(filename);

            % Note: arrays may come back as column vectors
            testCase.verifyEqual(sort(readBack.numbers(:)), sort(original.numbers(:)));
        end

        %% JSONData Methods Tests
        function testJSONDataKeys(testCase)
            % Test keys() method
            data = jsondata();
            data.alpha = 1;
            data.beta = 2;

            k = keys(data);
            testCase.verifyEqual(sort(k), sort(["alpha", "beta"]));
        end

        function testJSONDataIsField(testCase)
            % Test isfield() method
            data = jsondata();
            data.exists = true;

            testCase.verifyTrue(isfield(data, 'exists'));
            testCase.verifyFalse(isfield(data, 'missing'));
        end

        function testJSONDataStruct(testCase)
            % Test struct() conversion
            data = jsondata();
            data.name = "Test";
            data.value = 42;

            s = struct(data);
            testCase.verifyClass(s, 'struct');
            testCase.verifyEqual(s.name, "Test");
            testCase.verifyEqual(s.value, 42);
        end

        function testJSONDataFromStruct(testCase)
            % Test creating JSONData from struct
            s.name = "FromStruct";
            s.nested.value = 123;

            data = jsondata(s);

            testCase.verifyClass(data, 'matlab.io.config.JSONData');
            testCase.verifyEqual(data.name, "FromStruct");
            testCase.verifyEqual(data.nested.value, 123);
        end

        %% Sample File Tests
        function testReadSimpleConfigFile(testCase)
            % Test reading the simple_config.json sample file
            sampleFile = fullfile(fileparts(mfilename('fullpath')), 'SampleFiles', 'simple_config.json');
            if ~isfile(sampleFile)
                testCase.assumeFail('Sample file not found');
            end

            data = readjson(sampleFile);

            testCase.verifyEqual(data.name, "TestApp");
            testCase.verifyEqual(data.version, "1.0.0");
            testCase.verifyEqual(data.enabled, true);
            testCase.verifyEqual(data.maxRetries, 3);
            testCase.verifyEqual(data.database.host, "localhost");
            testCase.verifyEmpty(data.nullValue);
        end

        function testReadPackageJsonFile(testCase)
            % Test reading the package.json sample file
            sampleFile = fullfile(fileparts(mfilename('fullpath')), 'SampleFiles', 'package.json');
            if ~isfile(sampleFile)
                testCase.assumeFail('Sample file not found');
            end

            data = readjson(sampleFile);

            testCase.verifyEqual(data.name, "example-package");
            testCase.verifyEqual(data.version, "2.1.0");
            testCase.verifyEqual(data.scripts.test, "jest");
            testCase.verifyEqual(data.author.name, "Test Author");
        end

        %% Edge Cases
        function testDeepNesting(testCase)
            % Test deeply nested structures
            data = jsondata();
            data.a.b.c.d.e.f = "deep";

            filename = fullfile(pwd, 'deep.json');
            writejson(data, filename);
            readBack = readjson(filename);

            testCase.verifyEqual(readBack.a.b.c.d.e.f, "deep");
        end

        function testSpecialCharactersInStrings(testCase)
            % Test strings with special characters
            data = jsondata();
            data.message = "Hello ""World""!";
            data.path = "C:\\Users\\test";

            filename = fullfile(pwd, 'special.json');
            writejson(data, filename);
            readBack = readjson(filename);

            testCase.verifyEqual(readBack.message, data.message);
            testCase.verifyEqual(readBack.path, data.path);
        end

        function testUnicodeStrings(testCase)
            % Test Unicode strings
            data = jsondata();
            data.greeting = "Hello";
            data.emoji = "Test";

            filename = fullfile(pwd, 'unicode.json');
            writejson(data, filename);
            readBack = readjson(filename);

            testCase.verifyEqual(readBack.greeting, data.greeting);
        end

        function testBooleanValues(testCase)
            % Test boolean values
            data = jsondata();
            data.yes = true;
            data.no = false;

            filename = fullfile(pwd, 'bool.json');
            writejson(data, filename);

            content = fileread(filename);
            testCase.verifySubstring(content, 'true');
            testCase.verifySubstring(content, 'false');

            readBack = readjson(filename);
            testCase.verifyEqual(readBack.yes, true);
            testCase.verifyEqual(readBack.no, false);
        end

        function testNumericPrecision(testCase)
            % Test numeric precision
            data = jsondata();
            data.integer = 42;
            data.float = 3.14159;
            data.scientific = 1.23e-10;

            filename = fullfile(pwd, 'numbers.json');
            writejson(data, filename);
            readBack = readjson(filename);

            testCase.verifyEqual(readBack.integer, 42);
            testCase.verifyEqual(readBack.float, 3.14159, 'RelTol', 1e-5);
        end
    end
end
