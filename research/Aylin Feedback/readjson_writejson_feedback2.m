%[text] ## Comparison to readstruct and readdictionary
%[text] - Benefits of readstruct (dot indexing) without the downsides of STRUCT (fieldname limitations)
%[text] - Benefits of readdictionary (avoids fieldname modification) without the downsides (dictionary indexing) \
%[text] <u>**Why don't we add arbitrary fieldname support to STRUCT instead?**</u>
%[text] If the STRUCT datatype just supported arbitrary field names, then STRUCT would satisfy the use-cases for the JSONData/YAMLData/TOMLData objects without needing to add a new object.
%[text] Therefore I wonder if our internal efforts should focus on unblocking arbitrary fieldnames for STRUCT instead of adding custom objects for these configuration file formats.
%%
%[text] ## Array-of-objects behavior: TODO Try to Improve!
%[text] I haven't tried the Nx1 JSONData array behavior yet, so I just wanted to try a few cases with that.
S = readjson("twitter.json");
% S.statuses.created_at  % Errors - can't access fields of an array; need S.statuses(1).created_at
%[text] Its interesting that I cannot access "S.statuses.created\_at". This syntax works both for readstruct (which returns a CSL) as well as for jsonTree (which elides the CSL by returning another jsonTree array).
S = readstruct("twitter.json");
S.statuses.created_at % Comma separated list %[output:09e9ae3a] %[output:1c0c8d5a] %[output:2c04f838] %[output:53af40e7] %[output:885ba53d] %[output:508e7d09] %[output:574eac8f] %[output:536e93cb] %[output:104d8567] %[output:037a2c2e] %[output:7d34361e] %[output:65e76cde] %[output:3b3a65e2] %[output:1ad71170] %[output:56883ee2] %[output:30ae449e] %[output:1af54a18] %[output:659fb43b] %[output:2ab8c068] %[output:0f866f5b] %[output:9b3d61ee] %[output:3dd2c0e1] %[output:01056a34] %[output:630c7073] %[output:58909096] %[output:7d582ace] %[output:9fd5946a] %[output:20754647] %[output:219bcd0b] %[output:801195ec] %[output:63af2bea] %[output:925cc7c6] %[output:5d763809] %[output:92dd6cbc] %[output:1cd1319f] %[output:15f130c8] %[output:2fee55cd] %[output:3a52d7f0] %[output:56094035] %[output:9752760c] %[output:92e93f69] %[output:1d367dcd] %[output:85d94f4b] %[output:0d6e2f44] %[output:39f6ac9c] %[output:24d7f8cd] %[output:776f2a23] %[output:86e6682a] %[output:3e0077ec] %[output:9ccf25e7] %[output:45ab2197] %[output:6256480e] %[output:36dcd36f] %[output:7755dd49] %[output:0ee59fd0] %[output:0cb67ec5] %[output:615414bb] %[output:4162a81f] %[output:07bac21b] %[output:4dbd4e40] %[output:861d6a3e] %[output:3f1bb5ca] %[output:5d61790f] %[output:73b71abe] %[output:0a983bf1] %[output:08cb01c2] %[output:1f1cd226] %[output:62ca1961] %[output:0bc7f032] %[output:54fadbc1] %[output:9fd67a7f] %[output:63dba54d] %[output:7d35e648] %[output:5517d720] %[output:4108e66d] %[output:48910e81] %[output:89c23171] %[output:9a1e26df] %[output:06a4a891] %[output:76353e07] %[output:770106dc] %[output:5f04d008] %[output:324368db] %[output:6eaf644f] %[output:80165649] %[output:2ce1d1a1] %[output:17462375] %[output:58b3dc76] %[output:071819ca] %[output:47afe165] %[output:95d64573] %[output:03174fbd] %[output:1ee9af0d] %[output:41508bd0] %[output:66421c7d] %[output:159e3edf] %[output:46f21948] %[output:177ac461] %[output:5cd79eff] %[output:9b716d4f]
%[text] I think this forces users to write manual "for" loops (or arrayfun) with JSONData, which is slower and takes more code than some kind of default behavior for nested dot indexing on array-of-objects.
%[text] Array-of-objects is a popular way to organize JSON data, especially tables in JSON files, so I think it makes a lot of sense to add some convenience syntax for this case.
%[text] Note that `jsondecode` also doesn't let you do `S.statuses.created_at` in 1 expression since `S.statuses` is a cell array:
S = jsondecode(fileread("twitter.json"));
S.statuses %[output:2a338c8c]
%[text] This indicates that `JSONData` is more like a cell array than a homogeneous array, even though it uses parens intsead of brace to "dereference" elements in the cell. I'll explore this more in the next section.
%%
%[text] ## Ambiguity in JSONData array dereferencing vs. slicing
%[text] I feel like the syntax of JSONData arrays is a little confusing since it doesn't use brace indexing like a cell array, but it also doesn't do CSL generation like a struct array:
j = readjson("twitter.json");
j.statuses.created_at % struct-like access %[output:22378302]
j.statuses{1} % cell-like access
%[text] Instead, JSONData array only supports a limited struct-like parens access syntax:
j2 = j.statuses(1).created_at
%[text] This means that several syntaxes that are vectorized one-liners jsonTree become multi-line operations that need `for` loops in JSONData:
% Goal: Increment all retweet_count by 100

