package com.lingoport.figma2dev_java;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import com.lingoport.figma2dev_java.Figma2Dev;
import java.io.File;
import java.io.FileOutputStream;
import java.io.PrintStream;
import java.text.SimpleDateFormat;
import java.util.Date;

@SpringBootApplication
public class App {

	public static void main(String[] args) throws Exception {
		// *** Uncomment the code below to redirect console output to a log file *** //

        // Date now = new Date(); // Get the current date and time
        // SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd-HH:mm:ss"); // Create a SimpleDateFormat object with the desired pattern
        // String formattedDate = sdf.format(now); // Format the date

        // new File("testing/logs").mkdirs(); // Create logs directory if it doesn't exist
        // File logFile = new File("testing/logs/log_" + formattedDate + ".log"); // Create a File object for the log file

        // // Create FileOutputStreams for the log file (append mode)
        // FileOutputStream fosOut = new FileOutputStream(logFile, true);
        // FileOutputStream fosErr = new FileOutputStream(logFile, true);

        // // Create PrintStreams from the FileOutputStreams
        // PrintStream psOut = new PrintStream(fosOut);
        // PrintStream psErr = new PrintStream(fosErr);

        // // Redirect System.out and System.err
        // System.setOut(psOut);
        // System.setErr(psErr);

        // Call Figma2Dev main method
        Figma2Dev.main(args);
	}

}
