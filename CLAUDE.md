# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Binary and Dependencies Packager is a Bash utility script that automates packaging compiled binaries with their shared library dependencies into a tar.gz archive. It's designed for CI/CD pipelines where binaries need to be distributed with all required dependencies.

## Core Commands

### Running the Packager

```bash
./binDepPackager.sh [package-name]
```

- `[package-name]` (optional): Name for the output package and tarball. Defaults to "package" if not provided.
- Output: Creates `[package-name].tar.gz` containing `bin/` and `lib/` directories

### Testing the Script

```bash
# Test with default name
./binDepPackager.sh

# Test with custom name
./binDepPackager.sh myapp

# Display help
./binDepPackager.sh -h
```

## Prerequisites

The script expects:
- A `./build` directory containing compiled executables
- `ldd` command available (for finding shared library dependencies)
- Executables must be Linux binaries that can be analyzed by `ldd`

## Architecture

### Script Workflow

1. **Validation Phase** (lines 26-36):
   - Checks `./build` directory exists
   - Verifies at least one executable binary is present

2. **Directory Setup** (lines 45-47):
   - Creates `[name]/bin` for binaries
   - Creates `[name]/lib` for shared libraries

3. **Binary Collection** (lines 50-52):
   - Finds all executables in `./build` (excluding CMakeFiles directories)
   - Copies to `[name]/bin/`

4. **Dependency Resolution** (lines 55-63):
   - Runs `ldd` on each binary to find shared library dependencies
   - Extracts library paths (3rd field in ldd output)
   - Copies dependencies to `[name]/lib/`

5. **Packaging** (lines 66-69):
   - Creates tar.gz archive
   - Cleans up temporary directory structure

## Important Implementation Details

- **Dependency Detection**: Uses `ldd` with `awk '{ print $3 }'` to extract library paths
- **CMake Exclusion**: Explicitly prunes `CMakeFiles` directories during binary search
- **Error Handling**: Colored terminal output (ANSI codes) for warnings and errors
- **Cleanup**: Automatically removes temporary packaging directory after tar.gz creation
