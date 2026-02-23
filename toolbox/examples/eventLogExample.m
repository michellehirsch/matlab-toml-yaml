%[text] # Event Log Processing: Heterogeneous Schema Handling
%[text] Processing event streams is a natural fit for `configdata` arrays. Events from a real system rarely share the same fields — a `"start"` event carries a session ID, a `"measurement"` event carries sensor data, and an `"error"` event carries an error code and message. Struct arrays require every element to have every field, which means either padding with empty placeholders or giving up vectorized access. `configdata` arrays have no such constraint.
%%
%[text] ## Build the Event Log
%[text] Construct a synthetic stream of events. Each event is a `configdata` object. `"start"`, `"measurement"`, and `"error"` events each share a `timestamp` and `type` field, plus their own type-specific fields.
addpath('../')
rng(0)
events = [];
% Start event
e = configdata(); e.timestamp = 0; e.type = "start"; e.session_id = "abc123";
events = [events, e];
% Several temperature measurement events
for i = 1:5
    e = configdata();
    e.timestamp = i * 10;
    e.type = "measurement";
    e.sensor = "temperature";
    e.value = 20 + randn();
    e.unit = "celsius";
    events = [events, e];
end
% An error event
e = configdata(); e.timestamp = 37; e.type = "error";
e.code = 404; e.message = "Sensor timeout";
events = [events, e];
% Pressure measurement events
for i = 6:8
    e = configdata();
    e.timestamp = i * 10;
    e.type = "measurement";
    e.sensor = "pressure";
    e.value = 1013 + 2*randn();
    e.unit = "hPa";
    events = [events, e];
end
%%
%[text] ## Inspect the Array
%[text] Calling `keys` on a `configdata` array returns the **union** of all key names across every element. A second output gives the per-element key set, making it easy to see which events have which fields.
keys(events)
%%
[allKeys, perEvent] = keys(events);
isequal(perEvent{:})
%%
%[text] `describe` gives a structural overview of the whole array at once — useful for getting your bearings in an unfamiliar event stream.
describe(events)
%%
%[text] ## Filter by Event Type
%[text] Dot access on a `configdata` array gathers a field from every element. Because every event has `type`, this returns a string array you can compare directly. Logical indexing then selects the matching subset.
measurements = events(events.type == "measurement")
%%
errors = events(events.type == "error")
%%
%[text] ## Extract Typed Arrays from the Filtered Subset
%[text] Once you have a homogeneous subset, vectorized dot access returns typed MATLAB arrays — no loops, no cell gymnastics.
timestamps = measurements.timestamp
%%
values = measurements.value
%%
sensors = measurements.sensor
%%
%[text] ## Filter by Key Presence
%[text] The measurement events in this log come from two different sensors and would not all share the same sub-fields in a richer schema. `iskey` is vectorized: it returns a logical array the same size as the input, one entry per element.
iskey(measurements, "sensor")
%%
%[text] Use the result as a logical index to select only temperature readings, then compute the mean.
tempReadings = measurements(measurements.sensor == "temperature");
avgTemp = mean(tempReadings.value)
%%
%[text] The same pattern handles the pressure sensor.
pressureReadings = measurements(measurements.sensor == "pressure");
avgPressure = mean(pressureReadings.value)
%%
%[text] ## Why Not a Struct Array?
%[text] A MATLAB struct array requires every element to have the same field names. You would have to pad the `"start"` event with empty `sensor`, `value`, `unit`, `code`, and `message` fields, and do the same for `"error"` events. That padding is pure noise: `mean([events.value])` would silently include the empty placeholders unless you remembered to filter first.
%[text]
%[text] With `configdata`, the schema is per-element. Extracting `measurements.value` gives you only the values that exist. Filtering with `iskey` is explicit and composable. The result is direct vectorized access on heterogeneous data — without the boilerplate.
