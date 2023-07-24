#!/bin/bash
#
# Authors: Paris Moschovakos
# Email: paris@moschovakos.com
# Date: 24 July 2023
#

usage() {
  echo "Usage: $0 [name]"
  echo "Creates a package of binaries and their dependencies."
  echo
  echo "Arguments:"
  echo "  name    The name of the package. If not provided, 'package' will be used."
  echo
  echo "Options:"
  echo "  -h      Display this help message."
  echo
  exit 1
}

# If -h is passed, display the usage information
if [ "$1" == "-h" ]; then
  usage
fi

# Check if the build directory exists
if [ ! -d "./build" ]; then
  echo -e "\e[1;31mError: \e[3mbuild\e[23m directory does not exist.\e[0m"
  exit 1
fi

# Check if the build directory contains any binaries
if [ -z "$(find ./build -type f -executable -print -quit)" ]; then
  echo -e "\e[1;31mError: No binaries found in the \e[3mbuild\e[23m directory.\e[0m"
  exit 1
fi

# Set the name of the parent directory and tarball
name=$1
if [ -z "$name" ]; then
  echo -e "\e[1;33mWarning: No package name provided. Using default name 'package'.\e[0m"
  name="package"
fi

# Create bin and lib directories inside the parent directory if they don't exist
mkdir -p ./$name/bin
mkdir -p ./$name/lib

# Find binaries in build directory and copy them to bin
find ./build -type d -name 'CMakeFiles' -prune -o -type f -executable -print0 | while IFS= read -r -d '' file; do
    cp "$file" ./$name/bin/
done

# Get dependencies of the binaries
for binary in ./$name/bin/*; do
  # Use ldd to find dependencies and awk to get the third field (the dependency file path)
  ldd "$binary" | awk '{ print $3 }' | while read -r dependency; do
    if [ -f "$dependency" ]; then
      # Copy the dependency to the lib directory
      cp "$dependency" ./$name/lib/
    fi
  done
done

# Create a tar.gz file of the parent directory
tar -czvf $name.tar.gz ./$name

# Remove the parent directory after the tarball is created
rm -rf ./$name
