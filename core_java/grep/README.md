# Grep Application - Full Project README

This project contains three implementations of a Java-based Grep application:

1. **Basic Grep App** - implemented using loops, recursion, and Java I/O
2. **Lambda & Stream Grep App** - updated with Java 8 functional programming
3. **Dockerized Grep App** - packaged using Docker for easy distribution

Each implementation demonstrates a progressively more modern and scalable approach 
while still solving the same core problem: recursively searching files for lines that match a regex pattern.

---

# 1. Introduction

This project implements a Grep-like application that recursively searches through a directory, 
reads all files, and returns lines matching a given regular expression.

The project demonstrates the use of:
- Core Java (I/O, recursion, regex API, BufferedReader/Writer)
- Java 8 Lambda expressions & Stream API
- SLF4J Logging
- Maven for dependency management
- IntelliJ IDEA as the development environment
- Docker for containerized deployment

The three implementations show how the same problem can be solved using different programming 
paradigms and infrastructure approaches.

---

# 2. Quick Start Guide

## Run Loop-Based Grep App

```bash
java -cp target/grep-1.0-SNAPSHOT.jar \
ca.jrvs.apps.grep.JavaGrepLauncher \
"(?i).*juliet.*" ./data ./out/juliet.txt
```
## Run Lambda & Stream Grep App

```bash
java -cp target/grep-1.0-SNAPSHOT.jar \
ca.jrvs.apps.grep.JavaGrepLambdaLauncher \
"(?i).*juliet.*" ./data ./out/juliet_lambda.txt
```
## Run Dockerized Grep App
Build the image:
```bash
docker build -t jrvs/grep .
```
Run the container:
```bash
docker run --rm \
  -v $(pwd)/data:/data \
  -v $(pwd)/out:/out \
  jrvs/grep "(?i).*juliet.*" /data /out/result.txt

```

# 3. Implementation Details
## Basic Grep App (Loop-Based Implementation)

This version uses:

- Manual recursion to traverse directories
- BufferedReader to read files line-by-line
- Regex matching via Pattern and Matcher
- List-based aggregation of matched lines
- BufferedWriter for output

### Important Design Note
In this implementation, the regex pattern is compiled inside `process()`:

```java
pattern = Pattern.compile(regex);
```

This ensures the matcher is ready before scanning begins.

### Pseudocode

```bash
compile regex into Pattern

files = listFiles(rootDir)

matchedLines = []

for each file in files:
    lines = readLines(file)
    for each line:
        if containsPattern(line):
            add line to matchedLines

write matchedLines to output file

```

## 3.2 Lambda & Stream Grep App
This version enhances readability and performance using:

- `Files.walk()` to traverse directories

- `Files.lines()` to stream file lines lazily

- `flatMap`, `filter`, `collect` for a complete Stream pipeline

### Important Design Adjustment
In the lambda version, because the class overrides process(), the regex must be compiled in:

```java
setRegex();
```

This ensures the `pattern` is not null when used in:

```java
filter(this::containsPattern);
```

### Stream Pipeline Overview

```
Files.walk(rootDir)
  - filter regular files
  - flatMap: Files.lines(file)
  - filter: lines matching regex
  - collect to list
  - writeToFile()
```


## 3.3 Dockerized Grep App

The Docker version packages the application into a self-contained environment.
It allows running the grep tool without installing Java or Maven.

The Dockerfile:

- Uses OpenJDK as the base image

- Copies the built JAR into the image

- Sets an entrypoint that invokes the grep launcher

- Mounts data and output directories for flexible I/O

---
# 4. Performance Considerations

Both the loop and lambda implementations collect all matched lines into memory before writing 
them to the file.

This may cause memory pressure when processing:

- Extremely large files

- Very deep directory trees

- Large-volume match results

### Possible Improvement

Use a streaming writer that outputs each matching line immediately instead of storing 
them all in a list.


---

# 5. Testing
The application was manually tested by preparing sample text files and placing them in the `./data/` directory.

Multiple regex patterns were tested, including both case-sensitive and case-insensitive expressions.  

The output files generated under the `./out/` directory were compared between the loop-based and lambda-based implementations to ensure they produced the same line matches.

Logging was enabled using **SLF4J + Log4J**, which provided detailed execution information such as:
- Loaded regex pattern
- Root directory path
- Output file path
- Number of matched lines
- Completion status

Example (shortened) log output from the loop version:

```bash
INFO Starting grep process
INFO Regex: (?i).juliet.
INFO Root directory: ./data
INFO Output file: ./out/juliet.txt
INFO Total matched lines: 85
INFO Finished writing output.
```

These logs were used to verify correct file traversal, regex compilation, and output generation.

The Dockerized version was also tested by mounting the `data` and `out` directories into the container.  

The results produced inside Docker were identical to running the application directly through IntelliJ or Maven, 
confirming consistent behavior across environments.

---

# 6. Deployment (Docker)

A Dockerfile was created to package the application along with all dependencies.

This allows users to run the grep app without installing Java locally.

To deploy:

## Build the Docker image:

```bash
docker build -t jrvs/grep .
```

## Run the container:

```bash
docker run --rm \
  -v $(pwd)/data:/data \
  -v $(pwd)/out:/out \
  jrvs/grep "(?i).*juliet.*" /data /out/docker_result.txt
```

---

# 7. Improvements & Future Work

1. Write matched lines directly to the output file (streaming instead of storing).

2. Add automated JUnit tests for directory traversal, regex correctness, and stream processing.

3. Support parallel processing using parallelStream() for performance improvement.




















