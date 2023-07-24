# Binary and Dependencies Packager

Author: Paris Moschovakos  
Email: paris@moschovakos.com  
Date of Creation: July 24, 2023

## Overview

This Bash script is designed to automate the process of packaging binaries and their dependencies into a tar.gz file. The script is especially useful for CI/CD pipelines where the produced binaries and their dependencies need to be packaged together.

## Usage

To use the script, you can run it from your terminal with the following command:

\```bash
./package.sh [name]
\```

Where `[name]` is an optional argument that specifies the name of the parent directory and the tarball. If no name is provided, a default name ("package") will be used.

## How It Works

The script operates in several steps:

1. It creates a parent directory with the specified or default name. Inside this directory, it creates two subdirectories: `bin` for binaries and `lib` for dependencies.

2. It searches for binaries in the `./build` directory and copies them into the `./[name]/bin` directory.

3. It uses the `ldd` command to find the dependencies of each binary and copies these dependencies into the `./[name]/lib` directory.

4. Finally, it creates a tar.gz file of the parent directory, which includes the `bin` and `lib` directories.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
