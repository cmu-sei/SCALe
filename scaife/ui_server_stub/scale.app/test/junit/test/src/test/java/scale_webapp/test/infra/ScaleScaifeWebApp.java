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

import static org.junit.Assert.assertTrue;

import java.io.File;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.regex.Pattern;
import java.util.Iterator;

import org.openqa.selenium.Alert;
import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.NoAlertPresentException;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.StaleElementReferenceException;
import org.openqa.selenium.TimeoutException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.support.ui.ExpectedCondition;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.Select;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.gargoylesoftware.htmlunit.javascript.host.Console;

import org.junit.Assert;

import scale_webapp.test.infra.ScaleWebApp.ToolRow;
import scale_webapp.test.infra.ScaleWebApp.AlertConditionsViewerPage.AlertConditionRow;
import scale_webapp.test.infra.ScaleWebApp.HomePage.ProjectRow;
//import scale_webapp.test.scenario.webApp;

public class ScaleScaifeWebApp extends ScaleWebApp {
	private String scaife_user;
	private String scaife_password;

	public ScaifeIntegrationsPage ScaifeIntegrations = new ScaifeIntegrationsPage();

	/**
	 * Class constructor
	 *
	 * @param protocol
	 * @param host
	 * @param port
	 * @param user
	 * @param password
	 * @param scaife_user
	 * @param scaife_password
	 * @param driver
	 */
	public ScaleScaifeWebApp(String protocol, String host, int port, String user, String password, String scaife_user, String scaife_password, WebDriver driver) {

		super(protocol, host, port, user, password, driver);
		this.scaife_user = scaife_user;
		this.scaife_password = scaife_password;

	}

	public Boolean scaifeActive() {

		if (driver.findElements(By.id("connect_to_scaife")).size() > 0) {
			//System.out.println("not connected to SCAIFE");
			return false;
		} else if (driver.findElements(By.id("disconnect_from_scaife")).size() > 0) {
			//System.out.println("connected to SCAIFE");
			return true;
		} else {
			throw new NoSuchElementException("SCAIFE session indeterminate");
		}

	}

	public Boolean connectToScaife() {

		Boolean connected = false;
		waitForPageLoad(driver);
		if (! scaifeActive()) {
			System.out.println("establishing connection to SCAIFE");
			new WebDriverWait(driver, 10).until(ExpectedConditions
					.elementToBeClickable(driver.findElement(By.id("connect_to_scaife"))));
			driver.findElement(By.id("connect_to_scaife")).click();
			new WebDriverWait(driver, 30).until(ExpectedConditions
					.visibilityOfElementLocated(By.id("scaife-login-modal")));
			WebElement modal = driver.findElement(By.id("scaife-login-modal"));
			modal.findElement(By.id("user_field")).sendKeys(this.scaife_user);
			modal.findElement(By.id("password_field")).sendKeys(this.scaife_password);
			WebElement button = modal.findElement(By.id("scaifeLoginForm"))
					.findElement(By.xpath("//input[@value='Log In']"));
			button.click();
			waitForPageLoad(driver);
			new WebDriverWait(driver, 10).until(ExpectedConditions
					.visibilityOf(driver.findElement(By.id("disconnect_from_scaife"))));
			connected = true;
		} else {
			System.out.println("already connected to SCAIFE");
			connected = true;
		}
		return connected;

	}

	public Boolean disconnectFromScaife() {

		Boolean disconnected = false;
		waitForPageLoad(driver);
		if (scaifeActive()) {
			System.out.println("tearing down connection to SCAIFE");
			new WebDriverWait(driver, 10).until(ExpectedConditions
					.elementToBeClickable(driver.findElement(By.id("disconnect_from_scaife"))));
			driver.findElement(By.id("disconnect_from_scaife")).click();
			waitForPageLoad(driver);
			new WebDriverWait(driver, 10).until(ExpectedConditions
					.visibilityOf(driver.findElement(By.id("connect_to_scaife"))));
			disconnected = true;
		} else {
			System.out.println("already disconnected from SCAIFE");
			disconnected = true;
		}
		return disconnected;

	}

	public void launch(Boolean connect) {
		super.launch();
		if (connect) {
			assertTrue("failed to connect to SCAIFE", connectToScaife());
			System.out.println("launched app connected to SCAIFE");
		} else {
			System.out.println("launched app without connecting to SCAIFE");
		}
	}

