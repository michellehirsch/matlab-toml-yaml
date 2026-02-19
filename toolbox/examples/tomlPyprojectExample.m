%[text] # Working with TOML Arrays: Package Author Management
%[text] TOML's `[[array of tables]]` syntax is the standard way to represent collections of objects — package authors, server entries, dependency lists. Each `[[project.authors]]` block in the file becomes one element of a TOMLData array. This example shows how to read, query, modify, and write such a file.
%%
%[text] ## Read the Package File
%[text] Read `pyproject.toml`. The `[[project.authors]]` blocks are loaded as a 3x1 TOMLData array under `pkg.project.authors`.
pkg = readtoml("pyproject.toml")
%%
%[text] ## Collect All Author Names at Once
%[text] Dot notation on a TOMLData array gathers the named field from every element — no loop needed. This is the same syntax used for a struct array in MATLAB.
pkg.project.authors.name
%%
%[text] ## Find an Author by Name
%[text] Logical indexing works on TOMLData arrays just like MATLAB arrays.
isBob = pkg.project.authors.name == "Bob Martinez";
pkg.project.authors(isBob).email
%%
%[text] ## Update a Nested Field with Chained Assignment
%[text] A single chained expression handles array indexing and nested field access together.
pkg.project.authors(isBob).email = "bob.martinez@newuniversity.edu";
pkg.project.authors.email
%%
%[text] ## Add a New Author
%[text] Growing an array through a chained path (e.g., `pkg.project.authors(end+1) = ...`) is not supported. Instead, extract the array, append to it, then reassign.
authors = pkg.project.authors;
newAuthor = tomldata();
newAuthor.name = "Diana Torres";
newAuthor.email = "dtorres@lab.org";
authors(end+1) = newAuthor;
pkg.project.authors = authors;
pkg.project.authors.name
%%
%[text] ## Write Back to File
%[text] Write the updated package file. The writer automatically uses `[[project.authors]]` array-of-tables format for the authors array.
writetoml(pkg, "pyproject_updated.toml");
type("pyproject_updated.toml")
%%
%[text] ## Cleanup
delete("pyproject_updated.toml")
%[text]
%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
