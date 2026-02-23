%[text] # Experiment Tracking with configdata() and merge()
%[text] When running a parameter sweep, you need to track both the configuration that produced each result and the result itself. This example shows how `configdata()` and `merge()` make that natural — parameters and results live in the same object, variant creation is concise, and array operations make analysis straightforward.
%%
%[text] ## Define Base Parameters
%[text] Start with a shared base configuration that every run inherits. `configdata()` creates a format-neutral data object — not tied to any file format, just a container for structured data.
addpath('../')
baseParams = configdata();
baseParams.model = "linear";
baseParams.epochs = 50;
baseParams.optimizer = "sgd";
%%
%[text] ## Create Per-Run Parameter Sets with merge()
%[text] `merge()` combines two objects, with the second taking precedence for any overlapping keys. Here it means each run specifies only what changes — the shared parameters come through automatically. No copying boilerplate.
runs = [];
learningRates = [0.001, 0.01, 0.1, 0.5];
for i = 1:numel(learningRates)
    params = merge(baseParams, configdata(struct('learning_rate', learningRates(i))));
    runs = [runs, params];
end
runs
%%
%[text] ## Simulate Results
%[text] In a real workflow you would train a model here and record what came back. For illustration, a synthetic accuracy function peaks near `learning_rate = 0.01`. The results are written directly onto the same object that holds the parameters — no parallel arrays to keep in sync.
rng(42)
for i = 1:numel(runs)
    lr = runs(i).learning_rate;
    % Synthetic accuracy: best around lr=0.01
    runs(i).accuracy = 0.95 * exp(-50*(log(lr/0.01))^2) + 0.02*randn();
    runs(i).epochs_to_converge = round(20 + 80/(1 + lr*100));
end
%%
%[text] ## Analyze the Array
%[text] Dot access on a ConfigurationData array collects that field from every element and returns it as a plain MATLAB array — no loop required. Use this to find the best run and retrieve its complete record.
runs.learning_rate
runs.accuracy
%%
[bestAccuracy, idx] = max(runs.accuracy);
bestRun = runs(idx)
%%
%[text] ## Heterogeneous Fields with iskey()
%[text] Not every run needs the same keys. Runs that converged quickly triggered early stopping — a field that simply does not exist on the others. `iskey()` is vectorized across arrays, so you can filter by field presence without guarding every access.
for i = 1:numel(runs)
    if runs(i).epochs_to_converge < 30
        runs(i).early_stopped = true;
        runs(i).stopped_at_epoch = runs(i).epochs_to_converge;
    end
end
earlyStopped = runs(iskey(runs, "early_stopped"))
%%
%[text] Each entry in `earlyStopped` carries its full parameter set alongside the early-stopping metadata — everything in one place, with no schema enforcement forcing uniformity where the data naturally varies.