	public void launch() {
		launch(true);
	}

	public void uploadProject(String name) {
		this.goHome();
		uploadProject(this.Home.getProjectRowByName(name));
	}
	public void uploadProject(ProjectRow project) {
		project.uploadLink.click();
		new WebDriverWait(driver, 500).until(ExpectedConditions.alertIsPresent());
		Alert alert = driver.switchTo().alert();
		if (alert.getText().contains("upload requires")) {
			throw new AssertionError(alert.getText());
		}
		alert.accept();
		validatePage();
	}

	public void uploadLastProject() {
		uploadProject(this.Home.getLastProjectRow());
	}

	public class ScaifeIntegrationsPage {

		public String dialogId = "scaife-integration";
		public String successMsgId = "scaife-integration-success-msg";

		public WebElement dialogElement() {
			return driver.findElement(By.id(dialogId));
		}

		public WebElement successMsgElement() {
			return driver.findElement(By.id(successMsgId));
		}

		public Boolean successMsgIsVisible() {
			return this.successMsgElement().isDisplayed();
		}

		public void waitForVisibilityOfSuccessMsg() {
			// waiting on the successMsgElement() directly
			// can sometimes result in stale references
			new WebDriverWait(driver, 100).until(ExpectedConditions
					.visibilityOfElementLocated(By.id(successMsgId)));
		}

		public Set<String> uploadedItemLabels(String itemType) {
			Set<String> uploaded = new HashSet<>();
			if (! itemType.endsWith("s")) {
				itemType += "s";
			}
			String tbodyXpath = String.format("//div[@id = '%s']//table[contains(@class, 'scaife-%s')]//tbody", dialogId, itemType);
			WebElement tbodyElm = driver.findElement(By.xpath(tbodyXpath));
			List<WebElement> rows = tbodyElm.findElements(By.tagName("tr"));
			for (WebElement row : rows) {
				List<WebElement> cols = row.findElements(By.tagName("td"));
				if (cols.size() >= 2) {
					uploaded.add(ListItem.label(
							cols.get(0).getText().trim(),
							cols.get(1).getText().trim()));
				}
			}
			return uploaded;
		}

		public AccordionList getLangUploadList() {
			return new AccordionList(dialogElement().findElement(By.className("add-lang-list")));
		}

		public TableList getTaxoUploadList() {
			return new TableList(dialogElement().findElement(By.className("add-taxo-list")));
		}

		public TableList getToolUploadList() {
			return new TableList(dialogElement().findElement(By.className("add-tool-list")));
		}

	}

	public void goToUploadPage(String type) {
		ScaleScaifeWebApp.this.goHome();
		Actions action = new Actions(driver);
		String tabXpath = String.format("//li[@id = '%s-tab']//a[@id = '%s-tab-link']", type, type);
		WebElement tabElm = driver.findElement(By.xpath(tabXpath));
		//scrollIntoView(tabElm);
		//action.moveToElement(tabElm).click().perform();
		WebElement uploadElm = tabElm.findElement(By.xpath("../ul/li//a[contains(text(), 'Upload')]"));
		//new WebDriverWait(driver, 5).until(ExpectedConditions
		//		.elementToBeClickable(uploadElm));
		//action.moveToElement(uploadElm).click().perform();
		powerScrollAndClickElement(uploadElm);
		waitForPageLoad(driver);
		new WebDriverWait(driver, 1000).until(ExpectedConditions
				.visibilityOfElementLocated(By.id(ScaifeIntegrations.dialogId)));
	}

	public void goToLangUploadPage() {
		goToUploadPage("lang");
	}

	public void goToTaxoUploadPage() {
		goToUploadPage("taxo");
	}

	public void goToToolUploadPage() {
		goToUploadPage("tool");
	}

