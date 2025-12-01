package ca.jrvs.apps.grep;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.IOException;
import java.nio.file.*;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class JavaGrepLambdaImp extends JavaGrepImp {

    private static final Logger logger = LoggerFactory.getLogger(JavaGrepLambdaImp.class);

    @Override
    public List<File> listFiles(String rootDir) {
        try (Stream<Path> walk = Files.walk(Paths.get(rootDir))) {
            return walk.filter(Files::isRegularFile)
                    .map(Path::toFile)
                    .collect(Collectors.toList());
        } catch (IOException e) {
            logger.error("Failed to list files in directory: {}", rootDir, e);
            throw new RuntimeException(e);
        }
    }

    @Override
    public List<String> readLines(File inputFile) {
        try (Stream<String> lines = Files.lines(inputFile.toPath())) {
            return lines.collect(Collectors.toList());
        } catch (IOException e) {
            logger.error("Failed to read lines from file: {}", inputFile, e);
            throw new RuntimeException(e);
        }
    }

    @Override
    public void process() throws IOException {
        List<File> files = listFiles(getRootPath());

        List<String> matchedLines = files.stream()
                .flatMap(file -> {
                    try {
                        return Files.lines(file.toPath());
                    } catch (IOException e) {
                        logger.error("Unable to read file {}", file, e);
                        return Stream.<String>empty();
                    }
                })
                .filter(this::containsPattern)
                .collect(Collectors.toList());

        writeToFile(matchedLines);
    }




}