% jsonTree approach (vectorized syntax)
j = jsonread("twitter.json");
j.statuses.retweet_count = j.statuses.retweet_count + 100;

% JSONData approach
j = readjson("twitter.json");
for i=1:numel(j.statuses)
    j.statuses(i).retweet_count = j.statuses(i).retweet_count + 100;
end
%[text] This also has severe performance consequences since the JSONData approach is creating a lot of small MCOS objects (if you have a million rows, it'll create a million small MCOS objects), while the jsonTree approach is just working on 1 large MCOS object irregardless of the number of rows. It indicates that the JSONData approach will mostly work for small data, but won't scale well to medium-large data.
%[text] **\[MICHELLE\]** I agree with the flag on inability to access values of keys across an array and will try to come up with a design.
%[text] - 3 ideas for keys that don't exist on some array elements
%[text]     - Subset the array. This is what's currently in JSONTree. I find this behavior very surprising and not MATLAB-y -  expectation is that dot indexing into an array returns an array of the same size.
%[text]     - Just return missing on subsref, allow subsasgn to add the keys
%[text]     - Don't allow operating on keys that don't exist on an array element
%[text]         - Vectorize iskey, so you can do: 
%[text]             - keyfound = iskey(data.users,"name"); % Nx1 of 1s and 0s
%[text]             - data.users(keyfound).name = ... \
%[text] **\[MICHELLE\]** I agree that my approach will likely hit performance issues. Will look to see how bad it is.
%%
%[text] ## Round-trip issue with 1-element arrays in JSON
%[text] This is observable even in the small example provided with the `writejson` function:
pkg = jsondata();
pkg.name = "my-awesome-app";
pkg.version = "1.0.0";
pkg.description = "An awesome application";
pkg.main = "index.js";
pkg.scripts.test = "jest";
pkg.scripts.build = "tsc";
pkg.scripts.start = "node dist/index.js";
pkg.keywords = ["awesome"]; % Changed this from a 3-element array to a 1-element array (a scalar).
pkg.author.name = "Developer";
pkg.author.email = "dev@example.com";
pkg.license = "MIT";
pkg.dependencies.express = "^4.18.2";
pkg.dependencies.("body-parser") = "^1.20.0";
pkg.devDependencies.typescript = "^5.0.0";
pkg.devDependencies.jest = "^29.0.0";
pkg.devDependencies.("@types/node") = "^20.0.0";
pkg.repository.type = "git";
pkg.repository.url = "https://github.com/dev/my-awesome-app.git";
pkg.private = false;
writejson(pkg, "my_package.json");
type("my_package.json") %[output:1e6f659e]
%[text] Note here that `keywords` is now a non-array type, which now doesn't meet the schema for NPM's `package.json` files (see [https://www.schemastore.org/package.json](https://www.schemastore.org/package.json) where `keywords` is required to always be an `array`).
%[text] Its very tempting to think that accurate JSON `array` handling is a rare out-of-model use-case that can be enabled via an extra N-V pair or something like that. I understand that this is an annoying case to handle that complicates all the indexing. But I think its **very** telling that the *simplest real-world writejson example* **already** suffers from a correctness problem due to the default behavior of the design.
%[text] Also, I'm not convinced that there are a lot of users that ***NEED non-ASCII fieldname round-trip by default*** (and therefore need a custom datatype instead of `struct`) but ***DONT NEED array-of-1-element round-trip by default***. Array-of-objects are *very common, to the extent that it is already an issue in the very first real-world writejson example*. Why have we optimized this design to account for a rarer edge-case, but deprioritized handling a common case behind an off-by-default N-V pair?
%[text] **\[MICHELLE\]:** 
%[text] - Really good flag that the users who want name preservation also likely want array preservation - in both cases it's because they want to roundtrip. That said, I think we might be making nice enough behavior that users will prefer JSONData over struct even if they don't need roundtrip. The nice display and the (new) ability to dot index across an array. Name preservation is also extra appealing when you have names like "@name" so you don't get ugly x\_name.
%[text] - Current approach: 
%[text]     - Use SequenceRule = "cell" to force all arrays into cells when reading. More awkward to work with in MATLAB, but roundtrip nicely. I'm hesitant to make it the default
%[text]     - I've also added an ArrayKeys option to writejson that lets a user specify any keys (by name) that they want to force to be arrays. This lets them work with natural MATLAB arrays, but then ensure that the right ones are written as arrays when output
%[text]         - It's simple name matching without hierarchy - e.g. every key named foobar will be made array
%[text]         - I could improve this workflow by giving an output on readjson that lists keys that were arrays. Might be part of larger metadata output
%[text] - I still think my solution is nicely targeted and not very onerous, but need to compare with JSONTree experience to get a better feel (especially if JSONTree switches to native MATLAB types for values where possible). \
%%
%[text] ## Performance with real-world JSON files.
%[text] Comparisons with readstruct and jsondecode:
tic; S = readjson("twitter.json"); toc
Elapsed time is 1.309058 seconds.
tic; S = readstruct("twitter.json"); toc
Elapsed time is 0.146607 seconds.
tic; S = jsondecode(fileread("twitter.json")); toc
Elapsed time is 0.031396 seconds.
%[text] I know that some of this is just because the prototype is not optimized yet. But I think we should keep in mind that the readjson design requires a lot of small MCOS objects to be created, especially in the array-of-objects cases.
%[text] While this benchmark doesn't demonstrate the inefficiency of large numbers of small MCOS objects, it is something to keep in mind for the future.
%%
%[text] ## Small bug in jsondata ctor
j = jsondata(struct(A={1 2}))

j = 

  JSONData with keys:

    A: 1
%[text] This should probably be a JSONData array with 2 array elements.

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline","rightPanelPercent":16.3}
%---
%[output:09e9ae3a]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:15 +0000 2014\""}}
%---
%[output:1c0c8d5a]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:14 +0000 2014\""}}
%---
%[output:2c04f838]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:14 +0000 2014\""}}
%---
%[output:53af40e7]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:14 +0000 2014\""}}
%---
%[output:885ba53d]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:13 +0000 2014\""}}
%---
%[output:508e7d09]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:13 +0000 2014\""}}
%---
%[output:574eac8f]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:13 +0000 2014\""}}
%---
%[output:536e93cb]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:13 +0000 2014\""}}
%---
%[output:104d8567]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:13 +0000 2014\""}}
%---
%[output:037a2c2e]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:10 +0000 2014\""}}
%---
%[output:7d34361e]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:10 +0000 2014\""}}
%---
%[output:65e76cde]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:10 +0000 2014\""}}
%---
%[output:3b3a65e2]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:10 +0000 2014\""}}
%---
%[output:1ad71170]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:09 +0000 2014\""}}
%---
%[output:56883ee2]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:09 +0000 2014\""}}
%---
%[output:30ae449e]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:09 +0000 2014\""}}
%---
%[output:1af54a18]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:09 +0000 2014\""}}
%---
%[output:659fb43b]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:09 +0000 2014\""}}
%---
%[output:2ab8c068]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:09 +0000 2014\""}}
%---
%[output:0f866f5b]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:08 +0000 2014\""}}
%---
%[output:9b3d61ee]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:08 +0000 2014\""}}
%---
%[output:3dd2c0e1]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:08 +0000 2014\""}}
%---
%[output:01056a34]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:08 +0000 2014\""}}
%---
%[output:630c7073]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:08 +0000 2014\""}}
%---
%[output:58909096]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:07 +0000 2014\""}}
%---
%[output:7d582ace]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:07 +0000 2014\""}}
%---
%[output:9fd5946a]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:07 +0000 2014\""}}
%---
%[output:20754647]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:07 +0000 2014\""}}
%---
%[output:219bcd0b]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:07 +0000 2014\""}}
%---
%[output:801195ec]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:07 +0000 2014\""}}
%---
%[output:63af2bea]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:07 +0000 2014\""}}
%---
%[output:925cc7c6]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:07 +0000 2014\""}}
%---
%[output:5d763809]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:06 +0000 2014\""}}
%---
%[output:92dd6cbc]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:06 +0000 2014\""}}
%---
%[output:1cd1319f]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:06 +0000 2014\""}}
%---
%[output:15f130c8]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:06 +0000 2014\""}}
%---
%[output:2fee55cd]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:06 +0000 2014\""}}
%---
%[output:3a52d7f0]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:06 +0000 2014\""}}
%---
%[output:56094035]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:06 +0000 2014\""}}
%---
%[output:9752760c]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:05 +0000 2014\""}}
%---
%[output:92e93f69]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:05 +0000 2014\""}}
%---
%[output:1d367dcd]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:05 +0000 2014\""}}
%---
%[output:85d94f4b]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:05 +0000 2014\""}}
%---
%[output:0d6e2f44]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:05 +0000 2014\""}}
%---
%[output:39f6ac9c]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:05 +0000 2014\""}}
%---
%[output:24d7f8cd]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:05 +0000 2014\""}}
%---
%[output:776f2a23]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:05 +0000 2014\""}}
%---
%[output:86e6682a]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:05 +0000 2014\""}}
%---
%[output:3e0077ec]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:04 +0000 2014\""}}
%---
%[output:9ccf25e7]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:04 +0000 2014\""}}
%---
%[output:45ab2197]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:04 +0000 2014\""}}
%---
%[output:6256480e]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:04 +0000 2014\""}}
%---
%[output:36dcd36f]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:04 +0000 2014\""}}
%---
%[output:7755dd49]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:03 +0000 2014\""}}
%---
%[output:0ee59fd0]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:03 +0000 2014\""}}
%---
%[output:0cb67ec5]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:03 +0000 2014\""}}
%---
%[output:615414bb]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:03 +0000 2014\""}}
%---
%[output:4162a81f]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:03 +0000 2014\""}}
%---
%[output:07bac21b]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:03 +0000 2014\""}}
%---
%[output:4dbd4e40]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:03 +0000 2014\""}}
%---
%[output:861d6a3e]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:03 +0000 2014\""}}
%---
%[output:3f1bb5ca]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:03 +0000 2014\""}}
%---
%[output:5d61790f]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:02 +0000 2014\""}}
%---
%[output:73b71abe]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:02 +0000 2014\""}}
%---
%[output:0a983bf1]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:02 +0000 2014\""}}
%---
%[output:08cb01c2]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:02 +0000 2014\""}}
%---
%[output:1f1cd226]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:02 +0000 2014\""}}
%---
%[output:62ca1961]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:02 +0000 2014\""}}
%---
%[output:0bc7f032]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:02 +0000 2014\""}}
%---
%[output:54fadbc1]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:02 +0000 2014\""}}
%---
%[output:9fd67a7f]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:02 +0000 2014\""}}
%---
%[output:63dba54d]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:02 +0000 2014\""}}
%---
%[output:7d35e648]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:01 +0000 2014\""}}
%---
%[output:5517d720]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:01 +0000 2014\""}}
%---
%[output:4108e66d]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:01 +0000 2014\""}}
%---
%[output:48910e81]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:01 +0000 2014\""}}
%---
%[output:89c23171]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:01 +0000 2014\""}}
%---
%[output:9a1e26df]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:01 +0000 2014\""}}
%---
%[output:06a4a891]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:00 +0000 2014\""}}
%---
%[output:76353e07]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:00 +0000 2014\""}}
%---
%[output:770106dc]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:00 +0000 2014\""}}
%---
%[output:5f04d008]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:00 +0000 2014\""}}
%---
%[output:324368db]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:00 +0000 2014\""}}
%---
%[output:6eaf644f]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:00 +0000 2014\""}}
%---
%[output:80165649]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:29:00 +0000 2014\""}}
%---
%[output:2ce1d1a1]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:28:59 +0000 2014\""}}
%---
%[output:17462375]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:28:59 +0000 2014\""}}
%---
%[output:58b3dc76]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:28:59 +0000 2014\""}}
%---
%[output:071819ca]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:28:59 +0000 2014\""}}
%---
%[output:47afe165]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:28:59 +0000 2014\""}}
%---
%[output:95d64573]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:28:59 +0000 2014\""}}
%---
%[output:03174fbd]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:28:58 +0000 2014\""}}
%---
%[output:1ee9af0d]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:28:58 +0000 2014\""}}
%---
%[output:41508bd0]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:28:58 +0000 2014\""}}
%---
%[output:66421c7d]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:28:58 +0000 2014\""}}
%---
%[output:159e3edf]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:28:58 +0000 2014\""}}
%---
%[output:46f21948]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:28:58 +0000 2014\""}}
%---
%[output:177ac461]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:28:58 +0000 2014\""}}
%---
%[output:5cd79eff]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:28:57 +0000 2014\""}}
%---
%[output:9b716d4f]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Sun Aug 31 00:28:56 +0000 2014\""}}
%---
%[output:2a338c8c]
%   data: {"dataType":"tabular","outputData":{"columns":1,"header":"100×1 cell array","name":"ans","rows":100,"type":"cell","value":[["1×1 struct"],["1×1 struct"],["1×1 struct"],["1×1 struct"],["1×1 struct"],["1×1 struct"],["1×1 struct"],["1×1 struct"],["1×1 struct"],["1×1 struct"],["1×1 struct"],["1×1 struct"],["1×1 struct"],["1×1 struct"]]}}
%---
%[output:22378302]
%   data: {"dataType":"error","outputData":{"errorType":"runtime","text":"Error using <a href=\"matlab:matlab.lang.internal.introspective.errorDocCallback('matlab.io.config.ConfigurationData\/dotReference', '\/Users\/michellehirsch\/Coding\/AgentExperiments\/MATLAB\/Claude\/ConfigurationFileIO\/toolbox\/+matlab\/+io\/+config\/ConfigurationData.m', 378)\" style=\"font-weight:bold\"> . <\/a> (<a href=\"matlab: opentoline('\/Users\/michellehirsch\/Coding\/AgentExperiments\/MATLAB\/Claude\/ConfigurationFileIO\/toolbox\/+matlab\/+io\/+config\/ConfigurationData.m',378,0)\">line 378<\/a>)\nCannot access field 'created_at' on a [100 1] array of matlab.io.config.JSONData objects.\nIndex into the array first, e.g., obj(1).created_at or use:\n  arrayfun(@(x) x.created_at, obj)\n\nError in <a href=\"matlab:matlab.lang.internal.introspective.errorDocCallback('matlab.io.config.ConfigurationData\/dotReference', '\/Users\/michellehirsch\/Coding\/AgentExperiments\/MATLAB\/Claude\/ConfigurationFileIO\/toolbox\/+matlab\/+io\/+config\/ConfigurationData.m', 433)\" style=\"font-weight:bold\"> . <\/a> (<a href=\"matlab: opentoline('\/Users\/michellehirsch\/Coding\/AgentExperiments\/MATLAB\/Claude\/ConfigurationFileIO\/toolbox\/+matlab\/+io\/+config\/ConfigurationData.m',433,0)\">line 433<\/a>)\n                                value = dotReference(value, indexOp(2:end));"}}
%---
%[output:1e6f659e]
%   data: {"dataType":"text","outputData":{"text":"\n{\n  \"name\": \"my-awesome-app\",\n  \"version\": \"1.0.0\",\n  \"description\": \"An awesome application\",\n  \"main\": \"index.js\",\n  \"scripts\": {\n    \"test\": \"jest\",\n    \"build\": \"tsc\",\n    \"start\": \"node dist\/index.js\"\n  },\n  \"keywords\": \"awesome\",\n  \"author\": {\n    \"name\": \"Developer\",\n    \"email\": \"dev@example.com\"\n  },\n  \"license\": \"MIT\",\n  \"dependencies\": {\n    \"express\": \"^4.18.2\",\n    \"body-parser\": \"^1.20.0\"\n  },\n  \"devDependencies\": {\n    \"typescript\": \"^5.0.0\",\n    \"jest\": \"^29.0.0\",\n    \"@types\/node\": \"^20.0.0\"\n  },\n  \"repository\": {\n    \"type\": \"git\",\n    \"url\": \"https:\/\/github.com\/dev\/my-awesome-app.git\"\n  },\n  \"private\": false\n}\n","truncated":false}}
%---
