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

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.util.List;
import java.util.UUID;

import org.junit.AfterClass;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.openqa.selenium.Alert;
import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.Select;
import org.openqa.selenium.support.ui.WebDriverWait;

import junit.extensions.TestSetup;
import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;
import scale_webapp.test.infra.AppConfig;
import scale_webapp.test.infra.LocalWebServer;
import scale_webapp.test.infra.ScaleWebApp;
import scale_webapp.test.infra.ScaleWebApp.Verdict;
import scale_webapp.test.infra.ScaleWebApp.AlertConditionsViewerPage.AlertConditionRow;
import scale_webapp.test.infra.ScaleWebApp.HomePage.ProjectRow;
import scale_webapp.test.infra.ToolInfo;


public class TestWebAppCoreScenariosLocal extends TestCase{
	InputStream is;
	private static AppConfig config;
	private static LocalWebServer server;

	/**
	 * init suite
	 *
	 * @return
	 */
	public static Test suite() {
		return new TestSetup(new TestSuite(TestWebAppCoreScenariosLocal.class));
	}

	/**
	 * setup runs before test suite
	 */
	protected void setUp() throws Exception {
		is = getClass().getResourceAsStream("/test_config.json");
		config = new AppConfig(is, "local");
		server = new LocalWebServer(config.root, config.host, config.port);
		server.start();
	}

	/**
	 * teardown runs after test suite
	 */
	protected void tearDown() throws Exception {
		is.close();
		server.stop();
	}

	/**
	 * delete project and closer driver instance
	 *
	 * @param webApp
	 * @param projectName
	 */
	private void cleanupWebApp(ScaleWebApp webApp, String projectName) {
		try {
			if (webApp != null) {
				webApp.goHome();
				webApp.destroyProject(projectName);
				webApp.driver.quit();
				webApp.close();
			}
		} catch (Exception x) {
			System.err.println(x.toString());
		}
	}

	/**
	 * tests if local condition links are used when local docs are present
	 *
	 * @throws InterruptedException
	 */
	public void testLocalProjectLinks() throws InterruptedException {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(config.inputDirectory, "dos2unix/dos2unix-7.2.2.zip").toString();
		String fortifyPath = new File(config.inputDirectory, "dos2unix/analysis/fortify_10.xml").toString();
		String fortifyEditPath = new File(config.inputDirectory, "dos2unix/analysis/fortify_10_edit.xml").toString();
		String coverityEditPath = new File(config.inputDirectory, "dos2unix/analysis/coverity_1.json").toString();
		File src = new File(config.inputDirectory, "test_docs/c");
		File dest = new File(config.root, "public/doc/c");

		dest.mkdirs();
		for (File s : src.listFiles()) {
			try {
				File d = new File(dest.getPath(), s.getName());
				Files.copy(s.toPath(), d.toPath(), StandardCopyOption.REPLACE_EXISTING);
			} catch (IOException e) {
				e.printStackTrace();
				fail();
			}
		}

		try {

			webApp = config.createApp();

			webApp.launch();

			//test createSimpleProject
			webApp.createSimpleProject(projectName, projectDescription, archivePath, fortifyPath,
					ToolInfo.Fortify_C_ID);
			String suffix = "doc/c/FIO30-C.-Exclude-user-input-from-format-strings_347.html";

			webApp.waitForAlertConditionsTableLoad();

			int x = 0;
			do {
				for (AlertConditionRow r : webApp.AlertConditionsViewer.getAlertConditionRows()) {
					x+=1;
					assertEquals("FIO30-C", r.condition.getText());
					//TODO: Scale.app contains the google links even when running this test.
					//System.out.println("row's condition href attribute is '" + r.condition.getAttribute("href") + "', expected '" + suffix +"'");
					assertTrue(r.condition.getAttribute("href").endsWith(suffix));

				}
			} while (webApp.AlertConditionsViewer.goToNextPage());
			Assert.assertEquals(x, 10);

			//test EditSimpleProject(using fortifyEditPath)
			webApp.EditSimpleProject(projectName, fortifyEditPath, ToolInfo.Fortify_C_ID);

			webApp.waitForAlertConditionsTableLoad();
			x = 0;
			do {
				for (AlertConditionRow r : webApp.AlertConditionsViewer.getAlertConditionRows()) {
					x+=1;
					assertEquals("ARR30-C", r.condition.getText());
					assertEquals(("FIO30-C".equals(r.condition.getText())), false);
				}
			} while (webApp.AlertConditionsViewer.goToNextPage());

			Assert.assertEquals(x, 10);

			//test EditSimpleProject(using coverityEditPath)
			webApp.EditSimpleProject(projectName, coverityEditPath, ToolInfo.Coverity_C_ID);

			x = 0;
			do {
				for (AlertConditionRow r : webApp.AlertConditionsViewer.getAlertConditionRows()) {
					x+=1;
					if (!r.condition.getText().equals("ARR30-C") &&
						!r.condition.getText().equals("FIO21-C") &&
						!r.condition.getText().equals("CWE-377")) assert(false);
				}
			} while (webApp.AlertConditionsViewer.goToNextPage());
			//System.out.println("testing EditSimpleProject(using " + coverityEditPath + ")");
			Assert.assertEquals(x, 12);
		} finally {
			cleanupWebApp(webApp, projectName);
		}
	}

