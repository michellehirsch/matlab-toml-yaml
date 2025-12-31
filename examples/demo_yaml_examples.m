%[text] # Real-World YAML Examples
%[text] This demo shows how to work with realistic YAML configurations commonly used in DevOps and cloud deployments.
%[text] ## Example 1: Kubernetes Service Configuration
k8s = readyaml('kubernetes-service.yaml');
k8s %[output:03a49f5a]
%%
%[text] Access specific fields:
k8s.metadata.name %[output:73d00c27]
k8s.metadata.labels.app %[output:0604702a]
k8s.spec.ports.("http-port") %[output:66beaf93]
%%
%[text] ## Example 2: Docker Compose Configuration
compose = readyaml('simple-docker-compose.yaml');
%[text] MATLAB app service:
matlabApp = compose.services.("matlab-app");
matlabApp %[output:4794b3a7]
%%
%[text] Database service:
compose.services.postgres
%%
%[text] ## Example 3: GitHub Actions Workflow
gh = readyaml('simple-github-actions.yaml');
gh
%%
%[text] ## Example 4: Modifying Configuration
%[text] Update multiple settings at once:
k8s.spec.("sessionAffinity") = "None";
k8s.metadata.labels.version = "v2.0.0";
compose.services.("matlab-app").environment.("MAX_WORKERS") = 16;
compose.services.("matlab-app").deploy.replicas = 5;
%[text] View updated Kubernetes labels:
k8s.metadata.labels
%%
%[text] View updated Docker Compose settings:
compose.services.("matlab-app").environment
%%
%[text] ## Example 5: Writing Modified Configurations
yamlwrite(k8s, 'k8s-modified.yaml');
yamlwrite(compose, 'compose-modified.yaml');
disp('✓ Modified configurations written')
%%
%[text] ## Example 6: Converting to Struct
%[text] Convert to standard struct (hyphens become underscores):
k8sStruct = struct(k8s);
k8sStruct.metadata.labels
%%
%[text] ## Example 7: Configuration Summary
%[text] Extract key information into a report:
summary = struct();
summary.ServiceName = k8s.metadata.name;
summary.ServiceType = k8s.spec.type;
summary.AppImage = compose.services.("matlab-app").image;
summary.Replicas = compose.services.("matlab-app").deploy.replicas;
summary.MaxWorkers = compose.services.("matlab-app").environment.("MAX_WORKERS");
summary
%%
%[text] ## Summary
%[text] This demo showed:
%[text] - Reading YAML: `data = readyaml('file.yaml')`
%[text] - Accessing hyphenated keys: `data.("key-name")`
%[text] - Modifying values: `data.field = newValue`
%[text] - Writing YAML: `yamlwrite(data)` or `yamlwrite(data, 'output.yaml')`
%[text] - Converting to struct: `s = struct(data)` \

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
%[output:03a49f5a]
%   data: {"dataType":"textualVariable","outputData":{"name":"k8s","value":"  <a href=\"matlab:helpPopup('YAMLData')\" style=\"font-weight:bold\">YAMLData<\/a> with properties:\n\n    apiVersion: 'v1'\n    kind: 'Service'\n    metadata: [1×1 YAMLData with 3 fields]\n    spec: [1×1 YAMLData with 4 fields]\n\n    <a href=\"matlab:show(k8s)\">Show all values<\/a>\n"}}
%---
%[output:73d00c27]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"'matlab-web-service'"}}
%---
%[output:0604702a]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"'matlab-webapp'"}}
%---
%[output:66beaf93]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"80"}}
%---
%[output:4794b3a7]
%   data: {"dataType":"textualVariable","outputData":{"name":"matlabApp","value":"  <a href=\"matlab:helpPopup('YAMLData')\" style=\"font-weight:bold\">YAMLData<\/a> with properties:\n\n    SourceFile: 'simple-docker-compose.yaml'\n    container_name: 'matlab-app'\n    depends_on: [1x1 cell]\n    deploy: [1×1 ConfigurationData with 3 fields]\n    environment: [1×1 ConfigurationData with 6 fields]\n    image: 'matlab-runtime:R2024b'\n    ports: [1×1 ConfigurationData with 3 fields]\n    restart: 'unless-stopped'\n    volumes: [1×1 ConfigurationData with 3 fields]\n"}}
%---
