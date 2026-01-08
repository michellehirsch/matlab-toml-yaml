function test_multiline_strings
% Test multi-line string support in TOML parser

% Test 1: Basic multi-line string
tomlContent = ['description = """' newline ...
    'Line 1' newline ...
    'Line 2' newline ...
    '"""'];
filename = 'test_ml1.toml';
fid = fopen(filename, 'w');
fprintf(fid, '%s', tomlContent);
fclose(fid);
data = readtoml(filename);
assert(contains(data.description, 'Line 1'), 'Should contain Line 1');
assert(contains(data.description, newline), 'Should contain newline');
disp('Test 1: Basic multi-line string - PASSED');

% Test 2: Multi-line literal string
fid = fopen('test_ml2.toml', 'w');
fprintf(fid, 'regex = ''''''''\\nTest\\nString\\n''''''''\\n');
fclose(fid);
data = readtoml('test_ml2.toml');
assert(contains(data.regex, 'Test'), 'Should contain Test');
disp('Test 2: Multi-line literal string - PASSED');

% Test 3: Multi-line string in inline table
fid = fopen('test_ml3.toml', 'w');
fprintf(fid, 'data = { text = ''''''''\\nValue\\n'''''''' }\\n');
fclose(fid);
data = readtoml('test_ml3.toml');
assert(contains(data.data.text, 'Value'), 'Should contain Value');
disp('Test 3: Multi-line string in inline table - PASSED');

disp(' ');
disp('All multi-line string tests PASSED!');

% Cleanup
delete('test_ml1.toml', 'test_ml2.toml', 'test_ml3.toml');
end