	public Boolean selectItemsByName(String itemType, String name, List<String> versions) {
		String addListClass = String.format("add-%s-list", itemType);
		String addButtonClass = String.format("add-%s-button", itemType);
		WebElement dialogElm = ScaifeIntegrations.dialogElement();
		Set<String> uploadedLabels = ScaifeIntegrations.uploadedItemLabels(itemType);
		WebElement itemListElm = dialogElm.findElement(By.className(addListClass));
		String uploadName = name;
		CompoundList itemList;
		if (itemType.equals("lang")) {
			itemList = new AccordionList(itemListElm);
		} else if (itemType.equals("taxo")) {
			itemList = new TableList(itemListElm);
		} else if (itemType.equals("tool")) {
			itemList = new TableList(itemListElm);
			uploadName = name.split(" - ")[0];
		}
		else {
			throw new AssertionError("unknown upload item type");
		}
		Boolean itemsWereSelected = false;
		for (String version : versions) {
			if (version.equals("all")) {
				if (itemList.containsSublistName(name)) {
					if (itemList.getSublistByName(name).size() > 0) {
						itemList.getSublistByName(name).selectAll();
						itemsWereSelected = true;
					}
				}
			} else {
				String label = ListItem.label(name,  version);
				String uploadLabel = ListItem.label(uploadName,  version);
				assert(itemList.containsLabel(label) || uploadedLabels.contains(uploadLabel));
				if (itemList.containsLabel(label)) {
					itemList.itemSelectByLabel(label);
					itemsWereSelected = true;
				}
			}
		}
		WebElement elm = dialogElm.findElement(By.xpath(String.format(".//button[contains(@class, '%s')]", addButtonClass)));
		Actions action = new Actions(driver);
		// this scrolls things OUT of view sometimes, so don't use it
		//((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView(true);", tabElm);
		action.moveToElement(elm).click().perform();
		return itemsWereSelected;
	}

	public void uploadSelectedItems(String itemType) {
		String submitButtonClass = String.format("%sUpload-submit", itemType);
		Actions action = new Actions(driver);
		WebElement dialogElm = ScaifeIntegrations.dialogElement();
		// should probably check that things are actually selected
		// for upload, but not doing that yet
		WebElement button = dialogElm.findElement(By.className(submitButtonClass));
		scrollIntoView(button);
		action.moveToElement(button).click().perform();
		this.ScaifeIntegrations.waitForVisibilityOfSuccessMsg();
	}

	public void uploadLanguagesByName(String name, List<String> versions) {
		Map<String, List<String>> items = new HashMap<>();
		items.put(name,  versions);
		uploadLanguagesByName(items);
	}
	public void uploadLanguagesByName(Map<String, List<String>> items) {
		Boolean itemsWereSelected = false;
		for (Map.Entry<String, List<String>>  entry : items.entrySet()) {
			if (selectItemsByName("lang", entry.getKey(), entry.getValue()))
				itemsWereSelected = true;
		}
		if (itemsWereSelected) {
			uploadSelectedItems("lang");
			System.out.println("language uploads complete");

		} else {
			System.out.println("no languages selected (already uploaded?)");
		}
	}

	public void uploadTaxonomiesByName(String name, List<String> versions) {
		Map<String, List<String>> items = new HashMap<>();
		items.put(name,  versions);
		uploadTaxonomiesByName(items);
	}
	public void uploadTaxonomiesByName(Map<String, List<String>> items) {
		Boolean itemsWereSelected = false;
		for (Map.Entry<String, List<String>>  entry : items.entrySet()) {
			if (selectItemsByName("taxo", entry.getKey(), entry.getValue()))
				itemsWereSelected = true;
		}
		if (itemsWereSelected) {
			uploadSelectedItems("taxo");
			System.out.println("taxonomy uploads complete");
		} else {
			System.out.println("no taxonomies selected (already uploaded?)");
		}
	}

	public void uploadToolsByName(String name, List<String> versions) {
		Map<String, List<String>> items = new HashMap<>();
		items.put(name,  versions);
		uploadToolsByName(items);
	}
	public void uploadToolsByName(Map<String, List<String>> items) {
		Boolean itemsWereSelected = false;
		for (Map.Entry<String, List<String>>  entry : items.entrySet()) {
			if (selectItemsByName("tool", entry.getKey(), entry.getValue()))
				itemsWereSelected = true;
		}
		if (itemsWereSelected) {
			uploadSelectedItems("tool");
			System.out.println("tool uploads complete");

		} else {
			System.out.println("no tools selected (already uploaded?)");
		}
	}

