% Test dynamicprops behavior

% Experiment 1: Create array and test indexing
fprintf('=== Test 1: Arrays of dynamicprops ===\n');
obj1 = dynamicprops();
p1 = addprop(obj1, 'name');
obj1.name = 'Alice';

obj2 = dynamicprops();
p2 = addprop(obj2, 'name');
obj2.name = 'Bob';

arr = [obj1, obj2];

% Can we access arr.name?
try
    result = arr.name;
    fprintf('arr.name works! Returns comma-separated list\n');
catch ME
    fprintf('arr.name FAILED: %s\n', ME.message);
end

% Can we assign to array element?
fprintf('\n=== Test 2: Assignment to array element ===\n');
try
    arr(2).name = 'Suzie';
    fprintf('SUCCESS: arr(2).name = "Suzie" works!\n');
    fprintf('Verify: arr(2).name = %s\n', arr(2).name);
catch ME
    fprintf('FAILED: %s\n', ME.message);
end

% Test special characters
fprintf('\n=== Test 3: Special characters in property names ===\n');
obj3 = dynamicprops();
try
    p = addprop(obj3, 'build-system');
    fprintf('ERROR: Should have failed but addprop succeeded!\n');
catch ME
    fprintf('Expected failure: %s\n', ME.message);
    fprintf('(Properties must be valid MATLAB identifiers)\n');
end

% Can we use parenthesis notation?
try
    p = addprop(obj3, 'build_system');
    obj3.('build_system') = 'cmake';
    fprintf('Workaround: Use underscores and access via .() notation works\n');
catch ME
    fprintf('FAILED: %s\n', ME.message);
end

% Property ordering
fprintf('\n=== Test 4: Property ordering ===\n');
obj4 = dynamicprops();
addprop(obj4, 'z_field');
addprop(obj4, 'a_field'); 
addprop(obj4, 'm_field');
props = properties(obj4);
fprintf('Properties returned by properties(): %s\n', strjoin(props, ', '));
fprintf('(Alphabetically sorted, not insertion order)\n');
