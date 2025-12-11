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

## Known Issues and Limitations

### Critical Security Issues

⚠️ **IMPORTANT**: The current script has several security vulnerabilities that should be addressed before production use:

1. **Unquoted Variables** (lines 66, 69):
   - Variables `$name` are not quoted in `tar` and `rm -rf` commands
   - Could cause word splitting or unintended file deletion
   - If `$name` is empty, `rm -rf ./$name` becomes `rm -rf ./` (dangerous!)

2. **No Input Validation** (line 39):
   - Package name accepts any input without validation
   - Could allow path traversal: `./binDepPackager.sh "../../../etc"`
   - Could allow command injection with special characters

3. **Fragile ldd Parsing** (lines 57-62):
   - Using `awk '{ print $3 }'` doesn't handle all ldd output formats
   - `ldd` output varies: some libraries show path in field 3, others in field 1
   - Fails on virtual DSO entries like `linux-vdso.so.1`
   - Does not verify if files are actually ELF binaries before running `ldd`

### Reliability Issues

1. **No Error Handling**:
   - Script continues execution even when operations fail
   - No checks for disk space, permissions, or command availability
   - Missing `set -e` to exit on errors

2. **Missing Prerequisite Checks**:
   - Doesn't verify `ldd`, `tar`, `find`, or `awk` are available
   - No validation that files are ELF binaries (scripts will fail)

3. **No Symlink Preservation**:
   - `cp` without `-P` flag doesn't preserve symlinks
   - Can break library versioning schemes

4. **Duplicate Dependency Copying**:
   - Shared libraries used by multiple binaries are copied multiple times

### Platform Limitations

- **Linux-only**: Script only works on Linux systems with `ldd`
- **No macOS support**: macOS uses `otool` instead of `ldd`
- **Static binaries**: Statically-linked binaries work but dependency detection is unnecessary

## Common Pitfalls When Modifying

1. **Always quote variables**: Use `"${name}"` instead of `$name` in file operations
2. **Validate inputs**: Check package names for safe characters only (`[a-zA-Z0-9_-]`)
3. **Test ldd parsing**: Different library types produce different ldd output formats
4. **Check file types**: Use `file` command to verify ELF binaries before running `ldd`
5. **Handle errors**: Add `set -euo pipefail` and check return codes

## Testing the Script

When making changes, test with:

```bash
# Create test build directory
mkdir -p build
cp /bin/ls build/  # Simple binary for testing

# Test normal operation
./binDepPackager.sh test-pkg

# Verify output
tar -tzf test-pkg.tar.gz

# Test edge cases
./binDepPackager.sh ""  # Should use default name
./binDepPackager.sh "../path"  # Should be rejected (currently not!)
./binDepPackager.sh "name with spaces"  # Should be rejected

# Cleanup
rm -rf build test-pkg.tar.gz
```

## Future Improvements Needed

1. Add comprehensive input validation
2. Quote all variable expansions
3. Improve ldd parsing to handle all output formats
4. Add prerequisite command checks
5. Implement proper error handling with `set -e`
6. Add cleanup trap for temporary directories
7. Preserve symlinks with `cp -P`
8. Track and deduplicate dependencies
