# RFA Spec Template (2024 Updated Version)

# 

Project Details

# Project Kickoff

## Motivation and Key Users REQUIRED

Instructions...

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAA3NCSVQICAjb4U/gAAAAFVBMVEX///9wcHBwcHBwcHBwcHBwcHBwcHA3RenHAAAAB3RSTlMAZoiZzN3/SzZomQAAAAlwSFlzAAALEgAACxIB0t1+/AAAABx0RVh0U29mdHdhcmUAQWRvYmUgRmlyZXdvcmtzIENTNui8sowAAAAUdEVYdENyZWF0aW9uIFRpbWUANi8xLzEzOKlF0AAAACFJREFUCJljYCATsCgwqIAZTMnMyRAhsTABCIMxkVxTGQCLcwHyUKXpLgAAAABJRU5ErkJggg==)

- Note the problem are you trying to solve.
- List the workflows this feature will support.
- List any notable technical constraints, resource constraints, risks, assumptions.

# Requirements Analysis

## User Roles and Goals REQUIRED

Instructions...

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAA3NCSVQICAjb4U/gAAAAFVBMVEX///9wcHBwcHBwcHBwcHBwcHBwcHA3RenHAAAAB3RSTlMAZoiZzN3/SzZomQAAAAlwSFlzAAALEgAACxIB0t1+/AAAABx0RVh0U29mdHdhcmUAQWRvYmUgRmlyZXdvcmtzIENTNui8sowAAAAUdEVYdENyZWF0aW9uIFRpbWUANi8xLzEzOKlF0AAAACFJREFUCJljYCATsCgwqIAZTMnMyRAhsTABCIMxkVxTGQCLcwHyUKXpLgAAAABJRU5ErkJggg==)

- Identify distinct types of users (roles) and what each type is trying to do and why (goals).
- Capture anything you already know about the users like tasks, pains, requirements, or data sources.
- If this content exists already in another artifact, simply link to it here.

IDs should be descriptive (e.g. "RG_SCRIPTING") to easily reference later.

| **ID** | **Priority  <br>LOW MEDIUM HIGH** | **User Role** | **User Goal** | **Notes  <br>Optional** |
| --- | --- | --- | --- | --- |
| RG_XXX |     |     |     |     |
| RG_XXX |     |     |     |     |

## Use Cases

Instructions...

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAA3NCSVQICAjb4U/gAAAAFVBMVEX///9wcHBwcHBwcHBwcHBwcHBwcHA3RenHAAAAB3RSTlMAZoiZzN3/SzZomQAAAAlwSFlzAAALEgAACxIB0t1+/AAAABx0RVh0U29mdHdhcmUAQWRvYmUgRmlyZXdvcmtzIENTNui8sowAAAAUdEVYdENyZWF0aW9uIFRpbWUANi8xLzEzOKlF0AAAACFJREFUCJljYCATsCgwqIAZTMnMyRAhsTABCIMxkVxTGQCLcwHyUKXpLgAAAABJRU5ErkJggg==)

- Document all known user workflows that this project seeks to improve.
- Give each use case a unique ID; also give each pain point a unique ID.

IDs should be descriptive (e.g. "UC_ONBOARDING", "PP_OUTDATED") to easily reference later.

Use Case &lt;UC_XXX&gt;

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAA3NCSVQICAjb4U/gAAAAFVBMVEX///9wcHBwcHBwcHBwcHBwcHBwcHA3RenHAAAAB3RSTlMAZoiZzN3/SzZomQAAAAlwSFlzAAALEgAACxIB0t1+/AAAABx0RVh0U29mdHdhcmUAQWRvYmUgRmlyZXdvcmtzIENTNui8sowAAAAUdEVYdENyZWF0aW9uIFRpbWUANi8xLzEzOKlF0AAAACFJREFUCJljYCATsCgwqIAZTMnMyRAhsTABCIMxkVxTGQCLcwHyUKXpLgAAAABJRU5ErkJggg==)

### Use Case &lt;UC_XXX&gt;

| **User Role**  <br>from User Roles & Goals |     |
| --- | --- |
| **PRISM User Type**  <br>e.g. Newcomer, Casual User, Power User, Developer |     |

|     | **Current Workflow** | **Pain Point ID(s)** | **Examples  <br>Optional - e.g. screenshots, code snippets** |
| --- | --- | --- | --- |
| 1   |     | PP_XXX |     |
| 2   |     | PP_XXX |     |

