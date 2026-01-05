# Claude Development Documentation

This folder contains design decisions, development notes, and session history for the Configuration File I/O toolbox.

## Contents

- **DESIGN_DECISIONS.md** - Key architectural and naming choices
- **DEVELOPMENT_NOTES.md** - Implementation details, known issues, and future work
- **SESSION_NOTES.md** - Summary of recent development work

## Purpose

These documents capture the "why" behind the toolbox design:
- Why `readyaml` instead of `yamlread`?
- Why `SequenceRule` instead of `ArrayFormat`?
- Why create `ConfigurationData` as a shared base class?
- What are the known limitations?

## For Contributors

If you're considering contributing to this toolbox:
1. Read **DESIGN_DECISIONS.md** first to understand the philosophy
2. Check **DEVELOPMENT_NOTES.md** for implementation details and known issues
3. See **SESSION_NOTES.md** for recent changes

## For Users

These are development documents. For user documentation, see:
- **../README.md** - Main documentation
- **../GettingStarted.m** - Interactive tutorial
- **../examples/** - Example files

---

*This documentation helps maintain consistency as the toolbox evolves and makes it easier for future contributors to understand the design rationale.*
