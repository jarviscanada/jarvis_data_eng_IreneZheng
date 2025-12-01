package ca.jrvs.apps.grep;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;
import java.util.regex.Matcher;


public class JavaGrepImp implements JavaGrep {

    final Logger logger = LoggerFactory.getLogger(JavaGrepImp.class);

    private String rootPath;
    private String regex;
    private String outFile;

    private Pattern pattern;

    @Override
    public void process() throws IOException {

        logger.info("Starting grep process");//debug
        logger.info("Regex: {}", regex);//debug
        logger.info("Root directory: {}", rootPath);//debug
        logger.info("Output file: {}", outFile);//debug

        pattern = Pattern.compile(regex);

        List<String> matchedLines = new ArrayList<>();

        List<File> files = listFiles(rootPath);

        for (File file : files) {

            // Read all lines from the file
            List<String> lines = readLines(file);

            for (String line : lines) {
                if (containsPattern(line)) {
                    matchedLines.add(line);
                }
            }
        }

        logger.info("Total matched lines: {}", matchedLines.size());//debug

        writeToFile(matchedLines);

        logger.info("Finished writing output.");//debug

    }

    @Override
    public List<File> listFiles(String rootDir) {
        List<File> result = new ArrayList<>();
        File root = new File(rootDir); //converts the path string into a File object.

        // Check if the directory exists
        if (!root.exists()) {
            logger.error("Root directory does not exist: {}", rootDir); //if the folder doesn't exist, log an error and return an empty list.
            return result;
        }

        // Start recursion
        traverse(root, result); //helper function
        return result;
    }

    private void traverse(File file, List<File> result) {

        // If it's a directory, go inside it
        if (file.isDirectory()) {
            File[] children = file.listFiles();

            if (children != null) { //directory isn't empty
                for (File child : children) {
                    traverse(child, result); // recursion
                }
            }

        } else {
            // If it's a file, add to the result
            result.add(file);
        }
    }

    @Override
    public List<String> readLines(File inputFile) throws IOException {
        if (!inputFile.isFile()) {
            throw new IllegalArgumentException("Not a file: " + inputFile.getAbsolutePath());
        }

        List<String> lines = new ArrayList<>();

        // Try-with-resources: ensures reader is closed automatically
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(
                        Files.newInputStream(inputFile.toPath()),
                        StandardCharsets.UTF_8))) {

            String line;

            // Read file line by line
            while ((line = reader.readLine()) != null) {
                lines.add(line);
            }

        } catch (IOException e) {
            logger.error("Failed to read file: {}", inputFile.getAbsolutePath(), e);
            throw e;
        }

        return lines;
    }

    @Override
    public boolean containsPattern(String line) {
        Matcher matcher = pattern.matcher(line);
        return matcher.find();
    }

    @Override
    public void writeToFile(List<String> lines) throws IOException {
        try (BufferedWriter writer = new BufferedWriter(
                new OutputStreamWriter(
                        Files.newOutputStream(Paths.get(outFile)),
                        StandardCharsets.UTF_8))) {

            for (String line : lines) {
                writer.write(line);
                writer.newLine();
            }

        } catch (IOException e) {
            logger.error("Failed to write to file: {}", outFile, e);
            throw e;
        }
    }

    @Override
    public String getRootPath() {
        return rootPath;
    }

    @Override
    public void setRootPath(String rootPath) {
        this.rootPath = rootPath;
    }

    @Override
    public String getRegex() {
        return regex;
    }

    @Override
    public void setRegex(String regex) {
        this.regex = regex;
    }

    @Override
    public String getOutFile() {
        return outFile;
    }

    @Override
    public void setOutFile(String outFile) {
        this.outFile = outFile;
    }
}