## Other User Knowledge

Instructions...

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAA3NCSVQICAjb4U/gAAAAFVBMVEX///9wcHBwcHBwcHBwcHBwcHBwcHA3RenHAAAAB3RSTlMAZoiZzN3/SzZomQAAAAlwSFlzAAALEgAACxIB0t1+/AAAABx0RVh0U29mdHdhcmUAQWRvYmUgRmlyZXdvcmtzIENTNui8sowAAAAUdEVYdENyZWF0aW9uIFRpbWUANi8xLzEzOKlF0AAAACFJREFUCJljYCATsCgwqIAZTMnMyRAhsTABCIMxkVxTGQCLcwHyUKXpLgAAAABJRU5ErkJggg==)

- Capture any other work done to learn about users (e.g. customer workflows, summaries of user data with links to sources, MATLAB Answers questions).

## Requirements REQUIRED

Instructions...

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAA3NCSVQICAjb4U/gAAAAFVBMVEX///9wcHBwcHBwcHBwcHBwcHBwcHA3RenHAAAAB3RSTlMAZoiZzN3/SzZomQAAAAlwSFlzAAALEgAACxIB0t1+/AAAABx0RVh0U29mdHdhcmUAQWRvYmUgRmlyZXdvcmtzIENTNui8sowAAAAUdEVYdENyZWF0aW9uIFRpbWUANi8xLzEzOKlF0AAAACFJREFUCJljYCATsCgwqIAZTMnMyRAhsTABCIMxkVxTGQCLcwHyUKXpLgAAAABJRU5ErkJggg==)

- Capture the MVP, **functional, non-functional requirements**, including:
  - Quality attributes e.g. performance, security.
  - Other requirements considered that **will not** be addressed by this release deliverable - label these as "**out of scope**".
- Give each requirement a unique ID.

IDs should be descriptive (e.g. "R_ACCESSIBILITY").

| **ID** | **Statement** | **Pain Point ID(s)  <br>from Use Cases** | **Priority  <br>(MUST HAVE, NICE TO HAVE, OUT OF SCOPE)** |
| --- | --- | --- | --- |
| R_ACCESSIBILITY |     |     |     |
| R_SECURITY |     |     |     |
| R_PERFORMANCE |     |     |     |

# 

Functional Design

## Proposed Functional Design: Summary REQUIRED

Instructions...

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAA3NCSVQICAjb4U/gAAAAFVBMVEX///9wcHBwcHBwcHBwcHBwcHBwcHA3RenHAAAAB3RSTlMAZoiZzN3/SzZomQAAAAlwSFlzAAALEgAACxIB0t1+/AAAABx0RVh0U29mdHdhcmUAQWRvYmUgRmlyZXdvcmtzIENTNui8sowAAAAUdEVYdENyZWF0aW9uIFRpbWUANi8xLzEzOKlF0AAAACFJREFUCJljYCATsCgwqIAZTMnMyRAhsTABCIMxkVxTGQCLcwHyUKXpLgAAAABJRU5ErkJggg==)

- **First** complete the 'Proposed Design: Details' section below.
- **Then** summarize the proposed design here in 1-2 sentences.

## Proposed Design: Details REQUIRED

### Design Description & Design Cases

Instructions...

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAA3NCSVQICAjb4U/gAAAAFVBMVEX///9wcHBwcHBwcHBwcHBwcHBwcHA3RenHAAAAB3RSTlMAZoiZzN3/SzZomQAAAAlwSFlzAAALEgAACxIB0t1+/AAAABx0RVh0U29mdHdhcmUAQWRvYmUgRmlyZXdvcmtzIENTNui8sowAAAAUdEVYdENyZWF0aW9uIFRpbWUANi8xLzEzOKlF0AAAACFJREFUCJljYCATsCgwqIAZTMnMyRAhsTABCIMxkVxTGQCLcwHyUKXpLgAAAABJRU5ErkJggg==)

