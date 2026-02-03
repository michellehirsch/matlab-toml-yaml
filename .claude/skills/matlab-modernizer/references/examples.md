# MATLAB Modernization Examples

## String Arrays (instead of char/cell)

```matlab
% Before
name = 'John';
names = {'John', 'Jane'};

% After
name = "John";
names = ["John", "Jane"];
```

## Arguments Blocks (instead of varargin/inputParser)

```matlab
% Before
function result = processData(data, varargin)
    p = inputParser;
    addParameter(p, 'Method', 'default');
    parse(p, varargin{:});
    method = p.Results.Method;
end

% After
function result = processData(data, options)
    arguments
        data
        options.Method (1,1) string = "default"
    end
    method = options.Method;
end
```

## Arguments Block with Optional Named Parameter

```matlab
% Before
function result = process(data, searchKeyword)
    if nargin < 2
        searchKeyword = "MATLAB";
    end
end

% After
function result = process(data, options)
    arguments
        data (1,1) string
        options.SearchKeyword (1,1) string = "MATLAB"
    end
    searchKeyword = options.SearchKeyword;
end
% Call: process(data, SearchKeyword="Python")
```

## Table (instead of struct for tabular data)

```matlab
% Before
data.Name = {'Alice'; 'Bob'};
data.Age = [25; 30];

% After
data = table(["Alice"; "Bob"], [25; 30], VariableNames=["Name", "Age"]);
```

## Dictionary (instead of containers.Map)

```matlab
% Before
m = containers.Map({'a', 'b'}, {1, 2});
val = m('a');

% After
d = dictionary(["a", "b"], [1, 2]);
val = d("a");
```

## Dictionary (instead of struct for lookup)

```matlab
% Before (struct for lookup)
config.products.MATLAB = "Core";
config.products.Simulink = "Simulation";
category = config.products.(name);

% After (dictionary)
products = dictionary(["MATLAB", "Simulink"], ["Core", "Simulation"]);
category = products(name);
```

## compose (instead of sprintf for display)

```matlab
% Before
msg = sprintf('Value: %d', x);

% After
msg = compose("Value: %d", x);
```

## disp + string concatenation (instead of fprintf for logging)

```matlab
% Before
fprintf("Processing file: %s\n", filename);
fprintf("Found %d items\n", count);
fprintf("Done.\n");

% After
disp("Processing file: " + filename);
disp("Found " + count + " items");
disp("Done.");
```

## Live Scripts: Rich Text Instead of disp/fprintf

In Live Scripts, use rich text blocks for explanatory text:

```matlab
% Before (in Live Script)
disp("Now we plot the results");
plot(x, y)

% After (in Live Script)
%[text] Now we plot the results
plot(x, y)
```

Note: Keep `disp` for displaying computed values:
```matlab
%[text] The maximum value is:
disp(max(data))  % This is fine - shows a computed result
```

## compose with datetime (instead of sprintf + datestr)

```matlab
% Before
filename = sprintf('report_%s.csv', datestr(now, 'yyyy-mm-dd'));
filename = string(filename);

% After
filename = compose("report_%s.csv", string(datetime("now", Format="yyyy-MM-dd")));
```

## dateshift (instead of manual date arithmetic)

```matlab
% Before
nextMonth = datetime('now') + calmonths(1);
nextMonth.Day = 1;

% After
nextMonth = dateshift(datetime("now"), "start", "month") + calmonths(1);
```

## ISO 8601 datetime parsing

```matlab
% Before
createdAt = "2026-01-27T15:30:00.000Z";
dateStr = extractBefore(createdAt, "T");
postDate = datetime(dateStr, InputFormat="uuuu-MM-dd");

% After
postDate = datetime(createdAt, TimeZone="UTC");  % Parses ISO 8601 directly
```

## writelines (instead of fwrite for text)

```matlab
% Before
fid = fopen('file.txt', 'w');
fprintf(fid, '%s\n', lines{:});
fclose(fid);

% After
writelines(lines, "file.txt");
```

