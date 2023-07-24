#!/bin/bash

# Set the name of the parent directory and tarball
name=$1
if [ -z "$name" ]; then
    name="package"
fi

# Create bin and lib directories inside the parent directory if they don't exist
mkdir -p ./$name/bin
mkdir -p ./$name/lib

# Find binaries in build directory and copy them to bin
find ./build -type f -executable -print0 | while IFS= read -r -d '' file; do
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
