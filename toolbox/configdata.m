function data = configdata(input)
%CONFIGDATA Create a format-neutral hierarchical data object
%   data = CONFIGDATA() creates an empty ConfigurationData object.
%
%   data = CONFIGDATA(input) creates a ConfigurationData object initialized
%   from input, which can be a struct or dictionary.
%
%   Use this when you want ConfigurationData's dot notation, ordered keys,
%   and vectorized array operations but don't need file I/O. Unlike yamldata()
%   or tomldata(), configdata() objects accept any MATLAB type as a value,
%   including tables, categoricals, and complex numbers.
%
%   Example:
%       % Create empty and populate
%       d = configdata();
%       d.name = "Alice";
%       d.score = 95;
%
%       % Create from struct (e.g., from dir())
%       files = configdata(dir('*.m'));
%       names = files.name;    % string array — no cell gymnastics
%       big = files(files.bytes > 1e4);
%
%       % Holds any MATLAB type
%       d.results = table(["a";"b"], [1;2], VariableNames=["label","value"]);
%
%   See also: yamldata, tomldata, matlab.io.config.ConfigurationData

    if nargin == 0
        data = matlab.io.config.ConfigurationData();
    else
        data = matlab.io.config.ConfigurationData();
        data = importFrom(data, input);
    end
end