	/**
	 * tests to see if remote links are used when local docs are not present
	 */
	public void testRemoteProjectLinks() {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(config.inputDirectory, "dos2unix/dos2unix-7.2.2.zip").toString();
		String fortifyPath = new File(config.inputDirectory, "dos2unix/analysis/fortify_10.xml").toString();
		File dest = new File(config.root, "public/doc/c");

		dest.mkdirs();
		for (File d : dest.listFiles()) {
			d.delete();
		}

		try {
			webApp = config.createApp();

			webApp.launch();
			webApp.createSimpleProject(projectName, projectDescription, archivePath, fortifyPath,
					ToolInfo.Fortify_C_ID);
			String link = "http://www.google.com/search?btnI&q=FIO30-C%20site%3Awww.securecoding.cert.org";

			webApp.waitForAlertConditionsTableLoad();

			do {
				for (AlertConditionRow r : webApp.AlertConditionsViewer.getAlertConditionRows()) {
					assertEquals("FIO30-C", r.condition.getText());
					assertEquals(link, r.condition.getAttribute("href"));
				}
			} while (webApp.AlertConditionsViewer.goToNextPage());
		} finally {
			cleanupWebApp(webApp, projectName);
		}
	}


	/**
	 * scroll so that ele is within view
	 *
	 * @param driver
	 * @param ele
	 */
	public static void scrollIntoView(WebDriver driver, WebElement ele) {
		((JavascriptExecutor)driver).executeScript("window.scrollTo(" + ele.getLocation().x + "," + ele.getLocation().y + ")");
	}

