// <legal>
// SCALe version r.6.5.5.1.A
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
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.concurrent.TimeUnit;

import org.apache.commons.lang3.NotImplementedException;
import org.json.JSONObject;
import org.openqa.selenium.Dimension;
import org.openqa.selenium.Proxy;
import org.openqa.selenium.Proxy.ProxyType;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.firefox.FirefoxOptions;
import org.openqa.selenium.firefox.FirefoxDriverLogLevel;
import org.openqa.selenium.firefox.GeckoDriverService;
//import org.openqa.selenium.firefox.MarionetteDriver;
import org.openqa.selenium.ie.InternetExplorerDriver;
import org.openqa.selenium.ie.InternetExplorerOptions;
import org.openqa.selenium.remote.CapabilityType;
import org.openqa.selenium.remote.DesiredCapabilities;

public class AppConfig {
	public enum Browser {
		Firefox, Chrome, Explorer
	}

	public String protocol = "http";
	public String host = "localhost";
	public int port = 8083;
	public String user = "scale";
	public String password = "Change_me!";
	public String inputDirectory = null;
	public Browser browser;
	public Integer implicitTimeout = 20;
	public String root = null;
	public Proxy proxy = null;
	public String geckoDriverPath = "";
	public boolean headless = false;
	public boolean trace_log = false;

	public String scaife_user = "scaife";
	public String scaife_password = "So_fun!";

	/**
	 * Class constructor
	 * Build a webapp from the data in AppConfig.java
	 *
	 * @return ScaleWebApp instance
	 */
	public ScaleWebApp createApp() {
		WebDriver driver = getDriver();
		return new ScaleWebApp(this.protocol, this.host, this.port, this.user, this.password, driver);
	}

	/**
	 * Class constructor
	 * Build a scaife-enabled webapp from the data in AppConfig.java
	 *
	 * @return ScaleScaifeWebApp instance
	 */
	public ScaleScaifeWebApp createScaifeEnabledApp() {
		WebDriver driver = getDriver();
		return new ScaleScaifeWebApp(this.protocol, this.host, this.port, this.user, this.password, this.scaife_user, this.scaife_password, driver);
	}

	/**
	 * convert InputStream to a String
	 *
	 * @param is
	 * @return String
	 */
	public String streamToString(InputStream is) {
		BufferedReader reader = new BufferedReader(new InputStreamReader(is));
		StringBuilder out = new StringBuilder();
		String line;

		try {
			while ((line = reader.readLine()) != null) {
				out.append(line);
			}
			reader.close();
		} catch (Exception e) {
		}
		return out.toString();

	}

	/**
	 * Class constructor
	 *
	 * @param config
	 * @param serverId
	 */
	public AppConfig(InputStream config, String serverId) {
		String data = streamToString(config);
		JSONObject root = new JSONObject(data);
		JSONObject servers = root.getJSONObject("servers");
		JSONObject options = servers.getJSONObject(serverId);
		this.protocol = options.getString("protocol");
		this.host = options.getString("host");
		this.port = options.getInt("port");
		this.user = options.getString("user");
		this.password = options.getString("password");
		this.root = options.getString("root");
		this.scaife_user = options.getString("scaife_user");
		this.scaife_password = options.getString("scaife_password");
		this.browser = Enum.valueOf(Browser.class, root.getString("browser"));
		this.implicitTimeout = root.getInt("implicitTimeout");
		this.inputDirectory = root.getString("inputDirectory");
		this.geckoDriverPath = root.getString("geckoDriver");

		if (root.has("headless")) {
			this.headless = root.getBoolean("headless");
		}

		if (root.has("trace_log")) {
			this.trace_log = root.getBoolean("trace_log");
		}

		JSONObject proxyOptions = options.getJSONObject("proxy");
		if (proxyOptions != null) {
			this.proxy = new Proxy();
			String type = proxyOptions.getString("type");
			if (type.equalsIgnoreCase("DIRECT")) {
				this.proxy.setProxyType(ProxyType.DIRECT);
			} else if (type.equals("MANUAL")) {
				this.proxy.setProxyType(ProxyType.MANUAL);
				this.proxy.setHttpProxy(proxyOptions.getString("http"));
				this.proxy.setSslProxy(proxyOptions.getString("https"));
			}
		}
	}

	/**
	 * get WebDriver instance
	 *
	 * @return driver (WebDriver)
	 */
	private WebDriver getDriver() {
		WebDriver driver = null;
		//DesiredCapabilities cap = new DesiredCapabilities();
		//if (this.proxy != null) {
		//	cap.setCapability(CapabilityType.PROXY, proxy);
		//}
		//cap.setCapability(CapabilityType.ACCEPT_SSL_CERTS, true);

		switch (this.browser) {
		case Chrome:
			ChromeOptions chromeOptions = new ChromeOptions();
			if (this.proxy != null) {
				chromeOptions.setCapability(CapabilityType.PROXY, proxy);
			}
			chromeOptions.setCapability(CapabilityType.ACCEPT_SSL_CERTS, true);
			driver = new ChromeDriver(chromeOptions);
			break;
		case Explorer:
			InternetExplorerOptions ieOptions = new InternetExplorerOptions();
			if (this.proxy != null) {
				ieOptions.setCapability(CapabilityType.PROXY, proxy);
			}
			ieOptions.setCapability(CapabilityType.ACCEPT_SSL_CERTS, true);
			driver = new InternetExplorerDriver(ieOptions);
			break;
		case Firefox:
			System.setProperty("webdriver.gecko.driver", this.geckoDriverPath);
			FirefoxOptions firefoxOptions = new FirefoxOptions();

			if (this.proxy != null) {
				firefoxOptions.setCapability(CapabilityType.PROXY, proxy);
			}
			firefoxOptions.setCapability(CapabilityType.ACCEPT_SSL_CERTS, true);

			if(this.trace_log)
			{
				firefoxOptions.setLogLevel(FirefoxDriverLogLevel.TRACE);
			}

			if(this.headless)
			{
				firefoxOptions.addArguments("-headless");
			}
			driver = new FirefoxDriver(firefoxOptions);
			break;
		default:
			throw new NotImplementedException("Unimplemented browser type: " + this.browser);
		}

		if (implicitTimeout != null) {
			driver.manage().timeouts().implicitlyWait(implicitTimeout, TimeUnit.SECONDS);
		}
		return driver;
	}
}
