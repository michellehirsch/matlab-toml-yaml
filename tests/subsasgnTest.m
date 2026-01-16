classdef subsasgnTest < matlab.unittest.TestCase
    % Atomic tests for subsasgn on ConfigurationData base class

    methods (TestMethodSetup)
        function setupPath(testCase)
            addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'toolbox'));
        end
    end

    methods (Test)
        %% Core subsasgn tests against ConfigurationData
        function testAssignToArrayElementField(testCase)
            % Test: data.items(2).name = "New"
            data = ConfigurationData();
            data.items = [ConfigurationData(), ConfigurationData()];
            data.items(1).name = "First";
            data.items(2).name = "Second";

            data.items(2).name = "Changed";
            testCase.verifyEqual(data.items(2).name, "Changed");
            testCase.verifyEqual(data.items(1).name, "First");  % Unchanged
        end

        function testAssignNestedFieldInArrayElement(testCase)
            % Test: data.items(1).nested.value = 42
            data = ConfigurationData();
            data.items = [ConfigurationData(), ConfigurationData()];
            data.items(1).nested.value = 42;
            testCase.verifyEqual(data.items(1).nested.value, 42);
        end

        function testAssignDeepChainThroughArrayElement(testCase)
            % Test: data.items(1).a.b.c = "deep"
            data = ConfigurationData();
            data.items = [ConfigurationData()];
            data.items(1).a.b.c = "deep";
            testCase.verifyEqual(data.items(1).a.b.c, "deep");
        end

        function testDirectElementReplacement(testCase)
            % Test: data.items(2) = newElement (no further chaining)
            data = ConfigurationData();
            data.items = [ConfigurationData(), ConfigurationData()];
            data.items(1).x = 1;
            data.items(2).x = 2;

            newElem = ConfigurationData();
            newElem.x = 99;
            data.items(2) = newElem;

            testCase.verifyEqual(data.items(2).x, 99);
            testCase.verifyEqual(data.items(1).x, 1);  % Unchanged
        end

        %% Regression tests - ensure existing patterns still work
        function testSimpleDotAssign(testCase)
            data = ConfigurationData();
            data.title = "Test";
            testCase.verifyEqual(data.title, "Test");
        end

        function testChainedDotAssign(testCase)
            data = ConfigurationData();
            data.a.b.c = "deep";
            testCase.verifyEqual(data.a.b.c, "deep");
        end

        %% Subclass validation - TOMLData
        function testTOMLDataInheritsSubsasgn(testCase)
            data = TOMLData();
            data.items = [TOMLData(), TOMLData()];
            data.items(1).name = "Alice";
            data.items(2).name = "Bob";

            data.items(2).name = "Charlie";
            testCase.verifyEqual(data.items(2).name, "Charlie");
        end

        %% Subclass validation - YAMLData
        function testYAMLDataInheritsSubsasgn(testCase)
            data = YAMLData();
            data.items = [YAMLData(), YAMLData()];
            data.items(1).value = 10;
            data.items(2).value = 20;

            data.items(2).value = 99;
            testCase.verifyEqual(data.items(2).value, 99);
        end

        %% Reserved name collision tests (Issue #14)
        % With OverridesPublicDotMethodCall, users can have keys that match
        % method names. The key takes priority over the method when using
        % dot notation. Methods must be called with function syntax.

        function testKeyNamedKeys(testCase)
            % Test: user can create a key named "keys"
            data = ConfigurationData();
            data.keys = "my keys value";

            % Dot notation returns the data key, not the method
            testCase.verifyEqual(data.keys, "my keys value");

            % Function syntax still calls the method
            allKeys = keys(data);
            testCase.verifyEqual(allKeys, "keys");
        end

        function testKeyNamedIsfield(testCase)
            % Test: user can create a key named "isfield"
            data = ConfigurationData();
            data.isfield = true;

            % Dot notation returns the data key
            testCase.verifyEqual(data.isfield, true);

            % Function syntax still works for the method
            testCase.verifyTrue(isfield(data, "isfield"));
        end

        function testKeyNamedShow(testCase)
            % Test: user can create a key named "show"
            data = ConfigurationData();
            data.show = "my show value";

            % Dot notation returns the data key
            testCase.verifyEqual(data.show, "my show value");
        end

        function testKeyNamedStruct(testCase)
            % Test: user can create a key named "struct"
            data = ConfigurationData();
            data.struct = "struct value";

            % Dot notation returns the data key
            testCase.verifyEqual(data.struct, "struct value");

            % Function syntax still works for conversion
            s = struct(data);
            testCase.verifyTrue(isstruct(s));
            testCase.verifyEqual(s.struct, "struct value");
        end

        function testKeyNamedCopy(testCase)
            % Test: user can create a key named "copy"
            data = ConfigurationData();
            data.copy = "copy value";

            % Dot notation returns the data key
            testCase.verifyEqual(data.copy, "copy value");

            % Function syntax still works for the method
            dataCopy = copy(data);
            testCase.verifyEqual(dataCopy.copy, "copy value");
        end

        function testMultipleReservedNames(testCase)
            % Test: multiple reserved names can coexist
            data = ConfigurationData();
            data.keys = ["key1", "key2"];
            data.isfield = false;
            data.struct = "struct value";
            data.normal = "normal value";

            % All values accessible via dot notation
            testCase.verifyEqual(data.keys, ["key1", "key2"]);
            testCase.verifyEqual(data.isfield, false);
            testCase.verifyEqual(data.struct, "struct value");
            testCase.verifyEqual(data.normal, "normal value");

            % Method still works via function syntax
            allKeys = keys(data);
            testCase.verifyEqual(sort(allKeys), sort(["keys", "isfield", "struct", "normal"]));
        end

        function testReservedNameInYAMLData(testCase)
            % Test: reserved names work in YAMLData subclass
            data = YAMLData();
            data.keys = "yaml keys";

            testCase.verifyEqual(data.keys, "yaml keys");
            testCase.verifyEqual(keys(data), "keys");
        end

        function testReservedNameInTOMLData(testCase)
            % Test: reserved names work in TOMLData subclass
            data = TOMLData();
            data.keys = "toml keys";

            testCase.verifyEqual(data.keys, "toml keys");
            testCase.verifyEqual(keys(data), "keys");
        end
    end
end
