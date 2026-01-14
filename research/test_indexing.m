% Test indexing behavior with ConfigurationData arrays
tomlContent = ['[[users]]' newline ...
              'name = "Alice"' newline ...
              'email = "alice@example.com"' newline ...
              '' newline ...
              '[users.permissions]' newline ...
              'read = true' newline ...
              'write = true' newline ...
              'admin = false' newline ...
              '' newline ...
              '[[users]]' newline ...
              'name = "Bob"' newline ...
              'email = "bob@example.com"' newline ...
              '' newline ...
              '[users.permissions]' newline ...
              'read = true' newline ...
              'write = false' newline ...
              'admin = false'];

filename = '/tmp/test_users.toml';
fid = fopen(filename, 'w');
fprintf(fid, '%s', tomlContent);
fclose(fid);

cd('/Users/michellehirsch/Coding/AgentExperiments/MATLAB/Claude/ConfigurationFileIO/toolbox');
data = readtoml(filename);

% Test 1: Try data.users.name (should fail)
fprintf('\n=== Test 1: data.users.name ===\n');
try
    result = data.users.name;
    fprintf('SUCCESS: Got %s\n', string(result));
catch ME
    fprintf('ERROR: %s\n', ME.message);
end

% Test 2: Try data.users(1).name (should work)
fprintf('\n=== Test 2: data.users(1).name ===\n');
try
    result = data.users(1).name;
    fprintf('SUCCESS: Got "%s"\n', result);
catch ME
    fprintf('ERROR: %s\n', ME.message);
end

% Test 3: Try to set data.users(2).permissions = []
fprintf('\n=== Test 3: data.users(2).permissions = [] ===\n');
try
    data.users(2).permissions = [];
    fprintf('SUCCESS: Set permissions to []\n');
catch ME
    fprintf('ERROR: %s\n', ME.message);
end

% Test 4: Try to change data.users(2).name = "Suzie"
fprintf('\n=== Test 4: data.users(2).name = "Suzie" ===\n');
try
    data.users(2).name = "Suzie";
    fprintf('SUCCESS: Changed name to "Suzie"\n');
    fprintf('Verify: data.users(2).name = "%s"\n', data.users(2).name);
catch ME
    fprintf('ERROR: %s\n', ME.message);
end

% Test 5: Inspect subsref/subsasgn calls
fprintf('\n=== Test 5: Understanding the structure ===\n');
fprintf('class(data): %s\n', class(data));
fprintf('class(data.users): %s\n', class(data.users));
fprintf('size(data.users): [%s]\n', num2str(size(data.users)));
fprintf('class(data.users(1)): %s\n', class(data.users(1)));
