TODO

This is a list of stuff on Michelle's mind to try to tackle
* FIRST: Resume Claude conversation when ran out of cycles JAn 8 (properties -> keys terminology update)
* After that's done, be sure that I've fully moved over to keys terminology - all three readers/classes. Watch for contained display - these say 1×1 YAMLData with 3 fields]
* Consider if should make ConfigurationData abstract. If so, update documentation to be developer-oriented only, remove example.
* Consider if should factor into 3 repos: make toml and yaml separate, both bringing in ConfigurationData as a Git reference
* Put the classes into namespace: matlab.io.config
* Keep chipping away at array behavior to make sure it feels natural. Is there something we can do when a user accesses a field in an array. Struct outputs a CSL, but we can have heterogeneous keys in an array.

# Jan 9 noon
TOML
* make show() work on an array. Ex: t = readtoml("tests/SampleFiles/matlab2.toml")
t.project.shortcuts

* Support indexing to expand array:
t = readtoml("tests/SampleFiles/matlab.toml")
t.project.shortcuts(2) = t.project.shortcuts(1) % This errors

* Improve error message when try to index into a key of an array, e.g.
``` matlab
sc = readtoml("SqueakClassifier/matlab.toml")
sc.project.shortcuts
short = sc.project.shortcuts;
short.name
```

* Make a few long form examples for writing (maybe)
* readtoml errors: tests/SampleFiles/complex_workflow.toml

# Jan 15th - Jeremy's Observations

It would be good to use more modern practices as much as possible, especially if we plan to make this public. The more public "good" code out there, the more LLMs will be able to write better MATLAB code.

[X] Use writelines instead of direct fopen.
[X] Update tests to avoid generating cruft.
[] Use native strings instead of cellstr/char.
[] Allow partial/caseinsisentive matching in interface.
[] arrayfun/cellfun -> loops and vectorized calls as much as possible
[] Should we be using packages over projects? (I don't really know what to do with projects)
[] Use github actions for running tests and building mltbx file?