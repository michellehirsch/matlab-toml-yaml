classdef tomltest < matlab.unittest.TestCase
    % Tests for TOML parser with TOMLData objects
    
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

            testCase.verifyTrue(isfield(data, 'database'));
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

            testCase.verifyTrue(isfield(data, 'server'));
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
            tomlContent = '"special-key" = "value"';

            filename = 'test.toml';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', tomlContent);
            fclose(fid);

            data = readtoml(filename);

            % Access with parentheses for special characters
            testCase.verifyEqual(data.("special-key"), "value");
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

        function testArrayOfTables(testCase)
            % Test array of tables [[items]]
            tomlContent = ['[[items]]' newline ...
                          'name = "first"' newline ...
                          'value = 1' newline ...
                          '' newline ...
                          '[[items]]' newline ...
                          'name = "second"' newline ...
                          'value = 2' newline ...
                          '' newline ...
                          '[[items]]' newline ...
                          'name = "third"' newline ...
                          'value = 3'];

            filename = 'test.toml';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', tomlContent);
            fclose(fid);

            data = readtoml(filename);

            % Verify array of tables
            testCase.verifyEqual(length(data.items), 3);
            testCase.verifyEqual(data.items(1).name, "first");
            testCase.verifyEqual(data.items(1).value, 1);
            testCase.verifyEqual(data.items(2).name, "second");
            testCase.verifyEqual(data.items(2).value, 2);
            testCase.verifyEqual(data.items(3).name, "third");
            testCase.verifyEqual(data.items(3).value, 3);
        end

        function testNestedTablesInArrays(testCase)
            % Test nested tables within array of tables
            tomlContent = ['[[users]]' newline ...
                          'name = "Alice"' newline ...
                          'email = "alice@example.com"' newline ...
                          '' newline ...
                          '[users.permissions]' newline ...
                          'read = true' newline ...
                          'write = true' newline ...
                          'admin = false' newline ...
                          '' newline ...
                          '[[users]]' newline ...
                          'name = "Bob"' newline ...
                          'email = "bob@example.com"' newline ...
                          '' newline ...
                          '[users.permissions]' newline ...
                          'read = true' newline ...
                          'write = false' newline ...
                          'admin = false'];

            filename = 'test.toml';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', tomlContent);
            fclose(fid);

            data = readtoml(filename);

            % Verify array structure
            testCase.verifyEqual(length(data.users), 2);
            
            % First user
            testCase.verifyEqual(data.users(1).name, "Alice");
            testCase.verifyEqual(data.users(1).email, "alice@example.com");
            testCase.verifyEqual(data.users(1).permissions.read, true);
            testCase.verifyEqual(data.users(1).permissions.write, true);
            testCase.verifyEqual(data.users(1).permissions.admin, false);
            
            % Second user
            testCase.verifyEqual(data.users(2).name, "Bob");
            testCase.verifyEqual(data.users(2).email, "bob@example.com");
            testCase.verifyEqual(data.users(2).permissions.read, true);
            testCase.verifyEqual(data.users(2).permissions.write, false);
            testCase.verifyEqual(data.users(2).permissions.admin, false);
        end

        function testTOMLDataObject(testCase)
            % Test that TOMLData object works correctly
            tomlContent = ['title = "Test"' newline ...
                          '[database]' newline ...
                          'port = 5432'];

            filename = 'test.toml';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', tomlContent);
            fclose(fid);

            data = readtoml(filename);

            % Verify it's a TOMLData object
            testCase.verifyClass(data, 'TOMLData');
            
            % Verify we can convert to struct
            s = struct(data);
            testCase.verifyClass(s, 'struct');
            testCase.verifyEqual(s.title, "Test");
            testCase.verifyEqual(s.database.port, 5432);
        end

        function testSpecialCharacterKeys(testCase)
            % Test keys with special characters using parentheses notation
            tomlContent = ['"my-key" = 1' newline ...
                          '"another.key" = 2' newline ...
                          '[table."sub-table"]' newline ...
                          'value = 3'];

            filename = 'test.toml';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', tomlContent);
            fclose(fid);

            data = readtoml(filename);

            % Access with parentheses
            testCase.verifyEqual(data.("my-key"), 1);
            testCase.verifyEqual(data.("another.key"), 2);
            testCase.verifyEqual(data.table.("sub-table").value, 3);
        end
    end
end