## writelines (instead of fopen/fprintf/fclose)

```matlab
% Before
fid = fopen("output.html", "w");
fprintf(fid, "<!DOCTYPE html>\n");
fprintf(fid, "<html>\n");
fclose(fid);

% After
lines = ["<!DOCTYPE html>"; "<html>"];
writelines(lines, "output.html");
```

## readlines (instead of fread/textscan for text)

```matlab
% Before
fid = fopen('file.txt');
data = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);
lines = data{1};

% After
lines = readlines("file.txt");
```

## readlines (instead of fileread + string)

```matlab
% Before
content = fileread("config.txt");
content = string(content);

% After
content = join(readlines("config.txt"), newline);
```

## isfile / isfolder (instead of exist)

```matlab
% Before
if exist('data.mat', 'file')
if exist('myFolder', 'dir')

% After
if isfile("data.mat")
if isfolder("myFolder")
```

## matches (instead of strcmp/strcmpi)

```matlab
% Before
if strcmp(str, 'option1')
if strcmpi(str, 'Option1')

% After
if matches(str, "option1")
if matches(str, "option1", IgnoreCase=true)
```

## contains/startsWith/endsWith (instead of strfind/regexp)

```matlab
% Before
if ~isempty(strfind(str, 'pattern'))
if ~isempty(regexp(str, '^prefix'))

% After
if contains(str, "pattern")
if startsWith(str, "prefix")
```

## Implicit Expansion (instead of bsxfun)

```matlab
% Before
result = bsxfun(@minus, A, mean(A, 1));

% After
result = A - mean(A, 1);
```

## tiledlayout (instead of subplot)

```matlab
% Before
figure;
subplot(2, 2, 1); plot(x1);
subplot(2, 2, 2); plot(x2);

% After
figure;
tiledlayout(2, 2);
nexttile; plot(x1);
nexttile; plot(x2);
```

## exportgraphics (instead of print)

```matlab
% Before
print(gcf, 'figure.png', '-dpng', '-r300');

% After
exportgraphics(gcf, "figure.png", Resolution=300);
```

## Name=Value Syntax (instead of positional args)

```matlab
% Before
plot(x, y, 'LineWidth', 2, 'Color', 'red');

% After
plot(x, y, LineWidth=2, Color="red");
```

## jsondecode with TextType (R2022a+)

```matlab
% Before
data = jsondecode(response);  % Returns char arrays

% After
data = jsondecode(response, TextType="string");  % Returns strings
```

## weboptions Name=value

```matlab
% Before
opts = weboptions('HeaderFields', headers, 'ContentType', 'json', 'Timeout', 30);

% After
opts = weboptions(HeaderFields=headers, ContentType="json", Timeout=30);
```

## datetime Name=value

```matlab
% Before
t = datetime('now', 'TimeZone', 'UTC', 'Format', 'yyyy-MM-dd');

% After
t = datetime("now", TimeZone="UTC", Format="yyyy-MM-dd");
```

## native2unicode/isfield with strings

```matlab
% Before
bytes = native2unicode(data, 'UTF-8');
if isfield(s, 'fieldName')

% After
bytes = native2unicode(data, "UTF-8");
if isfield(s, "fieldName")
```

## error with strings

```matlab
% Before
error('myPackage:InvalidInput', 'Value must be positive');

% After
error("myPackage:InvalidInput", "Value must be positive");
```

## strings() instead of cell() for text

```matlab
% Before
urls = cell(n, 1);
for i = 1:n
    urls{i} = posts{i}.url;
end

% After
urls = cellfun(@(p) string(p.url), posts(:));
% Or preallocate:
urls = strings(n, 1);
```

## cellfun for extracting fields

```matlab
% Before
names = cell(numel(items), 1);
for i = 1:numel(items)
    names{i} = items{i}.name;
end

% After
names = cellfun(@(x) string(x.name), items(:));
```
