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
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
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
import scale_webapp.test.infra.ScaleWebApp;
import scale_webapp.test.infra.ScaleWebApp.AlertConditionsViewerPage.AlertConditionRow;
import scale_webapp.test.infra.ScaleWebApp.AlertConditionsViewerPage.FilterElems;
import scale_webapp.test.infra.ScaleWebApp.AlertConditionsViewerPage.FilterValues;
import scale_webapp.test.infra.ScaleWebApp.HomePage.ProjectRow;
import scale_webapp.test.infra.ScaleWebApp.ToolRow;
import scale_webapp.test.infra.ScaleWebApp.Verdict;
import scale_webapp.test.infra.ToolInfo;

/**
 * Unit tests for core web app functionality.
 */
public class TestWebAppCoreScenariosRemote extends TestCase {
	private AppConfig config;
	private LocalWebServer server;

	/**
	 * Class Constructor
	 *
	 * @param testName
	 */
	public TestWebAppCoreScenariosRemote(String testName) {
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
		return new TestSuite(TestWebAppCoreScenariosRemote.class);
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

	/**
	 * check that all of the filters are cleared
	 *
	 * @param webApp
	 */
	public void checkFiltersCleared(ScaleWebApp webApp) {
		FilterValues fVals = webApp.AlertConditionsViewer.getFilterValues();

		assertEquals("All IDs", fVals.idTypeFilter);
		assertEquals("", fVals.idFilter);
		assertEquals("-1", fVals.verdictFilter);
		assertEquals("-1", fVals.prevFilter);
		assertEquals("", fVals.pathFilter);
		assertEquals("", fVals.lineFilter);
		assertEquals("", fVals.checkerFilter);
		assertEquals("", fVals.toolFilter);
		assertEquals("", fVals.conditionFilter);
		assertEquals("View All", fVals.taxFilter);
		assertEquals("desc", fVals.sortDir);
		assertEquals("meta_alert_priority", fVals.sortBy);
	}

	/**
	 * check that the filter values match the values given in the method
	 * arguments
	 *
	 * @param webApp
	 * @param checker
	 * @param condition
	 * @param id
	 * @param idType
	 * @param line
	 * @param path
	 * @param prev
	 * @param sortBy
	 * @param sortDir
	 * @param tax
	 * @param tool
	 * @param verdict
	 */
	public void checkFilterValues(ScaleWebApp webApp, String checker,
			String condition, String id, String idType, String line,
			String path, String prev, String sortBy, String sortDir,
			String tax, String tool, String verdict) {
		FilterValues fVals = webApp.AlertConditionsViewer.getFilterValues();
		assertEquals(checker, fVals.checkerFilter);
		assertEquals(condition, fVals.conditionFilter);
		assertEquals(id, fVals.idFilter);
		assertEquals(idType, fVals.idTypeFilter);
		assertEquals(line, fVals.lineFilter);
		assertEquals(path, fVals.pathFilter);
		assertEquals(prev, fVals.prevFilter);
		assertEquals(sortBy, fVals.sortBy);
		assertEquals(sortDir, fVals.sortDir);
		assertEquals(tax, fVals.taxFilter);
		assertEquals(tool, fVals.toolFilter);
		assertEquals(verdict, fVals.verdictFilter);
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

			assertFalse(webApp.Home.getProjectNames().contains(projectName));
		} finally {
			cleanupWebApp( webApp, null);
		}
	}

	/**
	 * Test whether all alerts are uploaded to the webapp, from a given
	 * Fortify file and a zip archive.
	 */
	public void testAlertsPresentZip() {
		alertsPresent("dos2unix/dos2unix-7.2.2.zip");
	}

	/**
	 * Test whether all alerts are uploaded to the webapp, from a given
	 * Fortify file and a tgz archive
	 */
	public void testAlertsPresentTgz() {
		alertsPresent("dos2unix/dos2unix-7.2.2.tgz");
	}

	/**
	 * Test whether all alerts are uploaded to the webapp, from a given
	 * Fortify file and a tar.gz archive
	 */
	public void testAlertsPresentTarGz() {
		alertsPresent("dos2unix/dos2unix-7.2.2.tar.gz");
	}

	/**
	 * test that clearing filters after clicking on a checker link actually
	 * clears the filters
	 *
	 * @throws InterruptedException
	 */
	public void testCheckerLinkClearFilters() throws InterruptedException {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, "toy/toy.zip").toString();
		String rosePath = new File(this.config.inputDirectory, "toy/analysis/rosecheckers_oss.txt").toString();

