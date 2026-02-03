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
            % Test that null is converted to matlab.io.config.JSONNull (Issue #44)
            jsonText = '{"value": null}';

            filename = fullfile(pwd, 'test.json');
            writelines(jsonText, filename);

            data = readjson(filename);

            testCase.verifyClass(data.value, 'matlab.io.config.JSONNull');
            testCase.verifyTrue(isa(data.value, 'matlab.io.config.JSONNull'));
            % isempty returns true for backward compatibility
            testCase.verifyTrue(isempty(data.value));
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

        %% Single-Element Array Preservation Tests (Issue #48)
        function testSingleElementObjectArrayCell(testCase)
            % Single-element array of objects should stay as cell with SequenceRule='cell'
            jsonText = '{"images": [{"url": "test.jpg"}]}';

            filename = fullfile(pwd, 'test.json');
            writelines(jsonText, filename);

            data = readjson(filename, 'SequenceRule', 'cell');

            % images should be a cell array with one element
            testCase.verifyClass(data.images, 'cell');
            testCase.verifyEqual(numel(data.images), 1);
            testCase.verifyEqual(data.images{1}.url, "test.jpg");
        end

        function testSingleElementObjectArrayRoundtrip(testCase)
            % Round-trip should preserve single-element arrays with SequenceRule='cell'
            jsonText = '{"images": [{"url": "test.jpg"}]}';

            inFile = fullfile(pwd, 'in.json');
            writelines(jsonText, inFile);

            data = readjson(inFile, 'SequenceRule', 'cell');

            outFile = fullfile(pwd, 'out.json');
            writejson(data, outFile);

            content = fileread(outFile);
            % Should have array brackets around images value
            testCase.verifySubstring(content, '"images": [');
        end

        function testSingleElementNumericArrayCell(testCase)
            % Single-element numeric array with SequenceRule='cell'
            jsonText = '{"values": [42]}';

            filename = fullfile(pwd, 'test.json');
            writelines(jsonText, filename);

            data = readjson(filename, 'SequenceRule', 'cell');

            testCase.verifyClass(data.values, 'cell');
            testCase.verifyEqual(data.values{1}, 42);
        end

        function testSingleElementStringArrayCell(testCase)
            % Single-element string array with SequenceRule='cell'
            jsonText = '{"tags": ["alpha"]}';

            filename = fullfile(pwd, 'test.json');
            writelines(jsonText, filename);

            data = readjson(filename, 'SequenceRule', 'cell');

            testCase.verifyClass(data.tags, 'cell');
            testCase.verifyEqual(data.tags{1}, "alpha");
        end

        function testNestedSingleElementArraysCell(testCase)
            % Nested structure with multiple single-element arrays
            jsonText = '{"data": {"items": [{"name": "one"}], "refs": [{"id": 1}]}}';

            filename = fullfile(pwd, 'test.json');
            writelines(jsonText, filename);

            data = readjson(filename, 'SequenceRule', 'cell');

            testCase.verifyClass(data.data.items, 'cell');
            testCase.verifyClass(data.data.refs, 'cell');
        end

        function testAutoSequenceRuleUnchangedForSingleElement(testCase)
            % Verify SequenceRule='auto' (default) behavior is unchanged
            jsonText = '{"images": [{"url": "test.jpg"}]}';

            filename = fullfile(pwd, 'test.json');
            writelines(jsonText, filename);

            data = readjson(filename);  % Default is 'auto'

            % With 'auto', single-element array becomes scalar (existing behavior)
            testCase.verifyClass(data.images, 'matlab.io.config.JSONData');
            testCase.verifyEqual(data.images.url, "test.jpg");
        end

        function testNestedSampleRoundtripWithCell(testCase)
            % Full test with nested_sample.json using SequenceRule='cell'
            sampleFile = fullfile(fileparts(mfilename('fullpath')), 'SampleFiles', 'nested_sample.json');
            if ~isfile(sampleFile)
                testCase.assumeFail('Sample file not found');
            end

            data = readjson(sampleFile, 'SequenceRule', 'cell');

            outFile = fullfile(pwd, 'nested_roundtrip_cell.json');
            writejson(data, outFile);

            content = fileread(outFile);
            % images should be an array, not an object
            testCase.verifySubstring(content, '"images": [');
            % geometries should be an array, not an object
            testCase.verifySubstring(content, '"geometries": [');
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
            testCase.verifyClass(data.nullValue, 'matlab.io.config.JSONNull');
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

        function testSpecialCharacterKeys(testCase)
            % Test that keys with special characters are preserved
            data = jsondata();
            data.("this-name") = 123;
            data.("0invalid") = "test";
            data.("build-system") = "gradle";

            filename = fullfile(pwd, 'special_keys.json');
            writejson(data, filename);

            % Verify JSON contains original keys
            content = fileread(filename);
            testCase.verifySubstring(content, '"this-name"');
            testCase.verifySubstring(content, '"0invalid"');
            testCase.verifySubstring(content, '"build-system"');

            % Read back and verify original keys work
            readBack = readjson(filename);
            testCase.verifyEqual(readBack.("this-name"), 123);
            testCase.verifyEqual(readBack.("0invalid"), "test");
            testCase.verifyEqual(readBack.("build-system"), "gradle");

            % Verify aliases also work
            testCase.verifyEqual(readBack.this_name, 123);
            testCase.verifyEqual(readBack.x0invalid, "test");
            testCase.verifyEqual(readBack.build_system, "gradle");
        end

        function testNestedSpecialCharacterKeys(testCase)
            % Test special character keys in nested structures
            data = jsondata();
            data.("parent-key").("child-key") = "value";
            data.("parent-key").normal = 42;

            filename = fullfile(pwd, 'nested_special.json');
            writejson(data, filename);

            % Read back and verify
            readBack = readjson(filename);
            testCase.verifyEqual(readBack.("parent-key").("child-key"), "value");
            testCase.verifyEqual(readBack.("parent-key").normal, 42);

            % Verify aliases work
            testCase.verifyEqual(readBack.parent_key.child_key, "value");
        end

        %% Issue #49 — writejson array-of-objects crash
        function testWriteArrayOfObjectsRoundtrip(testCase)
            % Issue #49: writejson must not crash on arrays of ConfigurationData
            jsonText = '{"items": [{"name": "first", "value": 1}, {"name": "second", "value": 2}]}';

            inFile = fullfile(pwd, 'array_objects_in.json');
            writelines(jsonText, inFile);

            data = readjson(inFile);

            outFile = fullfile(pwd, 'array_objects_out.json');
            writejson(data, outFile);

            % Must produce valid JSON that can be re-read
            readBack = readjson(outFile);
            testCase.verifyTrue(isfield(readBack, 'items'));
        end

        function testWriteNestedArrayOfObjectsRoundtrip(testCase)
            % Issue #49: deeply nested object arrays (nested_sample.json pattern)
            sampleFile = fullfile(fileparts(mfilename('fullpath')), 'SampleFiles', 'nested_sample.json');
            if ~isfile(sampleFile)
                testCase.assumeFail('Sample file not found');
            end

            data = readjson(sampleFile);

            outFile = fullfile(pwd, 'nested_roundtrip.json');
            writejson(data, outFile);

            % Must produce valid, re-readable JSON
            readBack = readjson(outFile);
            testCase.verifyTrue(isfield(readBack, 'images'));
            testCase.verifyTrue(isfield(readBack, 'geometries'));
        end

        %% Issue #50 — key order preservation
        function testWritePreservesKeyOrder(testCase)
            % Issue #50: key order from source file must survive a roundtrip
            jsonText = '{"zebra": 1, "apple": 2, "mango": 3, "banana": 4}';

            inFile = fullfile(pwd, 'order_in.json');
            writelines(jsonText, inFile);

            data = readjson(inFile);

            outFile = fullfile(pwd, 'order_out.json');
            writejson(data, outFile);

            content = fileread(outFile);
            testCase.verifyTrue(strfind(content, '"zebra"') < strfind(content, '"apple"'));
            testCase.verifyTrue(strfind(content, '"apple"') < strfind(content, '"mango"'));
            testCase.verifyTrue(strfind(content, '"mango"') < strfind(content, '"banana"'));
        end

        function testWriteNewKeyAppendsAtEnd(testCase)
            % Issue #50: new keys added after reading append at end, not alphabetized
            jsonText = '{"second": 2, "first": 1}';

            inFile = fullfile(pwd, 'append_in.json');
            writelines(jsonText, inFile);

            data = readjson(inFile);
            data.third = 3;

            outFile = fullfile(pwd, 'append_out.json');
            writejson(data, outFile);

            content = fileread(outFile);
            testCase.verifyTrue(strfind(content, '"second"') < strfind(content, '"first"'));
            testCase.verifyTrue(strfind(content, '"first"') < strfind(content, '"third"'));
        end

        function testWritePreservesNestedKeyOrder(testCase)
            % Issue #50: key order must be preserved at every nesting level
            jsonText = '{"outer": {"zz": 1, "aa": 2, "mm": 3}}';

            inFile = fullfile(pwd, 'nested_order_in.json');
            writelines(jsonText, inFile);

            data = readjson(inFile);

            outFile = fullfile(pwd, 'nested_order_out.json');
            writejson(data, outFile);

            content = fileread(outFile);
            testCase.verifyTrue(strfind(content, '"zz"') < strfind(content, '"aa"'));
            testCase.verifyTrue(strfind(content, '"aa"') < strfind(content, '"mm"'));
        end

        %% Issue #44 — Null Handling Tests
        function testNullDistinguishedFromEmptyArray(testCase)
            % Issue #44: null and empty array should be distinguishable
            jsonText = '{"nullValue": null, "emptyArray": []}';

            filename = fullfile(pwd, 'test.json');
            writelines(jsonText, filename);

            data = readjson(filename);

            % null -> matlab.io.config.JSONNull
            testCase.verifyClass(data.nullValue, 'matlab.io.config.JSONNull');
            testCase.verifyTrue(isa(data.nullValue, 'matlab.io.config.JSONNull'));

            % empty array -> double []
            testCase.verifyClass(data.emptyArray, 'double');
            testCase.verifyEmpty(data.emptyArray);
            testCase.verifyFalse(isa(data.emptyArray, 'matlab.io.config.JSONNull'));
        end

        function testNullRoundtrip(testCase)
            % Issue #44: null should round-trip correctly
            jsonText = '{"value": null}';

            inFile = fullfile(pwd, 'null_in.json');
            writelines(jsonText, inFile);

            data = readjson(inFile);

            outFile = fullfile(pwd, 'null_out.json');
            writejson(data, outFile);

            content = fileread(outFile);
            testCase.verifySubstring(content, '"value": null');
        end

        function testEmptyArrayRoundtrip(testCase)
            % Issue #44: empty array should round-trip correctly
            jsonText = '{"items": []}';

            inFile = fullfile(pwd, 'empty_in.json');
            writelines(jsonText, inFile);

            data = readjson(inFile);

            outFile = fullfile(pwd, 'empty_out.json');
            writejson(data, outFile);

            content = fileread(outFile);
            % Empty arrays now round-trip as []
            testCase.verifySubstring(content, '"items": []');
        end

        function testNestedNullValue(testCase)
            % Issue #44: null values in nested objects
            jsonText = '{"outer": {"inner": null, "value": 42}}';

            filename = fullfile(pwd, 'test.json');
            writelines(jsonText, filename);

            data = readjson(filename);

            testCase.verifyClass(data.outer.inner, 'matlab.io.config.JSONNull');
            testCase.verifyEqual(data.outer.value, 42);
        end

        function testWriteNullDirectly(testCase)
            % Issue #44: writing matlab.io.config.JSONNull produces JSON null
            data = jsondata();
            data.nullable = matlab.io.config.JSONNull();
            data.name = "test";

            filename = fullfile(pwd, 'output.json');
            writejson(data, filename);

            content = fileread(filename);
            testCase.verifySubstring(content, '"nullable": null');
            testCase.verifySubstring(content, '"name": "test"');
        end

        function testNullEquality(testCase)
            % Test Null equality methods
            null1 = matlab.io.config.JSONNull();
            null2 = matlab.io.config.JSONNull();

            testCase.verifyTrue(null1 == null2);
            testCase.verifyTrue(isequal(null1, null2));
            testCase.verifyFalse(null1 == 5);
            testCase.verifyFalse(null1 == []);
        end

        function testNullIsEmpty(testCase)
            % Test that isempty returns true for Null (backward compatibility)
            null = matlab.io.config.JSONNull();
            testCase.verifyTrue(isempty(null));
        end

        function testMultipleNullValues(testCase)
            % Test multiple null values in same object
            jsonText = '{"a": null, "b": 1, "c": null, "d": "text"}';

            filename = fullfile(pwd, 'test.json');
            writelines(jsonText, filename);

            data = readjson(filename);

            testCase.verifyClass(data.a, 'matlab.io.config.JSONNull');
            testCase.verifyEqual(data.b, 1);
            testCase.verifyClass(data.c, 'matlab.io.config.JSONNull');
            testCase.verifyEqual(data.d, "text");
        end

        function testNullAndEmptyValueOmit(testCase)
            % Test EmptyValue='omit' behavior with Null
            data = jsondata();
            data.nullValue = matlab.io.config.JSONNull();
            data.emptyArray = [];
            data.name = "test";

            filename = fullfile(pwd, 'output.json');
            writejson(data, filename, 'EmptyValue', 'omit');

            content = fileread(filename);
            % Null should still be written (it's explicit null, not empty)
            testCase.verifySubstring(content, '"nullValue": null');
            % Empty array should be omitted
            testCase.verifyFalse(contains(content, '"emptyArray"'));
            testCase.verifySubstring(content, '"name": "test"');
        end
    end
end
