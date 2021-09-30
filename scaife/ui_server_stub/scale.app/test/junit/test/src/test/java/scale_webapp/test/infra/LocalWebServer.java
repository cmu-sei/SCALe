// <legal>
// SCALe version r.6.7.0.0.A
// 
// Copyright 2021 Carnegie Mellon University.
// 
// NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING
// INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON
// UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR
// IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF
// FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS
// OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT
// MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT,
// TRADEMARK, OR COPYRIGHT INFRINGEMENT.
// 
// Released under a MIT (SEI)-style license, please see COPYRIGHT file or
// contact permission@sei.cmu.edu for full terms.
// 
// [DISTRIBUTION STATEMENT A] This material has been approved for public
// release and unlimited distribution.  Please see Copyright notice for
// non-US Government use and distribution.
// 
// DM19-1274
// </legal>

package scale_webapp.test.infra;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.Socket;

public class LocalWebServer {
	private String root;
	private Process process;
	private String host;
	private int port;
	private String certFile;
	private String keyFile;
	private boolean useSSL;

	/**
	 * class constructor
	 *
	 * @param root
	 * @param host
	 * @param port
	 */
	public LocalWebServer(String root, String host, int port) {
		this.root = root;
		this.process = null;
		this.host = host;
		this.port = port;
		this.useSSL = false;
	}

	/**
	 * class constructor
	 *
	 * @param root
	 * @param port
	 * @param certFile
	 * @param keyFile
	 */
	public LocalWebServer(String root, int port, String certFile, String keyFile) {
		this.root = root;
		this.process = null;
		this.port = port;
		this.certFile = certFile;
		this.keyFile = keyFile;
		this.useSSL = true;
	}

	/**
	 * start webserver
	 */
	public void start() {
		if (this.process != null && this.process.isAlive()) {
			return;
		}
		String cmd, fmt;

		if (this.useSSL) {
			fmt = "bundle exec thin start --ssl --port %d --ssl-cert-file %s --ssl-key-file %s";
			cmd = String.format(fmt, this.port, this.certFile, this.keyFile);
		} else {
			fmt = "bundle exec thin start --port %d";
			cmd = String.format(fmt, this.port);
		}

		try {
			this.process = Runtime.getRuntime().exec(cmd, null, new File(root));
			//wait for server to start
			while(true) {
				if (serverListening(this.host, this.port)) {
					break;
				} else {
					waitSecond();
				}
			}

			StreamGobbler errorGobbler = new StreamGobbler(this.process.getErrorStream());
			StreamGobbler outputGobbler = new StreamGobbler(this.process.getInputStream());
			errorGobbler.start();
			outputGobbler.start();

		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	/**
	 * stop webserver
	 */
	public void stop() {
		if (this.process != null && this.process.isAlive()) {
			this.process.destroyForcibly();
			this.process = null;
		}
	}

	/**
	 * poll to see if host is listening on the port
	 *
	 * @param host
	 * @param port
	 * @return Boolean true, false if there's an error
	 */
	public static boolean serverListening(String host, int port) {
		Socket s = null;
		try {
			s = new Socket(host, port);
			return true;
		}
		catch (Exception e) {
			return false;
		}
		finally {
			if (s != null)
				try { s.close(); }
				catch (Exception e) {}
		}
	}

	private static void waitSecond() {
		try {
			Thread.sleep(1000);
		} catch (InterruptedException e) {
		}
	}

	class StreamGobbler extends Thread {
		InputStream is;

		// reads everything from is until empty.
		StreamGobbler(InputStream is) {
			this.is = is;
		}

		public void run() {
			try {
				InputStreamReader isr = new InputStreamReader(is);
				BufferedReader br = new BufferedReader(isr);
				String line = null;
				while ((line = br.readLine()) != null)
					System.out.println(line);
			} catch (IOException ioe) {
				ioe.printStackTrace();
			}
		}
	}
}