	public String createManualProjectOnePartA(AppConfig config) {

		String projectName = "dos2unix/rosecheckers ";
		projectName += UUID.randomUUID().toString();
		String projectDescription = "test project selenium";
		String toolID = ToolInfo.Rosecheckers_OSS_C_ID;
		String archiveFile = new File(config.inputDirectory, "dos2unix/dos2unix-7.2.2.tar.gz").toString();
		String analysisFile = new File(config.inputDirectory, "dos2unix/analysis/rosecheckers_oss.txt").toString();

		System.out.printf("creating project: %s\n", projectName);
		this.createSimpleProject(projectName, projectDescription, archiveFile, analysisFile, toolID, false); // do not
		System.out.printf("created phase 1 project: %s\n", projectName);

		String lang = "C";
		List<String> lang_versions = Arrays.asList("89");
		this.UploadAnalysis.selectLanguagesByName(lang, lang_versions);
		System.out.println("selected C89");
		this.finishCreatingProjectFromDatabase();

		System.out.printf("submitted project: %s\n", projectName);

		this.waitForAlertConditionsTableLoad();

		System.out.printf("created project: %s\n", projectName);

		// set some to verdict true
		Select menu = new Select(this.driver.findElement(By.id("checker")));
		String selection = "EXP12-C";
		try {
			menu.selectByVisibleText(selection);
		} catch (org.openqa.selenium.NoSuchElementException e) {
			throw new NoSuchElementException("Cannot make checker selection " + selection);
		}
		this.AlertConditionsViewer.filter();
		this.waitForAlertConditionsTableLoad();
		this.AlertConditionsViewer.getSelectAll().click();
		Map<String, String> determinations = new HashMap<>();
		determinations.put("mass_update_verdict", "True");
		this.AlertConditionsViewer.setMassUpdateDets(determinations);

		// set some to verdict false
		menu = new Select(driver.findElement(By.id("checker")));
		selection = "FIO30-C";
		try {
			menu.selectByVisibleText(selection);
		} catch (org.openqa.selenium.NoSuchElementException e) {
			throw new NoSuchElementException("Cannot make checker selection " + selection);
		}
		this.AlertConditionsViewer.filter();
		this.waitForAlertConditionsTableLoad();
		this.AlertConditionsViewer.getSelectAll().click();
		determinations = new HashMap<String, String>();
		determinations.put("mass_update_verdict", "False");
		this.AlertConditionsViewer.setMassUpdateDets(determinations);

		// upload languages (already defined above)
		// because we're uploading from splash page, need
		// all versions of the relevant tool languages
		Map<String, List<String>> langUploads = new HashMap<>();
		langUploads.put("C", Arrays.asList("all"));
		langUploads.put("C++", Arrays.asList("all"));
		this.goToLangUploadPage();
		this.uploadLanguagesByName(langUploads);

		// upload taxonomies
		Map<String, List<String>> taxos = new HashMap<>();
		taxos.put("CERT C Rules", Arrays.asList("2016 Edition"));
		taxos.put("CERT C++ Rules", Arrays.asList("2016 Edition (published 2017)"));
		this.goToTaxoUploadPage();
		this.uploadTaxonomiesByName(taxos);

		// upload tools
		Map<String, List<String>> tools = new HashMap<>();
		tools.put(ToolInfo.Rosecheckers_OSS_C_TXT, Arrays.asList(""));
		this.goToToolUploadPage();
		this.uploadToolsByName(tools);

		// upload project
		System.out.printf("uploading project %s\n", projectName);
		this.uploadProject(projectName);

		this.openProjectAlertsPage(projectName);

		// create and run a classifier
		this.createAndRunClassifier(projectName, "Random Forest");

		System.out.printf("project created: %s\n", projectName);
		return projectName;

	}

