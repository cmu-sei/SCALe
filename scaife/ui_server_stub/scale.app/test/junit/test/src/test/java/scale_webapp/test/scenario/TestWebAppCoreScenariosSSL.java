// <legal>
// SCALe version r.6.2.2.2.A
// 
// Copyright 2020 Carnegie Mellon University.
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

package scale_webapp.test.scenario;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;
import scale_webapp.test.infra.AppConfig;
import scale_webapp.test.infra.LocalWebServer;
import scale_webapp.test.infra.ScaleWebApp;
import scale_webapp.test.infra.ScaleWebApp.HomePage.ProjectRow;
import scale_webapp.test.infra.ToolInfo;

public class TestWebAppCoreScenariosSSL extends TestCase {
	private AppConfig config;
	private LocalWebServer server;

	/**
	 * Class consturctor
	 *
	 * @param testName
	 * @throws IOException
	 */
	public TestWebAppCoreScenariosSSL(String testName) throws IOException {
		super(testName);
		InputStream is = getClass().getResourceAsStream("/test_config.json");
		this.config = new AppConfig(is, "local_ssl");
		File certFile = new File(this.config.inputDirectory, "server.crt");
		File keyFile = new File(this.config.inputDirectory, "server.key");
		this.server = new LocalWebServer(this.config.root, this.config.port, certFile.toString(), keyFile.toString());

		//create destination folder
		File destFolder = new File(this.config.root, "cert/");
		destFolder.mkdirs();

		File certDest = new File(this.config.root, "cert/server.crt");
		File keyDest = new File(this.config.root, "cert/server.key");
		Files.copy(certFile.toPath(), certDest.toPath(), StandardCopyOption.REPLACE_EXISTING);
		Files.copy(keyFile.toPath(), keyDest.toPath(), StandardCopyOption.REPLACE_EXISTING);
	}

	@Override
	/**
	 * runs before test suite
	 */
	protected void setUp() throws Exception {
		super.setUp();
		this.server.start();
	}

	@Override
	/**
	 * runs after test suite
	 */
	protected void tearDown() throws Exception {
		super.tearDown();
		this.server.stop();
	}

	/**
	 * init suite
	 *
	 * @return
	 */
	public static Test suite() {
		return new TestSuite(TestWebAppCoreScenariosSSL.class);
	}

	/**
	 * deletes given project with projectName, deletes cert/server.* files,
	 * and closes driver instance
	 *
	 * @param webApp
	 * @param projectName
	 */
	private void cleanupWebApp(ScaleWebApp webApp, String projectName) {
		try {
			if (webApp != null) {
				if (projectName != null) {
					webApp.goHome();
					webApp.destroyProject(projectName);
				}

				//delete the server files.
				new File(this.config.root, "cert/server.crt").delete();
				new File(this.config.root, "cert/server.key").delete();

				webApp.getDriver().quit();
				webApp.close();
			}
		} catch (Exception x) {
			System.err.println(x.toString());
		}
	}

	/**
	 * Test the creation of a project.
	 */
	public void testProjectCreateAndDelete() {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, "dos2unix/dos2unix-7.2.2.zip").toString();
		String fortifyPath = new File(this.config.inputDirectory, "dos2unix/analysis/fortify.xml").toString();

		try {
			// Build a model of our Web App with the given driver.
			webApp = this.config.createApp();

			// Launch the app, create a project, then go back to the home page
			webApp.launch();
			webApp.createSimpleProject(projectName, projectDescription, archivePath, fortifyPath,
					ToolInfo.Fortify_C_ID);
			webApp.goHome();

			// Test that the project appears in the list
			ProjectRow project = webApp.Home.getProjectRowByName(projectName);
			assertEquals(project.nameLink.getText(), projectName);
			assertEquals(project.description.getText(), projectDescription);

			webApp.destroyProject(projectName);
			webApp.goHome();

			//Make sure the project was destroyed
			assertFalse(webApp.Home.getProjectNames().contains(projectName));

		} finally {
			cleanupWebApp(webApp, null); //project should already be destroyed
		}
	}

}
