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

package scale_webapp.test.scaife_integration;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.Set;
import java.util.UUID;

import org.junit.Assert;
import org.openqa.selenium.Alert;
import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.support.ui.ExpectedCondition;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.Select;
import org.openqa.selenium.support.ui.WebDriverWait;

import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;
import scale_webapp.test.infra.AppConfig;
import scale_webapp.test.infra.LocalWebServer;
import scale_webapp.test.infra.ScaleScaifeWebApp;
import scale_webapp.test.infra.ScaleWebApp;
import scale_webapp.test.infra.ScaleWebApp.AccordionList;
import scale_webapp.test.infra.ScaleWebApp.AlertConditionsViewerPage.AlertConditionRow;
import scale_webapp.test.infra.ScaleWebApp.AlertConditionsViewerPage.FilterElems;
import scale_webapp.test.infra.ScaleWebApp.AlertConditionsViewerPage.FilterValues;
import scale_webapp.test.infra.ScaleWebApp.HomePage.ProjectRow;
import scale_webapp.test.infra.ScaleWebApp.TableList;
import scale_webapp.test.infra.ScaleWebApp.ToolRow;
import scale_webapp.test.infra.ScaleWebApp.Verdict;
import scale_webapp.test.infra.ToolInfo;
import scale_webapp.test.infra.InputPathInfo;


/**
 * Unit tests for core web app functionality.
 */
public class ScaifeTestWebAppIntegration extends TestCase {
	private AppConfig config;
	private LocalWebServer server;

	/**
	 * Class Constructor
	 *
	 * @param testName
	 */
	public ScaifeTestWebAppIntegration(String testName) {
		super(testName);
		InputStream is = getClass().getResourceAsStream("/test_config.json");
		config = new AppConfig(is, "remote");
	}

	/**
	 * init suite
	 *
	 * @return
	 */
	public static Test suite() {
		return new TestSuite(ScaifeTestWebAppIntegration.class);
	}

	private void cleanupWebApp(ScaleWebApp webApp, String projectName) {
		try {
			if (webApp != null) {
				if (projectName != null) {
					webApp.goHome();
					webApp.destroyProject(projectName);
				}
				webApp.driver.quit();
				webApp.close();
			}
		} catch (Exception x) {
			System.err.println(x.toString());
		}
	}

	public void testScaifeConnect() throws InterruptedException {
		ScaleScaifeWebApp webApp = null;

		try {
			webApp = this.config.createScaifeEnabledApp();
			webApp.launch();
			assert(webApp.scaifeActive());
		}
		finally {
			cleanupWebApp(webApp, null);
		}
	}

	public void testCreateAndCompareManualProjectOnePartA() {

		ScaleScaifeWebApp webApp = null;
		String projectName = null;
		Boolean cleanupAfter = true;

		try {
			// Build a model of our Web App with the given driver.
			webApp = this.config.createScaifeEnabledApp();
			// Launch the app, create a project, then go back to the home page
			webApp.launch();
			projectName = webApp.createManualProjectOnePartA(this.config);
			this.runCanonicalProjectCompareScript("1a", projectName, cleanupAfter);
		} finally {
			if (cleanupAfter) {
				cleanupWebApp(webApp, projectName);
			}
			else {
				System.out.println("retaining test project");
				cleanupWebApp(webApp, null);
			}
		}

	}

	public void testCreateAndCompareManualProjectOnePartB() {

		ScaleScaifeWebApp webApp = null;
		String projectName = null;
		Boolean cleanupAfter = true;

		try {
			// Build a model of our Web App with the given driver.
			webApp = this.config.createScaifeEnabledApp();
			// Launch the app, create a project, then go back to the home page
			webApp.launch();
			projectName = webApp.createManualProjectOnePartB(this.config);
			this.runCanonicalProjectCompareScript("1b", projectName, cleanupAfter);
		} finally {
			if (cleanupAfter) {
				cleanupWebApp(webApp, projectName);
			}
			else {
				System.out.println("retaining test project");
				cleanupWebApp(webApp, null);
			}
		}

	}

	public void runCanonicalProjectCompareScript(String scenario) {
		runCanonicalProjectCompareScript(scenario, null, false);
	}
	public void runCanonicalProjectCompareScript(String scenario, Boolean cleanupAfter) {
		runCanonicalProjectCompareScript(scenario, null, cleanupAfter);
	}
	public void runCanonicalProjectCompareScript(String scenario, String projectName) {
		runCanonicalProjectCompareScript(scenario, projectName, null);
	}
	public void runCanonicalProjectCompareScript(String scenario, String projectName, Boolean cleanupAfter) {
		List<String> cmd = new ArrayList<>();
		cmd.add("../../../scripts/automation/create_and_compare_project_db.py");
		cmd.add("-v");
		if (! cleanupAfter)
			cmd.add("-k");
		if (projectName != null) {
			// otherwise the script will just use whatever the latest project is
			cmd.add("--project");
			cmd.add(projectName);
		}
		cmd.add(scenario);
		System.out.printf("running %s\n", String.join(" ",  cmd));
		ProcessBuilder pb = new ProcessBuilder(cmd);
		pb = pb.redirectErrorStream(true);
		try {
			Process proc = pb.start();
			InputStream is = proc.getInputStream();
			BufferedReader br = new BufferedReader(new InputStreamReader(is));
			String line = null;
			String err = "";
			while ((line = br.readLine()) != null) {
				err += "\n" + line;
				System.out.println(line);
			}
			int rc = proc.waitFor();
			if (rc != 0) {
				System.err.println(err);
			}
			assertEquals(err, 0, rc);
			System.out.println("selenium project matches automation project");
		} catch (Exception ex) {
			ex.printStackTrace();
			System.err.println(ex.toString());
			assert(false);
		}
	}

}
