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

package scale_webapp.test.stress;

import java.io.File;
import java.io.InputStream;
import java.util.UUID;

import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;
import scale_webapp.test.infra.AppConfig;
import scale_webapp.test.infra.ScaleWebApp;
import scale_webapp.test.infra.ToolInfo;
import scale_webapp.test.infra.InputPathInfo;

public class TestUploadAlertsStress extends TestCase {
	private AppConfig config;

	/**
	 * Class constructor
	 *
	 * @param testName
	 */
	public TestUploadAlertsStress(String testName) {
		super(testName);
		InputStream is = getClass().getResourceAsStream("/test_config.json");
		this.config = new AppConfig(is, "remote");
	}

	/**
	 * init suite
	 *
	 * @return
	 */
	public static Test suite() {
		return new TestSuite(TestUploadAlertsStress.class);
	}

	/**
	 * test creation of scale project with 100 alerts
	 */
	public void testCreate100Alerts() {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, InputPathInfo.RandomSrc).toString();
		String outputPath = new File(this.config.inputDirectory, InputPathInfo.RandomSrcToolOutputRosecheckers100).toString();

		try {
			webApp = this.config.createApp();
			webApp.launch();

			long before, after;
			before = System.currentTimeMillis();
			webApp.createSimpleProject(projectName, projectDescription, archivePath, outputPath, ToolInfo.Rosecheckers_OSS_C_ID,
					true);
			after = System.currentTimeMillis();
			System.out.println("100,100,Time," + (after - before));

		} finally {
			if (webApp != null) {
				webApp.goHome();
				webApp.destroyProject(projectName);
				webApp.close();
			}
		}
	}

	/**
	 * test creation of scale project with 600 alerts
	 */
	public void testCreate600Alerts() {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, InputPathInfo.RandomSrc).toString();
		String outputPath = new File(this.config.inputDirectory, InputPathInfo.RandomSrcToolOutputRosecheckers600).toString();

		try {
			webApp = this.config.createApp();
			webApp.launch();

			long before, after;
			before = System.currentTimeMillis();
			webApp.createSimpleProject(projectName, projectDescription, archivePath, outputPath, ToolInfo.Rosecheckers_OSS_C_ID,
					true);
			after = System.currentTimeMillis();
			System.out.println("100,600,Time," + (after - before));

		} finally {
			if (webApp != null) {
				webApp.goHome();
				webApp.destroyProject(projectName);
				webApp.close();
			}
		}
	}

	/**
	 * test creation of scale project with 1100 alerts
	 */
	public void testCreate1100Alerts() {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, InputPathInfo.RandomSrc).toString();
		String outputPath = new File(this.config.inputDirectory, InputPathInfo.RandomSrcToolOutputRosecheckers1100).toString();

		try {
			webApp = this.config.createApp();
			webApp.launch();

			long before, after;
			before = System.currentTimeMillis();
			webApp.createSimpleProject(projectName, projectDescription, archivePath, outputPath, ToolInfo.Rosecheckers_OSS_C_ID,
					true);
			after = System.currentTimeMillis();
			System.out.println("100,1100,Time," + (after - before));

		} finally {
			if (webApp != null) {
				webApp.goHome();
				webApp.destroyProject(projectName);
				webApp.close();
			}
		}
	}
}
