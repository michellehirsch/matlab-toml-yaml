% Test dynamicprops behavior with proper subclass
cd /tmp

% Experiment 1: Create array and test indexing
fprintf('=== Test 1: Arrays of dynamicprops ===\n');
obj1 = TestDynamic();
addprop(obj1, 'name');
obj1.name = 'Alice';

obj2 = TestDynamic();
addprop(obj2, 'name');
obj2.name = 'Bob';

arr = [obj1, obj2];

% Can we access arr.name?
try
    result = arr.name;
    fprintf('arr.name works! Returns comma-separated list:\n');
    disp(result);
catch ME
    fprintf('arr.name FAILED: %s\n', ME.message);
end

% Can we assign to array element?
fprintf('=== Test 2: Assignment to array element ===\n');
try
    arr(2).name = 'Suzie';
    fprintf('SUCCESS: arr(2).name = "Suzie" works!\n');
    fprintf('Verify: arr(2).name = %s\n', arr(2).name);
catch ME
    fprintf('FAILED: %s\n', ME.message);
end

% Test special characters
fprintf('=== Test 3: Special characters in property names ===\n');
obj3 = TestDynamic();
try
    addprop(obj3, 'build-system');
    fprintf('ERROR: Should have failed but addprop succeeded!\n');
catch ME
    fprintf('Expected failure: %s\n', ME.message);
    fprintf('(Properties must be valid MATLAB identifiers)\n');
end

% Property ordering
fprintf('=== Test 4: Property ordering ===\n');
obj4 = TestDynamic();
addprop(obj4, 'z_field');
addprop(obj4, 'a_field'); 
addprop(obj4, 'm_field');
props = properties(obj4);
fprintf('Properties: %s\n', strjoin(props, ', '));
fprintf('(Alphabetically sorted, not insertion order)\n');

% Heterogeneous properties in arrays
fprintf('=== Test 5: Heterogeneous properties ===\n');
addprop(arr(1), 'email');
arr(1).email = 'alice@example.com';
try
    emails = arr.email;
    fprintf('arr.email works:\n');
    disp(emails);
catch ME
    fprintf('FAILED: %s\n', ME.message);
end

% Nested objects
fprintf('=== Test 6: Nested dynamicprops ===\n');
obj5 = TestDynamic();
addprop(obj5, 'permissions');
obj5.permissions = TestDynamic();
addprop(obj5.permissions, 'read');
obj5.permissions.read = true;
fprintf('Nested access obj5.permissions.read = %d\n', obj5.permissions.read);
