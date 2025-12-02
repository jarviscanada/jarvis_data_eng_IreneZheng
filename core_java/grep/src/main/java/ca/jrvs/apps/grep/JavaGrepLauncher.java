package ca.jrvs.apps.grep;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class JavaGrepLauncher {

    private static final Logger logger = LoggerFactory.getLogger(JavaGrepLauncher.class);

    public static void main(String[] args) {
        if (args.length != 3) {
            throw new IllegalArgumentException("USAGE: regex rootPath outFile");
        }

        JavaGrepImp javaGrep = new JavaGrepImp();
        javaGrep.setRegex(args[0]);
        javaGrep.setRootPath(args[1]);
        javaGrep.setOutFile(args[2]);

        try{
            javaGrep.process();
        } catch (Exception e) {
            logger.error("Error Executing JavaGrep", e);
        }
    }
}
