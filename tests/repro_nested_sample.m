% Use absolute repository paths for reliability in MCP server runs
scriptFull = mfilename('fullpath');
scriptDir = fileparts(scriptFull);
repoRoot = fullfile(scriptDir, '..');
toolboxPath = fullfile(repoRoot, 'toolbox');
addpath(toolboxPath);

inputFile = fullfile(repoRoot, 'tests', 'SampleFiles', 'nested_sample.json');
outFile = fullfile(repoRoot, 'tests', 'SampleFiles', 'nested_sample_roundtrip.json');
errorMat = fullfile(repoRoot, 'tests', 'repro_nested_sample_error.mat');

try
    disp('--- Starting repro ---');
    m = readjson(inputFile);
    disp('Read completed. Class of m:');
    disp(class(m));
    disp('Contents preview:');
    % Call the display method as a function to avoid key/method conflicts
    try
        show(m);
    catch
        disp(m);
    end
    writejson(m, outFile);
    disp('Write completed successfully.');
catch ME
    fprintf('ERROR: %s\n', ME.message);
    for k = 1:numel(ME.stack)
        fprintf(' In %s at line %d\n', ME.stack(k).name, ME.stack(k).line);
    end
    save(errorMat,'ME');
    rethrow(ME);
end