	public String createManualProjectOnePartB(AppConfig config) {

		String projectName = "microjuliet/cppcheck ";
		projectName += UUID.randomUUID().toString();
		String projectDescription = "test project selenium";
		String toolID = ToolInfo.CPPCHECK_OSS_C_ID;
		String dataDir = new File(config.inputDirectory, "demo/micro_juliet_v1.2_cppcheck_b").toString();
		String archiveFile = new File(dataDir, "micro_juliet_cpp.zip").toString();
		String analysisFile = new File(dataDir, "micro_juliet_cppcheck_tool_output.xml").toString();
		String manifestFile = new File(dataDir, "micro_juliet_cpp_manifest.xml").toString();
		String fileInfoFile = new File(dataDir, "micro_juliet_cpp_files.csv").toString();
		String functionInfoFile = new File(dataDir, "micro_juliet_cpp_functions.csv").toString();

		System.out.printf("creating project: %s\n", projectName);
		this.createSimpleProject(projectName, projectDescription, archiveFile, analysisFile, toolID, false); // do not
		System.out.printf("created phase 1 project: %s\n", projectName);

		Map<String, List<String>> langSelects = new HashMap<>();
		langSelects.put("C", Arrays.asList("89"));
		langSelects.put("C++", Arrays.asList("98"));
		this.UploadAnalysis.selectLanguagesByName(langSelects);
		System.out.println("selected C89, CPP98");

		// test suit components
		this.UploadAnalysis.enableTestSuite();
		this.UploadAnalysis.setTestSuiteName("MicroJuliet");
		this.UploadAnalysis.setTestSuiteVersion("1.2");
		this.UploadAnalysis.setTestSuiteType("juliet");
		this.UploadAnalysis.setTestSuiteSardId("86");
		this.UploadAnalysis.setTestSuiteAuthorSource("someAuthor");
		this.UploadAnalysis.setTestSuiteLicenseString("someLicense");
		this.UploadAnalysis.setTestSuiteManifestFile(manifestFile);
		this.UploadAnalysis.setTestSuiteFileInfoFile(fileInfoFile);
		this.UploadAnalysis.setTestSuiteFunctionInfoFile(functionInfoFile);

		this.finishCreatingProjectFromDatabase();
		System.out.printf("submitted project: %s\n", projectName);

		this.waitForAlertConditionsTableLoad();
		System.out.printf("created project: %s\n", projectName);

		// upload languages (already defined above)
		// because we're uploading from splash page, need
		// all versions of the relevant tool languages
		Map<String, List<String>> langUploads = new HashMap<>();
		langUploads.put("C", Arrays.asList("all"));
		langUploads.put("C++", Arrays.asList("all"));
		this.goToLangUploadPage();
		this.uploadLanguagesByName(langUploads);

		// upload taxonomies
		Map<String, List<String>> taxos = new HashMap<>();
		taxos.put("CERT C Rules", Arrays.asList("2016 Edition"));
		taxos.put("CERT C++ Rules", Arrays.asList("2016 Edition (published 2017)"));
		taxos.put("CWE", Arrays.asList("2.11"));
		this.goToTaxoUploadPage();
		this.uploadTaxonomiesByName(taxos);

		// upload tools
		Map<String, List<String>> tools = new HashMap<>();
		tools.put(ToolInfo.CPPCHECK_OSS_C_TXT, Arrays.asList("1.86"));
		this.goToToolUploadPage();
		this.uploadToolsByName(tools);

		// upload project
		System.out.printf("uploading project %s\n", projectName);
		this.uploadProject(projectName);

		this.openProjectAlertsPage(projectName);

		// create and run a classifier
		this.createAndRunClassifier(projectName, "Random Forest");

		return projectName;

	}
	
	public void createAndRunClassifier(String projectName, String classifierType) {
		createAndRunClassifier(projectName, classifierType, null, null);
	}
	public void createAndRunClassifier(String projectName, String classifierType, String ahpoName, String adaptiveHeurName) {

		// expects to already be on project alerts page		
		String classifierName = this.createClassifier(projectName,  classifierType, ahpoName, adaptiveHeurName);
		this.runClassifier(classifierName);

	}
	
