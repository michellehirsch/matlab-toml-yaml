# Live Script Best Practice: One Output Per Section

## The Rule

**Try to have just one meaningful output per code section (between `%%` markers).**

Multiple interleaved lines of code and output make Live Scripts hard to follow and annoying to read.

## Why This Matters

Live Scripts are designed for interactive exploration. When every line produces output, it becomes:
- Cluttered and hard to scan
- Difficult to see the main results
- Annoying to step through

## Examples

### ❌ BAD - Multiple outputs per section
```matlab
%%
data = yamlread('config.yaml');
data.name                    % Output 1
data.version                 % Output 2  
data.database.host           % Output 3
data.database.port           % Output 4
```

This produces 4 separate outputs, cluttering the Live Script.

### ✅ GOOD - One output per section
```matlab
%%
%[text] Load and display configuration:
data = yamlread('config.yaml');
data
%%
%[text] Access specific fields:
data.name
data.database.host
```

Or even better - show the whole object once:
```matlab
%%
data = yamlread('config.yaml');
data
%%
%[text] Access database configuration:
data.database
```

## Techniques

### 1. Show Complete Objects
```matlab
%%
config = yamlread('app-config.yaml');
config
%%
%[text] Database settings:
config.database
```

### 2. Use Semicolons, Then Show Once
```matlab
%%
%[text] Update multiple settings:
k8s.spec.replicas = 5;
k8s.metadata.labels.version = "v2.0.0";
k8s.environment.debug = false;
%[text] View updated labels:
k8s.metadata.labels
```

### 3. Create Summary Structs
```matlab
%%
%[text] Extract configuration summary:
summary = struct();
summary.AppName = config.name;
summary.Version = config.version;
summary.Database = config.database.host;
summary
```

### 4. Use disp() for Messages
```matlab
%%
yamlwrite('output.yaml', data);
disp('✓ Configuration saved')
```

## Special Cases

### Multiple Related Values
When showing related values together makes sense, it's okay:
```matlab
%%
%[text] Service endpoints:
service.host
service.port
service.protocol
```

But consider showing the parent object instead:
```matlab
%%
%[text] Service configuration:
service
```

### Debugging/Development
During development, lots of outputs are fine. But clean them up before sharing!

## Application to YAML Examples

### Before (Cluttered)
```matlab
%%
k8s = yamlread('service.yaml');
k8s.metadata.name            % Output
k8s.metadata.namespace       % Output  
k8s.spec.type               % Output
k8s.spec.ports.http         % Output
```

### After (Clean)
```matlab
%%
k8s = yamlread('service.yaml');
k8s
%%
%[text] Service metadata:
k8s.metadata
%%
%[text] Service specification:
k8s.spec
```

## Summary

**One focused output per section = Better Live Scripts**

This makes your demos:
- Easier to read
- Easier to present
- More professional
- Less annoying to step through

---

**Add this to the Live Script skill documentation**
