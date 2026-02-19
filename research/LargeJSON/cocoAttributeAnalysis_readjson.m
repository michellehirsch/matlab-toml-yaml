%[text] # COCO Annotation Quality Pipeline - readjson
%[text] Benchmark use case for working with large JSON data in MATLAB with `readjson`.
%[text] **Goal**
%[text] Build an end‑to‑end *annotation quality and dataset health* pipeline for COCO-format JSON that:
%[text] 1. **Ingests** the COCO 2017 training annotations (`instances_train2017.json`, hundreds of MB) and (optionally) image metadata.
%[text] 2. **Validates & profiles annotations** (e.g., bbox vs. polygon area consistency, crowd labels, category imbalance, per-image instance density).
%[text] 3. **Computes shape-level measurements** linked to segmentation polygons and masks (ties nicely to your *regionprops*-oriented interests).
%[text] 4. **Surfaces outliers** (e.g., degenerate polygons, extreme bbox aspect ratios) and **exports a review pack** (JSON + figures) for labelers.
%[text] 5. **Writes back** a compact **review JSON** containing per-category stats, outlier lists, and per-image summary metrics. \
%%
%[text] ## Setup
%[text] Set yourself up with [https://github.com/michellehirsch/matlab-toml-yaml.](https://github.com/michellehirsch/matlab-toml-yaml.) Either open the project or add the toolbox folder to your path.
%[text] **If needed, download and unzip the data.** Just un-comment this. It's slow, so only do it once
% output  = fullfile(pwd, 'annotations_trainval2017.zip');
% url = "http://images.cocodataset.org/annotations/annotations_trainval2017.zip"; % per docs
% websave(output,url)
% unzip(output,pwd)
%%
%[text] Select the annotation file. The val set (19 MB, ~36K annotations) is used for development; switch to the train set (448 MB, ~860K annotations) for performance assessment.
%[text] **Update the following to point to where you put the data**.
useReallyBigFile = false;          % If true, uses 448MB file instead of 19MB file %[control:checkbox:222d]{"position":[20,25]}
fileroot = "VeryLargeData"; % Full path to the folder containing your data files %[control:editfield:61d4]{"position":[12,27]}

if useReallyBigFile
    filename = "instances_train2017.json";                      %#ok<*UNRCH>
else
    filename = "instances_val2017.json";                        
end

annotationFile = fullfile(fileroot,filename);
outputDir = fileroot;
d = dir(annotationFile);
fileSizeMB = d.bytes/(1024^2);
disp("Analyzing " + annotationFile + " (" + fileSizeMB + " MB)" ) %[output:2b338d2b]
%%
%[text] ## Load COCO Annotations with readjson
%[text] `readjson` parses the JSON file into a single JSONData object. `coco.images`, `coco.annotations`, and `coco.categories` are JSONData arrays accessed via chained dot notation throughout the pipeline.
tStart = tic; % Timing overall script

tic;
cocorj = readjson(annotationFile);
tRead = toc;
"readjson completed in " + tRead + " seconds" %[output:439add70]
%%
%[text] Quick look at what's inside:
"Images: " + numel(cocorj.images) + ", Annotations: " + numel(cocorj.annotations) + ", Categories: " + numel(cocorj.categories) %[output:9eb58b47]
%[text] Explore to understand what's in the file.
%[text] Display shows top-level keys:
cocorj %[output:435e5cd6]
%[text] Navigate through object to see details, e.g.:
cocorj.licenses %[output:356ec2c7]
cocorj.licenses.url %[output:24be9132]
%[text] Use describe for a complete overview of the data:
describe(cocorj) %[output:6af45544]
%%
%[text] ## Enrich Annotations
%[text] Map category IDs and image IDs to human-readable names.
[~, catIdx] = ismember(cocorj.annotations.category_id, cocorj.categories.id);
catNamePerAnnotation = cocorj.categories.name(catIdx);
[~, imgIdx] = ismember(cocorj.annotations.image_id, cocorj.images.id);
imgNamePerAnnotation = cocorj.images.file_name(imgIdx);
%%
%[text] ## Bounding Box Geometry
%[text] `coco.annotations.bbox` extracts every annotation's `[x y w h]` via chained dot notation. Each bbox is a 4x1 vector, so the result is a (4N)x1 column that we reshape into an Nx4 matrix.
bboxes = reshape(cocorj.annotations.bbox, 4, []).';  % AYLIN: This could actually return the right 2D matrix Nx4.
bbox_w = bboxes(:,3);
bbox_h = bboxes(:,4);
aspect = bbox_w ./ max(bbox_h, eps);
bbox_area = bbox_w .* bbox_h;
%%
%[text] ## Polygon Area Approximation
%[text] The `segmentation` field is heterogeneous: non-crowd annotations store polygon coordinate arrays, while crowd annotations store RLE-encoded masks (JSONData objects). We filter the JSONData array using `coco.annotations.iscrowd` and index into it directly.
isCrowd = logical(cocorj.annotations.iscrowd);
nAnnotations = numel(cocorj.annotations);
polyArea = nan(nAnnotations, 1);
nonCrowdAnnotations = cocorj.annotations(~isCrowd);
nonCrowdIdx = find(~isCrowd);
tic;
% Loop required: each annotation's segmentation is a variable-length polygon
% (different number of vertices), so polyarea cannot be vectorized. We also
% need to check iscell per element since some segmentations may be empty.
for k = 1:numel(nonCrowdIdx)
    seg = nonCrowdAnnotations(k).segmentation;
    % AYLIN: Might be able to use arrayfun to cover both cases

    if iscell(seg) % Disconnected regions are listed as multiple segments. Just add up the total area
        polyArea(nonCrowdIdx(k)) = sum(cellfun(@(xy) polyarea(xy(1:2:end), xy(2:2:end)), seg));
    else % A single segment
       x = seg(1:2:end);
       y = seg(2:2:end);
       polyArea(nonCrowdIdx(k)) = polyarea(x, y);
    end
end


tPoly = toc;
"Polygon area for " + numel(nonCrowdIdx) + " non-crowd annotations in " + tPoly + " seconds" %[output:2a20b397]
%%
%[text] Compute the area consistency ratio (polygon area / bbox area). Values near 1.0 indicate good agreement.
areaRatio = polyArea ./ max(bbox_area, eps);
%%
%[text] ## Build Analysis Table
%[text] Build table with results from analysis.
T = table( ... %[output:group:5935cdcd] %[output:5b262b80]
    cocorj.annotations.id, cocorj.annotations.image_id, cocorj.annotations.category_id, ... %[output:5b262b80]
    catNamePerAnnotation, isCrowd, cocorj.annotations.area, ... %[output:5b262b80]
    bbox_w, bbox_h, aspect, bbox_area, polyArea, areaRatio, imgNamePerAnnotation, ... %[output:5b262b80]
    'VariableNames', ["id", "image_id", "category_id", "category", ... %[output:5b262b80]
    "iscrowd", "area", "bbox_w", "bbox_h", "aspect", "bbox_area", ... %[output:5b262b80]
    "poly_area", "area_ratio", "image_file"]); %[output:group:5935cdcd] %[output:5b262b80]
head(T)
%%
%[text] ## Per-Image Instance Density
[densityCounts, ~] = groupcounts(cocorj.annotations.image_id);
meanDensity = mean(densityCounts);
medianDensity = median(densityCounts);
maxDensity = max(densityCounts);
"Per-image density: mean=" + round(meanDensity,1) + ", median=" + medianDensity + ", max=" + maxDensity
%%
%[text] ## Category-Level Profiling
G = groupsummary(T, "category", "mean", ...
    ["bbox_w", "bbox_h", "aspect", "poly_area", "bbox_area", "area_ratio"]);
catCounts = groupcounts(T.category);
G.Count = catCounts;
G = sortrows(G, "Count", "descend");
%%
%[text] Top 10 categories by annotation count:
G(1:min(10, height(G)), ["category", "Count", "mean_bbox_w", "mean_bbox_h", "mean_aspect"])
%%
%[text] ## Outlier Detection
%[text] Flag annotations with extreme aspect ratios (\>99.5th percentile), tiny bounding boxes (\<0.5th percentile area), or inconsistent polygon-to-bbox area ratios.
validAspect = T.aspect(~isinf(T.aspect) & ~isnan(T.aspect));
isExtremeAR = T.aspect > prctile(validAspect, 99.5);
validArea = T.bbox_area(T.bbox_area > 0);
isTinyBox = T.bbox_area < prctile(validArea, 0.5);
isBadRatio = T.area_ratio < 0.3 | T.area_ratio > 1.5;
outlierMask = isExtremeAR | isTinyBox | isBadRatio;
outliers = T(outlierMask, :);
outlierSummary = table( ...
    ["Total"; "Extreme aspect ratio"; "Tiny bounding box"; "Bad area ratio"], ...
    [height(outliers); nnz(isExtremeAR); nnz(isTinyBox); nnz(isBadRatio)], ...
    'VariableNames', ["Criterion", "Count"])
%%
%[text] ## Build Review Pack with jsondata + writejson
%[text] Construct the output JSON structure field-by-field using `jsondata()` and dot notation assignment. `numel(coco.images)` etc. reach back into the original JSONData for counts.
pack = jsondata();
pack.dataset = "COCO 2017 val";
pack.generatedOn = string(datetime("now", Format="yyyy-MM-dd HH:mm:ss"));
% pack.summary = jsondata();
pack.summary.totalImages = numel(cocorj.images);
pack.summary.totalAnnotations = numel(cocorj.annotations);
pack.summary.totalCategories = numel(cocorj.categories);
pack.summary.crowdAnnotations = nnz(isCrowd);
% pack.summary.imageDensity = jsondata();
pack.summary.imageDensity.mean = round(meanDensity, 2);
pack.summary.imageDensity.median = medianDensity;
pack.summary.imageDensity.max = maxDensity;
%%
%[text] Convert category stats and outliers into JSONData arrays for the review pack.
nCategories = height(G);
categoryStats = repmat(jsondata(), nCategories, 1);
% Loop required: each element of a JSONData array is an independent object
% with its own set of keys. There is no vectorized way to assign fields
% across all elements — each must be populated individually.
for i = 1:nCategories
    categoryStats(i).category = G.category(i);
    categoryStats(i).count = G.Count(i);
    categoryStats(i).mean_bbox_w = round(G.mean_bbox_w(i), 1);
    categoryStats(i).mean_bbox_h = round(G.mean_bbox_h(i), 1);
    categoryStats(i).mean_aspect = round(G.mean_aspect(i), 2);
    categoryStats(i).mean_poly_area = round(G.mean_poly_area(i), 1);
    categoryStats(i).mean_bbox_area = round(G.mean_bbox_area(i), 1);
    categoryStats(i).mean_area_ratio = round(G.mean_area_ratio(i), 3);
end
pack.stats = categoryStats;
%%
maxOutliers = min(100, height(outliers));
topOutliers = outliers(1:maxOutliers, :);
outlierRecords = repmat(jsondata(), maxOutliers, 1);
% Loop required: same as categoryStats above — each JSONData element in the
% array must be populated individually since field assignment is per-object.
for i = 1:maxOutliers
    outlierRecords(i).id = topOutliers.id(i);
    outlierRecords(i).image_id = topOutliers.image_id(i);
    outlierRecords(i).image_file = topOutliers.image_file(i);
    outlierRecords(i).category = topOutliers.category(i);
    outlierRecords(i).aspect = round(topOutliers.aspect(i), 2);
    outlierRecords(i).bbox_area = round(topOutliers.bbox_area(i), 1);
    outlierRecords(i).poly_area = round(topOutliers.poly_area(i), 1);
    outlierRecords(i).area_ratio = round(topOutliers.area_ratio(i), 3);
end
pack.outliers = outlierRecords;
%%
%[text] Write the review pack to JSON.
outputFile = fullfile(outputDir, "generated_writejson.json");
writejson(pack, outputFile, PrettyPrint=true);
"Wrote review JSON: " + outputFile
%%
%[text] Preview the output structure:
pack
%%
%[text] ## Summary Figures
%[text] ### Annotations per Category
barh(categorical(G.category, G.category), G.Count);
xlabel("Number of Annotations")
title("COCO Val 2017: Annotations per Category")
set(gca, FontSize=8)
%%
%[text] ### Aspect Ratio Distribution
histogram(log10(T.aspect(~isinf(T.aspect) & ~isnan(T.aspect))), 100);
xlabel("log_{10}(Aspect Ratio)")
ylabel("Count")
title("Bounding Box Aspect Ratio Distribution")
xline(log10(prctile(validAspect, 99.5)), "r--", "99.5th pctile");
xline(log10(prctile(validAspect, 0.5)), "r--", "0.5th pctile");
%%
%[text] ### BBox Area vs Polygon Area
%[text] Points near the red 1:1 line indicate consistent bbox and polygon areas. Outliers far from the line may indicate annotation quality issues.
hasPolyArea = ~isnan(T.poly_area) & T.bbox_area > 0;
scatter(T.bbox_area(hasPolyArea), T.poly_area(hasPolyArea), 1, "filled", ...
    MarkerFaceAlpha=0.1);
hold on
maxVal = max(T.bbox_area(hasPolyArea));
plot([0 maxVal], [0 maxVal], "r--", LineWidth=1.5);
hold off
xlabel("BBox Area (px^2)")
ylabel("Polygon Area (px^2)")
title("BBox Area vs Polygon Area")
set(gca, XScale="log", YScale="log")
%%
%[text] ## Wrap up
%[text] Save data, compute total time, look at memory consumption
save coco_readjson -v7.3
whostable
%[text] 
totalTime = "Total script execution time: " + toc(tStart) + " s"
%[text] 
function t=whostable()
m = evalin("caller","whos");
t = struct2table(m);

t.name = string(t.name);
t.class = string(t.class);
t.class = categorical(t.class);


t.MB = t.bytes/(1024*1024);
t = movevars(t,"MB","Before","bytes");
t = sortrows(t,"MB","descend");
t = removevars(t,["global", "bytes"]);
end

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
%[control:checkbox:222d]
%   data: {"defaultValue":false,"label":"useReallyBigFile","run":"Nothing"}
%---
%[control:editfield:61d4]
%   data: {"defaultValue":"\"\"","label":"fileroot","run":"Nothing","valueType":"String"}
%---
%[output:2b338d2b]
%   data: {"dataType":"text","outputData":{"text":"Analyzing VeryLargeData\/instances_val2017.json (19.0619 MB)\n","truncated":false}}
%---
%[output:439add70]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"readjson completed in 74.4516 seconds\""}}
%---
%[output:9eb58b47]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Images: 5000, Annotations: 36781, Categories: 80\""}}
%---
%[output:435e5cd6]
%   data: {"dataType":"textualVariable","outputData":{"name":"cocorj","value":"  <a href=\"matlab:helpPopup('matlab.io.config.JSONData')\" style=\"font-weight:bold\">JSONData<\/a> with keys:\n\n    info: [1x1 JSONData with 6 keys]\n    licenses: [8x1 JSONData]\n    images: [5000x1 JSONData]\n    annotations: [36781x1 JSONData]\n    categories: [80x1 JSONData]\n\n    <a href=\"matlab:show(cocorj)\">Show all values<\/a>\n"}}
%---
%[output:356ec2c7]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"  8x1 <a href=\"matlab:helpPopup matlab.io.config.JSONData\">JSONData<\/a> array with keys:\n\n    url\n    id\n    name\n\n    <a href=\"matlab:show(ans)\">Show all values<\/a>\n"}}
%---
%[output:24be9132]
%   data: {"dataType":"matrix","outputData":{"columns":1,"header":"8×1 string array","name":"ans","rows":8,"type":"string","value":[["http:\/\/creativecommons.org\/licenses\/by-nc-sa\/2.0\/"],["http:\/\/creativecommons.org\/licenses\/by-nc\/2.0\/"],["http:\/\/creativecommons.org\/licenses\/by-nc-nd\/2.0\/"],["http:\/\/creativecommons.org\/licenses\/by\/2.0\/"],["http:\/\/creativecommons.org\/licenses\/by-sa\/2.0\/"],["http:\/\/creativecommons.org\/licenses\/by-nd\/2.0\/"],["http:\/\/flickr.com\/commons\/usage\/"],["http:\/\/www.usa.gov\/copyright.shtml"]]}}
%---
%[output:6af45544]
%   data: {"dataType":"text","outputData":{"text":"\n  JSONData with 5 keys\n\n    info:\n        description:        \"COCO 2017 Dataset\" (string)\n        url:                \"http:\/\/cocodataset.org\" (string)\n        version:            \"1.0\" (string)\n        year:               2017 (double)\n        contributor:        \"COCO Consortium\" (string)\n        date_created:       \"2017\/09\/01\" (string)\n    licenses:           8x1 array\n        url:                string\n        id:                 double\n        name:               string\n    images:             5000x1 array\n        license:            double\n        file_name:          string\n        coco_url:           string\n        height:             double\n        width:              double\n        date_captured:      string\n        flickr_url:         string\n        id:                 double\n    annotations:        36781x1 array\n        segmentation:       double\n        area:               double\n        iscrowd:            double\n        image_id:           double\n        bbox:               double\n        category_id:        double\n        id:                 double\n    categories:         80x1 array\n        supercategory:      string\n        id:                 double\n        name:               string\n\n","truncated":false}}
%---
%[output:2a20b397]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"\"Polygon area for 36335 non-crowd annotations in 9.5959 seconds\""}}
%---
%[output:5b262b80]
%   data: {"dataType":"error","outputData":{"errorType":"runtime","text":"Unrecognized function or variable 'catNamePerAnnotation'."}}
%---