		try {
			// Build a model of our Web App with the given driver.
			webApp = this.config.createApp();

			// Launch the app, create a project, then go back to the home page
			webApp.launch();
			webApp.createSimpleProject(projectName, projectDescription, archivePath, rosePath,
					ToolInfo.Rosecheckers_OSS_C_ID);
			webApp.waitForAlertConditionsTableLoad();
			AlertConditionRow row = webApp.AlertConditionsViewer.getOneAlertConditionRow(1);
			new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions
					.elementToBeClickable(By.linkText("DCL13-C")));
			webApp.getDriver().findElement(By.linkText("DCL13-C")).click();
			webApp.waitForAlertConditionsTableLoad();
			webApp.AlertConditionsViewer.clearFilter();
			webApp.waitForAlertConditionsTableLoad();
			checkFiltersCleared(webApp);

		} finally {
			cleanupWebApp(webApp, projectName);
		}
	}

	/**
	 * Test whether the checkboxes associated with tool output uploads
	 * are checked when the files are uploaded
	 */
	public void testToolOutputCheckbox() {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, "dos2unix/dos2unix-7.2.2.zip").toString();
		String gccPath = new File(this.config.inputDirectory, "dos2unix/analysis/gcc_oss.txt").toString();
		String cppCheckPath = new File(this.config.inputDirectory, "dos2unix/analysis/cppcheck_oss.xml").toString();

		try {
			webApp = this.config.createApp();
			webApp.launch();

			webApp.goHome();
			webApp.Home.getNewProjectLink().click();

			webApp.validatePage();
			webApp.NewProject.getNameField().sendKeys(projectName);
			webApp.NewProject.getDescriptionField().sendKeys(projectDescription);
			webApp.NewProject.getCreateProjectButton().click();

			webApp.UploadAnalysis.getArchiveUploader().sendKeys(archivePath);


			ToolRow cppCheckRow = webApp.UploadAnalysis.getToolRowById(ToolInfo.CPPCHECK_OSS_C_ID, false);
			cppCheckRow.uploadFile.sendKeys(cppCheckPath);

			assert(cppCheckRow.checkbox.isSelected());

			ToolRow gccRow = webApp.UploadAnalysis.getToolRowById(ToolInfo.GCC_OSS_C_ID, false);
			gccRow.uploadFile.sendKeys(gccPath);

			assert(gccRow.checkbox.isSelected());

		} finally {
			cleanupWebApp(webApp, projectName);
		}

	}

	/**
	 * test if alerts are present when creating project with the given input and
	 * fortixy_30.xml
	 *
	 * @param input
	 */
	private void alertsPresent(String input) {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, input).toString();
		String fortifyPath = new File(this.config.inputDirectory, "dos2unix/analysis/fortify_30.xml").toString();

		try {
			webApp = this.config.createApp();
			webApp.launch();
			webApp.createSimpleProject(projectName, projectDescription, archivePath, fortifyPath,
					ToolInfo.Fortify_C_ID);

			int count = 0;
			do {
				for (AlertConditionRow r : webApp.AlertConditionsViewer.getAlertConditionRows()) {
					count++;
					if (!r.message.getText().startsWith("Message"))
						fail("Invalid message");
					// count scrambled
					//assertEquals(count + "", r.line.getText());
					assertEquals("fortify", r.tool.getText());
					assertTrue(r.path.getText().endsWith("common.c"));
					assertEquals("[Unknown]", r.verdict.getText());
					assertEquals("0", r.previous.getText());
					assertEquals("[ ]", r.flag.getText());
				}
			} while (webApp.AlertConditionsViewer.goToNextPage());
			assertEquals(30, count);
		} finally {
			cleanupWebApp( webApp, projectName);
		}

	}

	/**
	 * Test whether all alerts are uploaded to the webapp, from a given
	 * Fortify file.
	 * @throws InterruptedException
	 */
	public void testTwoUpload() throws InterruptedException {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, "dos2unix/dos2unix-7.2.2.zip").toString();
		String coverityPath = new File(this.config.inputDirectory, "dos2unix/analysis/coverity_1.json").toString();
		String fortifyPath = new File(this.config.inputDirectory, "dos2unix/analysis/fortify_10.xml").toString();
		int numRowsExpected = 12;
		try {


			webApp = this.config.createApp();
			webApp.launch();
			webApp.goHome();
			webApp.Home.getNewProjectLink().click();
			webApp.validatePage();
			webApp.NewProject.getNameField().sendKeys(projectName);
			webApp.NewProject.getDescriptionField().sendKeys(projectDescription);
			webApp.NewProject.getCreateProjectButton().click();
			webApp.validatePage();

			webApp.UploadAnalysis.getArchiveUploader().sendKeys(archivePath);
			ToolRow toolRow;
			toolRow = webApp.UploadAnalysis.getToolRowById(ToolInfo.Coverity_C_ID, false);
			toolRow.checkbox.click();
			toolRow.uploadFile.sendKeys(coverityPath);
			toolRow = webApp.UploadAnalysis.getToolRowById(ToolInfo.Fortify_C_ID, false);
			toolRow.checkbox.click();
			toolRow.uploadFile.sendKeys(fortifyPath);

			webApp.UploadAnalysis.getCreateDatabaseButton().click();
			webApp.validatePage();

			new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions.elementToBeClickable(webApp.UploadAnalysis.getCreateProjectFromDatabaseButton()));
			webApp.UploadAnalysis.getCreateProjectFromDatabaseButton().click();
			webApp.validatePage();

			webApp.waitForAlertConditionsTableLoad();

			int count = 0;
			do {
				count += webApp.AlertConditionsViewer.getAlertConditionRows().size();
			} while (webApp.AlertConditionsViewer.goToNextPage());
			assertEquals(numRowsExpected, count);
		} finally {
			cleanupWebApp( webApp, projectName);
		}
	}

	/**
	 * set a filter to a non-default value and filter. Then set that filter
	 * back to the default value and filter, check that the filter filters by
	 * that default value
	 *
	 * @throws InterruptedException
	 */
	public void testFilterBackToDefault() throws InterruptedException {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, "toy/toy.zip").toString();
		String rosecheckersPath = new File(this.config.inputDirectory, "toy/analysis/rosecheckers_oss.txt").toString();
		try {
			webApp = this.config.createApp();
			webApp.launch();
			webApp.createSimpleProject(projectName, projectDescription, archivePath, rosecheckersPath,
					ToolInfo.Rosecheckers_OSS_C_ID);
			webApp.validatePage();
			webApp.waitForAlertConditionsTableLoad();
			webApp.AlertConditionsViewer.clearFilter();
			webApp.waitForAlertConditionsTableLoad();
			WebDriver driver = webApp.getDriver();

			//number of Meta-Alerts with default filters
			int dNumRows = Integer.parseInt(driver.findElement(
					By.id("totalRecords")).getText());

			//get default filter values
			FilterValues fVals = webApp.AlertConditionsViewer.getFilterValues();
			String dChecker = fVals.checkerFilter;
			String dCondition = fVals.conditionFilter;
			String dId = fVals.idFilter;
			String dIdType = fVals.idTypeFilter;
			String dLine = fVals.lineFilter;
			String dPath = fVals.pathFilter;
			String dPrev = fVals.prevFilter;
			String dSortBy = fVals.sortBy;
			String dSortDir = fVals.sortDir;
			String dTax = fVals.taxFilter;
			String dTool = fVals.toolFilter;
			String dVerdict = fVals.verdictFilter;

			//set all of the filters
			String checker = "DCL00-C";
			String condition = "DCL00-C";
			String id = "1";
			String idType = "Display (d) ID";
			String line = "1";
			String path = "/ARR36-C/arr36-c-false-1.c";
			String prev = "0";
			String sortBy = "id";
			String sortDir = "asc";
			String tax = "CERT Rules";
			String tool = "rosecheckers_oss";
			String verdict = "0";

			FilterElems filterElems = webApp.AlertConditionsViewer.getFilterElems();
			filterElems.checkerFilter.selectByValue(checker);
			filterElems.conditionFilter.selectByValue(condition);
			filterElems.idFilter.sendKeys(new String[]{id});
			filterElems.idTypeFilter.selectByValue(idType);
			filterElems.lineFilter.sendKeys(new String[]{line});
			filterElems.pathFilter.sendKeys(new String[]{path});
			filterElems.prevFilter.selectByValue(prev);
			filterElems.sortBy.selectByValue(sortBy);
			filterElems.sortDir.selectByValue(sortDir);
			filterElems.taxFilter.selectByValue(tax);
			filterElems.toolFilter.selectByValue(tool);
			filterElems.verdictFilter.selectByValue(verdict);
			new WebDriverWait(webApp.getDriver(), 30).until(ExpectedConditions
					.elementToBeClickable(By.xpath("//input[@value='Filter']")));
			webApp.getDriver().findElement(
					By.xpath("//input[@value='Filter']")).click();
			webApp.waitForAlertConditionsTableLoad();

			//set all filters back to default values without using clear
			//filter button
			filterElems = webApp.AlertConditionsViewer.getFilterElems();
			filterElems.checkerFilter.selectByValue(dChecker);
			filterElems.conditionFilter.selectByValue(dCondition);
			filterElems.idFilter.clear();
			filterElems.idFilter.sendKeys(new String[]{dId});
			filterElems.idTypeFilter.selectByValue(dIdType);
			filterElems.lineFilter.clear();
			filterElems.lineFilter.sendKeys(new String[]{dLine});
			filterElems.pathFilter.clear();
			filterElems.pathFilter.sendKeys(new String[]{dPath});
			filterElems.prevFilter.selectByValue(dPrev);
			filterElems.sortBy.selectByValue(dSortBy);
			filterElems.sortDir.selectByValue(dSortDir);
			filterElems.taxFilter.selectByValue(dTax);
			filterElems.toolFilter.selectByValue(dTool);
			filterElems.verdictFilter.selectByValue(dVerdict);
			new WebDriverWait(webApp.getDriver(), 30).until(ExpectedConditions
					.elementToBeClickable(By.xpath("//input[@value='Filter']")));
			webApp.getDriver().findElement(
					By.xpath("//input[@value='Filter']")).click();
			webApp.waitForAlertConditionsTableLoad();

			//number of meta-alerts after setting filters to default without
			//using clear filters button
			int numRows = Integer.parseInt(driver.findElement(
					By.id("totalRecords")).getText());

			assertEquals(dNumRows,numRows);

		} finally {
			//clear the filters for other tests
			webApp.AlertConditionsViewer.clearFilter();
			cleanupWebApp(webApp, projectName);
		}
	}

	/**
	 * Test filtering alerts by taxonomy (CWEs, Cert Rules)
	 * @throws InterruptedException
	 */
	public void testFilterByTaxonomy() throws InterruptedException {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, "dos2unix/dos2unix-7.2.2.zip").toString();
		String coverityPath = new File(this.config.inputDirectory, "dos2unix/analysis/coverity.json").toString();
		String fortifyPath = new File(this.config.inputDirectory, "dos2unix/analysis/fortify.xml").toString();

		try {

			webApp = this.config.createApp();
			WebDriver driver = webApp.getDriver();
			webApp.launch();
			webApp.goHome();
			webApp.Home.getNewProjectLink().click();
			webApp.validatePage();
			webApp.NewProject.getNameField().sendKeys(projectName);
			webApp.NewProject.getDescriptionField().sendKeys(projectDescription);
			webApp.NewProject.getCreateProjectButton().click();
			webApp.validatePage();

			webApp.UploadAnalysis.getArchiveUploader().sendKeys(archivePath);
			ToolRow toolRow;
			toolRow = webApp.UploadAnalysis.getToolRowById(ToolInfo.Coverity_C_ID, false);
			toolRow.checkbox.click();
			toolRow.uploadFile.sendKeys(coverityPath);
			toolRow = webApp.UploadAnalysis.getToolRowById(ToolInfo.Fortify_C_ID, false);
			toolRow.checkbox.click();
			toolRow.uploadFile.sendKeys(fortifyPath);

			webApp.UploadAnalysis.getCreateDatabaseButton().click();
			webApp.validatePage();

			new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions.elementToBeClickable(webApp.UploadAnalysis.getCreateProjectFromDatabaseButton()));
			webApp.UploadAnalysis.getCreateProjectFromDatabaseButton().click();
			webApp.validatePage();

			webApp.waitForAlertConditionsTableLoad();

			Select taxonomyMenu = new Select(driver.findElement(By.id("taxonomy")));

			/*Test All */

			int numRowsExpected = 65;
			int rowsDisplayed = Integer.parseInt(driver.findElement(By.id("totalRecords")).getText());

			assertEquals(rowsDisplayed, numRowsExpected);

			/*Test CWEs */

			String taxonomy = "CWEs";
			try {
				taxonomyMenu.selectByVisibleText(taxonomy);
			} catch (org.openqa.selenium.NoSuchElementException e) {
				throw new NoSuchElementException("Cannot make taxonomy selection " + taxonomy);

			}
			webApp.AlertConditionsViewer.filter();

			new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions.visibilityOf(driver.findElement(By.id("totalRecords"))));
			numRowsExpected = 29;
			rowsDisplayed = Integer.parseInt(driver.findElement(By.id("totalRecords")).getText());

			assertEquals(rowsDisplayed, numRowsExpected);

			/*Test CERT rules */

			taxonomy = "CERT Rules";
			try {
				taxonomyMenu.selectByVisibleText(taxonomy);
			} catch (org.openqa.selenium.NoSuchElementException e) {
				throw new NoSuchElementException("Cannot make taxonomy selection " + taxonomy);

			}
			webApp.AlertConditionsViewer.filter();

			new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions.visibilityOf(driver.findElement(By.id("totalRecords"))));
			numRowsExpected = 36;
			rowsDisplayed = Integer.parseInt(driver.findElement(By.id("totalRecords")).getText());

			assertEquals(rowsDisplayed, numRowsExpected);

		} finally {
			cleanupWebApp( webApp, projectName);
		}
	}

	/**
	 * Test filtering by taxonomy CWEs for a project with rosecheckers
	 * toy with rosecheckers has no CWEs, filtering by CWE should result in
	 * no meta-alerts
	 *
	 * @throws InterruptedException
	 */
	public void testFilterByTaxonomyRose() throws InterruptedException {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, "toy/toy.zip").toString();
		String rosePath = new File(this.config.inputDirectory, "toy/analysis/rosecheckers_oss.txt").toString();

		try {
			// Build a model of our Web App with the given driver.
			webApp = this.config.createApp();

			// Launch the app, create a project, then go back to the home page
			webApp.launch();
			webApp.createSimpleProject(projectName, projectDescription, archivePath, rosePath,
					ToolInfo.Rosecheckers_OSS_C_ID);

			webApp.waitForAlertConditionsTableLoad();
			int totalRecords = Integer.parseInt(webApp.getDriver()
					.findElement(By.id("totalRecords")).getText());

			assertEquals(41, totalRecords);

			String taxonomy = "CWEs";
			Select taxonomyMenu = new Select(webApp.getDriver().findElement(By.id("taxonomy")));
			try {
				taxonomyMenu.selectByVisibleText(taxonomy);
			} catch (org.openqa.selenium.NoSuchElementException e) {
				throw new NoSuchElementException("Cannot make taxonomy selection " + taxonomy);

			}
			webApp.AlertConditionsViewer.filter();
			webApp.waitForAlertConditionsTableLoad();
			totalRecords = Integer.parseInt(webApp.getDriver()
					.findElement(By.id("totalRecords")).getText());

			assertEquals(0, totalRecords);

		} finally {
			cleanupWebApp(webApp, projectName);
		}
	}

	/**
	 * Test that I can create a new alert.
	 */
	public void testNewAlert() {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, "dos2unix/dos2unix-7.2.2.zip").toString();
		String fortifyPath = new File(this.config.inputDirectory, "dos2unix/analysis/fortify_30.xml").toString();

		try {
			webApp = this.config.createApp();

			webApp.launch();
			webApp.createSimpleProject(projectName, projectDescription, archivePath, fortifyPath,
					ToolInfo.Fortify_C_ID);
			WebDriver driver = webApp.getDriver();

			webApp.validatePage();

			webApp.AlertConditionsViewer.newAlert();
			String alert_id = webApp.NewAlert.getAlertIdField().getAttribute("value");
			String meta_alert_id = webApp.NewAlert.getMetaAlertIdField().getAttribute("value");

			webApp.NewAlert.getNotesField().sendKeys("testnotes");
			webApp.NewAlert.getPathField().sendKeys("testpath");
			webApp.NewAlert.getLineField().sendKeys("1");
			webApp.NewAlert.getMessageField().sendKeys("testmessage");
			webApp.NewAlert.getCheckerField().clear();
			webApp.NewAlert.getCheckerField().sendKeys("testchecker");
			webApp.NewAlert.getToolField().clear();
			webApp.NewAlert.getToolField().sendKeys("testtool");
			webApp.NewAlert.getConditionField().sendKeys("FIO30-C");
			webApp.NewAlert.getTitleField().sendKeys("testtitle");

			webApp.NewAlert.getConfidenceField().sendKeys("0");
			webApp.NewAlert.getSeverityField().sendKeys("1");
			webApp.NewAlert.getLikelihoodField().sendKeys("2");
			webApp.NewAlert.getRemediationField().sendKeys("3");
			webApp.NewAlert.getPriorityField().sendKeys("4");
			webApp.NewAlert.getLevelField().sendKeys("5");
			webApp.NewAlert.getCweLikelihoodField().sendKeys("6");

			webApp.NewAlert.getCreateButton().click();
			webApp.validatePage();


			webApp.AlertConditionsViewer.getIdFilter().clear();
			webApp.AlertConditionsViewer.getIdFilter().sendKeys(meta_alert_id);



			Select id_menu = new Select(driver.findElement(By.id("id_type")));

			String id_type = "Meta-Alert (m) ID";
			try {
				id_menu.selectByVisibleText(id_type);
			} catch (org.openqa.selenium.NoSuchElementException e) {
				throw new NoSuchElementException("Cannot make id selection " + id_type);
			}



			webApp.AlertConditionsViewer.filter();
			webApp.validatePage();


			(new WebDriverWait(webApp.getDriver(), 10)).until(new ExpectedCondition<Boolean>() {
				public Boolean apply(WebDriver d) {
					// There should be just two rows, the header and the new
					// alert
					return d.findElements(By.tagName("tr")).size() == 2;
				}
			});

			AlertConditionRow row = webApp.AlertConditionsViewer.getOneAlertConditionRow(1);
			assertEquals("99", row.metaAlertID);
			assertEquals("testpath", row.path.getText());
			assertEquals("1", row.line.getText());
			assertEquals("testmessage", row.message.getText());
			assertEquals("FIO30-C", row.condition.getText());
			assertEquals("testtitle", row.title.getText());
			assertEquals("testchecker", row.checker.getText());
			assertEquals("testtool", row.tool.getText());
			assertEquals("0.0", row.confidence.getText());
			assertEquals("", row.meta_alert_priority.getText());
			assertEquals("1", row.sev.getText());
			assertEquals("2", row.lik.getText());
			assertEquals("3", row.rem.getText());
			assertEquals("4", row.pri.getText());
			assertEquals("5", row.lev.getText());
			assertEquals("6", row.cwe_lik.getText());
			assertEquals("testnotes", row.notes.getText());

		} finally {
			cleanupWebApp( webApp, projectName);
		}
	}

	/**
	 * test editing CERT alert fields
	 *
	 * @throws InterruptedException
	 */
	public void testEditingCertAlertConditionFields() throws InterruptedException{
		// Need to edit a file with 10 non-fused alertConditions
		editAlertConditionFields("dos2unix/analysis/fortify_10.xml", ToolInfo.Fortify_C_ID);
	}

	/**
	 * test editing CWE alert fields
	 *
	 * @throws InterruptedException
	 */
	public void testEditingCweAlertConditionFields() throws InterruptedException{
		// Need to edit a file with 10 non-fused alertConditions
		editAlertConditionFields("dos2unix/analysis/cppcheck_oss_5.xml", ToolInfo.CPPCHECK_OSS_C_ID);
	}


	/**
	 * get rows with sharedIds for the given webaApp
	 *
	 * @param webApp
	 * @return set of shared ids
	 */
	public Set<String> getRowsWithSharedIds(ScaleWebApp webApp){

		Set<String> seenIds = new HashSet<String>();
		Set<String> sharedIds = new HashSet<String>();
		for (AlertConditionRow row : webApp.AlertConditionsViewer.getAlertConditionRows()) {

			String id = row.metaAlertID;
			if(seenIds.contains(id)){
				sharedIds.add(id);
			}
			seenIds.add(row.metaAlertID);
		}
		return sharedIds;

	}
	/**
	 * Test setting flags, verdicts, supplemental tags,
	 * and notes on the alertCondition viewer page.
	 * @throws InterruptedException
	 */
	private void editAlertConditionFields(String resultsFilepath, String checkerID) throws InterruptedException {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, "dos2unix/dos2unix-7.2.2.zip").toString();
		String resultsPath = new File(this.config.inputDirectory, resultsFilepath).toString();
		WebDriver driver = null;

		try {
			webApp = this.config.createApp();
			driver = webApp.getDriver();
			webApp.launch();
			webApp.createSimpleProject(projectName, projectDescription, archivePath, resultsPath,
					checkerID);

			webApp.validatePage();

			Verdict[] verdicts = Verdict.values();
			int curVerdict = 0;
			boolean flag = false;
			String[] dcTexts = webApp.AlertConditionsViewer.getSupplementalOptions();

			Set<String> sharedIds = getRowsWithSharedIds(webApp);
			int rowsViewed = 0;
			int totalRows = webApp.AlertConditionsViewer.getTotalRecords();

			for (int rowCounter = 1; rowCounter <= totalRows; rowCounter++) {
				AlertConditionRow row = webApp.AlertConditionsViewer.getOneAlertConditionRow(rowCounter);
				if (row == null) { break; }

				String alert_id = (String) row.alertID;
				String meta_alert_id = row.metaAlertID;;

				//skip rows with the same id because the app requires that they contain the same editable fields
				if(sharedIds.contains(meta_alert_id)){
					continue;
				}
				//select alternating options for flag
				if (flag) {
					row.flag.click();
					// Avoid Stale Reference
					row = webApp.AlertConditionsViewer.waitForRowRefresh(row);
				}
				flag = !flag;

				//select a rotating verdict based on curVerdict
				String verdictText = row.verdict.getText();
				Verdict oldVerdict = Verdict.valueOf(verdictText.substring(1,verdictText.length()-1));
				if (! oldVerdict.equals(verdicts[curVerdict])) {
					row.setVerdict(verdicts[curVerdict]);
					// Avoid Stale Reference
					row = webApp.AlertConditionsViewer.waitForRowRefresh(row);
				}

				curVerdict = (curVerdict + 1) % verdicts.length;

				new WebDriverWait(driver, 50).until(ExpectedConditions.visibilityOf(row.supplemental));
				// find and press the supplemental Edit button
				WebElement supp = row.supplemental;
				WebElement edit_button = supp.findElement(By.tagName("a"));
				scrollIntoView(driver, row.id);
				edit_button = supp.findElement(By.tagName("a"));
				edit_button.click();

				new WebDriverWait(driver, 50).until(ExpectedConditions.visibilityOf(driver.findElement(By.id("myModal"))));
				scrollIntoView(driver, driver.findElement(By.id("myModal")));

				//f ind all the editable fields in the supplemental dialog
				// select a rotating subset of supplemental options depending on the counter.
				if ((rowCounter % 2) == 1) {
					new WebDriverWait(webApp.getDriver(), 20).until(ExpectedConditions.elementToBeClickable(By.id("ignored")));
					WebElement ignored_box = driver.findElement(By.id("ignored"));
					ignored_box.click();
				}
				if (((rowCounter/2) % 2) == 1) {
					new WebDriverWait(webApp.getDriver(), 20).until(ExpectedConditions.elementToBeClickable(By.id("dead")));
					WebElement dead_box = driver.findElement(By.id("dead"));
					dead_box.click();
				}
				if (((rowCounter/4) % 2) == 1) {
					new WebDriverWait(webApp.getDriver(), 20).until(ExpectedConditions.elementToBeClickable(By.id("ie")));
					WebElement ie_box = driver.findElement(By.id("ie"));
					ie_box.click();
				}

				// select a rotating risk level based on suppCounter
				String dcText = dcTexts[rowCounter%4];
				new WebDriverWait(webApp.getDriver(), 50).until(ExpectedConditions.elementToBeClickable(By.id("dc_select")));
				WebElement dc_select = driver.findElement(By.id("dc_select"));

				row.setDCLevel(dc_select, dcText);
				new WebDriverWait(webApp.getDriver(), 50).until(ExpectedConditions.elementToBeClickable(By.className("supplemental-close")));
				WebElement dialog_close_button = driver.findElement(By.className("supplemental-close"));

				dialog_close_button.click(); // close pop-up window

				// Avoid Stale Reference
				row = webApp.AlertConditionsViewer.waitForRowRefresh(row);

				WebElement notes_cell = row.notes;
				new WebDriverWait(driver, 50).until(ExpectedConditions.visibilityOf(notes_cell));

				WebElement existing_note = notes_cell.findElement(By.tagName("div")).findElement(By.tagName("span"));
				existing_note.click();

				WebElement notes_field = existing_note.findElement(By.tagName("textarea"));
				new WebDriverWait(driver, 50).until(ExpectedConditions.visibilityOf(notes_field));

				String test_notes = "test notes" + Integer.toString(rowCounter);
				notes_field.sendKeys(test_notes);
				notes_field.submit();

				// Avoid Stale Reference
				row = webApp.AlertConditionsViewer.waitForRowRefresh(row);

				rowsViewed++;

			}

			if (rowsViewed <= 0) { // No alertConditions with different meta-alert-ids were changed.
				Assert.fail();
			}
			webApp.goHome();
			ProjectRow pr = webApp.Home.getProjectRowByName(projectName);
			pr.nameLink.click();

			webApp.validatePage();
			webApp.waitForAlertConditionsTableLoad();

			curVerdict = 0;
			int rowCounter = 1;
			flag = false;

			for (AlertConditionRow r : webApp.AlertConditionsViewer.getAlertConditionRows()) {

				String verdictText = r.verdict.getText();
				String flagText = r.flag.getText();
				String suppText = r.supplemental.getText();
				String[] displayedDCTexts = {"","Low","Med","High"};
				String notesText = r.notes.getText();

				Verdict actualVerdict = Verdict.valueOf(verdictText.substring(1,verdictText.length()-1));
				boolean actualFlag = flagText.contains("x");
				boolean actualDead = suppText.contains("Dead");
				boolean actualIgnore= suppText.contains("Ignored");
				boolean actualIE = suppText.contains("Inapplicable");

				boolean expectedIgnore = ( (rowCounter % 2) == 1);
				boolean expectedDead = ( ((rowCounter/2) % 2) == 1);
				boolean expectedIE = ( ((rowCounter/4) % 2) == 1);
				String expectedDCText = displayedDCTexts[rowCounter%4];
				String expectedNotes = "0test notes" + Integer.toString(rowCounter); // not erased when new note entered

				assertEquals(verdicts[curVerdict], actualVerdict);
				assertEquals(flag, actualFlag);
				assertEquals(expectedIgnore, actualIgnore);
				assertEquals(expectedDead, actualDead);

				assertEquals(expectedIE, actualIE);
				assertEquals(expectedNotes, notesText);

				if (rowCounter%4 == 0){
					assert (! suppText.contains("Dangerous"));
				}
				else{
					assert suppText.contains(expectedDCText);
				}

				flag = !flag;
				curVerdict = (curVerdict + 1) % verdicts.length;
				rowCounter++;
			}
		} finally {
			cleanupWebApp( webApp, projectName);
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
	 * Test the "set all" functionality on the alerts viewer page.
	 *
	 * This test now seems like a duplicate of testMassUpdateFused
	 */
	public void testSetAllVerdictsAndFlags() {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, "dos2unix/dos2unix-7.2.2.zip").toString();
		String fortifyPath = new File(this.config.inputDirectory, "dos2unix/analysis/fortify_10.xml").toString();

		try {
			webApp = this.config.createApp();
			webApp.launch();
			WebDriver driver = webApp.getDriver();
			webApp.createSimpleProject(projectName, projectDescription, archivePath, fortifyPath,
					ToolInfo.Fortify_C_ID);
			webApp.waitForAlertConditionsTableLoad();
			webApp.AlertConditionsViewer.getSelectAll().click();
			driver.findElement(By.linkText("Set selected to")).click();
			webApp.waitForPageLoad(driver);
			new WebDriverWait(driver, 10).until(ExpectedConditions
				.elementToBeClickable(By.id("flag")));
			webApp.AlertConditionsViewer.getSelectAllFlag().selectByVisibleText("Flagged");
			new WebDriverWait(driver, 10).until(ExpectedConditions
					.elementToBeClickable(By.id("mass_update_verdict")));
			webApp.AlertConditionsViewer.getSelectAllVerdict().selectByVisibleText("Unknown");
			webApp.AlertConditionsViewer.update();
			webApp.validatePage();

			webApp.goHome();
			webApp.validatePage();
			ProjectRow pr = webApp.Home.getProjectRowByName(projectName);
			pr.nameLink.click();
			webApp.validatePage();

			for (AlertConditionRow r : webApp.AlertConditionsViewer.getAlertConditionRows()) {
				String verdictText = r.verdict.getText();
				String flagText = r.flag.getText();
				boolean isFlagged = flagText.contains("x");

				assertEquals("[Unknown]", verdictText);
				assertTrue(isFlagged);
			}
		} finally {
			cleanupWebApp( webApp, projectName);
		}
	}

	/**
	 * Test that massUpdate only updates alerts in the current project
	 *
	 * @throws InterruptedException
	 */
	public void testMassUpdateCurrentProjectOnly() throws InterruptedException {
		ScaleWebApp webApp = null;
		String projectNameOld = UUID.randomUUID().toString();
		String projectNameNew = UUID.randomUUID().toString();
		String verdict = "False";
		String flag = "Flagged";
		String ignored = "Ignored";
		String dead = "Dead";
		String ienv = "Yes";
		String dc = "Medium Risk";

		try {
			webApp = this.config.createApp();
			webApp.launch();
			WebDriver driver = webApp.getDriver();

			// Create new project
			String projectDescriptionNew = projectNameNew.hashCode() + "";
			String archivePathNew = new File(this.config.inputDirectory, "toy2/toy2.zip").toString();
			String alertPathNew = new File(this.config.inputDirectory, "toy2/analysis/rosecheckers2_oss.txt").toString();
			webApp.createSimpleProject(projectNameNew, projectDescriptionNew, archivePathNew, alertPathNew,
					ToolInfo.Rosecheckers_OSS_C_ID);

			// Now create old project
			webApp.goHome();
			String projectDescriptionOld = projectNameOld.hashCode() + "";
			String archivePathOld = new File(this.config.inputDirectory, "toy/toy.zip").toString();
			String alertPathOld = new File(this.config.inputDirectory, "toy/analysis/rosecheckers_oss.txt").toString();
			webApp.createSimpleProject(projectNameOld, projectDescriptionOld, archivePathOld, alertPathOld,
					ToolInfo.Rosecheckers_OSS_C_ID);
			webApp.validatePage();
			webApp.waitForPageLoad(driver);
			//massUpdate alerts in old project
			webApp.AlertConditionsViewer.changeAlertConditionsPerPage(100);
			webApp.waitForAlertConditionsTableLoad();
			webApp.AlertConditionsViewer.getSelectAll().click();
			webApp.AlertConditionsViewer.setMassUpdateDets(verdict, flag, ignored, dead, ienv, dc);
			webApp.AlertConditionsViewer.changeAlertConditionsPerPage(100);

			//check new project to make sure verdicts haven't been erroneously changed
			webApp.goHome();
			driver.findElement(By.linkText(projectNameNew)).click();
			for (AlertConditionRow r : webApp.AlertConditionsViewer.getAlertConditionRows()) {
				String verdictText = r.verdict.getText();
				String supText = r.supplemental.getText();

				assertEquals("[Unknown]", verdictText);
				assertEquals("Edit", supText);
			}

		} finally {
			cleanupWebApp(webApp, projectNameOld);
			cleanupWebApp(webApp, projectNameNew);
		}
	}

	/**
	 * Test that massUpdate updates all sub-alerts in fused alertConditions
	 */
	public void testMassUpdateFused() throws InterruptedException {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, "dos2unix/dos2unix-7.2.2.zip").toString();
		String coverityPath = new File(this.config.inputDirectory, "dos2unix/analysis/coverity.json").toString();
		String fortifyPath = new File(this.config.inputDirectory, "dos2unix/analysis/fortify.xml").toString();
		String verdict = "False";
		String flag = "Flagged";
		String ignored = "Ignored";
		String dead = "Dead";
		String ienv = "Yes";
		String dc = "Medium Risk";

		try {
			webApp = this.config.createApp();
			webApp.createProjectWithFusion(projectName,
			projectDescription, archivePath, coverityPath, fortifyPath);
			WebDriver driver = webApp.getDriver();
			webApp.AlertConditionsViewer.changeAlertConditionsPerPage(100);
			webApp.waitForAlertConditionsTableLoad();

			webApp.AlertConditionsViewer.getSelectAll().click();
			webApp.AlertConditionsViewer.setMassUpdateDets(verdict, flag, ignored, dead, ienv, dc);
			webApp.waitForAlertConditionsTableLoad();

			WebElement fusedOffButton = webApp.getDriver().findElement(By.id("fused_off_button"));
			new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions
					.refreshed(ExpectedConditions
					.elementToBeClickable(fusedOffButton)));
			fusedOffButton.click();
			webApp.validatePage();
			webApp.waitForAlertConditionsTableLoad();
			webApp.AlertConditionsViewer.changeAlertConditionsPerPage(100);
			webApp.validatePage();
			webApp.waitForAlertConditionsTableLoad();

			for (AlertConditionRow r : webApp.AlertConditionsViewer.getAlertConditionRows()) {
				String verdictText = r.verdict.getText();
				String flagText = r.flag.getText();
				boolean isFlagged = flagText.contains("x");
				String supText = r.supplemental.getText();
				String expectedSupText = "Ignored\nDead\nInapplicable Env.\n"
					+ "Dangerous - Med\nEdit";
				assertEquals("[False]", verdictText);
				assertTrue(isFlagged);
				assertEquals(supText, expectedSupText);

			}
		} finally {
			cleanupWebApp( webApp, projectName);
		}
	}

	public void testMassUpdateSelectAllCheckbox() throws InterruptedException {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, "dos2unix/dos2unix-7.2.2.zip").toString();
		String srcPath = new File(this.config.inputDirectory, "dos2unix/analysis/rosecheckers_oss.txt").toString();

		try {
			// Build a model of our Web App with the given driver.
			webApp = this.config.createApp();

			// Launch the app, create a project, then go back to the home page
			webApp.launch();
			WebDriver driver = webApp.getDriver();
			webApp.createSimpleProject(projectName, projectDescription, archivePath, srcPath,
					ToolInfo.Rosecheckers_OSS_C_ID);
			webApp.AlertConditionsViewer.getSelectAllCheckbox().click();
			driver.findElement(By.linkText("Set selected to")).click();
			webApp.waitForPageLoad(driver);
			new WebDriverWait(driver, 10).until(ExpectedConditions
					.elementToBeClickable(By.id("flag")));
			webApp.AlertConditionsViewer.getSelectAllFlag().selectByVisibleText("Flagged");
			new WebDriverWait(driver, 10).until(ExpectedConditions
					.elementToBeClickable(By.id("mass_update_verdict")));
			webApp.AlertConditionsViewer.getSelectAllVerdict().selectByVisibleText("False");
			webApp.AlertConditionsViewer.update();
			webApp.waitForPageLoad(webApp.getDriver());
			new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions
					.elementToBeClickable(By.id("select_all_checkbox")));

			assertEquals(null, webApp.AlertConditionsViewer.getSelectAllCheckbox().getAttribute("checked"));
		} finally {
			cleanupWebApp( webApp, projectName);
		}
	}

	/**
	 * Test that the source links work correctly on the alerts viewer page.
	 */
	public void IGNOREDtestSourceLinks() {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, "dos2unix/dos2unix-7.2.2.zip").toString();
		String fortifyPath = new File(this.config.inputDirectory, "dos2unix/analysis/fortify_10.xml").toString();
		WebDriver driver = null;

		try {
			webApp = this.config.createApp();
			driver = webApp.getDriver();
			webApp.launch();
			webApp.createSimpleProject(projectName, projectDescription, archivePath, fortifyPath,
					ToolInfo.Fortify_C_ID);

			for (AlertConditionRow row : webApp.AlertConditionsViewer.getAlertConditionRows()) {
				String lineText = row.line.getText();
				String pathText = row.path.getText();
				if (pathText.startsWith("/")) {
					pathText.replaceFirst("/", "");
				}

				// Click the source code link
				row.line.click();
				webApp.validatePage();

				// Switch to the source code frame
				driver.switchTo().frame("src_frame");
				WebElement globalPagesLine = driver.findElement(By.id("L" + lineText));
				String globalPagesPath = driver.findElement(By.className("header")).getText();

				// Make sure the page points to the right file, and that the
				// right line is highlighted
				assertTrue(globalPagesPath.endsWith(pathText));
				try {
					globalPagesLine.findElement(By.className("yellow-highlighter"));
				} catch (Exception e) {
					fail("Could not find element with class name 'yellow-highlighter'");
				}

				// Go back to the parent frame
				driver.switchTo().parentFrame();
			}

		} finally {
			cleanupWebApp( webApp, projectName);
		}
	}

	/**
	 * test meta alerts are fused correctly
	 *
	 * @throws InterruptedException
	 */
	public void testMetaAlertFusion() throws InterruptedException {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, "dos2unix/dos2unix-7.2.2.zip").toString();
		String coverityPath = new File(this.config.inputDirectory, "dos2unix/analysis/coverity.json").toString();
		String fortifyPath = new File(this.config.inputDirectory, "dos2unix/analysis/fortify.xml").toString();


		try {
			webApp = this.config.createApp();
			webApp.createProjectWithFusion(projectName, projectDescription,
					archivePath, coverityPath, fortifyPath);

			webApp.AlertConditionsViewer.changeAlertConditionsPerPage(100);

			//Retrieve meta alert
			String selected_meta_alert = "21 meta_alert alert-warning";

			webApp.waitForAlertConditionsTableLoad();
		//	new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions
		//		.visibilityOf(webApp.getDriver()
		//		.findElement(By.className("21"))));
			ArrayList<AlertConditionRow> rows = new ArrayList();
			int rowCount = 1;
			int metaAlertRow = -1;

			for (AlertConditionRow row : webApp.AlertConditionsViewer.getAlertConditionRows()) {
				String meta_alert_id = row.metaAlertID;

				if(selected_meta_alert.equals(meta_alert_id)){
					rows.add(row);
					if (metaAlertRow == -1) {
						metaAlertRow = rowCount;
					}
				}

				rowCount++;
			}

			AlertConditionRow metaAlertConditionRow = rows.get(0);

			String meta_alert_id = metaAlertConditionRow.metaAlertID;

			setVerdictInfo(metaAlertConditionRow, webApp, metaAlertRow, true);

			webApp.waitForAlertConditionsTableLoad();

			WebElement fusedOffButton = webApp.getDriver().findElement(By.id("fused_off_button"));
			new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions.elementToBeClickable(fusedOffButton));
			fusedOffButton.click();

			webApp.AlertConditionsViewer.changeAlertConditionsPerPage(500);
			//go to page with selected alert (FIXME...need better way to find selected alert)
			//for (int i = 0; i < 5; i++) {
			//	webApp.AlertConditionsViewer.goToNextPage();
			//	Thread.sleep(50);
			//}

			webApp.validatePage();

			for (AlertConditionRow r : webApp.AlertConditionsViewer.getAlertConditionRows()){
				String row_meta_alert = r.metaAlertID;
				if(row_meta_alert.equals(selected_meta_alert)){
					String flagText = r.flag.getText();
					boolean isFlagged = flagText.contains("x");
					String verdictText = r.verdict.getText();
					String supplementalText = r.supplemental.getText();
					String notesText = r.notes.getText();


					assertTrue(isFlagged);
					assertEquals("[True]", verdictText);
					assertEquals("Ignored" + "\n" +
							"Dead" + "\n" +
							"Inapplicable Env." + "\n" +
							"Dangerous - Med" + "\n" +
							"Edit" , supplementalText);
					assertEquals("test notes0", notesText);
				}
			}
		} finally {
			cleanupWebApp( webApp, projectName);
		}
	}

	/**
	 * check if alerts show up on multiple pages
	 *
	 * @throws InterruptedException
	 */
	public void testAlertUniqueness() throws InterruptedException {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, "dos2unix/dos2unix-7.2.2.zip").toString();
		String coverityPath = new File(this.config.inputDirectory, "dos2unix/analysis/coverity.json").toString();
		String fortifyPath = new File(this.config.inputDirectory, "dos2unix/analysis/fortify.xml").toString();

		try {
			webApp = this.config.createApp();
			webApp.createProjectWithFusion(projectName,
					projectDescription, archivePath, coverityPath, fortifyPath);
			ArrayList<String> displayIds = new ArrayList();

			do {
				for (AlertConditionRow row : webApp.AlertConditionsViewer.getAlertConditionRows()) {
					String display_id = row.id.getText();
					if (display_id != null && !display_id.isEmpty()) {
						if(displayIds.contains(display_id)) {
							Assert.fail("alert is duplicated on multiple pages");

						} else {
							displayIds.add(display_id);
						}
					}
				}
			} while (webApp.AlertConditionsViewer.goToNextPage());

			int guiCount = Integer.parseInt(webApp.getDriver().findElement(By.id("totalRecords")).getText());

			Assert.assertEquals(guiCount, displayIds.size());
		} finally {
			cleanupWebApp( webApp, projectName);
		}
	}

	/**
	 * compare number of rows in alerts table to the total alert count in
	 * GUI middle menu in unfused view
	 *
	 * @throws InterruptedException
	 */
	public void testUnfusedAlertCount() throws InterruptedException {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, "dos2unix/dos2unix-7.2.2.zip").toString();
		String coverityPath = new File(this.config.inputDirectory, "dos2unix/analysis/coverity.json").toString();
		String fortifyPath = new File(this.config.inputDirectory, "dos2unix/analysis/fortify.xml").toString();

		try {
			webApp = this.config.createApp();
			webApp.createProjectWithFusion(projectName,
					projectDescription, archivePath, coverityPath, fortifyPath);
			WebElement fusedOffButton = webApp.getDriver().findElement(By.id("fused_off_button"));
			fusedOffButton.click();
			webApp.validatePage();
			int rowCount = 0;

			do {
				rowCount += webApp.AlertConditionsViewer.getAlertConditionRows().size();

			} while (webApp.AlertConditionsViewer.goToNextPage());

			int guiCount = Integer.parseInt(webApp.getDriver().findElement(By.id("totalRecords")).getText());

			Assert.assertEquals(guiCount, rowCount);
		} finally {
			cleanupWebApp( webApp, projectName);
		}
	}

	/**
	 * Set flag, verdict, notes, and supplemental determinations
	 * @param webApp
	 * @throws InterruptedException
	 */
	private void setVerdictInfo(AlertConditionRow row, ScaleWebApp webApp, int rowNumber, boolean setNotesandFlag) throws InterruptedException {
		Verdict[] verdicts = Verdict.values();
		row.setVerdict(verdicts[rowNumber % 5]);

		// Avoid Stale Reference
		row = webApp.AlertConditionsViewer.getOneAlertConditionRow(rowNumber);

		//find and press the supplemental Edit button
		WebElement supp = row.supplemental;
		WebElement edit_button = supp.findElement(By.tagName("a"));

		WebDriver driver = webApp.getDriver();
		scrollIntoView(driver, edit_button);
		edit_button.click();

		WebElement dc_select = driver.findElement(By.id("dc_select"));

		String[] dcTexts = webApp.AlertConditionsViewer.getSupplementalOptions();
		String dcText = dcTexts[((rowNumber + 1) % dcTexts.length-1) + 1]; //eliminate out of bound error
		row.setDCLevel(dc_select, dcText);

		WebElement dialog_close_button = driver.findElement(By.className("supplemental-close"));

		//find all the editable fields in the supplemental dialog
		WebElement ignored_box = driver.findElement(By.id("ignored"));
		WebElement dead_box = driver.findElement(By.id("dead"));
		WebElement ie_box = driver.findElement(By.id("ie"));

		//click the supplemental values from the modal.
		//Note: Driver waits are due to timing issues that may arise
		switch(rowNumber % 4) {
			case 0:
				ignored_box.click();
				new WebDriverWait(webApp.getDriver(), 20).until(ExpectedConditions.elementToBeClickable(ie_box));
				ie_box.click();
				break;
			case 1:
				ignored_box.click();
				new WebDriverWait(webApp.getDriver(), 20).until(ExpectedConditions.elementToBeClickable(dead_box));
				dead_box.click();
				new WebDriverWait(webApp.getDriver(), 20).until(ExpectedConditions.elementToBeClickable(ie_box));
				ie_box.click();
				break;
			case 2:
				ignored_box.click();
				new WebDriverWait(webApp.getDriver(), 20).until(ExpectedConditions.elementToBeClickable(dead_box));
				dead_box.click();
				break;
			case 3:
				dead_box.click();
				new WebDriverWait(webApp.getDriver(), 20).until(ExpectedConditions.elementToBeClickable(ie_box));
				ie_box.click();
				break;

		}

		new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions.elementToBeClickable(dialog_close_button));
		dialog_close_button.click();

		if(setNotesandFlag) {
			row = webApp.AlertConditionsViewer.getOneAlertConditionRow(rowNumber);
			new WebDriverWait(webApp.getDriver(), 50).until(ExpectedConditions.elementToBeClickable(row.flag));
			row.flag.click();

			// Avoid Stale Reference
			row = webApp.AlertConditionsViewer.getOneAlertConditionRow(rowNumber);

			WebElement notes_cell = row.notes;
			new WebDriverWait(driver, 50).until(ExpectedConditions.visibilityOf(notes_cell));

			WebElement existing_note = notes_cell.findElement(By.tagName("div")).findElement(By.tagName("span"));
			existing_note.click();

			WebElement notes_field = existing_note.findElement(By.tagName("textarea"));
			new WebDriverWait(driver, 50).until(ExpectedConditions.visibilityOf(notes_field));
			notes_field.sendKeys(webApp.AlertConditionsViewer.getTestNotes());
			notes_field.submit(); // trigger best_in_place success

			// SendKeys does not trigger a change event so trigger the change event here (GeckoDriver issue in FireFox)
			((JavascriptExecutor) driver).executeScript("arguments[0].dispatchEvent(new Event('change'));", existing_note);

			webApp.waitForAlertConditionsTableLoad();
		}

		if(driver.findElement(By.id("myModal")).isDisplayed())
			dialog_close_button.click();
	}

	/**
	 * Test that viewing old determinations works correctly.
	 * @throws InterruptedException
	 */
	public void testDeterminationLog() throws InterruptedException {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, "dos2unix/dos2unix-7.2.2.zip").toString();
		String coverityPath = new File(this.config.inputDirectory, "dos2unix/analysis/coverity_1.json").toString();

		try {
			webApp = this.config.createApp();
			webApp.launch();

			webApp.createSimpleProject(projectName, projectDescription, archivePath, coverityPath,
					ToolInfo.Coverity_C_ID);

			AlertConditionRow row = webApp.AlertConditionsViewer.getOneAlertConditionRow(1);
			setVerdictInfo(row, webApp, 1, true);


			// Go back to project page, to verify that 'previous' field is now nonzero
			webApp.goHome();
			ProjectRow pr = webApp.Home.getProjectRowByName(projectName);
			pr.nameLink.click();

			// Store the current window handle
			String winHandleBefore = webApp.getDriver().getWindowHandle();

			row = webApp.AlertConditionsViewer.getOneAlertConditionRow(1);


			// Code now removes the initial determination from previous value
			// Supplementals are also sent in one request (previous value)
			row.previous.findElement(By.tagName("a")).click();
			webApp.validatePage();
			new WebDriverWait(webApp.getDriver(), 20).until(ExpectedConditions.numberOfWindowsToBe((2)));

			// Switch to new window opened
			for(String winHandle : webApp.getDriver().getWindowHandles()){
				if(!winHandle.equals(winHandleBefore)){
					webApp.getDriver().switchTo().window(winHandle);
				}
			}

			new WebDriverWait(webApp.getDriver(), 20).until(
					ExpectedConditions.visibilityOf(webApp.getDriver().findElement(By.id("determinations_table"))));
			WebElement moreViewer = webApp.getDriver().findElement(By.id("determinations_table"));

			int count = 0;
			WebElement last_tr = null;
			for (WebElement e : moreViewer.findElements(By.tagName("tr"))) {
				count++;
				last_tr = e;
			}
			List<WebElement> cells = last_tr.findElements(By.tagName("td"));
			assertEquals( 5, count); // 4 determinations made + header;
			assertEquals( 5, cells.size());
			// answers[0] is a timestamp, ignore it
			String answers[] = new String[] {"", "[x]", "[False]",
					"Ignored Dead Inapplicable Env. Dangerous Construct - Med", "0test notes"};
			for (int i = 1; i < answers.length; i++) {
				assertEquals(answers[i], cells.get(i).getText());
			}

			// Close the new window
			webApp.getDriver().close();

			// Switch back to original window
			webApp.getDriver().switchTo().window(winHandleBefore);
		} finally {
			cleanupWebApp(webApp, projectName);
		}
	}

	/**
	 * Test that no alerts were incorrectly fused in this project
	 */
	public void testAlertFusion() {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String codebasePath = new File(this.config.inputDirectory, "toy/toy.zip").toString();
		String alertPath = new File(this.config.inputDirectory, "toy/analysis/rosecheckers_oss.txt").toString();
		int alertCount = 41;

		try {
			webApp = this.config.createApp();
			webApp.launch();
			webApp.createSimpleProject(projectName, projectDescription, codebasePath, alertPath,
					ToolInfo.Rosecheckers_OSS_C_ID);

			int count = 0;
			do {
				count += webApp.AlertConditionsViewer.getAlertConditionRows().size();
			} while (webApp.AlertConditionsViewer.goToNextPage());
			assertEquals(alertCount, count);

			WebDriver driver = webApp.getDriver();
			WebElement fusedOffButton = driver.findElement(By.id("fused_off_button"));
			fusedOffButton.click();
			webApp.validatePage();

			count = 0;
			do {
				count += webApp.AlertConditionsViewer.getAlertConditionRows().size();
			} while (webApp.AlertConditionsViewer.goToNextPage());
			assertEquals(alertCount, count);

		} finally {
			cleanupWebApp( webApp, projectName);
		}
	}

	/**
	 * Test that updating unfused determinations, updates all related alert conditions with the same meta-alert-id
	 */
	public void testUpdateDeterminations() {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String codebasePath = new File(this.config.inputDirectory, "dos2unix/dos2unix-7.2.2.zip").toString();
		String cppcheckPath = new File(this.config.inputDirectory, "dos2unix/analysis/cppcheck_oss.xml").toString();

		try {
			webApp = this.config.createApp();
			webApp.launch();
			webApp.createSimpleProject(projectName, projectDescription, codebasePath, cppcheckPath,
					ToolInfo.CPPCHECK_OSS_C_ID);

			// Get the unfused view
			WebDriver driver = webApp.getDriver();
			WebElement fusedOffButton = driver.findElement(By.id("fused_off_button"));
			fusedOffButton.click();
			webApp.validatePage();
			webApp.waitForAlertConditionsTableLoad();

			// Filter the results to get 2 alert conditions with the same meta-alert-id
			String lineNumber = "1906";
			FilterElems filterElems = webApp.AlertConditionsViewer.getFilterElems();
			filterElems.lineFilter.sendKeys(lineNumber);

			new WebDriverWait(webApp.getDriver(), 30).until(ExpectedConditions
					.elementToBeClickable(By.xpath("//input[@value='Filter']")));
			webApp.getDriver().findElement(
					By.xpath("//input[@value='Filter']")).click();
			webApp.waitForAlertConditionsTableLoad();

			int changed_alert_row = 1;
			int expected_alert_row = 2;

			AlertConditionRow row = webApp.AlertConditionsViewer.getOneAlertConditionRow(changed_alert_row);

			row.flag.click();

			// Avoid Stale Reference
			row = webApp.AlertConditionsViewer.waitForRowRefresh(row);

			// Set Verdict to Dependent
			Verdict[] verdicts = Verdict.values();
			Verdict expectedVerdict = verdicts[3];
			row.setVerdict(expectedVerdict);

			// Avoid Stale Reference
			row = webApp.AlertConditionsViewer.waitForRowRefresh(row);

			new WebDriverWait(driver, 50).until(ExpectedConditions.visibilityOf(row.supplemental));

			// Find and press the supplemental Edit button
			WebElement supp = row.supplemental;
			WebElement edit_button = supp.findElement(By.tagName("a"));
			scrollIntoView(driver, row.id);
			edit_button.click();

			new WebDriverWait(driver, 50).until(ExpectedConditions.visibilityOf(driver.findElement(By.id("myModal"))));
			scrollIntoView(driver, driver.findElement(By.id("myModal")));

			// Find all the editable fields in the supplemental dialog
			// Set all of the fields to true and DC to High
			new WebDriverWait(webApp.getDriver(), 20).until(ExpectedConditions.elementToBeClickable(By.id("ignored")));
			WebElement ignored_box = driver.findElement(By.id("ignored"));
			ignored_box.click();

			new WebDriverWait(webApp.getDriver(), 20).until(ExpectedConditions.elementToBeClickable(By.id("dead")));
			WebElement dead_box = driver.findElement(By.id("dead"));
			dead_box.click();

			new WebDriverWait(webApp.getDriver(), 20).until(ExpectedConditions.elementToBeClickable(By.id("ie")));
			WebElement ie_box = driver.findElement(By.id("ie"));
			ie_box.click();

			String[] dcTexts = webApp.AlertConditionsViewer.getSupplementalOptions();
			String dcText = dcTexts[3];
			new WebDriverWait(webApp.getDriver(), 50).until(ExpectedConditions.elementToBeClickable(By.id("dc_select")));
			WebElement dc_select = driver.findElement(By.id("dc_select"));
			row.setDCLevel(dc_select, dcText);

			// Close the supplemental modal
			new WebDriverWait(webApp.getDriver(), 50).until(ExpectedConditions.elementToBeClickable(By.className("supplemental-close")));
			WebElement dialog_close_button = driver.findElement(By.className("supplemental-close"));
			dialog_close_button.click(); //close pop-up window

			// Avoid Stale Reference
			row = webApp.AlertConditionsViewer.waitForRowRefresh(row);

			WebElement notes_cell = row.notes;
			new WebDriverWait(driver, 50).until(ExpectedConditions.visibilityOf(notes_cell));

			WebElement existing_note = notes_cell.findElement(By.tagName("div")).findElement(By.tagName("span"));
			existing_note.click();

			WebElement notes_field = existing_note.findElement(By.tagName("textarea"));
			new WebDriverWait(driver, 50).until(ExpectedConditions.visibilityOf(notes_field));

			String test_notes = "testing the notes section";
			notes_field.sendKeys(test_notes);
			notes_field.submit(); // trigger success event

			webApp.waitForAlertConditionsTableLoad();

			for (AlertConditionRow r : webApp.AlertConditionsViewer.getAlertConditionRows()){
				String flagText = r.flag.getText();
				boolean isFlagged = flagText.contains("x");
				String verdictText = r.verdict.getText();
				String supplementalText = r.supplemental.getText();
				String notesText = r.notes.getText();
				String previousText = r.previous.getText();

				assertTrue(isFlagged);
				assertEquals("[Dependent]", verdictText);
				assertEquals("Ignored" + "\n" +
						"Dead" + "\n" +
						"Inapplicable Env." + "\n" +
						"Dangerous - High" + "\n" +
						"Edit" , supplementalText);
				assertEquals("0" + test_notes, notesText);
				assertEquals("4", previousText); // 4 determinations made
			}
		} finally {
			// Clear Filters for other Tests
			webApp.AlertConditionsViewer.clearFilter();
			cleanupWebApp( webApp, projectName);
		}
	}


	/**
	 * Test that the cascade-determinations feature works as advertised
	 * @throws InterruptedException
	 *
	 * Goals and intent of this test:
	 *
	 * a) at least 1 meta-alert determination that cascades
	 * b) at least 1 meta-alert determination from toy1 that doesn't cascade
	 * c) at least 1 meta-alert determination in toy2 that couldn't have a
	 *	determination cascaded to it (meaning there's no matching code
	 *	in toy 1)
	 */
	public void testCascadeDeterminations() throws InterruptedException {
		ScaleWebApp webApp = null;
		String projectNameOld = UUID.randomUUID().toString();
		String projectNameNew = UUID.randomUUID().toString();

		try {
			webApp = this.config.createApp();
			webApp.launch();
			WebDriver driver = webApp.getDriver();
			Verdict[] verdictTexts = Verdict.values();
			String[] dcTexts = webApp.AlertConditionsViewer.getSupplementalOptions();
			String[] displayedDCTexts = {"","Low","Med","High"};
			String testNote = "test note";

			String zapLine = "20";
			String zapChecker = "DCL00-C";

			// Create new project
			String projectDescriptionNew = projectNameNew.hashCode() + "";
			String archivePathNew = new File(this.config.inputDirectory, "toy2/toy2.zip").toString();
			String alertPathNew = new File(this.config.inputDirectory, "toy2/analysis/rosecheckers2_oss.txt").toString();
			webApp.createSimpleProject(projectNameNew, projectDescriptionNew, archivePathNew, alertPathNew,
					ToolInfo.Rosecheckers_OSS_C_ID);

			// Now create old project
			webApp.goHome();
			String projectDescriptionOld = projectNameOld.hashCode() + "";
			String archivePathOld = new File(this.config.inputDirectory, "toy/toy.zip").toString();
			String alertPathOld = new File(this.config.inputDirectory, "toy/analysis/rosecheckers_oss.txt").toString();
			webApp.createSimpleProject(projectNameOld, projectDescriptionOld, archivePathOld, alertPathOld,
					ToolInfo.Rosecheckers_OSS_C_ID);
			webApp.validatePage();

			// Add some verdicts to old project
			for (int rowCounter = 1; rowCounter < webApp.AlertConditionsViewer.getTotalRecords(); rowCounter++) {

				AlertConditionRow row = webApp.AlertConditionsViewer.getOneAlertConditionRow(rowCounter);
				if (row == null) {
					// no more alerts on page
					break;
				}

				// note: reassign row at the end of each operation to avoid stale references

				// set verdict to counter item
				if (rowCounter <= verdictTexts.length) {
					row.setVerdict(verdictTexts[rowCounter - 1]);
					// Avoid Stale Reference
					row = webApp.AlertConditionsViewer.waitForRowRefresh(row);
				}

				// set 'dangerous' to counter item
				if (rowCounter <= dcTexts.length) {
					//find and press the supplemental Edit button
					WebElement supp = row.supplemental;
					WebElement edit_button = supp.findElement(By.tagName("a"));

					new WebDriverWait(webApp.getDriver(), 20).until(ExpectedConditions.elementToBeClickable(edit_button));
					edit_button.click();

					// Set the 'dangerous' box
					WebElement dc_select = driver.findElement(By.id("dc_select"));
					String dcText = dcTexts[rowCounter - 1];

					row.setDCLevel(dc_select, dcText);

					// For second row, set the other items
					if (rowCounter == 2) {
						WebElement ignored_box = driver.findElement(By.id("ignored"));
						new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions.elementToBeClickable(ignored_box));
						ignored_box.click();

						WebElement dead_box = driver.findElement(By.id("dead"));
						new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions.elementToBeClickable(dead_box));
						dead_box.click();

						WebElement ie_box = driver.findElement(By.id("ie"));
						new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions.elementToBeClickable(ie_box));
						ie_box.click();
					}

					WebElement dialog_close_button = driver.findElement(By.className("supplemental-close"));
					new WebDriverWait(webApp.getDriver(), 20).until(ExpectedConditions.elementToBeClickable(dialog_close_button));
					dialog_close_button.click(); //close pop-up window

					// Avoid Stale Reference
					row = webApp.AlertConditionsViewer.waitForRowRefresh(row);
				}

				// Set flag and note only for second alert
				if (rowCounter == 2) {
					new WebDriverWait(webApp.getDriver(), 20).until(ExpectedConditions.elementToBeClickable(row.flag));
					row.flag.click();

					// Avoid Stale Reference
					row = webApp.AlertConditionsViewer.waitForRowRefresh(row);

					new WebDriverWait(webApp.getDriver(), 20).until(ExpectedConditions
							.elementToBeClickable(row.notes));
					WebElement notes_cell = row.notes;
					new WebDriverWait(webApp.getDriver(), 20).until(ExpectedConditions
							.elementToBeClickable(
									notes_cell.findElement(By.tagName("div"))
									.findElement(By.tagName("span"))));
					WebElement existing_note = notes_cell.findElement(By.tagName("div")).findElement(By.tagName("span"));

					new WebDriverWait(webApp.getDriver(), 20).until(ExpectedConditions.elementToBeClickable(existing_note));
					existing_note.click();

					new WebDriverWait(webApp.getDriver(), 20).until(ExpectedConditions
							.elementToBeClickable(existing_note.findElement(By.tagName("textarea"))));
					WebElement notes_field = existing_note.findElement(By.tagName("textarea"));

					Thread.sleep(1000); // datetime accurate only to second, this should be latest determination
					notes_field.sendKeys(testNote);
					notes_field.submit();
					// Avoid Stale Reference
					row = webApp.AlertConditionsViewer.waitForRowRefresh(row);
					notes_cell = row.notes;
					new WebDriverWait(webApp.getDriver(), 20).until(ExpectedConditions
							.textToBePresentInElement(notes_cell
									.findElement(By.tagName("div"))
 									.findElement(By.tagName("span")), "0" + testNote));
				}

				// set determination on alert that will be missing from 'new'
				if (row.line.getText().equals(zapLine) && row.checker.getText().equals(zapChecker)) {
					// set verdict to true
					row.setVerdict(verdictTexts[0]);
					// Avoid Stale Reference
					System.out.printf("extra refresh (dc zap): %d\n", rowCounter);
					row = webApp.AlertConditionsViewer.waitForRowRefresh(row);
				}

			}

			// Edit new project
			webApp.goHome();
			webApp.validatePage();

			new WebDriverWait(webApp.getDriver(), 20).until(ExpectedConditions.elementToBeClickable(webApp.Home.getEditLink(projectNameNew)));
			webApp.Home.getEditLink(projectNameNew).click();

			webApp.validatePage();

			// Cascade old project's determinations
			WebElement oldProjects = webApp.Edit.getProjectsSelection();
			oldProjects.click();
			Select select = new Select(oldProjects);
						//			Select select = new Select(oldProjects.findElement(By.tagName("select")));
			select.selectByVisibleText(projectNameOld);
			WebElement cascadeButton = webApp.Edit.getCascadeDeterminationsButton();
			cascadeButton.click();

			webApp.validatePage();
			webApp.waitForAlertConditionsTableLoad();

			// Now verify that all determinations that should cascade exist in new project.
			boolean zapLineFound = false;
			for (int rowCounter = 1; rowCounter < webApp.AlertConditionsViewer.getTotalRecords(); rowCounter++) {
				AlertConditionRow row = webApp.AlertConditionsViewer.getOneAlertConditionRow(rowCounter);
				if (row == null) {
					// no more alerts on page
					break;
				}

				// Verify verdict
				String verdictText = row.verdict.getText();
				Verdict actualVerdict = Verdict.valueOf(verdictText.substring(1,verdictText.length()-1));
				new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions
						.elementToBeClickable(row.supplemental));
				String suppText = row.supplemental.getText();
				new WebDriverWait(webApp.getDriver(), 20).until(ExpectedConditions
						.elementToBeClickable(row.notes));
				String notesText = row.notes.getText();
				String actualFlag = row.flag.getText();

				if (rowCounter == 1) {
					assertEquals(Verdict.valueOf("True"), actualVerdict);
					assert(!actualFlag.contains("x"));
					assertEquals(suppText, "Edit");
					assert(notesText.contains("Cascaded"));
				} else if (rowCounter == 2) {
					assertEquals(Verdict.valueOf("False"), actualVerdict);
					assert(actualFlag.contains("x"));
					assert(suppText.contains("Dangerous - Low"));
					assert(suppText.contains("Ignored"));
					assert(suppText.contains("Dead"));
					assert(suppText.contains("Inapplicable Env."));
					assert(notesText.contains(testNote));
					assert(notesText.contains("Cascaded"));
				} else if (rowCounter == 3) {
					assertEquals(Verdict.valueOf("Complex"), actualVerdict);
					assert(!actualFlag.contains("x"));
					assert(suppText.contains("Dangerous - Med"));
					assert(notesText.contains("Cascaded"));
				} else if (rowCounter == 4) {
					assertEquals(Verdict.valueOf("Dependent"), actualVerdict);
					assert(!actualFlag.contains("x"));
					assert(suppText.contains("Dangerous - High"));
					assert(notesText.contains("Cascaded"));
				} else {
					assertEquals(Verdict.valueOf("Unknown"), actualVerdict);
					assert(!actualFlag.contains("x"));
					assertEquals(suppText, "Edit");
					assert(notesText.equals("0"));
				}

				// make sure that our targeted alert is gone now; the combination
				// of this with having compared the remaining rows in the page
				// as having no determinations satisfy conditions b) and c)
				// for this test
				if (row.line.getText() == zapLine && row.checker.getText() == zapChecker) {
					// the determination has already been compared to "Unknown", etc,
					// but the alert itself shouldn't even be present
					zapLineFound = true;
				}

			}

			// no alert present for chosen line
			assert(!zapLineFound);

		} finally {
			webApp.goHome();
			webApp.destroyProject(projectNameOld);
			cleanupWebApp( webApp, projectNameNew);
		}
	}


	/**
	 * Test that the "More" link works correctly.
	 * @throws InterruptedException
	 */
	public void testMoreLink() throws InterruptedException {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, "dos2unix/dos2unix-7.2.2.zip").toString();
		String coverityPath = new File(this.config.inputDirectory, "dos2unix/analysis/coverity_1.json").toString();

		try {
			webApp = this.config.createApp();
			webApp.launch();
			webApp.createSimpleProject(projectName, projectDescription, archivePath, coverityPath,
					ToolInfo.Coverity_C_ID);
			List<AlertConditionRow> rows = webApp.AlertConditionsViewer.getAlertConditionRows();
			Assert.assertEquals(2, rows.size());
			AlertConditionRow row = rows.get(0);

			// Store the current window handle
			String winHandleBefore = webApp.getDriver().getWindowHandle();

			// Perform the click operation that opens new window
			row.message.findElement(By.linkText("Secondary Message Set")).click();
			webApp.validatePage();

			//Wait for the new window to open
			new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions.numberOfWindowsToBe((2)));

			// Switch to new window opened
			for(String winHandle : webApp.getDriver().getWindowHandles()){
				if(!winHandle.equals(winHandleBefore)){
					webApp.getDriver().switchTo().window(winHandle);
				}
			}

			// Perform the actions on new window

			WebElement moreViewer = webApp.getDriver().findElement(By.id("messages_table"));
			boolean firstRow = true;
			int count = 0;
			for (WebElement e : moreViewer.findElements(By.tagName("tr"))) {
				List<WebElement> cells = e.findElements(By.tagName("td"));
				if (cells.size() != 3) {
					continue;
				}
				count++;

				if (firstRow) {
					assertEquals("5", cells.get(0).getText());
					assertEquals("5", cells.get(1).getText());
					firstRow = false;
				} else {
					assertEquals((count - 1) + "", cells.get(0).getText());
					assertEquals((count - 1) + "", cells.get(1).getText());
				}
			}
			assertEquals(5, count);

			// Close the new window
			webApp.getDriver().close();

			// Switch back to original window
			webApp.getDriver().switchTo().window(winHandleBefore);


		} finally {
			cleanupWebApp( webApp, projectName);
		}
	}

	/**
	 * Check for errors in CWE display.
	 */
	public void testCweDisplay() {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, "dos2unix/dos2unix-7.2.2.zip").toString();
		String cppcheckPath = new File(this.config.inputDirectory, "dos2unix/analysis/cppcheck_oss.xml").toString();
		int numRowsExpected = 23;

		try {
			webApp = this.config.createApp();
			webApp.launch();
			webApp.createSimpleProject(projectName, projectDescription, archivePath, cppcheckPath,
					ToolInfo.CPPCHECK_OSS_C_ID);

			WebDriver driver = webApp.getDriver();
			WebElement fusedOffButton = driver.findElement(By.id("fused_off_button"));

			fusedOffButton.click();
			webApp.validatePage();

			//Check the fields in the fourth row (header + actual row number)
			AlertConditionRow row = webApp.AlertConditionsViewer.getOneAlertConditionRow(5);

			assertEquals("/dos2unix-7.2.2/common.c", row.path.getText());
			assertEquals("732", row.line.getText());
			assertEquals("CWE-119", row.condition.getText());
			assertEquals("Improper Restriction of Operations within the Bounds of a Memory Buffer", row.title.getText());
			assertEquals("arrayIndexOutOfBounds", row.checker.getText());
			assertEquals("cppcheck_oss", row.tool.getText());
			assertEquals("", row.confidence.getText());
			assertEquals("", row.meta_alert_priority.getText());
			assertEquals("", row.sev.getText());
			assertEquals("", row.lik.getText());
			assertEquals("", row.rem.getText());
			assertEquals("", row.pri.getText());
			assertEquals("", row.lev.getText());
			assertEquals("High", row.cwe_lik.getText());

			// Check for duplicate rows. Any two rows may
			// have the same id or same condition, but not both.
			// (This is no longer true in the unfused view ~DS)
			String[] id_conditions = new String[numRowsExpected];
			int row_counter = 0;
			do{
				for (AlertConditionRow r : webApp.AlertConditionsViewer.getAlertConditionRows()) {
					String id_condition = r.id.getText() + r.condition.getText();
					id_conditions[row_counter] = id_condition;
					row_counter++;
				}
			} while (webApp.AlertConditionsViewer.goToNextPage());
			assertEquals(numRowsExpected, row_counter);
		} finally {
			cleanupWebApp( webApp, projectName);
		}
	}

	/**
	 * Check for errors in CWE display.
	 * @throws InterruptedException
	 */
	public void testCwePlusCert() throws InterruptedException {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, "dos2unix/dos2unix-7.2.2.zip").toString();
		String cppcheckPath = new File(this.config.inputDirectory, "dos2unix/analysis/cppcheck_oss.v.1.83.xml").toString();
		int numRowsExpected = 22;

		try {
			webApp = this.config.createApp();
			webApp.launch();
			webApp.goHome();
			webApp.Home.getNewProjectLink().click();
			webApp.validatePage();
			webApp.NewProject.getNameField().sendKeys(projectName);
			webApp.NewProject.getDescriptionField().sendKeys(projectDescription);
			webApp.NewProject.getCreateProjectButton().click();
			webApp.validatePage();

			webApp.UploadAnalysis.getArchiveUploader().sendKeys(archivePath);
			ToolRow toolRow;
			toolRow = webApp.UploadAnalysis.getToolRowById(ToolInfo.CPPCHECK_OSS_C_ID, false);
			toolRow.checkbox.click();
			toolRow.uploadFile.sendKeys(cppcheckPath);

			webApp.UploadAnalysis.getCreateDatabaseButton().click();

			new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions.elementToBeClickable(webApp.UploadAnalysis.getCreateProjectFromDatabaseButton()));
			webApp.UploadAnalysis.getCreateProjectFromDatabaseButton().click();

			webApp.waitForAlertConditionsTableLoad();

			WebDriver driver = webApp.getDriver();
			WebElement fusedOffButton = driver.findElement(By.id("fused_off_button"));

			fusedOffButton.click();
			webApp.validatePage();

			int row_counter = 0;
			do{
				for (AlertConditionRow r : webApp.AlertConditionsViewer.getAlertConditionRows()) {
					row_counter++;
				}
			} while (webApp.AlertConditionsViewer.goToNextPage());
			assertEquals(numRowsExpected, row_counter);
		} finally {
			cleanupWebApp( webApp, projectName);
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

	public void createRunRetrainDeleteClassifierCheckFilters(ScaleWebApp webApp,
			String checker, String condition, String id, String idType,
			String line, String path, String prev, String sortBy,
			String sortDir, String tax, String tool, String verdict) {

		//create classifier scheme
		String classifierName = "classifierScheme1";
		WebDriver driver = webApp.getDriver();

		//WORKAROUND: Implement a better way!
		//Check to ensure the test classifier does not exist, if it does delete it first before running the rest of the test.
		//TODO: Discuss DB mocks or an easier way to delete the classifier after it has been created (currently deleting between running tests)
		//Removing just the project doesn't remove the classifier scheme.
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
			try {
				removeModalContents(removeClassifier, "classifier", driver);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}

		webApp.waitForAlertConditionsTableLoad();

		new WebDriverWait(webApp.getDriver(), 30).until(ExpectedConditions
				.visibilityOfElementLocated(By.id("classifier_instance_chosen")));
		WebElement classifierTextElem = webApp.getDriver().findElement(By.id("classifier_instance_chosen"));
		Select select = new Select(classifierTextElem);
		WebElement option = select.getFirstSelectedOption();

		String classifierSelectText = option.getText();
		assertEquals(classifierSelectText, "-Select Classifier Instance-");

		//Open the modal and verify the results.
		Actions create_action = new Actions(driver);

		//Hover over classifier dropdown and open a new classifier modal

		new WebDriverWait(webApp.getDriver(), 40).until(ExpectedConditions
				.elementToBeClickable(By.xpath("//li[@id='classifier-dropdown']//a")));
		create_action.moveToElement(driver.findElement(By.xpath("//li[@id='classifier-dropdown']//a"))).click().perform();

		new WebDriverWait(webApp.getDriver(), 40).until(ExpectedConditions
				.elementToBeClickable(By.xpath("//li[@id='new-classifier-link']//a")));
		create_action.moveToElement(driver.findElement(By.xpath("//li[@id='new-classifier-link']//a"))).perform();

		new WebDriverWait(webApp.getDriver(), 40).until(ExpectedConditions
				.visibilityOfElementLocated(By.className("classifiers")));
		create_action.moveToElement(driver.findElements(By.className("classifiers")).get(0)).click().perform();


		//Classifier Modal is opened
		new WebDriverWait(webApp.getDriver(), 30).until(ExpectedConditions
				.visibilityOfElementLocated(By.id("modal-placement")));
		WebElement modal_close_button = driver.findElement(By.id("classifier-class-modal"));

		//set values in the Classifier Modal
		driver.findElement(By.id("classifier_name")).sendKeys(classifierName);

		WebElement projectSelected = driver.findElements(By.xpath("//div[@id='all_projects']//li[@class='list_item']")).get(0);
		projectSelected.click();


		//Add projects to the selected projects section
		WebElement add_button = driver.findElement(By.id("add_button"));

		new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions.elementToBeClickable(add_button));
		add_button.click();

		new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions.presenceOfAllElementsLocatedBy(By.xpath("//div[@id='ah']//li[@class='ah-tabs ']//a")));

		//Select an adaptive heuristic
		List<WebElement> ahList = driver.findElements(By.xpath("//div[@id='ah']//li[@class='ah-tabs ']//a"));
		WebElement ahSelected = ahList.get(0);

		scrollIntoView(driver, ahSelected);
		ahSelected.click();

		//Selected an AHPO
		Select ahpo_select = new Select(driver.findElement(By.id("ahpoSelects")));
		ahpo_select.selectByVisibleText("sei-ahpo");

		WebElement submit_button = driver.findElement(By.id("submit-modal"));
		submit_button.click();

		webApp.waitForAlertConditionsTableLoad();

		//TODO: replace this with the correct wait condition.
		//I don't know what that is
		try {
			Thread.sleep(1000);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		//check filter values
		checkFilterValues(webApp, checker, condition, id, idType, line,
				path, prev, sortBy, sortDir, tax, tool, verdict);

		//classify, select the classifier option from the dropdown
		new WebDriverWait(webApp.getDriver(), 30).until(ExpectedConditions
				.visibilityOfElementLocated(By.id("classifier_instance_chosen")));
		WebElement classifierTextSelect = webApp.getDriver().findElement(By.id("classifier_instance_chosen"));
		Select classifier_select = new Select(classifierTextSelect);
		classifier_select.selectByVisibleText(classifierName);

		new WebDriverWait(webApp.getDriver(), 20).until(
				ExpectedConditions.elementToBeClickable(
						By.id("run-classifier-btn")));
		driver.findElement(By.id("run-classifier-btn")).click();
		webApp.waitForAlertConditionsTableLoad();

		//TODO: replace this with the correct wait condition.
		//I don't know what that is
		try {
			Thread.sleep(1000);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		//check filter values
		checkFilterValues(webApp, checker, condition, id, idType, line,
				path, prev, sortBy, sortDir, tax, tool, verdict);

		//retrain
		webApp.waitForAlertConditionsTableLoad();

		Actions edit_action = new Actions(driver);
		((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView(true);", driver.findElement(By.xpath("//li[@id='classifier-dropdown']//a")));

		new WebDriverWait(webApp.getDriver(), 40).until(ExpectedConditions
				.elementToBeClickable(By.xpath("//li[@id='classifier-dropdown']//a")));
		edit_action.moveToElement(driver.findElement(By.xpath("//li[@id='classifier-dropdown']//a"))).click().perform();

		new WebDriverWait(webApp.getDriver(), 40).until(ExpectedConditions
				.elementToBeClickable(By.linkText(classifierName)));
		edit_action.moveToElement(driver.findElement(By.linkText(classifierName))).click().perform();

		new WebDriverWait(webApp.getDriver(), 20).until(
				ExpectedConditions.elementToBeClickable(
						By.id("submit-modal")));
		driver.findElement(By.id("submit-modal")).click();
		webApp.waitForAlertConditionsTableLoad();

		//TODO: replace this with the correct wait condition.
		//I don't know what that is
		try {
			Thread.sleep(1000);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		//check filter values
		checkFilterValues(webApp, checker, condition, id, idType, line,
				path, prev, sortBy, sortDir, tax, tool, verdict);

		//delete
		Actions delete_action = new Actions(driver);
		((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView(true);", driver.findElement(By.xpath("//li[@id='classifier-dropdown']//a")));

		new WebDriverWait(webApp.getDriver(), 40).until(ExpectedConditions
				.elementToBeClickable(By.xpath("//li[@id='classifier-dropdown']//a")));
		delete_action.moveToElement(driver.findElement(By.xpath("//li[@id='classifier-dropdown']//a"))).click().perform();

		new WebDriverWait(webApp.getDriver(), 40).until(ExpectedConditions
				.elementToBeClickable(driver.findElement(By.linkText(classifierName))));
		delete_action.moveToElement(driver.findElement((By.linkText(classifierName)))).click().perform();

		new WebDriverWait(webApp.getDriver(), 10).until(
				ExpectedConditions.elementToBeClickable(
						By.id("delete-modal")));
		driver.findElement(By.id("delete-modal")).click();

		String windowHandle = driver.getWindowHandle();
		new WebDriverWait(webApp.getDriver(), 10).until(
				ExpectedConditions.alertIsPresent());
		driver.switchTo().alert().accept();
		webApp.waitForAlertConditionsTableLoad();
		new WebDriverWait(webApp.getDriver(), 10).until(
				ExpectedConditions.elementToBeClickable(
						By.id("sort_column")));

		//TODO: replace this with the correct wait condition.
		//I don't know what that is
		try {
			Thread.sleep(1000);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		//check filter values
		checkFilterValues(webApp, checker, condition, id, idType, line,
				path, prev, sortBy, sortDir, tax, tool, verdict);
	}

	/**
	 * make sure the filters persist when classifier is created, retrained,
	 * run, or deleted
	 *
	 * @throws InterruptedException
	 */
	public void testClassifyFiltersPersist() throws InterruptedException {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, "toy/toy.zip").toString();
		String rosecheckersPath = new File(this.config.inputDirectory, "toy/analysis/rosecheckers_oss.txt").toString();
		try {
			webApp = this.config.createApp();
			webApp.launch();
			webApp.createSimpleProject(projectName, projectDescription, archivePath, rosecheckersPath,
					ToolInfo.Rosecheckers_OSS_C_ID);
			webApp.validatePage();
			webApp.waitForAlertConditionsTableLoad();

			//set all of the filters
			String checker = "DCL00-C";
			String condition = "DCL00-C";
			String id = "1";
			String idType = "Display (d) ID";
			String line = "1";
			String path = "/ARR36-C/arr36-c-false-1.c";
			String prev = "0";
			String sortBy = "id";
			String sortDir = "asc";
			String tax = "CERT Rules";
			String tool = "rosecheckers_oss";
			String verdict = "0";

			FilterElems filterElems = webApp.AlertConditionsViewer.getFilterElems();
			filterElems.checkerFilter.selectByVisibleText(checker);
			filterElems.conditionFilter.selectByVisibleText(condition);
			filterElems.idFilter.sendKeys(new String[]{id});
			filterElems.idTypeFilter.selectByVisibleText(idType);
			filterElems.lineFilter.sendKeys(new String[]{line});
			filterElems.pathFilter.sendKeys(new String[]{path});
			filterElems.prevFilter.selectByValue(prev);
			filterElems.sortBy.selectByValue(sortBy);
			filterElems.sortDir.selectByVisibleText(sortDir);
			filterElems.taxFilter.selectByVisibleText(tax);
			filterElems.toolFilter.selectByVisibleText(tool);
			filterElems.verdictFilter.selectByValue(verdict);
			new WebDriverWait(webApp.getDriver(), 30).until(ExpectedConditions
					.elementToBeClickable(By.xpath("//input[@value='Filter']")));
			webApp.getDriver().findElement(
					By.xpath("//input[@value='Filter']")).click();
			webApp.waitForAlertConditionsTableLoad();
			createRunRetrainDeleteClassifierCheckFilters(webApp, checker, condition, id, idType, line,
					path, prev, sortBy, sortDir, tax, tool, verdict);

			//check unfused view
			new WebDriverWait(webApp.getDriver(), 30).until(ExpectedConditions
					.elementToBeClickable(By.id("fused_off_button")));
			webApp.getDriver().findElement(By.id("fused_off_button")).click();
			webApp.waitForAlertConditionsTableLoad();
			createRunRetrainDeleteClassifierCheckFilters(webApp, checker, condition, id, idType, line,
					path, prev, sortBy, sortDir, tax, tool, verdict);

		} finally {
			//clear the filters for other tests
			if(webApp.getDriver().findElement(By.id("modal-placement")).isDisplayed()) {
				WebElement dialog_close_button = webApp.getDriver().findElement(By.id("modal-placement"));
				dialog_close_button.click();
			}

			webApp.AlertConditionsViewer.clearFilter();
			cleanupWebApp(webApp, projectName);
		}
	}

	/**
	 * tests creating and running classifier behavior
	 *
	 * @throws InterruptedException
	 */
	public void testCreateandRunClassifier() throws InterruptedException {
		 /*
		  * Ensure the ClassifierChosen hyperlink contains 'None Selected' and the Run Classifier button is disabled (cannot get confidence values)
		  * Open the classifier modal and set the values in the interface. Click the Create Classifier button (which should close the modal,
		  * if the values are valid). Next check the ClassifierChosen hyperlink to ensure the name matches the classifier name specified.
		  * Note: Verifying confidence values is inefficient since values are currently randomly generated. Thus we check to ensure the values are
		  * between zero and 100.
		  * As additional taxonomies are added to scale this test will need to be updated.
		  */
			ScaleWebApp webApp = null;
			String projectName = UUID.randomUUID().toString();
			String projectDescription = projectName.hashCode() + "";
			String archivePath = new File(this.config.inputDirectory, "toy2/toy2.zip").toString();
			String rosecheckersPath = new File(this.config.inputDirectory, "toy2/analysis/rosecheckers2_oss.txt").toString();

			try {
				webApp = this.config.createApp();
				webApp.launch();
				webApp.createSimpleProject(projectName, projectDescription, archivePath, rosecheckersPath,
						ToolInfo.Rosecheckers_OSS_C_ID);
				webApp.validatePage();
				webApp.waitForAlertConditionsTableLoad();

				WebDriver driver = webApp.getDriver();

				webApp.waitForPageLoad(driver);

				String classifierName = "classifierScheme1";

				//WORKAROUND: Implement a better way!
				//Check to ensure the test classifier does not exist, if it does delete it first before running the rest of the test.
				//TODO: Discuss DB mocks or an easier way to delete the classifier after it has been created (currently deleting between running tests)
				//Removing just the project doesn't remove the classifier scheme.
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

				//TestCreateandRunClassifier officially starts here.
				new WebDriverWait(webApp.getDriver(), 30).until(ExpectedConditions
						.visibilityOfElementLocated(By.id("classifier_instance_chosen")));
				WebElement classifierTextElem = webApp.getDriver().findElement(By.id("classifier_instance_chosen"));
				Select select = new Select(classifierTextElem);
				WebElement option = select.getFirstSelectedOption();

				String classifierSelectText = option.getText();
				assertEquals(classifierSelectText, "-Select Classifier Instance-");

				//Open the modal and verify the results.
				Actions action = new Actions(driver);

				//Hover over classifier dropdown and open a new classifier modal

				new WebDriverWait(webApp.getDriver(), 40).until(ExpectedConditions
						.elementToBeClickable(By.xpath("//li[@id='classifier-dropdown']//a")));
				action.moveToElement(driver.findElement(By.xpath("//li[@id='classifier-dropdown']//a"))).click().perform();

				new WebDriverWait(webApp.getDriver(), 40).until(ExpectedConditions
						.elementToBeClickable(By.xpath("//li[@id='new-classifier-link']//a")));
				action.moveToElement(driver.findElement(By.xpath("//li[@id='new-classifier-link']//a"))).perform();

				new WebDriverWait(webApp.getDriver(), 40).until(ExpectedConditions
						.visibilityOfElementLocated(By.className("classifiers")));
				action.moveToElement(driver.findElements(By.className("classifiers")).get(0)).click().perform();


				//Classifier Modal is opened
				new WebDriverWait(webApp.getDriver(), 30).until(ExpectedConditions
						.visibilityOfElementLocated(By.id("modal-placement")));
				WebElement modal_close_button = driver.findElement(By.id("classifier-class-modal"));

				//set values in the Classifier Modal
				driver.findElement(By.id("classifier_name")).sendKeys(classifierName);

				WebElement projectSelected = driver.findElements(By.xpath("//div[@id='all_projects']//li[@class='list_item']")).get(0);
				projectSelected.click();


				//Add projects to the selected projects section
				WebElement add_button = driver.findElement(By.id("add_button"));

				new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions.elementToBeClickable(add_button));
				add_button.click();

				new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions
						.presenceOfAllElementsLocatedBy(By.xpath("//div[@id='ah']//li[@class='ah-tabs ']//a")));

				//Select an adaptive heuristic
				List<WebElement> ahList = driver.findElements(By.xpath("//div[@id='ah']//li[@class='ah-tabs ']//a"));
				WebElement ahSelected = ahList.get(0);

				scrollIntoView(driver, ahSelected);
				ahSelected.click();

				//Selected an AHPO
				Select ahpo_select = new Select(driver.findElement(By.id("ahpoSelects")));
				ahpo_select.selectByVisibleText("sei-ahpo");

				WebElement submit_button = driver.findElement(By.id("submit-modal"));
				submit_button.click();


				//Verify the results
				webApp.waitForAlertConditionsTableLoad();

				new WebDriverWait(webApp.getDriver(), 30).until(ExpectedConditions
						.visibilityOfElementLocated(By.id("classifier_instance_chosen")));
				WebElement classifierTextSelect = webApp.getDriver().findElement(By.id("classifier_instance_chosen"));
				Select classifier_select = new Select(classifierTextSelect);
				classifier_select.selectByVisibleText(classifierName);

				new WebDriverWait(webApp.getDriver(), 20).until(ExpectedConditions
						.elementToBeClickable(driver.findElement(By.id("run-classifier-btn"))));
				driver.findElement(By.id("run-classifier-btn")).click();

				String rcBtnId = "run-classifier-btn";
				new WebDriverWait(driver, 20).until(ExpectedConditions
						.elementToBeClickable(driver.findElement(By.id(rcBtnId))));
				driver.findElement(By.id(rcBtnId)).click();
				try {
					// give the page a chance running status
					Thread.sleep(2000);
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
				new WebDriverWait(driver, 500).until(
						ExpectedConditions.textToBe(By.id(rcBtnId), "Classify"));

				webApp.waitForAlertConditionsTableLoad();

				for (AlertConditionRow row : webApp.AlertConditionsViewer.getAlertConditionRows()) {
					Double rowConfidence = Double.parseDouble(row.confidence.getText());
					assertTrue(rowConfidence > 0 && rowConfidence < 100);
				}

			} finally {
				cleanupWebApp( webApp, projectName);
			}
	}

	/**
	 * test creating and running priority scheme behavior
	 *
	 * @throws InterruptedException
	 */
	public void testCreatePrioritization() throws InterruptedException {
		/*
		 * Open the prioritization modal and create a verifiable prioritization scheme. Verify the values in the AlertCondition Pri column are the expected results.
		 * Note: As additional taxonomies are added to scale this test will need to be updated.
		 */
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, "toy/toy.zip").toString();
		String rosecheckersPath = new File(this.config.inputDirectory, "toy/analysis/rosecheckers_oss.txt").toString();

		try {
			webApp = this.config.createApp();
			webApp.launch();
			webApp.createSimpleProject(projectName, projectDescription, archivePath, rosecheckersPath,
					ToolInfo.Rosecheckers_OSS_C_ID);
			webApp.validatePage();
			webApp.waitForAlertConditionsTableLoad();

			WebDriver driver = webApp.getDriver();

			String priorityName = "priorityTest";

			//WORKAROUND: Implement a better way! Note this also verifies that the delete method works :D

			//Additional Note, these checks are not as important as in classifier because the priority scheme is not being saved
			List<WebElement> priorityList = driver.findElements(By.xpath("//li[@id='priorityscheme-dropdown']//ul//li//a"));
			WebElement removePriority = null;

			if(priorityList.size() > 1) {
				for (WebElement p : priorityList) {
					if(p.getAttribute("innerHTML").contentEquals(priorityName)){
						removePriority = p;
					}
				}
			}

			//Test priority scheme does exist, remove the scheme from the DB with the Browser
			if(removePriority != null){
				removeModalContents(removePriority, "priorityScheme", driver);
			}

			webApp.waitForAlertConditionsTableLoad();
			webApp.waitForPageLoad(driver);

			//Open the modal and verify the results.
			Actions action = new Actions(driver);
			new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions
					.elementToBeClickable(driver.findElement(By.xpath("//li[@id='priorityscheme-dropdown']//a"))));
			action.moveToElement(driver.findElement(By.xpath("//li[@id='priorityscheme-dropdown']//a"))).click().perform();

			new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions
					.elementToBeClickable(driver.findElement(By.xpath("//*[@class='priorities' and contains(text(),'Create New Scheme')]"))));
			action.moveToElement(driver.findElement(By.xpath("//*[@class='priorities' and contains(text(),'Create New Scheme')]"))).click().perform();
			webApp.waitForPageLoad(driver);

			//Set values in the Priority Scheme modal
			webApp.PrioritySchemeModal.setName(priorityName);

			//Go to CWE tab
			webApp.PrioritySchemeModal.fillCWETab();

			//Go to CERT tab
			webApp.PrioritySchemeModal.fillCERTTab();

			//generate the formula to calculate the priority
			webApp.PrioritySchemeModal.genFormula();

			//save priority scheme
			webApp.PrioritySchemeModal.saveScheme();

			//run priority scheme
			webApp.PrioritySchemeModal.runScheme();

			//Verify the results
			for (AlertConditionRow row : webApp.AlertConditionsViewer.getAlertConditionRows()) {
				String condition = row.condition.getText();
				int severity = (row.sev.getText().isEmpty()) ? 0 : Integer.parseInt(row.sev.getText());
				int likelihood = (row.lik.getText().isEmpty()) ? 0 : Integer.parseInt(row.lik.getText());
				int remediation = (row.rem.getText().isEmpty()) ? 0 : Integer.parseInt(row.rem.getText());
				int meta_alert_priority = (row.meta_alert_priority.getText().isEmpty()) ? 0 : Integer.parseInt(row.meta_alert_priority.getText());

				if(condition.startsWith("CWE")){
					assertEquals(likelihood, meta_alert_priority);
				}else {
					assertEquals(severity*2+remediation, meta_alert_priority);
				}
			}

			//upload user columns and make sure they persist in the priority scheme modal
			String userUploadfPath = new File(this.config.inputDirectory,
				"misc/user_upload_example.csv").toString();
			webApp.PrioritySchemeModal.uploadUserCols(userUploadfPath);
			//open priority scheme to edit
			webApp.PrioritySchemeModal.openSchemeFromNav(priorityName);

			//verify user uploaded fields initialized to 0
			new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions
				.elementToBeClickable(driver.findElement(By.id("upload_safeguard_countermeasure"))));
			assertEquals("0", driver.findElement(By.id("upload_safeguard_countermeasure")).getAttribute("value"));
			new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions
				.elementToBeClickable(driver.findElement(By.id("upload_complexity"))));
			assertEquals("0", driver.findElement(By.id("upload_complexity")).getAttribute("value"));

			//set some of the user uploaded field weights
			new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions
				.elementToBeClickable(driver.findElement(By.id("upload_safeguard_countermeasure"))));
			driver.findElement(By.id("upload_safeguard_countermeasure")).clear();
			driver.findElement(By.id("upload_safeguard_countermeasure")).sendKeys("1");
			new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions
				.elementToBeClickable(driver.findElement(By.id("upload_complexity"))));
			driver.findElement(By.id("upload_complexity")).clear();
			driver.findElement(By.id("upload_complexity")).sendKeys("5");

			//generate the formula to calculate the priority
			webApp.PrioritySchemeModal.genFormula();
			//save priority scheme
			webApp.PrioritySchemeModal.saveScheme();

			//run priority scheme
			webApp.PrioritySchemeModal.runScheme();

			webApp.PrioritySchemeModal.openSchemeFromNav(priorityName);

			//verify user uploaded fields persist
			new WebDriverWait(webApp.getDriver(), 20).until(ExpectedConditions
				.elementToBeClickable(driver.findElement(By.id("upload_safeguard_countermeasure"))));
			assertEquals("1", driver.findElement(By.id("upload_safeguard_countermeasure")).getAttribute("value"));
			new WebDriverWait(webApp.getDriver(), 20).until(ExpectedConditions
				.elementToBeClickable(driver.findElement(By.id("upload_complexity"))));
			assertEquals("5", driver.findElement(By.id("upload_complexity")).getAttribute("value"));
		} finally {
			cleanupWebApp(webApp, projectName);
		}

	}

	/**
	 * sets alerts per page dropdown, changes fusion view, and checks if the
	 * selection persists
	 *
	 * @throws InterruptedException
	 */
	public void testPerPagePersist() throws InterruptedException {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, "dos2unix/dos2unix-7.2.2.zip").toString();
		String fortifyPath = new File(this.config.inputDirectory, "dos2unix/analysis/fortify.xml").toString();
		int perPage = 100;

		try {
			// Build a model of our Web App with the given driver.
			webApp = this.config.createApp();

			// Launch the app, create a project, then go back to the home page
			webApp.launch();
			webApp.createSimpleProject(projectName, projectDescription, archivePath, fortifyPath,
					ToolInfo.Fortify_C_ID);
			webApp.waitForAlertConditionsTableLoad();
			webApp.AlertConditionsViewer.changeAlertConditionsPerPage(perPage);
			WebElement fusedOffButton = webApp.getDriver().findElement(By.id("fused_off_button"));
			fusedOffButton.click();
			webApp.waitForAlertConditionsTableLoad();
			new WebDriverWait(webApp.getDriver(), 40).until(ExpectedConditions
				.elementToBeClickable(By.name("alertConditionsPerPage")));
			Select select = new Select(webApp.getDriver().findElement(By.name("alertConditionsPerPage")));
			int option = Integer.parseInt(select.getFirstSelectedOption().getText());
			assertEquals(perPage, option);

		} finally {
			cleanupWebApp( webApp, null);
		}
	}

	/**
	 * sets SCAIFE mode dropdown and checks that the correct elements are displayed for the mode
	 *
	 * @throws InterruptedException
	 */
	public void testSCAIFEMode() throws InterruptedException {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, "dos2unix/dos2unix-7.2.2.zip").toString();
		String srcPath = new File(this.config.inputDirectory, "dos2unix/analysis/rosecheckers_oss.txt").toString();

		try {
			// Build a model of our Web App with the given driver.
			webApp = this.config.createApp();
			WebDriver driver = webApp.getDriver();

			// Launch the app, create a project, then go back to the home page
			webApp.launch();
			webApp.createSimpleProject(projectName, projectDescription, archivePath, srcPath,
					ToolInfo.Rosecheckers_OSS_C_ID);
			webApp.waitForAlertConditionsTableLoad();

			new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions
					.elementToBeClickable(By.id("scaife_mode_select")));
			Select dropdown = new Select(driver.findElement(By.id("scaife_mode_select")));

			assertEquals("Demo", dropdown.getFirstSelectedOption().getText());
			assert driver.findElements(By.id("classifier-dropdown")).size() > 0 ;
			assert driver.findElements(By.id("priorityscheme-dropdown")).size() > 0;
			assert driver.findElements(By.id("classifier_instance_chosen")).size() > 0;
			assert driver.findElements(By.id("run-classifier-btn")).size() > 0;

			//select "Connected", then close the login modal
			dropdown.selectByVisibleText("Connected");
			webApp.waitForPageLoad(driver);
			new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions
				.elementToBeClickable(By.className("close")));
			driver.findElement(By.className("close")).click();
			new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions
					.stalenessOf(driver.findElement(By.id("scaife_mode_select"))));
			dropdown = new Select(driver.findElement(By.id("scaife_mode_select")));
			assertEquals("Demo", dropdown.getFirstSelectedOption().getText());
			assert driver.findElements(By.id("classifier-dropdown")).size() > 0 ;
			assert driver.findElements(By.id("priorityscheme-dropdown")).size() > 0;
			assert driver.findElements(By.id("classifier_instance_chosen")).size() > 0;
			assert driver.findElements(By.id("run-classifier-btn")).size() > 0;

			//select "Connected", then click "Sign Up", then close register modal"
			dropdown.selectByVisibleText("Connected");
			webApp.waitForPageLoad(driver);
			driver.findElement(By.xpath("//input[@value='Sign Up']")).click();
			webApp.waitForPageLoad(driver);
			new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions
				.visibilityOfElementLocated(By.id("scaifeRegisterModalLabel")));
			assertEquals( driver.findElement(By.id("scaifeRegisterModalLabel"))
				.getText(), "SCAIFE: Sign Up");
			webApp.waitForPageLoad(driver);
			driver.findElement(By.id("scaife-register-modal")).findElement(By.className("close")).click();
			new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions
					.stalenessOf(driver.findElement(By.id("scaife_mode_select"))));
			new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions
					.elementToBeClickable(By.id("scaife_mode_select")));
			dropdown = new Select(driver.findElement(By.id("scaife_mode_select")));
			assertEquals("Demo", dropdown.getFirstSelectedOption().getText());
			assert driver.findElements(By.id("classifier-dropdown")).size() > 0 ;
			assert driver.findElements(By.id("priorityscheme-dropdown")).size() > 0;
			assert driver.findElements(By.id("classifier_instance_chosen")).size() > 0;
			assert driver.findElements(By.id("run-classifier-btn")).size() > 0;


			//switch to SCALe-only mode
			dropdown.selectByVisibleText("SCALe-only");
			webApp.waitForAlertConditionsTableLoad();
			dropdown = new Select(driver.findElement(By.id("scaife_mode_select")));

			assertEquals("SCALe-only", dropdown.getFirstSelectedOption().getText());
			assert driver.findElements(By.id("classifier-dropdown")).size() == 0;
			assert driver.findElements(By.id("priorityscheme-dropdown")).size() == 0;
			assert driver.findElements(By.id("classifier_instance_chosen")).size() == 0;
			assert driver.findElements(By.id("run-classifier-btn")).size() == 0;


		} finally {
			cleanupWebApp( webApp, projectName);
		}
	}

	/**
	 * Test that setting view to false, then going home, then opening a
	 * project, alerts are still displayed
	 *
	 * @throws InterruptedException
	 */
	public void testViewPersist() throws InterruptedException {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, "toy/toy.zip").toString();
		String toolPath = new File(this.config.inputDirectory, "toy/analysis/rosecheckers_oss.txt").toString();

		try {
			// Build a model of our Web App with the given driver.
			webApp = this.config.createApp();

			// Launch the app, create a project, then go back to the home page
			webApp.launch();
			WebDriver driver = webApp.getDriver();
			webApp.createSimpleProject(projectName, projectDescription, archivePath, toolPath,
					ToolInfo.Rosecheckers_OSS_C_ID);
			webApp.waitForAlertConditionsTableLoad();
			WebElement fusedOffButton = webApp.getDriver().findElement(By.id("fused_off_button"));
			new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions
					.refreshed(ExpectedConditions
					.elementToBeClickable(fusedOffButton)));
			fusedOffButton.click();
			webApp.validatePage();
			webApp.waitForAlertConditionsTableLoad();
			webApp.goHome();
			driver.findElement(By.linkText(projectName)).click();
			webApp.waitForAlertConditionsTableLoad();
			webApp.AlertConditionsViewer.changeAlertConditionsPerPage(100);

			assertEquals(webApp.AlertConditionsViewer.getAlertConditionRows().size(),
					Integer.parseInt(driver.findElement(By.id("totalRecords"))
							.getText()));

		} finally {
			cleanupWebApp( webApp, projectName);
		}
	}

	 /** Test that ensures page filtering persists when the application is reloaded
	 * @throws InterruptedException
	 */
	public void testFilterPersistence() throws InterruptedException {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();

		try {
			webApp = this.config.createApp();
			webApp.launch();
			WebDriver driver = webApp.getDriver();

			// Create project
			String projectDescription = projectName.hashCode() + "";
			String archivePath = new File(this.config.inputDirectory, "toy/toy.zip").toString();
			String alertPath = new File(this.config.inputDirectory, "toy/analysis/rosecheckers_oss.txt").toString();

			webApp.createSimpleProject(projectName, projectDescription, archivePath, alertPath,
					ToolInfo.Rosecheckers_OSS_C_ID);

			webApp.validatePage();

			int index = 2; //complex verdicts
			Verdict[] verdictTexts = Verdict.values();
			Verdict selectedVerdict = verdictTexts[index];

			//get the number of Alerts in the GUI
			int totalAlerts = webApp.AlertConditionsViewer.getAlertConditionRows().size();

			// Add the verdict to first 10 alerts
			int numOfRowsToFilter = 10;

			for (int rowCounter = 1; rowCounter < numOfRowsToFilter; rowCounter++) {
				// Avoid Stale Reference
				AlertConditionRow row = webApp.AlertConditionsViewer.getOneAlertConditionRow(rowCounter);

				row.setVerdict(selectedVerdict);
			}

			webApp.waitForAlertConditionsTableLoad();

			Select select = new Select(webApp.getDriver().findElement(By.id("verdict")));
			select.selectByIndex(index);

			//filter by the selected index
			webApp.AlertConditionsViewer.filter();
			webApp.validatePage();
			webApp.waitForAlertConditionsTableLoad();

			assertEquals(webApp.AlertConditionsViewer.getAlertConditionRows().size(), numOfRowsToFilter-1);

			webApp.AlertConditionsViewer.clearFilter();
			webApp.validatePage();
			webApp.waitForAlertConditionsTableLoad();

			assertEquals(webApp.AlertConditionsViewer.getAlertConditionRows().size(), totalAlerts);

		} finally {
			cleanupWebApp(webApp, projectName);
		}
	}

	/**
	 * test to see if update project database keeps previous determinations
	 *
	 * @throws InterruptedException
	 */
	public void testUpdateProjectDatabase() throws InterruptedException {

		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";
		String archivePath = new File(this.config.inputDirectory, "dos2unix/dos2unix-7.2.2.zip").toString();
		String analysisPath = new File(this.config.inputDirectory, "dos2unix/analysis/cppcheck_oss.v.1.83.xml").toString();
		String analysisPath2 = new File(this.config.inputDirectory, "dos2unix/analysis/rosecheckers_oss.txt").toString();

		try {
			// Build a model of our Web App with the given driver.
			webApp = this.config.createApp();

			// Launch the app, create a project, then go back to the home page
			webApp.launch();
			webApp.createSimpleProject(projectName, projectDescription, archivePath, analysisPath,
					ToolInfo.CPPCHECK_OSS_C_ID);

			//set first AlertCondition to false
			AlertConditionRow row = webApp.AlertConditionsViewer.getOneAlertConditionRow(1);
			row.setVerdict(Verdict.False);
			webApp.waitForAlertConditionsTableLoad();
			webApp.goHome();

			new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions
					.elementToBeClickable(webApp.getDriver()
							.findElement(By.linkText(projectName))));
			WebElement projectLink = webApp.getDriver()
					.findElement(By.linkText(projectName));
			projectLink.findElement(By.xpath("../.."))
				.findElements(By.tagName("td")).get(3)
				.findElement(By.className("edit_project")).click();

			//add cppcheck_oss SA tool output
			ToolRow toolRow = webApp.UploadAnalysis.getToolRowById(ToolInfo.Rosecheckers_OSS_C_ID, false);
			toolRow.checkbox.click();
			toolRow.uploadFile.sendKeys(analysisPath2);
			new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions
					.elementToBeClickable(webApp.getDriver()
							.findElement(By.id("update_project_button"))));
			webApp.getDriver().findElement(By.id("update_project_button"))
				.click();
			webApp.validatePage();
			webApp.waitForAlertConditionsTableLoad();
			int totalRecords = webApp.AlertConditionsViewer.getTotalRecords();
			assertEquals(259, totalRecords);

			new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions
					.elementToBeClickable(webApp.getDriver()
							.findElement(By.id("verdict"))));
			Select vDropdown = new Select(webApp.getDriver()
					.findElement(By.id("verdict")));
			vDropdown.selectByVisibleText("False");
			new WebDriverWait(webApp.getDriver(), 10).until(ExpectedConditions
					.elementToBeClickable(webApp.getDriver()
							.findElement(By.xpath("//input[@value='Filter']"))));
			webApp.getDriver().findElement(
					By.xpath("//input[@value='Filter']")).click();

			totalRecords = Integer.parseInt(webApp.getDriver()
					.findElement(By.id("totalRecords")).getText());

			//false determination set previously should still be there
			assertEquals(1, totalRecords);

		} finally {
			cleanupWebApp(webApp, projectName);
		}
	}

	/**
	 * Test tool version selects -- cppcheck_oss 1.83
	 */
	public void testToolVersionSelectsCppcheck183() {
		String toolVersion = "1.83";
		String testProjectPath = new File(this.config.inputDirectory, "dos2unix").toString();
		String testInputPath = new File(testProjectPath, "analysis").toString();
		String archivePath = new File(testProjectPath, "dos2unix-7.2.2.zip").toString();
		String cppcheckPath = new File(testInputPath, "cppcheck_oss.v." + toolVersion + ".xml").toString();

		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";


		HashMap<String, String> tools = new HashMap<String, String>();
		tools.put(cppcheckPath, ToolInfo.CPPCHECK_OSS_C_ID);

		HashMap<String, String> toolVersions = new HashMap<String, String>();
		toolVersions.put(ToolInfo.CPPCHECK_OSS_C_ID, toolVersion);

		try {
			webApp = this.config.createApp();
			webApp.launch();
			webApp.createMultiToolVersionProject(projectName, projectDescription, archivePath, tools, toolVersions);
			assertEquals(21, webApp.AlertConditionsViewer.getTotalRecords());
		} finally {
			cleanupWebApp( webApp, projectName);
		}
	}

	/**
	 * Test tool version selects -- fortify
	 */
	public void testToolVersionSelectsFortify6() {
		String toolVersion = "6.10.0120";
		String testProjectPath = new File(this.config.inputDirectory, "dos2unix").toString();
		String testInputPath = new File(testProjectPath, "analysis").toString();
		String archivePath = new File(testProjectPath, "dos2unix-7.2.2.zip").toString();
		String fortifyPath = new File(testInputPath, "fortify.v." + toolVersion + ".xml").toString();

		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";


		HashMap<String, String> tools = new HashMap<String, String>();
		tools.put(fortifyPath, ToolInfo.Fortify_C_ID);

		HashMap<String, String> toolVersions = new HashMap<String, String>();
		toolVersions.put(ToolInfo.Fortify_C_ID, toolVersion);

		try {
			webApp = this.config.createApp();
			webApp.launch();
			webApp.createMultiToolVersionProject(projectName, projectDescription, archivePath, tools, toolVersions);
			assertEquals(22, webApp.AlertConditionsViewer.getTotalRecords());
		} finally {
			cleanupWebApp( webApp, projectName);
		}
	}

	/**
	 * Test tool version selects -- cppcheck_oss 1.00
	 */
	public void testToolVersionSelectsCppcheck100() {
		String toolVersion = "1.00";
		String testProjectPath = new File(this.config.inputDirectory, "jasper").toString();
		String testInputPath = new File(testProjectPath, "analysis").toString();
		String archivePath = new File(testProjectPath, "jasper-1.900.zip").toString();
		String cppcheckPath = new File(testInputPath, "cppcheck_oss.v." + toolVersion + ".xml").toString();

		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";


		HashMap<String, String> tools = new HashMap<String, String>();
		tools.put(cppcheckPath, ToolInfo.CPPCHECK_OSS_C_ID);

		HashMap<String, String> toolVersions = new HashMap<String, String>();
		toolVersions.put(ToolInfo.CPPCHECK_OSS_C_ID, toolVersion);

		try {
			webApp = this.config.createApp();
			webApp.launch();
			webApp.createMultiToolVersionProject(projectName, projectDescription, archivePath, tools, toolVersions);
			assertEquals(521, webApp.AlertConditionsViewer.getTotalRecords());
		} finally {
			cleanupWebApp( webApp, projectName);
		}
	}

	public void testSwampCppcheckUpload() {
		ScaleWebApp webApp = null;
		String projectName = UUID.randomUUID().toString();
		String projectDescription = projectName.hashCode() + "";

		String testProjectPath = new File(this.config.inputDirectory, "dos2unix").toString();
		String testInputPath = new File(testProjectPath, "analysis").toString();
		String archivePath = new File(testProjectPath, "dos2unix-7.2.2.zip").toString();
		String cppcheckPath = new File(testInputPath, "cppcheck_v_1.75_Ubuntu_12.04_scarf.xml").toString();
		String cppcheckVersion = "1.86";

		try {
			webApp = this.config.createApp();

			webApp.launch();
			webApp.createSwampProject(projectName, projectDescription, archivePath, cppcheckPath,
					ToolInfo.SWAMP_OSS_C_ID, ToolInfo.CPPCHECK_OSS_C_TXT, cppcheckVersion);
			assertEquals(15, webApp.AlertConditionsViewer.getTotalRecords());
		} finally {
			cleanupWebApp( webApp, projectName);
		}

	}

}