	/**
	 * Test the sanitizer script
	 * @throws InterruptedException
	 */
	public void testProjectSanitizer() throws InterruptedException {

		boolean keepTestProject = false;
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String testProjectPath = new File(this.config.inputDirectory, "dos2unix").toString();
		String testInputPath = new File(testProjectPath, "analysis").toString();

		String archivePath = new File(testProjectPath, "dos2unix-7.2.2.zip").toString();
		String gccPath = new File(testInputPath, "gcc_oss.txt").toString();
		String rosecheckersPath = new File(testInputPath, "rosecheckers_oss.txt").toString();
		//String coverityPath = new File(testInputPath, "coverity.json").toString();
		String ccsmPath = new File(testInputPath, "ccsm_oss.csv").toString();
		String lizardPath = new File(testInputPath, "lizard_oss.csv").toString();
		//String understandPath = new File(testInputPath, "understand.csv").toString();
		String testPyScript = new File(this.config.root, "test/python/test_sanitizer.py").toString();

		//String cppcheckPath = new File(testInputPath, "cppcheck_oss.xml").toString();

		HashMap<String, String> tools = new HashMap<String, String>();
		tools.put(gccPath, ToolInfo.GCC_OSS_C_ID);
		tools.put(rosecheckersPath, ToolInfo.Rosecheckers_OSS_C_ID);
		//tools.put(coverityPath, ToolInfo.Coverity_C_ID);
		tools.put(ccsmPath, ToolInfo.CCSM_OSS_Metric_ID);
		tools.put(lizardPath, ToolInfo.Lizard_OSS_Metric_ID);
		//tools.put(understandPath, ToolInfo.Understand_Metric_ID);
		//tools.put(cppcheckPath, ToolInfo.CPPCHECK_OSS_C_ID);;

		String userUploadFilePath = new File(this.config.inputDirectory, "misc/user_upload_example.csv").toString();
		String priorityName = "priorityScheme1";

			try {
				// Build a model of our Web App with the given driver.
				webApp = config.createApp();

				// Launch the app, create a project, then go back to the home page
				webApp.launch();
				webApp.createMultiToolProject(projectName, projectDescription, archivePath, tools);

				WebDriver driver = webApp.getDriver();
				webApp.waitForAlertConditionsTableLoad();
				webApp.waitForPageLoad(driver);

				// upload user columns
				webApp.PrioritySchemeModal.uploadUserCols(userUploadFilePath);

				webApp.waitForAlertConditionsTableLoad();

				// set first AlertCondition to false, second AlertCondition to true
				AlertConditionRow row = webApp.AlertConditionsViewer.getAlertConditionRows().get(0);

				scrollIntoView(driver, row.verdict);
				new WebDriverWait(webApp.getDriver(), 100).until(ExpectedConditions
						.elementToBeClickable(By.linkText("FIO30-C")));
				webApp.waitForAlertConditionsTableLoad();
				row.setVerdict(Verdict.False);
				row = webApp.AlertConditionsViewer.getAlertConditionRows().get(1);
				scrollIntoView(driver, row.verdict);
				webApp.waitForAlertConditionsTableLoad();
				row.setVerdict(Verdict.True);

				webApp.waitForAlertConditionsTableLoad();
				webApp.waitForPageLoad(driver);

				// Open prioritizationScheme modal and verify results
				Actions action = new Actions(driver);
				WebElement priority_menu = driver.findElement(By.xpath("//li[@id='priorityscheme-dropdown']//a"));
				scrollIntoView(driver, priority_menu);
				new WebDriverWait(webApp.getDriver(), 1000).until(ExpectedConditions
						.elementToBeClickable(priority_menu));
				action.moveToElement(priority_menu).click().perform();

				new WebDriverWait(webApp.getDriver(), 25).until(ExpectedConditions
						.elementToBeClickable(driver.findElement(By.xpath("//*[@class='priorities' and contains(text(),'Create New Scheme')]"))));
				action.moveToElement(driver.findElement(By.xpath("//*[@class='priorities' and contains(text(),'Create New Scheme')]"))).click().perform();

				webApp.waitForPageLoad(driver);

				// set values in the Priority Scheme modal
				webApp.PrioritySchemeModal.setName(priorityName);

				// set user uploaded field weights
				webApp.PrioritySchemeModal.setUserUploadWeights();

				// setup CWE tab
				webApp.PrioritySchemeModal.fillCWETab();
				webApp.PrioritySchemeModal.modifyCWEPrioritySchemaWithUserUpload();
				webApp.waitForPageLoad(driver);

				// setup CERT tab
				webApp.PrioritySchemeModal.fillCERTTab();
				webApp.PrioritySchemeModal.modifyCERTPrioritySchemaWithUserUpload();
				webApp.waitForPageLoad(driver);

				// generate the formula to calculate the priority
				webApp.PrioritySchemeModal.genFormula();

				// save priority scheme
				webApp.PrioritySchemeModal.saveScheme();

				// run priority scheme
				webApp.PrioritySchemeModal.runScheme();

				webApp.waitForPageLoad(driver);

				try {
					Thread.sleep(5000);
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}

				String classifierName = "classifierScheme1";
				// WORKAROUND: Implement a better way!
				// Check to ensure the test classifier does not exist, if it does delete it first before running the rest of the test.
				// TODO: Discuss DB mocks or an easier way to delete the classifier after it has been created (currently deleting between running tests)
				// Removing just the project doesn't remove the classifier scheme.
				List<WebElement> classifierList = driver.findElements(By.xpath("//li[@id='classifier-dropdown']//ul//li//a"));
				WebElement removeClassifier = null;

				if(classifierList.size() > 1) {
					for (WebElement c : classifierList) {
						if(c.getAttribute("innerHTML").contentEquals(classifierName)){
							removeClassifier = c;
						}
					}
				}

				if(removeClassifier != null) {
					removeModalContents(removeClassifier, "classifier", driver);
				}

				webApp.waitForAlertConditionsTableLoad();

				try {
					Thread.sleep(5000);
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				webApp.waitForAlertConditionsTableLoad();

				WebElement classifierTextElem = webApp.getDriver().findElement(By.id("classifier_instance_chosen"));
				Select select = new Select(classifierTextElem);
				WebElement option = select.getFirstSelectedOption();

				String classifierSelectText = option.getText();
				assertEquals(classifierSelectText, "-Select Classifier Instance-");

				// Open the modal and verify the results.
				action = new Actions(driver);

				// Hover over classifier dropdown and open a new classifier modal

				new WebDriverWait(webApp.getDriver(), 40).until(ExpectedConditions
						.elementToBeClickable(By.xpath("//li[@id='classifier-dropdown']//a")));
				action.moveToElement(driver.findElement(By.xpath("//li[@id='classifier-dropdown']//a"))).click().perform();

				new WebDriverWait(webApp.getDriver(), 40).until(ExpectedConditions
						.elementToBeClickable(By.xpath("//li[@id='new-classifier-link']//a")));
				action.moveToElement(driver.findElement(By.xpath("//li[@id='new-classifier-link']//a"))).perform();

				new WebDriverWait(webApp.getDriver(), 40).until(ExpectedConditions
						.visibilityOfElementLocated(By.className("classifiers")));
				action.moveToElement(driver.findElements(By.className("classifiers")).get(0)).click().perform();

				// Classifier Modal is opened
				new WebDriverWait(webApp.getDriver(), 30).until(ExpectedConditions
						.visibilityOfElementLocated(By.id("modal-placement")));
				WebElement modal_close_button = driver.findElement(By.id("classifier-class-modal"));

				// set values in the Classifier Modal
				driver.findElement(By.id("classifier_name")).sendKeys(classifierName);

				WebElement projectSelected = driver.findElements(By.xpath("//div[@id='all_projects']//li[@class='list_item']")).get(0);
				projectSelected.click();

				// Add projects to the selected projects section
				WebElement add_button = driver.findElement(By.id("add_button"));

				new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions.elementToBeClickable(add_button));
				add_button.click();

				new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions.presenceOfAllElementsLocatedBy(By.xpath("//div[@id='ah']//li[@class='ah-tabs ']//a")));

				// Select an adaptive heuristic
				List<WebElement> ahList = driver.findElements(By.xpath("//div[@id='ah']//li[@class='ah-tabs ']//a"));
				WebElement ahSelected = ahList.get(1);

				scrollIntoView(driver, ahSelected);
				ahSelected.click();

				// Selected an AHPO
				Select ahpo_select = new Select(driver.findElement(By.id("ahpoSelects")));
				ahpo_select.selectByVisibleText("sei-ahpo");

				WebElement submit_button = driver.findElement(By.id("submit-modal"));
				submit_button.click();


				// Verify the results
				webApp.waitForAlertConditionsTableLoad();

				WebElement classifierTextSelect = webApp.getDriver().findElement(By.id("classifier_instance_chosen"));
				Select classifier_select = new Select(classifierTextSelect);
				classifier_select.selectByVisibleText(classifierName);

				// classify
				new WebDriverWait(webApp.getDriver(), 10).until(
						ExpectedConditions.elementToBeClickable(
								By.id("run-classifier-btn")));
				driver.findElement(By.id("run-classifier-btn")).click();
				webApp.waitForAlertConditionsTableLoad();

				// NOTE: this step is unnecessary, DB is directly loaded since
				// this test runs in the local scenario
				//
				// export the newly-created project to default download directory
				/*
				webApp.goHome();
				ProjectRow pr = webApp.Home.getProjectRowByName(projectName);
				pr.exportDbLink.click();
				*/

				// test exported db
				String noSanitizeOption = "--sanitizer-no-sanitize";
				runTestSanitizerScript(testPyScript, projectName, keepTestProject, noSanitizeOption);


				// test sanitized db
				noSanitizeOption = "";
				runTestSanitizerScript(testPyScript, projectName, keepTestProject, noSanitizeOption);

				try {
					Thread.sleep(10000);
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}

				} finally {
					if (keepTestProject) {
				webApp.goHome();
			webApp.driver.quit();
			webApp.close();
			} else {
				cleanupWebApp(webApp, projectName);
			}
		}
	}

	/**
	 * helper method to remove classifiers or prioritization schemes if they exist in the DB prior to running the
	 *
	 * @throws InterruptedException
	 */
	private void removeModalContents(WebElement removeObject, String objectType, WebDriver driver) throws InterruptedException{
		//Classifier or Prioritization Scheme exists, remove the object from the DB with the Browser
			Actions removeAction = new Actions(driver);
			WebElement deleteBtn = null;

			if(objectType == "classifier") {
				new WebDriverWait(driver, 40).until(ExpectedConditions.visibilityOf(driver.findElement(By.xpath("//li[@id='classifier-dropdown']//a"))));
				removeAction.moveToElement(driver.findElement(By.xpath("//li[@id='classifier-dropdown']//a"))).click().perform();

				new WebDriverWait(driver, 40).until(ExpectedConditions.visibilityOf(removeObject));
				removeAction.moveToElement(removeObject).click().perform();

				new WebDriverWait(driver, 30).until(ExpectedConditions.visibilityOf(driver.findElement(By.id("modal-placement"))));
				driver.findElement(By.id("delete-modal")).click();

			} else if (objectType == "priorityScheme") {
				new WebDriverWait(driver, 40).until(ExpectedConditions.visibilityOf(driver.findElement(By.xpath("//li[@id='priorityscheme-dropdown']//a"))));
				removeAction.moveToElement(driver.findElement(By.xpath("//li[@id='priorityscheme-dropdown']//a"))).click().perform();

				new WebDriverWait(driver, 40).until(ExpectedConditions.visibilityOf(removeObject));
				removeAction.moveToElement(removeObject).click().perform();

				new WebDriverWait(driver, 30).until(ExpectedConditions.visibilityOf(driver.findElement(By.id("priority-scheme-modal"))));
				driver.findElement(By.id("delete-priority-modal")).click();
			}

			new WebDriverWait(driver, 2).until(ExpectedConditions.alertIsPresent());
			Alert alert = driver.switchTo().alert();
			alert.accept();

	}

	public void runTestSanitizerScript(String testPyScript, String projectName, boolean keepTestProject, String noSanitizeOption) {
		ProcessBuilder pb = null;
		if (keepTestProject) {
			pb = new ProcessBuilder("pytest", testPyScript, "-s", "-k", "TestSanitizer", "--sanitizer-project=" + projectName, "--sanitizer-keep", noSanitizeOption);
		}
		else {
			pb = new ProcessBuilder("pytest", testPyScript, "-s", "-k", "TestSanitizer", "--sanitizer-project=" + projectName, noSanitizeOption);
		}
		pb = pb.redirectErrorStream(true);
		try {
			Process proc = pb.start();
			InputStream is = proc.getInputStream();
			BufferedReader br = new BufferedReader(new InputStreamReader(is));
			String line = null;
			String err = "";
			while ((line = br.readLine()) != null) {
				err += "\n" + line;
			}
			int rc = proc.waitFor();
			if (rc != 0) {
				System.err.println(err);
			}
			assertEquals(err, 0, rc);
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

}
