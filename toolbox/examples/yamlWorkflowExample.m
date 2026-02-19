%[text] # Working with YAML Arrays: CI Workflow Management
%[text] GitHub Actions workflows are a real-world example of YAML files that contain arrays of objects. Each CI job has a `steps` array where every element is a mapping with fields like `name`, `uses`, and `with`. This example shows how to read, inspect, and update such a workflow file.
type ci.yaml %[output:9b279e59]
%%
%[text] ## Read the Workflow
%[text] Read the CI configuration file. The nested structure is preserved as YAMLData objects.
wf = readyaml("ci.yaml") %[output:2faf8072]
%%
%[text] ## Access the Steps Array
%[text] The `steps` key holds a 4x1 YAMLData array — one element per step. Each element is a YAMLData object with its own fields.
steps = wf.jobs.test.steps %[output:5506ad51]
%%
%[text] ## Collect Field Values Across All Steps
%[text] Use dot notation on the array to gather a field from every element at once — no loop needed. This works like a vectorized field read across the whole array. The values must be of the same type and compatible size. If they are heterogeneous, this errors.
names = steps.name %[output:3ccb8d3a]
%%
%[text] Not all steps have all of the same keys. There are a few ways to figure out which have which. Call `show` and look for yourself:
show(steps) %[output:2288a0fe]
%%
%[text] `iskey` is vectorized, so you can programmatically check all array elements:
iskey(steps,"with") %[output:305f88c6]
%%
%[text] ## Find a Step by Name
%[text] Logical indexing works on YAMLData arrays just like MATLAB numeric arrays. Combine with dot access to filter by field value.
isMatlabSetup = steps.name == "Setup MATLAB";
matlabStep = steps(isMatlabSetup) %[output:05add0ed]
%%
%[text] The matched step has a nested `with` object holding its parameters:
matlabStep.with.release %[output:1b35069e]
%%
%[text] ## Update a Nested Field with Chained Assignment
%[text] The full chained path — array indexing followed by nested dot access — works as a single assignment expression. No need to extract, modify, and reassign.
wf.jobs.test.steps(isMatlabSetup).with.release = "R2025a";
wf.jobs.test.steps(isMatlabSetup).with.release %[output:9ec21f19]
%%
%[text] ## Write the Updated Workflow
%[text] Write the modified workflow back to a YAML file. The output preserves the original block structure.
writeyaml(wf, "ci_updated.yaml");
type("ci_updated.yaml") %[output:3a865602]
%%
%[text] ## Write the Updated Workflow
%[text] Write the modified workflow back to a YAML file. The output preserves the original block structure.
writeyaml(wf, "ci_updated.yaml", SectionSpacing="loose");
type("ci_updated.yaml") %[output:38dbb7e9]
%%
%[text] ## Cleanup
delete("ci_updated.yaml")
%[text] 

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
%[output:9b279e59]
%   data: {"dataType":"text","outputData":{"text":"\n# GitHub Actions CI workflow for a MATLAB toolbox\nname: CI\n\non:\n  push:\n    branches: [main, develop]\n  pull_request:\n    branches: [main]\n\njobs:\n  test:\n    runs-on: ubuntu-latest\n\n    steps:\n      - name: Checkout code\n        uses: actions\/checkout@v4\n\n      - name: Setup MATLAB\n        uses: matlab-actions\/setup-matlab@v2\n        with:\n          release: R2024b\n          products: MATLAB Statistics_and_Machine_Learning_Toolbox\n\n      - name: Run tests\n        uses: matlab-actions\/run-tests@v2\n        with:\n          source-folder: src\n          test-results-junit: test-results\/results.xml\n          code-coverage-cobertura: coverage\/coverage.xml\n\n      - name: Upload test results\n        uses: actions\/upload-artifact@v4\n        with:\n          name: test-results\n          path: test-results\/\n","truncated":false}}
%---
%[output:2faf8072]
%   data: {"dataType":"textualVariable","outputData":{"name":"wf","value":"  <a href=\"matlab:helpPopup('matlab.io.config.YAMLData')\" style=\"font-weight:bold\">YAMLData<\/a> with keys:\n\n    name: \"CI\"\n    on: [1x1 YAMLData with 2 keys]\n    jobs: [1x1 YAMLData with 1 key]\n\n    <a href=\"matlab:show(wf)\">Show all values<\/a>\n"}}
%---
%[output:5506ad51]
%   data: {"dataType":"textualVariable","outputData":{"name":"steps","value":"  1x4 <a href=\"matlab:helpPopup matlab.io.config.YAMLData\">YAMLData<\/a> array with keys:\n\n    name\n    uses\n    with\n\n    (keys vary by element)\n\n    <a href=\"matlab:show(steps)\">Show all values<\/a>\n"}}
%---
%[output:3ccb8d3a]
%   data: {"dataType":"matrix","outputData":{"columns":4,"header":"1×4 string array","name":"names","rows":1,"type":"string","value":[["Checkout code","Setup MATLAB","Run tests","Upload test results"]]}}
%---
%[output:2288a0fe]
%   data: {"dataType":"text","outputData":{"text":"item:\n  - name: Checkout code\n    uses: actions\/checkout@v4\n  - name: Setup MATLAB\n    uses: matlab-actions\/setup-matlab@v2\n    with:\n      release: R2024b\n      products: MATLAB Statistics_and_Machine_Learning_Toolbox\n  - name: Run tests\n    uses: matlab-actions\/run-tests@v2\n    with:\n      source-folder: src\n      test-results-junit: test-results\/results.xml\n      code-coverage-cobertura: coverage\/coverage.xml\n  - name: Upload test results\n    uses: actions\/upload-artifact@v4\n    with:\n      name: test-results\n      path: test-results\/\n\n","truncated":false}}
%---
%[output:305f88c6]
%   data: {"dataType":"matrix","outputData":{"columns":4,"header":"1×4 logical array","name":"ans","rows":1,"type":"logical","value":[["0","1","1","1"]]}}
%---
%[output:05add0ed]
%   data: {"dataType":"textualVariable","outputData":{"name":"matlabStep","value":"  <a href=\"matlab:helpPopup('matlab.io.config.YAMLData')\" style=\"font-weight:bold\">YAMLData<\/a> with keys:\n\n    name: \"Setup MATLAB\"\n    uses: \"matlab-actions\/setup-matlab@v2\"\n    with: [1x1 YAMLData with 2 keys]\n\n    <a href=\"matlab:show(matlabStep)\">Show all values<\/a>\n"}}
%---
%[output:1b35069e]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"R2024b\""}}
%---
%[output:9ec21f19]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"R2025a\""}}
%---
%[output:3a865602]
%   data: {"dataType":"text","outputData":{"text":"\nname: CI\non:\n  push:\n    branches:\n      - main\n      - develop\n  pull_request:\n    branches: main\njobs:\n  test:\n    runs-on: ubuntu-latest\n    steps:\n      - name: Checkout code\n        uses: actions\/checkout@v4\n      - name: Setup MATLAB\n        uses: matlab-actions\/setup-matlab@v2\n        with:\n          release: R2025a\n          products: MATLAB Statistics_and_Machine_Learning_Toolbox\n      - name: Run tests\n        uses: matlab-actions\/run-tests@v2\n        with:\n          source-folder: src\n          test-results-junit: test-results\/results.xml\n          code-coverage-cobertura: coverage\/coverage.xml\n      - name: Upload test results\n        uses: actions\/upload-artifact@v4\n        with:\n          name: test-results\n          path: test-results\/\n","truncated":false}}
%---
%[output:38dbb7e9]
%   data: {"dataType":"text","outputData":{"text":"\nname: CI\non:\n  push:\n    branches:\n      - main\n      - develop\n  pull_request:\n    branches: main\njobs:\n  test:\n    runs-on: ubuntu-latest\n    steps:\n      - name: Checkout code\n        uses: actions\/checkout@v4\n      - name: Setup MATLAB\n        uses: matlab-actions\/setup-matlab@v2\n        with:\n          release: R2025a\n          products: MATLAB Statistics_and_Machine_Learning_Toolbox\n      - name: Run tests\n        uses: matlab-actions\/run-tests@v2\n        with:\n          source-folder: src\n          test-results-junit: test-results\/results.xml\n          code-coverage-cobertura: coverage\/coverage.xml\n      - name: Upload test results\n        uses: actions\/upload-artifact@v4\n        with:\n          name: test-results\n          path: test-results\/\n","truncated":false}}
%---