	public String createClassifier(String projectName, String classifierType) {
		return createClassifier(projectName, classifierType, null, null);
	}
	public String createClassifier(String projectName, String classifierType, String ahpoName, String adaptiveHeurName) {

		// expects to already be on project alerts page

		new WebDriverWait(driver, 40).until(ExpectedConditions
				.visibilityOfElementLocated(By.id("classifier-dropdown")));

		int typeCount = 0;
		List<WebElement> classifierList = driver.findElements(By.xpath("//li[@id='classifier-dropdown']//ul//li//a[contains(@class, 'existing-classifier')]"));
		for (WebElement c : classifierList) {
			if(c.getAttribute("innerHTML").contains(classifierType))
				typeCount += 1;
		}
		String classifierName = String.format("%s: %s %s", "selenium", classifierType, typeCount);
		System.out.printf("classifierName: %s\n", classifierName);

		Actions action = new Actions(driver);

		new WebDriverWait(driver, 40).until(ExpectedConditions
				.elementToBeClickable(By.xpath("//li[@id='classifier-dropdown']//a")));
		action.moveToElement(driver.findElement(By.xpath("//li[@id='classifier-dropdown']//a"))).click().perform();

		new WebDriverWait(driver, 40).until(ExpectedConditions
				.elementToBeClickable(By.xpath("//li[@id='new-classifier-link']//a")));
		action.moveToElement(driver.findElement(By.xpath("//li[@id='new-classifier-link']//a"))).perform();

		new WebDriverWait(driver, 40).until(ExpectedConditions
				.visibilityOfElementLocated(By.className("classifiers")));
		//action.moveToElement(driver.findElements(By.className("classifiers")).get(0)).click().perform();

		String selectXpath = String.format("//a[contains(@class, 'classifiers') and text() = '%s']", classifierType);
		WebElement choiceElm = driver.findElement(By.xpath(selectXpath));
		//action.moveToElement(choiceElm).click().perform();
		powerClickElement(choiceElm);
		// Classifier Modal is opened
		new WebDriverWait(driver, 30)
				.until(ExpectedConditions.visibilityOfElementLocated(By.id("modal-placement")));

		// set values in the Classifier Modal
		driver.findElement(By.id("classifier_name")).sendKeys(classifierName);

		String projectSelectXpath = String.format("//div[@id='all_projects']//li[@class='list_item' and contains(text(), '%s')]", projectName);
		WebElement projectSelected = driver.findElement(By.xpath(projectSelectXpath));
		projectSelected.click();

		// Add projects to the selected projects section
		WebElement add_button = driver.findElement(By.id("add_button"));

		new WebDriverWait(driver, 10).until(ExpectedConditions.elementToBeClickable(add_button));
		add_button.click();

		new WebDriverWait(driver, 10).until(ExpectedConditions
				.presenceOfAllElementsLocatedBy(By.xpath("//div[@id='ah']//li[@class='ah-tabs ']//a")));

		if (adaptiveHeurName != null) {
			// Select the adaptive heuristic
			String ahXpath = String.format("\"//div[@id='ah']//li[@class='ah-tabs ']//a[contains(text(), '%s')]", adaptiveHeurName);
			WebElement ahSelected = driver.findElement(By.xpath(ahXpath));
			scrollIntoView(ahSelected);
			ahSelected.click();
		}

		if (ahpoName != null) {
			// Selected the AHPO
			Select ahpoSelect = new Select(driver.findElement(By.id("ahpoSelects")));
			ahpoSelect.selectByVisibleText(ahpoName);
		}

		WebElement submitButton = driver.findElement(By.id("submit-modal"));
		System.out.printf("submitting classifier: %s\n", classifierName);
		submitButton.click();

		try {
			new WebDriverWait(driver, 500)
				.until(ExpectedConditions.invisibilityOfElementLocated(By.id("modal-placement")));
			this.waitForAlertConditionsTableLoad(50);
		} catch (TimeoutException e) {
			// perhaps something went wrong, check for error text
			WebElement err_elm = driver.findElement(By.id("classifier-errors"));
			if (err_elm.isDisplayed()) {
				throw new TimeoutException("error creating classifier: " + err_elm.getText());
			}
		}

		return classifierName;
		
	}
	
	public void runClassifier(String classifierName) {
		
		this.waitForAlertConditionsTableLoad();
		// Run the classifier
		new WebDriverWait(driver, 30).until(ExpectedConditions
				.visibilityOfElementLocated(By.id("classifier_instance_chosen")));
		try {
			// this element sometimes goes stale, haven't tracked it down yet
			// meanwhile, sleep for a second while...whatever...happens.
			Thread.sleep(1000);
		} catch (InterruptedException e3) {
			e3.printStackTrace();
		}
		WebElement classifierSelectElm = driver.findElement(By.id("classifier_instance_chosen"));
		Select classifierSelect = new Select(classifierSelectElm);
		classifierSelect.selectByVisibleText(classifierName);
		System.out.printf("running classifier: %s\n", classifierName);
		String rcBtnId = "run-classifier-btn";
		scrollIntoView(driver.findElement(By.id(rcBtnId)));
		new WebDriverWait(driver, 20).until(ExpectedConditions
				.elementToBeClickable(driver.findElement(By.id(rcBtnId))));
		driver.findElement(By.id(rcBtnId)).click();
		try {
			// give the page a chance to update running status
			Thread.sleep(3000);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		new WebDriverWait(driver, 500).until(
				ExpectedConditions.textToBe(By.id(rcBtnId), "Classify"));
		this.waitForAlertConditionsTableLoad();
		
	}
	
}
