# PersonalFileManager-Bash

A command-line application for keeping track of personal files through a lightweight text-based index.

This project was developed as part of an Operating Systems coursework assignment. The goal was to build a practical Bash application that manages file metadata, validates user input, and provides an interactive menu-driven workflow in a Linux terminal.

## Features

- Add files to a local index using their absolute path
- Store metadata for each file:
  - file name
  - full path
  - user-defined description
  - category
  - automatic date of registration
- List all indexed files in a formatted table
- Filter listed files by category
- Search files by partial matches in the file name or description
- Remove files from the index without deleting them from the file system
- Validate input for paths, duplicate entries, empty fields, and invalid options

## Tech Stack

- Bash shell scripting
- Linux command-line utilities: `grep`, `awk`, `nl`, `column`, `date`
- Plain text storage through `index.txt`

## Project Structure

```text
.
├── file-manager.sh     # Main Bash application
├── Documentation.pdf   # Original project documentation
└── README.md
```

At runtime, the application creates an `index.txt` file if it does not already exist. This file stores the indexed records in the following format:

```text
file_name|full_path|description|category|date_added
```

## How to Run

1. Clone the repository:

```bash
git clone https://github.com/tiberiucirstea/PersonalFileManager-Bash.git
cd PersonalFileManager-Bash
```

2. Make the script executable:

```bash
chmod +x file-manager.sh
```

3. Start the application:

```bash
./file-manager.sh
```

## Menu Options

When started, the application displays an interactive menu:

```text
1. Add files
2. List files
3. Search files
4. Delete files
5. Exit
```

The user can repeat operations, return to the main menu, or exit the application at any time.

## Validation Rules

The application includes validation logic to keep the index consistent:

- File paths must be absolute and must point to an existing file
- Directories cannot be registered
- Duplicate file names are rejected
- Description and category fields cannot be empty
- Description and category values can contain only letters, digits, and underscores
- Search terms must contain at least 3 characters
- Delete operations require confirmation before modifying the index

## What This Project Demonstrates

This project highlights practical command-line application development in Bash, including:

- modular shell scripting with reusable functions
- file-based persistence
- structured text processing
- interactive terminal input handling
- defensive validation and error handling
- basic CRUD-style operations in a Unix-like environment
