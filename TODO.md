TODO

This is a list of stuff on Michelle's mind to try to tackle
* FIRST: Resume Claude conversation when ran out of cycles JAn 8 (properties -> keys terminology update)
* After that's done, be sure that I've fully moved over to keys terminology - all three readers/classes. Watch for contained display - these say 1×1 YAMLData with 3 fields]
* Consider if should make ConfigurationData abstract. If so, update documentation to be developer-oriented only, remove example.
* Consider if should factor into 3 repos: make toml and yaml separate, both bringing in ConfigurationData as a Git reference
* Put the classes into namespace: matlab.io.config
* Keep chipping away at array behavior to make sure it feels natural. Is there something we can do when a user accesses a field in an array. Struct outputs a CSL, but we can have heterogeneous keys in an array.