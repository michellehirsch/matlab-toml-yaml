%[text] # File Analysis with configdata — Struct Arrays Without the Friction
%[text] MATLAB's `dir()` returns a struct array, but working with that struct array is awkward. This example shows how `configdata()` eliminates the friction.
%%
%[text] ## The Classic Struct Array Problem
%[text] `dir()` returns a struct array. When you index into a field across all elements, MATLAB returns a comma-separated list — not an array. You have to wrap it in `{}` or `string({...})` to get something you can actually work with.
d = dir('*.m');
% This returns a comma-separated list, not an array:
%   d.name        % multiple outputs, not indexable
% You have to write this instead:
names = string({d.name}) %[output:0b0466bd]
%%
%[text] Filtering requires the same ceremony. There is no clean way to write `d(d.bytes > 5000)` — you have to extract the field first, build a logical index, and apply it manually.
bytes = [d.bytes];
large = d(bytes > 5000);
string({large.name}) %[output:0b0b7dfc]
%%
%[text] ## The configdata Approach
%[text] Wrap the struct array in `configdata()` and the friction disappears. Dot access on the array returns a proper string array, and logical indexing works exactly like it does on numeric arrays.
files = configdata(dir('*.m'));
files.name %[output:8ed317d9]
%%
%[text] Filtering is now a one-liner. The result is a `ConfigurationData` array you can keep working with.
large = files(files.bytes > 5000);
large.name %[output:4d5129ca]
%%
%[text] ## Sorting by a Field
%[text] To find the largest files, sort on the `bytes` field and index into the result. `files.bytes` returns a numeric array, so `sort` works directly.
[~, idx] = sort(files.bytes, 'descend');
largest = files(idx(1:3));
largest.name %[output:4ec57efa]
%%
%[text] ## Heterogeneous Fields
%[text] `dir()` structs have uniform fields, but real-world data often does not. When elements have different fields, `iskey` lets you filter to only those that have a particular key. Build a small heterogeneous array to see this in action.
item1 = configdata();
item1.name = "alpha.m";
item1.bytes = 1200;
item1.tag = "core";
item2 = configdata();
item2.name = "beta.m";
item2.bytes = 800;
item3 = configdata();
item3.name = "gamma.m";
item3.bytes = 3400;
item3.tag = "util";
items = [item1, item2, item3];
%%
%[text] `iskey` is vectorized — it returns a logical array showing which elements have the field. Use it as a logical index to filter the array.
hasTag = iskey(items, "tag");
tagged = items(hasTag);
tagged.name %[output:6a26a5d4]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
%[output:0b0466bd]
%   data: {"dataType":"matrix","outputData":{"columns":14,"header":"1×14 string array","name":"names","rows":1,"type":"string","value":[["conversionExample.m","eventLogExample.m","experimentTrackingExample.m","fileAnalysisExample.m","readiniExample.m","readjsonExample.m","readtomlExample.m","readyamlExample.m","tomlPyprojectExample.m","writeiniExample.m","writejsonExample.m","writetomlExample.m","writeyamlExample.m","yamlWorkflowExample.m"]]}}
%---
%[output:0b0b7dfc]
%   data: {"dataType":"matrix","outputData":{"columns":8,"header":"1×8 string array","name":"ans","rows":1,"type":"string","value":[["eventLogExample.m","readjsonExample.m","readtomlExample.m","readyamlExample.m","writejsonExample.m","writetomlExample.m","writeyamlExample.m","yamlWorkflowExample.m"]]}}
%---
%[output:8ed317d9]
%   data: {"dataType":"matrix","outputData":{"columns":1,"header":"14×1 string array","name":"ans","rows":14,"type":"string","value":[["conversionExample.m"],["eventLogExample.m"],["experimentTrackingExample.m"],["fileAnalysisExample.m"],["readiniExample.m"],["readjsonExample.m"],["readtomlExample.m"],["readyamlExample.m"],["tomlPyprojectExample.m"],["writeiniExample.m"]]}}
%---
%[output:4d5129ca]
%   data: {"dataType":"matrix","outputData":{"columns":1,"header":"8×1 string array","name":"ans","rows":8,"type":"string","value":[["eventLogExample.m"],["readjsonExample.m"],["readtomlExample.m"],["readyamlExample.m"],["writejsonExample.m"],["writetomlExample.m"],["writeyamlExample.m"],["yamlWorkflowExample.m"]]}}
%---
%[output:4ec57efa]
%   data: {"dataType":"matrix","outputData":{"columns":1,"header":"3×1 string array","name":"ans","rows":3,"type":"string","value":[["readjsonExample.m"],["writetomlExample.m"],["readtomlExample.m"]]}}
%---
%[output:6a26a5d4]
%   data: {"dataType":"matrix","outputData":{"columns":2,"header":"1×2 string array","name":"ans","rows":1,"type":"string","value":[["alpha.m","gamma.m"]]}}
%---
