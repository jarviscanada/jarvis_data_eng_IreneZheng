package ca.jrvs.apps.grep;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class JavaGrepLambdaLauncher {

    private static final Logger logger = LoggerFactory.getLogger(JavaGrepLambdaLauncher.class);

    public static void main(String[] args) {
        if (args.length != 3) {
            logger.error("USAGE: regex rootPath outFile");
            System.exit(1);
        }

        JavaGrepLambdaImp grep = new JavaGrepLambdaImp();
        grep.setRegex(args[0]);
        grep.setRootPath(args[1]);
        grep.setOutFile(args[2]);

        try {
            grep.process();
        } catch (Exception e) {
            logger.error("Failed to run lambda grep", e);
        }
    }
}
