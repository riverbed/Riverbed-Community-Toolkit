// Cookbook106.java
//
// Riverbed-Community-Toolkit (https://github.com/riverbed/Riverbed-Community-Toolkit)
// 106-opentelemetry-autoinstrumentation-java-app
// version: 22.3.29
//
// Simple Java app to demonstrate OpenTelemetry autoinstrumentation of the java.net.HttpURLConnection class

package com.aternity.techcommunity ;

import java.io.*;
import java.net.*  ;
import java.lang.Thread;

public class cookbook106 {

    public static void get_apm_webpage() {
        
        try {
            URL url = new URL("https://www.riverbed.com/products/application-performance-monitoring");
            HttpURLConnection urlConnection = (HttpURLConnection) url.openConnection();
            BufferedReader in = new BufferedReader(new InputStreamReader(urlConnection.getInputStream()));
            String inputLine;
            while ((inputLine = in.readLine()) != null) {
                if (inputLine.contains("APM")) {
                    System.out.println("APM");
                }
            }
            in.close();
            Thread.sleep(10000);
        } catch(Exception e) {
            System.out.println(e) ;
            return;
        }
    }

	public static void main(String[] args) {
		
        System.out.println("Starting...") ;

        get_apm_webpage();

        System.out.println("Done.") ;
	}

}