- Describe the details of the design using artifacts of your choice.
- Include step-by-step walkthroughs of all relevant design cases (i.e. the user's proposed flow through the design).

For **APIs**, consider including:

- Process diagrams
- Functions, classes, property names, values, etc. with code snippets and a description line for each

### Design Rationale

|     | **Pros** | **Priority  <br>(LOW MEDIUM HIGH)** |
| --- | --- | --- |
| 1   |     |     |
| 2   |     |     |

|     | **Cons** | **Mitigation Plans** | **Priority  <br>(LOW MEDIUM HIGH)** |
| --- | --- | --- | --- |
| 1   |     |     |     |
| 2   |     |     |     |

### Error Conditions and Edge Cases

Instructions...

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAA3NCSVQICAjb4U/gAAAAFVBMVEX///9wcHBwcHBwcHBwcHBwcHBwcHA3RenHAAAAB3RSTlMAZoiZzN3/SzZomQAAAAlwSFlzAAALEgAACxIB0t1+/AAAABx0RVh0U29mdHdhcmUAQWRvYmUgRmlyZXdvcmtzIENTNui8sowAAAAUdEVYdENyZWF0aW9uIFRpbWUANi8xLzEzOKlF0AAAACFJREFUCJljYCATsCgwqIAZTMnMyRAhsTABCIMxkVxTGQCLcwHyUKXpLgAAAABJRU5ErkJggg==)

- Document any known conditions that will induce errors or warnings.
- Work with Doc to propose error / warning messages for each of these conditions.

Refer to guidance on [authoring error messages](https://mathworks.sharepoint.com/sites/doc/SitePages/Error-Message-Program.aspx?ga=1).

|     | **Condition** | **Proposed Error / Warning Message** |
| --- | --- | --- |
| 1   |     |     |
| 2   |     |     |

## Alternate Designs Considered

Instructions...

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAA3NCSVQICAjb4U/gAAAAFVBMVEX///9wcHBwcHBwcHBwcHBwcHBwcHA3RenHAAAAB3RSTlMAZoiZzN3/SzZomQAAAAlwSFlzAAALEgAACxIB0t1+/AAAABx0RVh0U29mdHdhcmUAQWRvYmUgRmlyZXdvcmtzIENTNui8sowAAAAUdEVYdENyZWF0aW9uIFRpbWUANi8xLzEzOKlF0AAAACFJREFUCJljYCATsCgwqIAZTMnMyRAhsTABCIMxkVxTGQCLcwHyUKXpLgAAAABJRU5ErkJggg==)

- Briefly describe the alternate designs considered and the rationale.
- Try to explore **at least 3-4** design alternatives**.**
- Link any artifacts that capture the details of the alternate designs.
- Copy the 'Expand' macro as needed.

Alternate Design &lt;1&gt;

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAA3NCSVQICAjb4U/gAAAAFVBMVEX///9wcHBwcHBwcHBwcHBwcHBwcHA3RenHAAAAB3RSTlMAZoiZzN3/SzZomQAAAAlwSFlzAAALEgAACxIB0t1+/AAAABx0RVh0U29mdHdhcmUAQWRvYmUgRmlyZXdvcmtzIENTNui8sowAAAAUdEVYdENyZWF0aW9uIFRpbWUANi8xLzEzOKlF0AAAACFJREFUCJljYCATsCgwqIAZTMnMyRAhsTABCIMxkVxTGQCLcwHyUKXpLgAAAABJRU5ErkJggg==)

### Alternate Design &lt;1&gt;

#### Design Description

#### Design Rationale

|     | **Pros** | **Priority  <br>(LOW MEDIUM HIGH)** |
| --- | --- | --- |
| 1   |     |     |
| 2   |     |     |

|     | **Cons** | **Priority  <br>(LOW MEDIUM HIGH)** |
| --- | --- | --- |
| 1   |     |     |
| 2   |     |     |

## Design Assessment

Instructions...

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAA3NCSVQICAjb4U/gAAAAFVBMVEX///9wcHBwcHBwcHBwcHBwcHBwcHA3RenHAAAAB3RSTlMAZoiZzN3/SzZomQAAAAlwSFlzAAALEgAACxIB0t1+/AAAABx0RVh0U29mdHdhcmUAQWRvYmUgRmlyZXdvcmtzIENTNui8sowAAAAUdEVYdENyZWF0aW9uIFRpbWUANi8xLzEzOKlF0AAAACFJREFUCJljYCATsCgwqIAZTMnMyRAhsTABCIMxkVxTGQCLcwHyUKXpLgAAAABJRU5ErkJggg==)

- Capture the assessment metrics that will be used to evaluate the design i.e. the "definition of done" for this feature.
- Note any special considerations, e.g. release compatibility, licensing, etc.

Refer to guidance on [design assessment](https://mathworks.sharepoint.com/sites/devu/RFAINcommunity/RFResourceCenter/SitePages/Design-Assessment.aspx).

# 

Architectural Design

## Proposed Architectural Design: Summary REQUIRED

Instructions...

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAA3NCSVQICAjb4U/gAAAAFVBMVEX///9wcHBwcHBwcHBwcHBwcHBwcHA3RenHAAAAB3RSTlMAZoiZzN3/SzZomQAAAAlwSFlzAAALEgAACxIB0t1+/AAAABx0RVh0U29mdHdhcmUAQWRvYmUgRmlyZXdvcmtzIENTNui8sowAAAAUdEVYdENyZWF0aW9uIFRpbWUANi8xLzEzOKlF0AAAACFJREFUCJljYCATsCgwqIAZTMnMyRAhsTABCIMxkVxTGQCLcwHyUKXpLgAAAABJRU5ErkJggg==)

- **After** documenting the detailed proposed architecture below, summarize it in 1-2 sentences.

## Proposed Design: Details REQUIRED

### Architecture Description

Instructions...

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAA3NCSVQICAjb4U/gAAAAFVBMVEX///9wcHBwcHBwcHBwcHBwcHBwcHA3RenHAAAAB3RSTlMAZoiZzN3/SzZomQAAAAlwSFlzAAALEgAACxIB0t1+/AAAABx0RVh0U29mdHdhcmUAQWRvYmUgRmlyZXdvcmtzIENTNui8sowAAAAUdEVYdENyZWF0aW9uIFRpbWUANi8xLzEzOKlF0AAAACFJREFUCJljYCATsCgwqIAZTMnMyRAhsTABCIMxkVxTGQCLcwHyUKXpLgAAAABJRU5ErkJggg==)

- Provide link to existing architectural design document if applicable
- Capture any additional details about the proposed architecture **not covered** by the sections below.

### Overview Document

Instructions...

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAA3NCSVQICAjb4U/gAAAAFVBMVEX///9wcHBwcHBwcHBwcHBwcHBwcHA3RenHAAAAB3RSTlMAZoiZzN3/SzZomQAAAAlwSFlzAAALEgAACxIB0t1+/AAAABx0RVh0U29mdHdhcmUAQWRvYmUgRmlyZXdvcmtzIENTNui8sowAAAAUdEVYdENyZWF0aW9uIFRpbWUANi8xLzEzOKlF0AAAACFJREFUCJljYCATsCgwqIAZTMnMyRAhsTABCIMxkVxTGQCLcwHyUKXpLgAAAABJRU5ErkJggg==)

- Link an overview document that captures the problem and proposed solution at a high level.

### Non-Functional Requirements

Instructions...

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAA3NCSVQICAjb4U/gAAAAFVBMVEX///9wcHBwcHBwcHBwcHBwcHBwcHA3RenHAAAAB3RSTlMAZoiZzN3/SzZomQAAAAlwSFlzAAALEgAACxIB0t1+/AAAABx0RVh0U29mdHdhcmUAQWRvYmUgRmlyZXdvcmtzIENTNui8sowAAAAUdEVYdENyZWF0aW9uIFRpbWUANi8xLzEzOKlF0AAAACFJREFUCJljYCATsCgwqIAZTMnMyRAhsTABCIMxkVxTGQCLcwHyUKXpLgAAAABJRU5ErkJggg==)

- Describe how the proposed architecture delivers on any non-functional requirements identified during the RF process.

### Architecturally-Significant Design Cases

Instructions...

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAA3NCSVQICAjb4U/gAAAAFVBMVEX///9wcHBwcHBwcHBwcHBwcHBwcHA3RenHAAAAB3RSTlMAZoiZzN3/SzZomQAAAAlwSFlzAAALEgAACxIB0t1+/AAAABx0RVh0U29mdHdhcmUAQWRvYmUgRmlyZXdvcmtzIENTNui8sowAAAAUdEVYdENyZWF0aW9uIFRpbWUANi8xLzEzOKlF0AAAACFJREFUCJljYCATsCgwqIAZTMnMyRAhsTABCIMxkVxTGQCLcwHyUKXpLgAAAABJRU5ErkJggg==)

- Note which design cases (from the Proposed Design: Details section above) have architectural significance and capture any findings below.

The main purpose of an architecture spike is to ensure that the solution to the architecturally significant design cases meets all driving non-functional requirements.

### Design Rationale

|     | **Pros** | **Priority  <br>LOW MEDIUM HIGH** |
| --- | --- | --- |
| 1   |     |     |
| 2   |     |     |

|     | **Cons** | **Mitigation Plans** | **Priority  <br>LOW MEDIUM HIGH** |
| --- | --- | --- | --- |
| 1   |     |     |     |
| 2   |     |     |     |

## Alternate Architecture Designs Considered

Instructions...

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAA3NCSVQICAjb4U/gAAAAFVBMVEX///9wcHBwcHBwcHBwcHBwcHBwcHA3RenHAAAAB3RSTlMAZoiZzN3/SzZomQAAAAlwSFlzAAALEgAACxIB0t1+/AAAABx0RVh0U29mdHdhcmUAQWRvYmUgRmlyZXdvcmtzIENTNui8sowAAAAUdEVYdENyZWF0aW9uIFRpbWUANi8xLzEzOKlF0AAAACFJREFUCJljYCATsCgwqIAZTMnMyRAhsTABCIMxkVxTGQCLcwHyUKXpLgAAAABJRU5ErkJggg==)

- Briefly describe the alternate architectures considered and the rationale.
- Try to explore **at least 3-4** architecture alternatives.
- Link any artifacts that capture the details of the alternate architectures.
- As needed, repeat the sections below for each of the alternate architectures.

Refer to additional instructions above for the "Proposed Design: Details" and subsections.

Alternate Architecture &lt;1&gt;

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAA3NCSVQICAjb4U/gAAAAFVBMVEX///9wcHBwcHBwcHBwcHBwcHBwcHA3RenHAAAAB3RSTlMAZoiZzN3/SzZomQAAAAlwSFlzAAALEgAACxIB0t1+/AAAABx0RVh0U29mdHdhcmUAQWRvYmUgRmlyZXdvcmtzIENTNui8sowAAAAUdEVYdENyZWF0aW9uIFRpbWUANi8xLzEzOKlF0AAAACFJREFUCJljYCATsCgwqIAZTMnMyRAhsTABCIMxkVxTGQCLcwHyUKXpLgAAAABJRU5ErkJggg==)

### Alternate Architecture &lt;1&gt;

#### Design Description

#### Design Rationale

|     | **Pros** | **Priority  <br>LOW MEDIUM HIGH** |
| --- | --- | --- |
| 1   |     |     |
| 2   |     |     |

|     | **Cons** | **Priority  <br>LOW MEDIUM HIGH** |
| --- | --- | --- |
| 1   |     |     |
| 2   |     |     |

# Test Strategy & Testability

Instructions...

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAA3NCSVQICAjb4U/gAAAAFVBMVEX///9wcHBwcHBwcHBwcHBwcHBwcHA3RenHAAAAB3RSTlMAZoiZzN3/SzZomQAAAAlwSFlzAAALEgAACxIB0t1+/AAAABx0RVh0U29mdHdhcmUAQWRvYmUgRmlyZXdvcmtzIENTNui8sowAAAAUdEVYdENyZWF0aW9uIFRpbWUANi8xLzEzOKlF0AAAACFJREFUCJljYCATsCgwqIAZTMnMyRAhsTABCIMxkVxTGQCLcwHyUKXpLgAAAABJRU5ErkJggg==)

- Capture the test strategy and feature testability, including:
  - Unit tests you plan to write
  - Links to test procedure and strategy documents
- Incorporate design adjustments and testing hooks where appropriate to allow for testability.
- Review high-level details of the test strategy during any RFA review, and note any design adjustments here.

# 

Documentation Notes

Instructions...

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAA3NCSVQICAjb4U/gAAAAFVBMVEX///9wcHBwcHBwcHBwcHBwcHBwcHA3RenHAAAAB3RSTlMAZoiZzN3/SzZomQAAAAlwSFlzAAALEgAACxIB0t1+/AAAABx0RVh0U29mdHdhcmUAQWRvYmUgRmlyZXdvcmtzIENTNui8sowAAAAUdEVYdENyZWF0aW9uIFRpbWUANi8xLzEzOKlF0AAAACFJREFUCJljYCATsCgwqIAZTMnMyRAhsTABCIMxkVxTGQCLcwHyUKXpLgAAAABJRU5ErkJggg==)

- Capture any content or notes that will support documentation for this feature.