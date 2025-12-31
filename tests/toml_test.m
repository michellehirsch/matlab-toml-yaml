classdef toml_test < matlab.unittest.TestCase

    properties (TestParameter)
    end

    methods (TestClassSetup)
        function addToPath(testCase)
            % Add toolbox folder to path
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture('../toolbox'));
        end
    end

    methods (TestMethodSetup)
        function createTempFile(testCase)
            % Create temporary file for tests
            testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture);
        end
    end

    methods (Test)

        function testSimpleKeyValue(testCase)
            % Test simple key-value pairs
            tomlContent = ['title = "My App"' newline ...
                          'version = 1' newline ...
                          'enabled = true'];

            filename = 'test.toml';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', tomlContent);
            fclose(fid);

            data = readtoml(filename);

            testCase.verifyEqual(data.title, "My App");
            testCase.verifyEqual(data.version, 1);
            testCase.verifyEqual(data.enabled, true);
        end

        function testNumbers(testCase)
            % Test integer and float parsing
            tomlContent = ['integer = 42' newline ...
                          'float = 3.14' newline ...
                          'negative = -17' newline ...
                          'withUnderscore = 1_000_000'];

            filename = 'test.toml';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', tomlContent);
            fclose(fid);

            data = readtoml(filename);

            testCase.verifyEqual(data.integer, 42);
            testCase.verifyEqual(data.float, 3.14, 'AbsTol', 1e-10);
            testCase.verifyEqual(data.negative, -17);
            testCase.verifyEqual(data.withUnderscore, 1000000);
        end

        function testStrings(testCase)
            % Test string parsing
            tomlContent = ['basic = "hello world"' newline ...
                          'literal = ''C:\Users\path''' newline ...
                          'escaped = "Line 1\nLine 2"'];

            filename = 'test.toml';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', tomlContent);
            fclose(fid);

            data = readtoml(filename);

            testCase.verifyEqual(data.basic, "hello world");
            testCase.verifyEqual(data.literal, "C:\Users\path");
            testCase.verifyTrue(contains(data.escaped, newline));
        end

        function testArrays(testCase)
            % Test array parsing
            tomlContent = ['numbers = [1, 2, 3, 4]' newline ...
                          'strings = ["red", "green", "blue"]' newline ...
                          'empty = []'];

            filename = 'test.toml';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', tomlContent);
            fclose(fid);

            data = readtoml(filename);

            testCase.verifyEqual(data.numbers, [1, 2, 3, 4]);
            testCase.verifyEqual(data.strings, ["red", "green", "blue"]);
            testCase.verifyEqual(data.empty, []);
        end

        function testTables(testCase)
            % Test table parsing
            tomlContent = ['[database]' newline ...
                          'server = "192.168.1.1"' newline ...
                          'port = 5432' newline ...
                          'enabled = true'];

            filename = 'test.toml';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', tomlContent);
            fclose(fid);

            data = readtoml(filename);

            testCase.verifyTrue(isfield(data, "database"));
            testCase.verifyEqual(data.database.server, "192.168.1.1");
            testCase.verifyEqual(data.database.port, 5432);
            testCase.verifyEqual(data.database.enabled, true);
        end

        function testNestedTables(testCase)
            % Test nested table parsing
            tomlContent = ['[server.database]' newline ...
                          'host = "localhost"' newline ...
                          'port = 3306'];

            filename = 'test.toml';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', tomlContent);
            fclose(fid);

            data = readtoml(filename);

            testCase.verifyTrue(isfield(data, "server"));
            testCase.verifyEqual(data.server.database.host, "localhost");
            testCase.verifyEqual(data.server.database.port, 3306);
        end

        function testInlineTable(testCase)
            % Test inline table parsing
            tomlContent = 'point = {x = 1, y = 2, z = 3}';

            filename = 'test.toml';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', tomlContent);
            fclose(fid);

            data = readtoml(filename);

            testCase.verifyEqual(data.point.x, 1);
            testCase.verifyEqual(data.point.y, 2);
            testCase.verifyEqual(data.point.z, 3);
        end

        function testComments(testCase)
            % Test that comments are ignored
            tomlContent = ['# This is a comment' newline ...
                          'key = "value"  # inline comment' newline ...
                          '# Another comment' newline ...
                          'number = 42'];

            filename = 'test.toml';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', tomlContent);
            fclose(fid);

            data = readtoml(filename);

            testCase.verifyEqual(data.key, "value");
            testCase.verifyEqual(data.number, 42);
        end

        function testMixedTypeArrayError(testCase)
            % Test that mixed-type arrays throw error
            tomlContent = 'mixed = [1, "two", 3]';

            filename = 'test.toml';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', tomlContent);
            fclose(fid);

            testCase.verifyError(@() readtoml(filename), 'readtoml:MixedTypeArray');
        end

        function testMetadataOutput(testCase)
            % Test that metadata is returned with key ordering
            tomlContent = ['title = "My App"' newline ...
                          'version = 1' newline ...
                          '[database]' newline ...
                          'server = "localhost"' newline ...
                          'port = 5432'];

            filename = 'test.toml';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', tomlContent);
            fclose(fid);

            [data, metadata] = readtoml(filename);

            % Verify data is struct
            testCase.verifyTrue(isstruct(data));
            testCase.verifyEqual(data.database.server, "localhost");
            testCase.verifyEqual(data.database.port, 5432);

            % Verify metadata is dictionary
            testCase.verifyClass(metadata, 'dictionary');

            % Verify root key order is preserved
            testCase.verifyTrue(isKey(metadata, ""));
            rootKeys = metadata{""}{1};
            testCase.verifyEqual(rootKeys(1), "title");
            testCase.verifyEqual(rootKeys(2), "version");
            testCase.verifyEqual(rootKeys(3), "database");
        end

        function testWriteSimple(testCase)
            % Test writing simple struct
            data.title = "Test App";
            data.version = 2;
            data.enabled = true;

            filename = 'output.toml';
            writetoml(filename, data);

            % Read back and verify
            readData = readtoml(filename);
            testCase.verifyEqual(readData.title, "Test App");
            testCase.verifyEqual(readData.version, 2);
            testCase.verifyEqual(readData.enabled, true);
        end

        function testWriteTable(testCase)
            % Test writing nested tables
            data.database.server = "192.168.1.1";
            data.database.port = 5432;

            filename = 'output.toml';
            writetoml(filename, data);

            % Read back and verify
            readData = readtoml(filename);
            testCase.verifyEqual(readData.database.server, "192.168.1.1");
            testCase.verifyEqual(readData.database.port, 5432);
        end

        function testWriteArray(testCase)
            % Test writing arrays
            data.numbers = [1, 2, 3, 4, 5];
            data.colors = ["red", "green", "blue"];

            filename = 'output.toml';
            writetoml(filename, data);

            % Read back and verify
            readData = readtoml(filename);
            testCase.verifyEqual(readData.numbers, [1, 2, 3, 4, 5]);
            testCase.verifyEqual(readData.colors, ["red", "green", "blue"]);
        end

        function testWriteStruct(testCase)
            % Test writing struct
            data.title = "My Config";
            data.database.server = "localhost";
            data.database.port = 3306;

            filename = 'output.toml';
            writetoml(filename, data);

            % Read back and verify
            readData = readtoml(filename);
            testCase.verifyEqual(readData.title, "My Config");
            testCase.verifyEqual(readData.database.server, "localhost");
            testCase.verifyEqual(readData.database.port, 3306);
        end

        function testRoundTrip(testCase)
            % Test round-trip: write then read
            original.app = "TestApp";
            original.version = 1.5;
            original.ports = [8080, 8081, 8082];
            original.config.timeout = 30;
            original.config.retries = 3;

            filename = 'roundtrip.toml';
            writetoml(filename, original);
            readBack = readtoml(filename);

            testCase.verifyEqual(readBack.app, original.app);
            testCase.verifyEqual(readBack.version, original.version);
            testCase.verifyEqual(readBack.ports, original.ports);
            testCase.verifyEqual(readBack.config.timeout, original.config.timeout);
            testCase.verifyEqual(readBack.config.retries, original.config.retries);
        end

        function testRoundTripWithMetadata(testCase)
            % Test round-trip with metadata preserves key order
            tomlContent = ['zebra = 1' newline ...
                          'apple = 2' newline ...
                          'middle = 3'];

            filename = 'input.toml';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', tomlContent);
            fclose(fid);

            % Read with metadata
            [data, metadata] = readtoml(filename);

            % Write with metadata
            outfile = 'output.toml';
            writetoml(outfile, data, 'Metadata', metadata);

            % Read output as text to verify order
            content = string(fileread(outfile));
            lines = splitlines(content);

            % Verify key order is preserved
            testCase.verifyTrue(contains(lines(1), 'zebra'));
            testCase.verifyTrue(contains(lines(2), 'apple'));
            testCase.verifyTrue(contains(lines(3), 'middle'));
        end

        function testOverwriteProtection(testCase)
            % Test that files are not overwritten by default
            filename = 'protected.toml';
            data1.key = "value1";
            writetoml(filename, data1);

            data2.key = "value2";
            testCase.verifyError(@() writetoml(filename, data2), 'writetoml:FileExists');
        end

        function testOverwriteAllowed(testCase)
            % Test that OverWrite option works
            filename = 'overwrite.toml';
            data1.key = "value1";
            writetoml(filename, data1);

            data2.key = "value2";
            writetoml(filename, data2, 'OverWrite', true);

            readBack = readtoml(filename);
            testCase.verifyEqual(readBack.key, "value2");
        end

        function testHexNumbers(testCase)
            % Test hexadecimal number parsing
            tomlContent = 'hex = 0xDEADBEEF';

            filename = 'test.toml';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', tomlContent);
            fclose(fid);

            data = readtoml(filename);

            testCase.verifyEqual(data.hex, hex2dec('DEADBEEF'));
        end

        function testBinaryNumbers(testCase)
            % Test binary number parsing
            tomlContent = 'binary = 0b11010110';

            filename = 'test.toml';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', tomlContent);
            fclose(fid);

            data = readtoml(filename);

            testCase.verifyEqual(data.binary, bin2dec('11010110'));
        end

        function testOctalNumbers(testCase)
            % Test octal number parsing
            tomlContent = 'octal = 0o755';

            filename = 'test.toml';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', tomlContent);
            fclose(fid);

            data = readtoml(filename);

            testCase.verifyEqual(data.octal, base2dec('755', 8));
        end

        function testDatetime(testCase)
            % Test datetime parsing
            tomlContent = 'date = 2024-12-29T10:30:00Z';

            filename = 'test.toml';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', tomlContent);
            fclose(fid);

            data = readtoml(filename);

            testCase.verifyClass(data.date, 'datetime');
        end

        function testDottedKeys(testCase)
            % Test dotted keys (a.b = value creates nested structure)
            tomlContent = 'a.b.c = "nested value"';

            filename = 'test.toml';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', tomlContent);
            fclose(fid);

            data = readtoml(filename);

            testCase.verifyEqual(data.a.b.c, "nested value");
        end

        function testQuotedKeys(testCase)
            % Test quoted keys (keys with special characters)
            tomlContent = '"special key" = "value"';

            filename = 'test.toml';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', tomlContent);
            fclose(fid);

            data = readtoml(filename);

            testCase.verifyEqual(data.specialKey, "value");
        end

        function testBooleans(testCase)
            % Test boolean values
            tomlContent = ['t = true' newline ...
                          'f = false'];

            filename = 'test.toml';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', tomlContent);
            fclose(fid);

            data = readtoml(filename);

            testCase.verifyEqual(data.t, true);
            testCase.verifyEqual(data.f, false);
            testCase.verifyClass(data.t, 'logical');
        end

        function testIntegerVsFloatRoundTrip(testCase)
            % Test that integers stay integers in round-trip
            data.integer = 42;
            data.float = 3.14;

            filename = 'numbers.toml';
            writetoml(filename, data);

            % Read file as text to verify format
            content = fileread(filename);

            testCase.verifyTrue(contains(content, 'integer = 42'));
            testCase.verifyTrue(contains(content, 'float = 3.14'));
            testCase.verifyFalse(contains(content, 'integer = 42.0'));
        end
    end
end
