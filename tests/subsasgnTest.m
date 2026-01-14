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
    end
end
