function data = tomldata(input)
%TOMLDATA Create a TOMLData object for storing TOML-style configuration
%   data = TOMLDATA() creates an empty TOMLData object.
%
%   data = TOMLDATA(input) creates a TOMLData object initialized from input,
%   which can be a struct or dictionary.
%
%   Example:
%       % Create empty and populate
%       config = tomldata();
%       config.database.host = 'localhost';
%       config.database.port = 5432;
%
%       % Create from struct
%       s.name = 'MyApp';
%       s.version = '1.0';
%       config = tomldata(s);
%
%   See also: readtoml, writetoml, matlab.io.config.TOMLData

    if nargin == 0
        data = matlab.io.config.TOMLData();
    else
        data = matlab.io.config.TOMLData();
        data = importFrom(data, input);
    end
end
