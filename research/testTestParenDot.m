% Now test it
cd /tmp
obj = TestParenDot();

% Create an array of TestParenDot objects
arr = [TestParenDot(), TestParenDot()];
arr(1).Data('name') = 'Alice';
arr(2).Data('name') = 'Bob';

fprintf('=== Test 1: Direct array indexing ===\n');
try
    arr(2).name = 'Suzie';
    fprintf('SUCCESS: arr(2).name = "Suzie" works!\n');
    fprintf('Value: %s\n', arr(2).Data('name'));
catch ME
    fprintf('FAILED: %s\n', ME.message);
end

fprintf('\n=== Test 2: Through a parent object ===\n');
parent = TestParenDot();
parent.Data('users') = arr;

try
    parent.users(2).name = 'Charlie';
    fprintf('SUCCESS: parent.users(2).name = "Charlie" works!\n');
    users = parent.Data('users');
    fprintf('Value: %s\n', users(2).Data('name'));
catch ME
    fprintf('FAILED: %s\n', ME.message);
end

fprintf('\n=== Checking if parenDotAssign was called ===\n');
fprintf('Methods available:\n');
methods_list = methods('TestParenDot');
has_parendot = any(strcmp(methods_list, 'parenDotAssign'));
fprintf('Has parenDotAssign: %d\n', has_parendot);
fprintf('Has parenDotListLength: %d\n', any(strcmp(methods_list, 'parenDotListLength')));
