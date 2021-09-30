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
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.Iterator;
import java.util.concurrent.TimeUnit;

import org.openqa.selenium.Alert;
import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.NoAlertPresentException;
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

import scale_webapp.test.infra.ScaleWebApp.HomePage.ProjectRow;

import org.apache.commons.lang3.tuple.Pair;
import org.junit.Assert;

public class ScaleWebApp {
	private String protocol;
	private String host;
	private int port;
	private String scale_user;
	private String scale_password;
	private boolean connected = false;
	public AppConfig remoteConfig;
	public WebDriver driver;

	public HomePage Home = new HomePage();
	public NewProjectPage NewProject = new NewProjectPage();
	public UploadAnalysisPage UploadAnalysis = new UploadAnalysisPage();
	public EditPage Edit = new EditPage();
	public AlertConditionsViewerPage AlertConditionsViewer = new AlertConditionsViewerPage();
	public NewAlertPage NewAlert = new NewAlertPage();
	public PrioritySchemeModal PrioritySchemeModal = new PrioritySchemeModal();

	/**
	 * Class constructor
	 *
	 * @param protocol
	 * @param host
	 * @param port
	 * @param scale_user
	 * @param scale_password
	 * @param driver
	 */
	public ScaleWebApp(String protocol, String host, int port, String scale_user, String scale_password, WebDriver driver) {
		this.protocol = protocol;
		this.host = host;
		this.port = port;
		this.scale_user = scale_user;
		this.scale_password = scale_password;
		this.driver = driver;
		// this is only for locating the scale.app/scripts dir
		InputStream is = getClass().getResourceAsStream("/test_config.json");
		this.remoteConfig = new AppConfig(is, "local");
	}

	public void waitForPageLoad(WebDriver driver) {
		new WebDriverWait(driver, 50).until((ExpectedCondition<Boolean>) wd ->
											((JavascriptExecutor) wd).executeScript(
																					"return (document.readyState == 'complete' && jQuery.active == 0)"
																					).equals(true));
	}

	public void exportProject(String projectIdOrName) {
		String comparisonScript = new File(remoteConfig.root, "scripts/generate_and_compare_project_db.py").toString();
		ProcessBuilder pb = null;

		// default output is scale.app/db/external.sqlite3;
		// comparison python script will find it
		pb = new ProcessBuilder("python", comparisonScript, projectIdOrName);
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
			if (rc != 0) {
				throw new AssertionError(err);
			}
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

	/**
	 * Create a project with fused alertConditions, then turn fusion on.
	 *
	 * @param webApp
	 * @param projectName
	 * @param projectDescription
	 * @param archivePath
	 * @param cppcheckPath
	 * @param rosecheckersPath
	 * @return
	 */
	public void createProjectWithFusion(String projectName, String projectDescription,
                                            String archivePath, String cppcheckPath, String rosecheckersPath) {

		this.launch();
		this.goHome();
		this.Home.getNewProjectLink().click();
		this.validatePage();
		this.NewProject.getNameField().sendKeys(projectName);
		this.NewProject.getDescriptionField().sendKeys(projectDescription);
		this.NewProject.getCreateProjectButton().click();
		this.validatePage();

		this.UploadAnalysis.getArchiveUploader().sendKeys(archivePath);
		ToolRow toolRow;
		toolRow = this.UploadAnalysis.getToolRowById(ToolInfo.CPPCHECK_OSS_C_ID, false);
		toolRow.checkbox.click();
		toolRow.uploadFile.sendKeys(cppcheckPath);
		toolRow = this.UploadAnalysis.getToolRowById(ToolInfo.Rosecheckers_OSS_C_ID, false);
		toolRow.checkbox.click();
		toolRow.uploadFile.sendKeys(rosecheckersPath);

		this.UploadAnalysis.getCreateDatabaseButton().click();
		this.validatePage();

		new WebDriverWait(this.getDriver(), 10).until(ExpectedConditions.elementToBeClickable(this.UploadAnalysis.getCreateProjectFromDatabaseButton()));
		this.UploadAnalysis.getCreateProjectFromDatabaseButton().click();
		this.validatePage();

		WebDriver driver = this.getDriver();
		WebElement fusedOnButton = driver.findElement(By.id("fused_on_button"));
		new WebDriverWait(driver, 10).until(ExpectedConditions.elementToBeClickable(fusedOnButton));

		fusedOnButton.click();
		this.validatePage();
		this.waitForAlertConditionsTableLoad();
	}

	/**
	 * get homepage URL
	 *
	 * @return (String) homepage url
	 */
	public String getHomeUrl() {
            // No longer using HTTP basic authentication
            return String.format("%s://%s:%d", this.protocol, this.host, this.port);
	}

	/**
	 * check if exception caught
	 */
	public void validatePage() {
		if (this.driver.getTitle().indexOf("Exception caught") != -1) {
			Assert.fail("Internal Server Error");
		}
	}

	/**
	 * go to homepage
	 */
	public void launch() {
		this.driver.get(this.getHomeUrl());
                if (!this.connected) {
                    this.login();
                    this.connected = true;
                }
		validatePage();
	}

	/**
	 * Login to SCALe
	 */
	public Boolean login() {
		waitForPageLoad(this.driver);
		if (this.driver.findElements(By.id("connect_to_scaife")).size() == 0) {
                    System.out.println("already connected to SCAIFE");
                    return true;
                }

                System.out.println("Login to SCALe");
                new WebDriverWait(driver, 10).until(ExpectedConditions
                                                    .elementToBeClickable(driver.findElement(By.id("user-login"))));
                driver.findElement(By.id("user-login")).click();
                new WebDriverWait(driver, 30).until(ExpectedConditions
                                                    .visibilityOfElementLocated(By.id("user-login-modal")));
                WebElement modal = driver.findElement(By.id("user-login-modal"));
                WebElement button = modal.findElement(By.xpath("//input[@value='Sign Up']"));
                button.click();
                new WebDriverWait(driver, 30).until(ExpectedConditions
                                                    .visibilityOfElementLocated(By.id("user-register-modal")));
                modal = driver.findElement(By.id("user-register-modal"));
                modal.findElement(By.id("user_field")).sendKeys(this.scale_user);
                modal.findElement(By.id("password_field")).sendKeys(this.scale_password);
                button = modal.findElement(By.id("userRegisterForm"))
                    .findElement(By.xpath("//input[@value='Register']"));
                modal.findElement(By.id("firstname_field")).sendKeys("John");  // these must not be blank
                modal.findElement(By.id("lastname_field")).sendKeys("Doe");
                modal.findElement(By.id("org_field")).sendKeys("ACME");
                button.click();
                waitForPageLoad(driver);
                new WebDriverWait(driver, 10).until(ExpectedConditions
                                                    .visibilityOf(driver.findElement(By.id("user-logout"))));
                System.out.println("Login to SCALe succeeeded");
		return true;
	}


	/**
	 * close driver instance
	 */
	public void close() {
		this.driver.quit();
	}

	/**
	 * create a scale project using output from a single tool
	 *
	 * @param name
	 * @param desc
	 * @param archive
	 * @param path
	 * @param tool
	 */
	public void createSimpleProject(String name, String desc, String archive, String path, String tool) {
		this.createSimpleProject(name, desc, archive, path, tool, true);
	}

	public void createSimpleProject(String name, String desc, String archive, String path, String tool, boolean finish) {
		this.goHome();
		this.Home.getNewProjectLink().click();

		System.out.printf("project home, about to create: %s\n", name);
		validatePage();
		this.NewProject.getNameField().sendKeys(name);
		this.NewProject.getDescriptionField().sendKeys(desc);
		this.NewProject.getCreateProjectButton().click();
		System.out.printf("project initial: %s\n", name);

		System.out.printf("sending archive as key: %s\n", archive);
		this.UploadAnalysis.getArchiveUploader().sendKeys(archive);
		System.out.printf("sent archive as key: %s\n", archive);
		ToolRow toolRow = this.UploadAnalysis.getToolRowById(tool, false);
		toolRow.checkbox.click();
		toolRow.uploadFile.sendKeys(path);
		System.out.printf("sent tool as key: %s\n", path);

		new WebDriverWait(this.driver, 20).until(ExpectedConditions.elementToBeClickable(this.UploadAnalysis.getCreateDatabaseButton()));

		this.UploadAnalysis.getCreateDatabaseButton().click();
		System.out.printf("project db created: %s\n", name);

		new WebDriverWait(this.driver, 20).until(ExpectedConditions.visibilityOf(UploadAnalysis.getCreateProjectFromDatabaseButton()));
		validatePage();

		if (finish) {
			finishCreatingProjectFromDatabase();
		}

	}

	/**
	 * create a scale project using output from multiple tools with versions
	 *
	 * @param name
	 * @param desc
	 * @param archive
	 * @param swamp_tool
	 * @param sca_tool
	 * @param sca_tool_version
	 */
	public void createSwampProject(String name, String desc, String archive, String path, String swamp_tool, String sca_tool, String sca_tool_version) {
		this.createSwampProject(name, desc, archive, path, swamp_tool, sca_tool, sca_tool_version, true);
	}
	public void createSwampProject(String name, String desc, String archive, String path, String swamp_tool, String sca_tool, String sca_tool_version, boolean finish) {
		this.goHome();
		this.Home.getNewProjectLink().click();

		validatePage();
		this.NewProject.getNameField().sendKeys(name);
		this.NewProject.getDescriptionField().sendKeys(desc);
		this.NewProject.getCreateProjectButton().click();

		this.UploadAnalysis.getArchiveUploader().sendKeys(archive);

		ToolRow toolRow = this.UploadAnalysis.getToolRowById(swamp_tool, false);
		toolRow.checkbox.click();
		toolRow.uploadFile.sendKeys(archive);

		String selected_tool = sca_tool + "/" + sca_tool_version;
		toolRow.tool_options.selectByVisibleText(selected_tool);

		toolRow.uploadFile.sendKeys(path);

		if (finish) {
			finishCreatingProjectFromDatabase();
		}

	}

	/**
	 * create a scale project using output from multiple tools
	 *
	 * @param name
	 * @param desc
	 * @param archive
	 * @param tools
	 */
	public void createMultiToolProject(String name, String desc, String archive, HashMap<String, String> tools) {
		this.createMultiToolProject(name, desc, archive, tools, null, true);
	}
	public void createMultiToolProject(String name, String desc, String archive, HashMap<String, String> tools, List<String> langs) {
		this.createMultiToolProject(name, desc, archive, tools, langs, true);
	}
	public void createMultiToolProject(String name, String desc, String archive, HashMap<String, String> tools, List<String> langs, boolean finish) {
		this.goHome();
		this.Home.getNewProjectLink().click();

		validatePage();
		this.NewProject.getNameField().sendKeys(name);
		this.NewProject.getDescriptionField().sendKeys(desc);
		this.NewProject.getCreateProjectButton().click();

		this.UploadAnalysis.getArchiveUploader().sendKeys(archive);

		Set set = tools.entrySet();
		Iterator iterator = set.iterator();
		while(iterator.hasNext()) {
			Map.Entry entry = (Map.Entry)iterator.next();
			ToolRow toolRow = this.UploadAnalysis.getToolRowById((String)entry.getValue(), false);
			toolRow.checkbox.click();
			toolRow.uploadFile.sendKeys((String)entry.getKey());
		}

		new WebDriverWait(this.driver, 20).until(ExpectedConditions.elementToBeClickable(this.UploadAnalysis.getCreateDatabaseButton()));

		this.UploadAnalysis.getCreateDatabaseButton().click();

		new WebDriverWait(this.driver, 20).until(ExpectedConditions.visibilityOf(UploadAnalysis.getCreateProjectFromDatabaseButton()));
		validatePage();

		if (finish) {
			finishCreatingProjectFromDatabase();
		}

		//this.AlertConditionsViewer.
		//UploadAnalysisPage.uploadUserCols(userUploadsPath);
	}

	/**
	 * create a scale project using output from multiple tools with versions
	 *
	 * @param name
	 * @param desc
	 * @param archive
	 * @param tools
	 * @param toolVersions
	 */
	public void createMultiToolVersionProject(String name, String desc, String archive, HashMap<String, String> tools, HashMap<String, String> toolVersions) {
		this.createMultiToolVersionProject(name, desc, archive, tools, toolVersions, true);
	}
	public void createMultiToolVersionProject(String name, String desc, String archive, HashMap<String, String> tools, HashMap<String, String> toolVersions, boolean finish) {
		this.goHome();
		this.Home.getNewProjectLink().click();

		validatePage();
		this.NewProject.getNameField().sendKeys(name);
		this.NewProject.getDescriptionField().sendKeys(desc);
		this.NewProject.getCreateProjectButton().click();

		this.UploadAnalysis.getArchiveUploader().sendKeys(archive);

		Set set = tools.entrySet();
		Iterator iterator = set.iterator();
		while(iterator.hasNext()) {
			Map.Entry entry = (Map.Entry)iterator.next();
			String toolID = (String)entry.getValue();
			String toolVersion = toolVersions.get(toolID);
			ToolRow toolRow = this.UploadAnalysis.getToolRowById(toolID, false);
			toolRow.checkbox.click();
			if (toolRow.versions != null) {
				toolRow.versions.selectByVisibleText(toolVersion);
			}
			toolRow.uploadFile.sendKeys((String)entry.getKey());
		}

		new WebDriverWait(this.driver, 20).until(ExpectedConditions.elementToBeClickable(this.UploadAnalysis.getCreateDatabaseButton()));

		this.UploadAnalysis.getCreateDatabaseButton().click();

		new WebDriverWait(this.driver, 20).until(ExpectedConditions.visibilityOf(UploadAnalysis.getCreateProjectFromDatabaseButton()));
		validatePage();

		if (finish) {
			finishCreatingProjectFromDatabase();
		}

	}

	public void finishCreatingProjectFromDatabase() {
		new WebDriverWait(this.driver, 20).until(ExpectedConditions.elementToBeClickable(this.UploadAnalysis.getCreateDatabaseButton()));
		this.UploadAnalysis.getCreateDatabaseButton().click();
		new WebDriverWait(this.driver, 20).until(ExpectedConditions.visibilityOf(UploadAnalysis.getCreateProjectFromDatabaseButton()));
		validatePage();
		(new WebDriverWait(driver, 10)).until(new ExpectedCondition<Boolean>() {
				public Boolean apply(WebDriver d) {
					return UploadAnalysis.getCreateProjectFromDatabaseButton().isEnabled();
				}
			});
		this.UploadAnalysis.getCreateProjectFromDatabaseButton().click();
		this.waitForAlertConditionsTableLoad();
		validatePage();
	}

	/**
	 * Delete the project with the given name
	 *
	 * @param name
	 */
	public void destroyProject(String name) {
		this.goHome();
		ProjectRow project = this.Home.getProjectRowByName(name);
		project.destroyLink.click();

		try {
			new WebDriverWait(driver, 2).until(ExpectedConditions.alertIsPresent());
			Alert alert = driver.switchTo().alert();
			alert.accept();
			new WebDriverWait(driver, 3).until(ExpectedConditions
											.not(ExpectedConditions
													.presenceOfAllElementsLocatedBy(
																					By.linkText(name))));
		} catch (Exception e) {
			//exception handling
		}
		validatePage();
	}

	/**
	 * get WebDriver instance
	 *
	 * @return WebDriver instance
	 */
	public WebDriver getDriver() {
		return this.driver;
	}

	/**
	 * go to homepage
	 */
	public void goHome() {
		driver.get(this.getHomeUrl());

		try { // Sometimes there is an alert present when first logging in
			Alert alert = driver.switchTo().alert();
			alert.accept();
		}catch(NoAlertPresentException e) {
			; //do nothing
		}
		validatePage();
	}

	public void openProjectAlertsPage(String projectName) {
		this.goHome();
		new WebDriverWait(this.getDriver(), 10).until(ExpectedConditions
				.elementToBeClickable(this.getDriver()
						.findElement(By.linkText(projectName))));
		WebElement projectLink = this.getDriver()
			.findElement(By.linkText(projectName));
		scrollIntoView(projectLink);
		projectLink.click();
		this.validatePage();
	}

	public class HomePage {
		public class ProjectRow {

			public WebElement nameLink;
			public WebElement description;
			public WebElement createDbLink;
			public WebElement editLink;
			public WebElement exportCsvLink;
			public WebElement exportDbLink;
			public WebElement uploadLink;
			public WebElement destroyLink;

			public ProjectRow(WebElement tr) {
				List<WebElement> items = tr.findElements(By.tagName("td"));
				this.nameLink = items.get(0).findElement(By.tagName("a"));
				this.description = items.get(1);
				this.editLink = items.get(3).findElement(By.className("edit_project"));
				this.exportCsvLink = items.get(3).findElement(By.className("export_tables"));
				this.exportDbLink = items.get(3).findElement(By.className("export_db"));
				this.uploadLink = items.get(3).findElement(By.className("upload_project"));
				this.destroyLink = items.get(3).findElement(By.className("delete_project"));
			}

		}

		/**
		 * get new project link in GUI
		 *
		 * @return (WebElement) new project link
		 */
		public WebElement getNewProjectLink() {
			return driver.findElement(By.id("new_project"));
		}


		/**
		 * get edit project link in GUI
		 *
		 * @param projectName
		 * @return WebElement
		 */
		public WebElement getEditLink(String projectName) {
			ProjectRow projectRow = getProjectRowByName(projectName);
			return projectRow.editLink;
		}

		/**
		 * get upload project link in GUI
		 *
		 * @param projectName
		 * @return WebElement
		 */
		public WebElement getUploadLink(String projectName) {
			ProjectRow projectRow = getProjectRowByName(projectName);
			return projectRow.uploadLink;
		}

		/**
		 * get ProjectRow corresponding to the given name
		 *
		 * @param name
		 * @return ProjectRow
		 */
		public ProjectRow getProjectRowByName(String name) {
			List<ProjectRow> rows = getProjectRowsByName(name);
			for (ProjectRow row : getProjectRows()) {
				if (row.nameLink.getText().trim().equals(name)) {
					rows.add(row);
				}
			}
			// return the most recent project if there is more than
			// one with this name
			if (rows.size() == 0)
				throw new AssertionError("project not found: " + name);
			return rows.get(rows.size() - 1);
		}

		/**
		 * get all ProjectRows in the project
		 *
		 * @return List<ProjectRow>
		 */
		public List<ProjectRow> getProjectRows() {
			List<ProjectRow> result = new ArrayList<>();
			for (WebElement e : driver.findElements(By.tagName("tr"))) {
				if (e.findElements(By.xpath(".//td[1]//a")).size() > 0) {
					result.add(new ProjectRow(e));
				}
			}
			return result;
		}

		public List<ProjectRow> getProjectRowsByName(String name) {
			List<ProjectRow> result = new ArrayList<>();
			for (WebElement link : driver.findElements(By.linkText(name))) {
				result.add(new ProjectRow(link.findElement(By.xpath("../.."))));
			};
			return result;
		}

		public ProjectRow getProjectRowByOffset(int offset) {
			List<ProjectRow> rows = this.getProjectRows();
			if (offset < 0) {
				offset += rows.size();
			}
			return rows.get(offset);
		}

		public ProjectRow getLastProjectRow() {
			return getProjectRowByOffset(-1);
		}

		/**
		 * get list of project names
		 *
		 * @return List<String>
		 */
		public List<String> getProjectNames(){
			List<String> result = new ArrayList<String>();
			List<ProjectRow> projectList = this.getProjectRows();

			for (ProjectRow row : projectList) {
				result.add(row.nameLink.getText());
			}
			return result;
		}
	}

	public class NewProjectPage {
		public WebElement getNameField() {
			return driver.findElement(By.id("project_name"));
		}

		public WebElement getDescriptionField() {
			return driver.findElement(By.id("project_description"));
		}

		public WebElement getCreateProjectButton() {
			return driver.findElement(By.xpath("//input[@value='Create Project']"));
		}

		public WebElement getBackLink() {
			return driver.findElement(By.linkText("Back"));
		}
	}

	public class ToolRow {
		public WebElement checkbox;
		public Select versions;
		public Select tool_options; // Used for SWAMP tool selections
		public WebElement tool_version; // Used for SWAMP tool versions
		public WebElement uploadFile;
		public WebElement scriptOutput;
	}

	/*	there are lots of times where list elements are:

			- .isDisplayed() : true
			- .isEnabled() : true
			- condition Clickable : true

		... but nevertheless you still get an out of bounds
		exception during action.moveToElement(). The code
		below seems to work in all cases
	*/
	public void powerClickElement(WebElement elm) {
		((JavascriptExecutor)driver).executeScript("arguments[0].click()", elm);
	}

	public void powerScrollAndClickElement(WebElement elm) {
		scrollIntoView(elm);
		((JavascriptExecutor)driver).executeScript("arguments[0].click()", elm);
	}

	public void scrollIntoView(WebElement elm) {
		((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView(true);", elm);
	}

	public void scrollIntoViewCoords(WebElement elm) {
		((JavascriptExecutor)driver).executeScript("window.scrollTo(" + elm.getLocation().x + "," + elm.getLocation().y + ")");
	}

	/* getText() doesn't work all the time, maybe when element isn't displayed */
	public String getActualText(WebElement elm) {
		return elm.getAttribute("innerHTML").trim();
	}

	public static class ListItem implements Comparable<ListItem> {

		public String name;
		public String value;
		public String id;
		public WebElement element;
		public String label;
		private String key;

		public static String label(String name, String val) {
			return String.format("%s %s", name, val).trim();
		}

		public ListItem(String name, String val, String id, WebElement elm) {
			this.name = name;
			this.value = val;
			this.id = id;
			this.element = elm;
			this.label = ListItem.label(name, val);
		}

		public ListItem(String name, String val, WebElement elm) {
			this(name, val, elm.getAttribute("data-id"), elm);
		}

		@Override
		public boolean equals(Object obj) {
			if (this == obj)
				return true;
			if (!(obj instanceof ListItem))
				return false;
			ListItem that = (ListItem) obj;
			return this.label.equals(that.label);
		}

		@Override
		public int hashCode() {
			return this.label.hashCode();
		}

		@Override
		public int compareTo(ListItem that) {
			return this.label.compareTo(that.label);
		}

	}

	public class ListItemList {

		public List<ListItem> items;
		public Map<String, ListItem> itemsById;
		public Map<String, ListItem> itemsByLabel;

		public ListItemList() {
			this.items = new ArrayList<>();
			this.itemsById = new HashMap<>();
			this.itemsByLabel = new HashMap<>();
		}

		public void addItem(ListItem item) {
			if (this.itemsById.containsKey(item.id))
				throw new AssertionError("element ID collision: " + item.id);
			if (this.itemsByLabel.containsKey(item.label))
				throw new AssertionError("label collision: " + item.label);
			this.items.add(item);
			this.itemsById.put(item.id, item);
			this.itemsByLabel.put(item.label, item);
		}

		public void addItem(String name, String val, WebElement elm) {
			this.addItem(new ListItem(name, val, elm));
		}

		public void addItem(String name, String val, String id, WebElement elm) {
			this.addItem(new ListItem(name, val, id, elm));
		}

		public int size() {
			return this.items.size();
		}

		public Boolean containsItem(ListItem item) {
			return this.itemsById.containsKey(item.id);
		}

		public Boolean containsLabel(String label) {
			return this.itemsByLabel.containsKey(label);
		}

		public Boolean itemIsSelectedById(String id) {
			WebElement row = this.itemsById.get(id).element;
			List<String> classes = new ArrayList<>(Arrays.asList(row.getAttribute("class").split(" ")));
			return (classes.contains("list-active-item"));
		}

		public void itemToggleById(String id) {
			WebElement row = this.itemsById.get(id).element;
			Actions action = new Actions(driver);
			new WebDriverWait(driver, 5).until(
					ExpectedConditions.elementToBeClickable(row));
			powerScrollAndClickElement(row);
		}

		public void itemSelectById(String id) {
			if (! this.itemIsSelectedById(id)) {
				this.itemToggleById(id);
			}
		}

		public void itemDeselectById(String id) {
			if (this.itemIsSelectedById(id)) {
				this.itemToggleById(id);
			}
		}

		public void selectAll() {
			for (ListItem item : this.items) {
				this.itemSelectById(item.id);
			}
		}

		public void deselectAll() {
			for (ListItem item : this.items) {
				this.itemDeselectById(item.id);
			}
		}

		public Boolean itemIsSelectedByLabel(String label) {
			ListItem item = this.itemsByLabel.get(label);
			return this.itemIsSelectedById(item.id);
		}

		public void itemToggleByLabel(String label) {
			ListItem item = this.itemsByLabel.get(label);
			this.itemToggleById(item.id);
		}

		public void itemSelectByLabel(String label) {
			if (! this.itemIsSelectedByLabel(label)) {
				this.itemToggleByLabel(label);
			}
		}

		public void itemDeselectByLabel(String label) {
			if (this.itemIsSelectedByLabel(label)) {
				this.itemToggleByLabel(label);
			}
		}

		public Boolean itemIsSelectedByNameValue(String name, String val) {
			String label = ListItem.label(name, val);
			return this.itemIsSelectedByLabel(label);
		}

		public void itemToggleByNameValue(String name, String val) {
			String label = ListItem.label(name, val);
			this.itemToggleByLabel(label);
		}

		public void itemSelectByNameValue(String name, String val) {
			if (! this.itemIsSelectedByNameValue(name, val)) {
				this.itemToggleByNameValue(name, val);
			}
		}

		public void itemDeselectByNameValue(String name, String val) {
			if (this.itemIsSelectedByNameValue(name, val)) {
				this.itemToggleByNameValue(name, val);
			}
		}

	}

	public class Sublist extends ListItemList {

		public String name;

		public Sublist(String name) {
			super();
			this.name = name;
		}

		public Boolean itemIsSelectedByValue(String val) {
			return this.itemIsSelectedByNameValue(this.name, val);
		}

		public void itemToggleByValue(String val) {
			this.itemToggleByNameValue(this.name, val);
		}

		public void itemSelectByValue(String val) {
			this.itemSelectByNameValue(this.name, val);
		}

		public void itemDeselectByValue(String val) {
			this.itemDeselectByNameValue(this.name, val);
		}

	}

	public abstract class CompoundList<T extends Sublist> extends ListItemList {

		public WebElement root;
		public final List<T> sublists;
		public List<String> sublistNames;
		public final HashMap<String, T> sublistsByName;
		public final HashMap<String, T> sublistsByItemLabel;
		public final HashMap<String, T> sublistsByItemId;

		public CompoundList() {
			super();
			this.sublists = new ArrayList<>();
			this.sublistNames = new ArrayList<>();
			this.sublistsByName = new HashMap<>();
			this.sublistsByItemLabel = new HashMap<>();
			this.sublistsByItemId = new HashMap<>();
		}

		public void addSublist(T sublist) {
			this.sublists.add(sublist);
			this.sublistNames.add(sublist.name);
			this.sublistsByName.put(sublist.name, sublist);
			for (ListItem item : sublist.items) {
				this.addItem(item);
				this.sublistsByItemLabel.put(item.label, sublist);
				this.sublistsByItemId.put(item.id, sublist);
			}
		}

		public Boolean containsSublistName(String name) {
			return this.sublistsByName.containsKey(name);
		}

		public T getSublistByName(String name) {
			return this.sublistsByName.get(name);
		}

		public T getSublistByItemId(String id) {
			return this.sublistsByItemId.get(id);
		}

		public T getSublistByItemLabel(String label) {
			return this.sublistsByItemLabel.get(label);
		}

		public T getSublistByItemNameValue(String name, String val) {
			return this.sublistsByItemLabel.get(ListItem.label(name, val));
		}

		public void selectAll() {
			for (T sublist : this.sublists) {
				sublist.selectAll();
			}
		}

		public void deselectAll() {
			for (T sublist : this.sublists) {
				sublist.deselectAll();
			}
		}

	}

	public final class TableList extends CompoundList<Sublist> {

		WebElement root;

		public TableList(WebElement tableElm) {
			super();
			assert(tableElm.getTagName().equals("table") || tableElm.getTagName().equals("tbody"));
			this.root = tableElm;

			HashMap<String, List<WebElement>> rowsByName = new HashMap<>();
			for (WebElement elm : this.root.findElements(By.className("list-item"))) {
				String name = getActualText(elm.findElements(By.tagName("td")).get(0));
				if (! rowsByName.containsKey(name)) {
					this.sublistNames.add(name);
					rowsByName.put(name, new ArrayList<>());
				}
				rowsByName.get(name).add(elm);
			}
			for (String name : rowsByName.keySet()) {
				Sublist sublist = new Sublist(name);
				for (WebElement row : rowsByName.get(name)) {
					List<String> classes = new ArrayList<>(Arrays.asList(row.getAttribute("class").split(" ")));
					assert(classes.contains("list-item"));
					List<WebElement> cols = row.findElements(By.tagName("td"));
					// getText() comes up empty sometimes -- maybe when element not visible?
					String rname = getActualText(cols.get(0));
					String value = getActualText(cols.get(1));
					assert(rname.equals(sublist.name));
					sublist.addItem(new ListItem(sublist.name, value, row));
				}
				this.addSublist(sublist);
			}
		}
	}

	public final class AccordionList extends CompoundList<AccordionList.AccordionSublist> {

		WebElement root;

		public AccordionList(WebElement acc_elm) {
			super();
			assert(acc_elm.getTagName().equals("div"));
			List<String> classes = new ArrayList<>(Arrays.asList(acc_elm.getAttribute("class").split(" ")));
			if (! classes.contains("accordion")) {
				acc_elm = acc_elm.findElement(By.className("accordion"));
				classes = new ArrayList<>(Arrays.asList(acc_elm.getAttribute("class").split(" ")));
			}
			assert(classes.contains("accordion"));
			this.root = acc_elm;
			for (WebElement elm : this.root.findElements(By.className("list-item"))) {
				this.addSublist(new AccordionSublist(elm));
			}
		}

		// make sure sublist is expanded first
		public void itemToggleById(String id) {
			this.sublistsByItemId.get(id).select();
			this.sublistsByItemId.get(id).itemToggleById(id);
		}

		public Boolean itemIsSelectedByNameValue(String name, String val) {
			return this.sublistsByName.get(name).itemIsSelectedByValue(val);
		}

		public void itemToggleByNameValue(String name, String val) {
			this.sublistsByName.get(name).select();
			this.sublistsByName.get(name).itemToggleByValue(val);
		}

		public void itemToggleByLabel(String label) {
			this.sublistsByItemLabel.get(label).select();
			this.sublistsByItemLabel.get(label).itemToggleByLabel(label);
		}

		public class AccordionSublist extends Sublist {

			public WebElement hotlink;
			public WebElement root;
			public WebElement allElement;

			public AccordionSublist(WebElement toggleElm) {
				super(toggleElm.getText().trim());
				assert(toggleElm.getAttribute("data-toggle").equals("collapse"));
				this.hotlink = toggleElm;
				String hotlinkId = this.hotlink.getAttribute("href").substring(this.hotlink.getAttribute("href").lastIndexOf("#") + 1);
				this.root = this.hotlink.findElement(By.xpath("./.."))
						.findElement(By.id(hotlinkId));
				for (WebElement elm : this.root.findElements(By.className("sublist-item"))) {
					// getText() doesn't work here for some reason
					// String val = elm.getText().trim();
					String value = elm.getAttribute("textContent").trim();
					if (value.equals("all")) {
						this.allElement = elm;
					} else {
						this.addItem(this.name, value, elm);
					}
				}
			}

			// is the language group unfurled
			public Boolean selected() {
				return this.hotlink.getAttribute("aria-expanded").equals("true");
			}

			// toggle/untoggle accordion for language group
			public void toggle() {
				scrollIntoView(this.hotlink);
				Actions action = new Actions(driver);
				action.moveToElement(this.hotlink).click().perform();
			}

			// unfurl accordion for language group
			public void select() {
				if (! this.selected()) {
					this.toggle();
				}
			}

			// collapse accordion for language group
			public void deselect() {
				if (this.selected()) {
					this.toggle();
				}
			}

			// 'all' row
			public Boolean allIsSelected() {
				List<String> classes = new ArrayList<>(Arrays.asList(this.allElement.getAttribute("class").split(" ")));
				return (classes.contains("list-active-item"));
			}

			public Boolean itemIsSelectedByNameValue(String name, String val) {
				if (val.equals("all")) {
					return this.allIsSelected();
				} else {
					return super.itemIsSelectedByNameValue(name, val);
				}
			}

			public void itemToggleByNameValue(String name, String val) {
				if (val.equals("all")) {
					this.toggleAll();
				} else {
					super.itemToggleByNameValue(name, val);
				}
			}

			public void toggleAll() {
				this.select();
				Actions action = new Actions(driver);
				action.moveToElement(this.allElement).click().perform();
			}

			public void selectAll() {
				if (! this.allIsSelected()) {
					this.toggleAll();
				}
			}

			public void deselectAll() {
				if (this.allIsSelected()) {
					this.toggleAll();
				}
			}

			public void itemToggleById(String id) {
				this.select();
				super.itemToggleById(id);
			}

			public Boolean itemIsSelectedByValue(String val) {
				return this.itemIsSelectedByNameValue(this.name, val);
			}

			public void itemToggleByValue(String val) {
				this.itemToggleByNameValue(this.name, val);
			}

			public void itemSelectByValue(String val) {
				this.itemSelectByNameValue(this.name, val);
			}

			public void itemDeselectByValue(String val) {
				this.itemDeselectByNameValue(this.name, val);
			}

		}

	}

	public class UploadAnalysisPage {

		String testInputsClass = "test-elements";

		/**
		 * get archive uploader in GUI
		 *
		 * @return WebElement
		 */
		public WebElement getArchiveUploader() {
			new WebDriverWait(driver, 500).until(ExpectedConditions
												 .elementToBeClickable(driver.findElement(By.id("file_source"))));
			WebElement fsrc = driver.findElement(By.id("file_source"));
			System.out.printf("found file_source: %s\n", fsrc);
			return fsrc;
		}

		/**
		 * get ToolRow corresponding to the given id
		 *
		 * @param id
		 * @param afterUpload
		 * @return ToolRow
		 */
		public ToolRow getToolRowById(String id, boolean afterUpload) {
			ToolRow row = new ToolRow();
			String cbQuery = "//input[@value='" + id + "' and @type='checkbox']";
			List<WebElement> cells = driver.findElement(By.xpath(cbQuery)).findElement(By.xpath("../.."))
				.findElements(By.tagName("td"));
			row.checkbox = cells.get(0).findElement(By.className("selectTool"));
			System.out.printf("found checkbox: %s : %s\n", id, row.checkbox);
			WebElement versionTag = cells.get(1).findElement(By.id("tool_versions_" + id));

			if (id.startsWith("swamp")) {
				row.tool_options = new Select(cells.get(1).findElement(By.className("swamp_tool_select")));
				row.tool_version = versionTag;
			}

			if (versionTag.getTagName().equals("select")) {
				row.versions = new Select(versionTag);
			}

			if (afterUpload) {
				row.uploadFile = cells.get(2);
			} else {
				row.uploadFile = cells.get(2).findElement(By.id("file_" + id));

			}
			row.scriptOutput = cells.get(3);

			return row;
		}

		/**
		 * get create database button in GUI
		 *
		 * @return WebElement
		 */
		public WebElement getCreateDatabaseButton() {
			new WebDriverWait(driver, 500).until(ExpectedConditions
												 .elementToBeClickable(driver.findElement(By.id("create_database_button"))));
			return driver.findElement(By.id("create_database_button"));
		}

		/**
		 * get create project from database button in GUI
		 *
		 * @return WebElement
		 */
		public WebElement getCreateProjectFromDatabaseButton() {
			new WebDriverWait(driver, 500).until(ExpectedConditions
												 .elementToBeClickable(driver.findElement(By.id("create_project_button"))));
			return driver.findElement(By.id("create_project_button"));
		}

		public void selectLanguagesByName(String name, List<String> versions) {
			Map<String, List<String>> items = new HashMap<>();
			items.put(name, versions);
			selectLanguagesByName(items);
		}
		public void selectLanguagesByName(Map<String, List<String>> items) {
			WebElement dialogElm = driver.findElement(By.id("lang-select-dialogs"));
			AccordionList itemList = new AccordionList(dialogElm.findElement(By.className("add-lang-list")));
			WebElement addButton = dialogElm.findElement(By.className("add-lang-button"));
			for (Map.Entry<String, List<String>> entry : items.entrySet()) {
				String name = entry.getKey();
				List<String> versions = entry.getValue();
				for (String version : versions) {
					itemList.itemSelectByNameValue(name, version);
				}
			}
			Actions action = new Actions(driver);
			// this scrolls things OUT of view sometimes, so don't use it
			//((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView(true);", tabElm);
			action.moveToElement(addButton).click().perform();
		}

		// test suite fields

		public void enableTestSuite() {
			Actions action = new Actions(driver);
			WebElement elm = driver.findElement(By.id("project_is_test_suite_true"));
			scrollIntoView(elm);
			action.moveToElement(elm).click().perform();
		}

		public void setTestSuiteName(String val) {
			Actions action = new Actions(driver);
			WebElement elm = driver.findElement(By.id("project_test_suite_name"));
			elm.sendKeys(val);
		}

		public void setTestSuiteVersion(String val) {
			Actions action = new Actions(driver);
			WebElement elm = driver.findElement(By.id("project_test_suite_version"));
			elm.sendKeys(val);
		}

		public void setTestSuiteType(String val) {
			Actions action = new Actions(driver);
			WebElement elm = driver.findElement(By.id("project_test_suite_version"));
			Select testTypeElm = new Select(driver.findElement(By.className("project-test-suite-type")));
			testTypeElm.selectByValue(val);
		}

		public void setTestSuiteSardId(String val) {
			Actions action = new Actions(driver);
			WebElement elm = driver.findElement(By.id("project_test_suite_sard_id"));
			elm.sendKeys(val);
		}

		public void setTestSuiteAuthorSource(String val) {
			Actions action = new Actions(driver);
			WebElement elm = driver.findElement(By.id("project_author_source"));
			elm.sendKeys(val);
		}

		public void setTestSuiteLicenseString(String val) {
			Actions action = new Actions(driver);
			WebElement elm = driver.findElement(By.id("project_license_file"));
			elm.sendKeys(val);
		}

		public void setTestSuiteManifestFile(String val) {
			Actions action = new Actions(driver);
			WebElement elm = driver.findElement(By.id("file_manifest_file"));
			elm.sendKeys(val);
		}

		public void setTestSuiteFileInfoFile(String val) {
			Actions action = new Actions(driver);
			WebElement elm = driver.findElement(By.id("file_file_info_file"));
			elm.sendKeys(val);
		}

		public void setTestSuiteFunctionInfoFile(String val) {
			Actions action = new Actions(driver);
			WebElement elm = driver.findElement(By.id("file_function_info_file"));
			elm.sendKeys(val);
		}

	}


	public class EditPage {

		/**
		 * get ToolRow corresponding to given id
		 *
		 * @param tool
		 * @param afterUpload
		 * @return ToolRow
		 */
		public ToolRow getToolRowById(String tool, boolean afterUpload) {
			ToolRow row = new ToolRow();
			String cbQuery = "//input[@value='" + tool + "' and @type='checkbox']";
			List<WebElement> cells = driver.findElement(By.xpath(cbQuery)).findElement(By.xpath("../.."))
				.findElements(By.tagName("td"));
			row.checkbox = cells.get(0).findElement(By.className("selectTool"));
			WebElement versionTag = cells.get(1).findElement(By.id("tool_versions_" + tool));

			if (tool.startsWith("swamp")) {
				row.tool_options = new Select(cells.get(1).findElement(By.className("swamp_tool_select")));
				row.tool_version = versionTag;
			}

			if (versionTag.getTagName().equals("select")) {
				row.versions = new Select(versionTag);
			}
			if (afterUpload) {
				row.uploadFile = cells.get(2);
			} else {
				row.uploadFile = cells.get(2).findElement(By.id("file_" + tool));
			}
			row.scriptOutput = cells.get(3);

			return row;
		}

		public WebElement getUpdateDatabaseButton() {
			return driver.findElement(By.id("update_project_button"));
		}

		public WebElement getProjectsSelection() {
			return driver.findElement(By.id("old_projects_selection"));
		}

		public WebElement getCascadeDeterminationsButton() {
			return driver.findElement(By.id("cascade_determinations_button"));
		}
	}

	/**
	 * click edit button in GUI for the given project
	 *
	 * @param projectName
	 * @param path
	 * @param tool
	 */
	public void EditSimpleProject(String projectName, String path, String tool) {
		this.goHome();

		new WebDriverWait(this.driver, 50).until(ExpectedConditions.elementToBeClickable(this.Home.getEditLink(projectName)));
		validatePage();
		this.Home.getEditLink(projectName).click();

		new WebDriverWait(this.driver, 50).until(ExpectedConditions.visibilityOf(this.Edit.getUpdateDatabaseButton()));
		validatePage();
		ToolRow toolRow = this.Edit.getToolRowById(tool, false);
		toolRow.checkbox.click();

		toolRow.uploadFile.sendKeys(path);

		this.Edit.getUpdateDatabaseButton().click();

		validatePage();
	}

	/**
	 * wait for loader to disappear indicating alertConditions table is done loading
	 */
	public void waitForAlertConditionsTableLoad() {
		waitForAlertConditionsTableLoad(50);
	}
	public void waitForAlertConditionsTableLoad(int timeout) {
            for (int i = 0; i < 2; i++) {
                if (i > 0) {
                    try {
                        TimeUnit.SECONDS.sleep(1);
                    } catch (InterruptedException x) {/* ignore */}
                }
                try {
                    new WebDriverWait(driver, timeout)
			.until(ExpectedConditions.visibilityOfElementLocated(By.id("alert_conditions_table")));
                    new WebDriverWait(driver, timeout)
			.until(ExpectedConditions.invisibilityOfElementLocated(By.id("loader")));
                } catch (NullPointerException x) {/* ignore */}
            }
	}

	public class AlertConditionsViewerPage {

		public int numAlertConditionFields = 24; //number of alert items listed below, from checkbox to notes inclusive

		public class FilterElems {
			public Select idTypeFilter;
			public WebElement idFilter;
			public Select verdictFilter;
			public Select prevFilter;
			public WebElement pathFilter;
			public WebElement lineFilter;
			public Select checkerFilter;
			public Select toolFilter;
			public Select conditionFilter;
			public Select taxFilter;
		}

		public class FilterValues {
			public String idTypeFilter;
			public String idFilter;
			public String verdictFilter;
			public String prevFilter;
			public String pathFilter;
			public String lineFilter;
			public String checkerFilter;
			public String toolFilter;
			public String conditionFilter;
			public String taxFilter;
		}

		public class AlertConditionRow {
			public WebElement checkbox;
			public WebElement id;
			public WebElement flag;
			public WebElement verdict;
			public WebElement supplemental;
			public WebElement previous;
			public WebElement path;
			public WebElement line;
			public WebElement message;
			public WebElement checker;
			public WebElement tool;
			public WebElement condition;
			public WebElement title;
			public WebElement class_label;
			public WebElement confidence;
			public WebElement category;
			public WebElement meta_alert_priority;
			public WebElement sev;
			public WebElement lik;
			public WebElement rem;
			public WebElement pri;
			public WebElement lev;
			public WebElement cwe_lik;
			public WebElement notes;
			public WebElement row;
			public Object alertID;
			public String metaAlertID;

			/*//TODO is this necessary? -llbengtson
			  public WebElement ignored;
			  public WebElement dead;
			  public WebElement inapplicable_environment;
			  public WebElement dangerous_construct;
			*/

			/**
			 * set verdict to the given verdict
			 *
			 * @param verdict
			 */
			public void setVerdict(Verdict verdict) {
				//((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView(true);", this.verdict);
				((JavascriptExecutor) driver).executeScript("arguments[0].click();", this.verdict);
				//	this.verdict.click();

				Select select = new Select(this.verdict.findElement(By.tagName("select")));
				select.selectByVisibleText(verdict.toString());

				waitForPageLoad(driver);
			 //   new WebDriverWait(driver, 50).until(ExpectedConditions.elementToBeClickable(this.verdict.findElement(By.tagName("select"))));
			}

			/**
			 * set DC level to given levelText
			 *
			 * @param selector
			 * @param levelText
			 */
			public void setDCLevel(WebElement selector, String levelText){
				//	((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView(true);", selector);
				((JavascriptExecutor) driver).executeScript("arguments[0].click();", selector);
				//selector.click();
				Select select = new Select(selector.findElement(By.tagName("select")));
				select.selectByVisibleText(levelText);
			}
		}

		/**
		 * open the massUpdate modal, fill out the selected key/vals, then submit
		 *
		 * @param determinations
		 */
		public void setMassUpdateDets(Map<String, String> determinations) {
			driver.findElement(By.linkText("Set selected to")).click();
			waitForPageLoad(driver);
			Set set = determinations.entrySet();
			Iterator iterator = set.iterator();
			while(iterator.hasNext()) {
				Map.Entry entry = (Map.Entry)iterator.next();
				String elm_id = (String)entry.getKey();
				String elm_selection = (String)entry.getValue();
				new WebDriverWait(driver, 10).until(ExpectedConditions
						.elementToBeClickable(By.id(elm_id)));
				new Select(driver.findElement(By.id(elm_id)))
					.selectByVisibleText(elm_selection);
			}
			AlertConditionsViewer.update();
			validatePage();
			waitForAlertConditionsTableLoad();
			waitForPageLoad(driver);
		}

		/**
		 * open the massUpdate modal, fill out the form, then submit
		 *
		 * @param verdict
		 * @param flag
		 * @param ignored
		 * @param dead
		 * @param ienv
		 * @param dc
		 */
		public void setMassUpdateDets(String verdict, String flag,
									String ignored, String dead, String ienv, String dc) {
			driver.findElement(By.linkText("Set selected to")).click();
			waitForPageLoad(driver);
			new WebDriverWait(driver, 10).until(ExpectedConditions
												.elementToBeClickable(By.id("mass_update_verdict")));
			AlertConditionsViewer.getSelectAllVerdict().selectByVisibleText("False");
			new WebDriverWait(driver, 10).until(ExpectedConditions
												.elementToBeClickable(By.id("flag")));
			AlertConditionsViewer.getSelectAllFlag().selectByVisibleText("Flagged");
			new WebDriverWait(driver, 10).until(ExpectedConditions
												.elementToBeClickable(By.id("ignored")));
			new Select(driver.findElement(By.id("ignored"))).selectByVisibleText("Ignored");
			new WebDriverWait(driver, 10).until(ExpectedConditions
												.elementToBeClickable(By.id("dead")));
			new Select(driver.findElement(By.id("dead"))).selectByVisibleText("Dead");
			new WebDriverWait(driver, 10).until(ExpectedConditions
												.elementToBeClickable(By.id("inapplicable_environment")));
			new Select(driver.findElement(By.id("inapplicable_environment")))
				.selectByVisibleText("Yes");
			new WebDriverWait(driver, 10).until(ExpectedConditions
												.elementToBeClickable(By.id("mass_update_dc")));
			new Select(driver.findElement(By.id("mass_update_dc")))
				.selectByVisibleText("Medium Risk");

			AlertConditionsViewer.update();
			validatePage();
			waitForAlertConditionsTableLoad();
			waitForPageLoad(driver);
		}

		/**
		 * change alertsperpage via the dropdown in GUI
		 *
		 * @param d - option to select
		 */
		public void changeAlertConditionsPerPage(int d) {
			new WebDriverWait(driver, 10).until(ExpectedConditions
												.elementToBeClickable(driver.findElement(By.name("alertConditionsPerPage"))));
			Select drpDPP = new Select(driver.findElement(By.name("alertConditionsPerPage")));
			drpDPP.selectByVisibleText(Integer.toString(d));
			new WebDriverWait(driver, 10).until(ExpectedConditions
												.elementToBeClickable(By.xpath("//input[@value='Go']")));
			WebElement goBtn = driver.findElement(By.xpath("//input[@value='Go']"));
			goBtn.click();
			validatePage();
			waitForAlertConditionsTableLoad();
		}

		/**
		 * checkbox for selecting all alertConditions that meet filter reqs
		 *
		 * @return
		 */
		public WebElement getSelectAllCheckbox() {
			return driver.findElement(By.id("select_all_checkbox"));
		}

		/**
		 * checkbox for selecting all alertConditions on the page
		 *
		 * @return
		 */
		public WebElement getSelectAll() {
			return driver.findElement(By.id("selectAllCheckboxes"));
		}

		public Select getSelectAllVerdict() {
			return new Select(driver.findElement(By.id("mass_update_verdict")));
		}

		public Select getSelectAllFlag() {
			return new Select(driver.findElement(By.id("flag")));
		}

		/**
		 * get all of the filter elements
		 *
		 * @return
		 */
		public FilterElems getFilterElems() {
			FilterElems filters = new FilterElems();
			filters.idTypeFilter = getIdTypeFilter();
			filters.idFilter = getIdFilter();
			filters.verdictFilter = getVerdictFilter();
			filters.prevFilter = getPreviousFilter();
			filters.pathFilter = getPathFilter();
			filters.lineFilter = getLineFilter();
			filters.checkerFilter = getCheckerFilter();
			filters.toolFilter = getToolFilter();
			filters.conditionFilter = getConditionFilter();
			filters.taxFilter = getTaxonomyFilter();

			return filters;
		}

		/**
		 * get the values of each filter element
		 *
		 * @return
		 */
		public FilterValues getFilterValues() {
			FilterValues fVals = new FilterValues();
			fVals.idTypeFilter = getIdTypeFilter()
				.getFirstSelectedOption().getAttribute("value");
			fVals.idFilter = getIdFilter().getAttribute("value");
			fVals.verdictFilter = getVerdictFilter()
				.getFirstSelectedOption().getAttribute("value");
			fVals.prevFilter = getPreviousFilter()
				.getFirstSelectedOption().getAttribute("value");
			fVals.pathFilter = getPathFilter().getAttribute("value");
			fVals.lineFilter = getLineFilter().getAttribute("value");
			fVals.checkerFilter = getCheckerFilter()
				.getFirstSelectedOption().getAttribute("value");
			fVals.toolFilter = getToolFilter()
				.getFirstSelectedOption().getAttribute("value");
			fVals.conditionFilter = getConditionFilter()
				.getFirstSelectedOption().getAttribute("value");
			fVals.taxFilter = getTaxonomyFilter()
				.getFirstSelectedOption().getAttribute("value");

			return fVals;
		}

		public Select getIdTypeFilter() {
			return new Select(driver.findElement(By.id("id_type")));
		}

		public WebElement getIdFilter() {
			return driver.findElement(By.id("ID"));
		}

		public Select getVerdictFilter() {
			return new Select(driver.findElement(By.id("verdict")));
		}

		public Select getPreviousFilter() {
			return new Select(driver.findElement(By.id("previous")));
		}

		public WebElement getPathFilter() {
			return driver.findElement(By.id("filter_path"));
		}

		public WebElement getLineFilter() {
			return driver.findElement(By.id("line"));
		}

		public Select getCheckerFilter() {
			return new Select(driver.findElement(By.id("checker")));
		}

		public Select getToolFilter() {
			return new Select(driver.findElement(By.id("tool")));
		}

		public Select getConditionFilter() {
			return new Select(driver.findElement(By.id("condition")));
		}

		public Select getTaxonomyFilter() {
			return new Select(driver.findElement(By.id("taxonomy")));
		}

		public String[] getSupplementalOptions() {
			String [] dcTexts = {"No", "Low Risk", "Medium Risk", "High Risk"};
			return dcTexts;
		}

		public String getTestNotes() {
			return "test notes";
		}

		public int getTotalRecords() {
			String total = driver.findElement(By.id("totalRecords")).getText();
			return Integer.parseInt(total);
		}

		/**
		 * build a row object from the row element
		 */
		public AlertConditionRow makeRowFromElement(WebElement rowElement) {
			AlertConditionRow alertConditionRow = new AlertConditionRow();
			List<WebElement> items = rowElement.findElements(By.tagName("td"));
			if (items.size() == 0) {
				return alertConditionRow;
			}
			if (items.size() != numAlertConditionFields) {
				if (items.size() > 0){
					System.out.println(String.format("Wrong number of cells in row! Expected %d but got %d", numAlertConditionFields, items.size()));
				}
			}

			/*
			 * Rationale: If a cell contains a UI element we can interact
			 * with, we extract such element. E.G. a link, a checkbox, etc.
			 * If the cell just contains text, we just assign the
			 * <td>...</td> element to the appropriate WebElement field. The
			 * ID cell (index 1) can be both, however, so we just assign the
			 * <td> field and will have to deal with that in the test case
			 * logic.
			*/

			alertConditionRow.row = rowElement;
			alertConditionRow.alertID = rowElement.getAttribute("id"); //display_id
			alertConditionRow.metaAlertID = rowElement.getAttribute("class");

			int idx = 0;

			alertConditionRow.checkbox = items.get(idx++).findElement(By.tagName("input"));
			alertConditionRow.id = items.get(idx++);
			alertConditionRow.flag = items.get(idx++).findElement(By.tagName("div")).findElement(By.tagName("span"));
			alertConditionRow.verdict = items.get(idx++).findElement(By.tagName("div")).findElement(By.tagName("span"));
			alertConditionRow.supplemental = items.get(idx++);
			alertConditionRow.notes = items.get(idx++);
			alertConditionRow.previous = items.get(idx++);
			alertConditionRow.path = items.get(idx++);
			alertConditionRow.line = items.get(idx++).findElement(By.tagName("a"));
			alertConditionRow.message = items.get(idx++);
			alertConditionRow.checker = items.get(idx++);
			alertConditionRow.tool = items.get(idx++);
			alertConditionRow.condition = items.get(idx++).findElement(By.tagName("a"));
			alertConditionRow.title = items.get(idx++);
			alertConditionRow.class_label = items.get(idx++);
			alertConditionRow.confidence = items.get(idx++);
			alertConditionRow.category = items.get(idx++);
			alertConditionRow.meta_alert_priority = items.get(idx++);
			alertConditionRow.sev = items.get(idx++);
			alertConditionRow.lik = items.get(idx++);
			alertConditionRow.rem = items.get(idx++);
			alertConditionRow.pri = items.get(idx++);
			alertConditionRow.lev = items.get(idx++);
			alertConditionRow.cwe_lik = items.get(idx++);

			return alertConditionRow;
		}

		/**
		 * Get a specific alert row
		 *
		 * @return
		 */
		public AlertConditionRow getOneAlertConditionRow(int i) {
			waitForAlertConditionsTableLoad();

			AlertConditionRow alertConditionRow = null;

			List<WebElement> rows = driver.findElements(By.tagName("tr"));
			if (i < rows.size()) {
				WebElement rowElement = driver.findElements(By.tagName("tr")).get(i);
				alertConditionRow = makeRowFromElement(rowElement);
			}

			return alertConditionRow;
		}

		/**
		 * Get alert rows
		 *
		 * @return
		 */
		public List<AlertConditionRow> getAlertConditionRows() {
			waitForAlertConditionsTableLoad();

			List<AlertConditionRow> result = new ArrayList<AlertConditionRow>();

			int numRows = driver.findElements(By.tagName("tr")).size();
			WebElement e;
			for (int i = 1; i < numRows; i++) { //first tr is the header row
				AlertConditionRow alertConditionRow = getOneAlertConditionRow(i);
				result.add(alertConditionRow);
			}
			return result;
		}

		/**
		 * wait for a particular element (found by locator) to be refreshed
		 */
		public WebElement waitForElementRefresh(WebElement elm, By locator, int timeout) {
			try {
				new WebDriverWait(getDriver(), 3).until(ExpectedConditions.stalenessOf(elm));
				new WebDriverWait(getDriver(), 3).until(ExpectedConditions.presenceOfElementLocated(locator));
				elm = driver.findElement(locator);
			} catch (TimeoutException e) {
				// probably was a no-op (something was set to a new
				// value equal to old value)
				System.out.println("element refresh timeout");
			}
			return elm;
		}
		public WebElement waitForElementRefresh(WebElement elm, By locator) {
			int timeout = 3;
			return this.waitForElementRefresh(elm, locator, timeout);
		}

		/**
		 * wait for a particular row to be refreshed
		 */
		public AlertConditionRow waitForRowRefresh(AlertConditionRow row) {
			By locator = By.xpath("//*[@id='alertConditionsTableBody']/tr[@id='" + row.alertID + "']");
			WebElement elm = this.waitForElementRefresh(row.row, locator);
			if (elm != row.row) {
				row = this.makeRowFromElement(elm);
			}
			return row;
		}

		/**
		 * click next page button in GUI
		 *
		 * @return true if successful, false otherwise
		 */
		public boolean goToNextPage() {
			String initPage = null;
			waitForAlertConditionsTableLoad();

			try {
				initPage = driver.findElement(By.className("active")).findElement(By.tagName("span")).getText();
			} catch (Exception e) {
				// Not present if there is only 1 page
				return false;
			}
			WebElement temp = driver.findElement(By.className("next"));

			WebElement nextButton = driver.findElement(By.className("next"));

			WebElement childElement = nextButton.findElements(By.xpath(".//*")).get(0);

			if (childElement.getTagName().equals("span")) { //check if link to next page exists
				return false;
			}

			nextButton = nextButton.findElement(By.tagName("a"));
			nextButton.click();
			validatePage();
			final String initPageCpy = initPage;
			(new WebDriverWait(driver, 10)).until(new ExpectedCondition<Boolean>() {
					public Boolean apply(WebDriver d) {
						try {
							String curPage = driver.findElement(By.className("active")).findElement(By.tagName("span")).getText();
							return !curPage.equals(initPageCpy);
						} catch (StaleElementReferenceException e) {
							// Clicking next runs some JavaScript and updates the
							// DOM. If we try to query the DOM too quickly, selenium
							// might try to access the stale DOM, resulting in an
							// exception. For now, just count this as a failure,
							// and retry.
							return false;
						}
					}
				});

			return true;
		}

		public void newAlert() {
			driver.findElement(By.id("create_new_alert_and_condition")).click();
		}

		public void filter() {
			driver.findElement(By.xpath("//input[@value='Filter']")).click();
		}

		public void clearFilter() {
			driver.findElement(By.id("clear-filters")).click();
		}

		public void update() {
			driver.findElement(By.xpath("//input[@value='Update']")).click();
		}

            /**
             * Set the sort field to the following values
             *
             * @param webApp
             * @param sortValues
             */
            public void setSortField(String[] sortValues) {
                WebElement sortButton = driver.findElement(By.id("sorting"));

                sortButton.click();
                waitForPageLoad(driver);
                new WebDriverWait(driver, 10).until(ExpectedConditions
                                                    .elementToBeClickable(driver.findElement(By.id("submit-sort-modal"))));
                WebElement submitButton = driver.findElement(By.id("submit-sort-modal"));
                WebElement addButton = driver.findElement(By.id("add_sk_button"));
                WebElement removeButton = driver.findElement(By.id("remove_sk_button"));
                WebElement sortKeysUnselected = driver.findElement(By.id("sort_keys_unselected"));
                WebElement sortKeysSelected = driver.findElement(By.id("sort_keys_selected"));

                // Remove everything from selected items
                int num_elems = sortKeysSelected.findElements(By.className("list_item")).size();
                for (int i = 0; i < num_elems; i++) {
                    WebElement selectedKey = sortKeysSelected.findElement(By.className("list_item"));
                    selectedKey.click();
                    new WebDriverWait(driver, 10).until(ExpectedConditions
                                                        .elementToBeClickable(removeButton));
                    removeButton.click();
                    new WebDriverWait(driver, 10).until(ExpectedConditions
                                                        .elementToBeClickable(submitButton));
                }

                // Now select items in sortValues
                for (String sortValue : sortValues) {
                    String keyValue = String.format("//li[@class='list_item' and contains(text(), '%s')]", sortValue);
                    WebElement key = sortKeysUnselected.findElement(By.xpath( keyValue));
                    key.click();
                    new WebDriverWait(driver, 10).until(ExpectedConditions
                                                        .elementToBeClickable(addButton));
                    addButton.click();
                    new WebDriverWait(driver, 10).until(ExpectedConditions
                                                        .elementToBeClickable(submitButton));
                }

                submitButton.click();
            }

            /**
             * Reset the sort field to default value
             *
             * @param webApp
             */
            public void resetSortField() {
                this.setSortField(new String[] {"Time DESC"});
            }
	}

	public class NewAlertPage {
		public WebElement getVerdictCombobox() {
			return driver.findElement(By.id("display_verdict"));
		}

		public WebElement getSupplementalField() {
			return driver.findElement(By.id("display_supplemental"));
		}

		public WebElement getPreviousCombobox() {
			return driver.findElement(By.id("display_previous"));
		}

		public WebElement getMetaAlertIdField() {
			return driver.findElement(By.id("display_meta_alert_id"));
		}

		public WebElement getAlertIdField() {
			return driver.findElement(By.id("display_display_id"));
		}

		public WebElement getPathField() {
			return driver.findElement(By.id("display_path"));
		}

		public WebElement getLineField() {
			return driver.findElement(By.id("display_line"));
		}

		public WebElement getMessageField() {
			return driver.findElement(By.id("display_message"));
		}

		public WebElement getCheckerField() {
			return driver.findElement(By.id("display_checker"));
		}

		public WebElement getToolField() {
			return driver.findElement(By.id("display_tool"));
		}

		public WebElement getConditionField() {
			return driver.findElement(By.id("display_condition"));
		}

		public WebElement getTitleField() {
			return driver.findElement(By.id("display_title"));
		}

		public WebElement getClassLabelCombobox() {
			return driver.findElement(By.id("display_class_label"));
		}

		public WebElement getConfidenceField() {
			return driver.findElement(By.id("display_confidence"));
		}

		public WebElement getCategoryField() {
			return driver.findElement(By.id("display_category"));
		}

		public WebElement getAlertPriorityField() {
			return driver.findElement(By.id("display_meta_alert_priority"));
		}

		public WebElement getSeverityField() {
			return driver.findElement(By.id("display_severity"));
		}

		public WebElement getLikelihoodField() {
			return driver.findElement(By.id("display_likelihood"));
		}

		public WebElement getRemediationField() {
			return driver.findElement(By.id("display_remediation"));
		}

		public WebElement getPriorityField() {
			return driver.findElement(By.id("display_priority"));
		}

		public WebElement getLevelField() {
			return driver.findElement(By.id("display_level"));
		}

		public WebElement getCweLikelihoodField() {
			return driver.findElement(By.id("display_cwe_likelihood"));
		}

		public WebElement getNotesField() {
			return driver.findElement(By.id("display_notes"));
		}

		public WebElement getCreateButton() {
			return driver.findElement(By.id("create_new_alert"));
		}
	}

	public class PrioritySchemeModal {
		/**
		 * fill out the priority name field in the modal
		 *
		 * @param priorityName
		 */
		public void setName(String priorityName) {
			new WebDriverWait(driver, 10).until(ExpectedConditions
												.elementToBeClickable(driver.findElement(By.id("priority_name"))));
			driver.findElement(By.id("priority_name")).sendKeys(priorityName);
		}

		public void fillCWETab() {
			driver.findElement(By.xpath("//li[@id='CWES']//a")).click();
			driver.findElement(By.id("cwes_cwe_likelihood")).clear();
			driver.findElement(By.id("cwes_cwe_likelihood")).sendKeys("3");
			WebElement cweTextBox = driver.findElement(By.id("cwes_txt"));

			//Formula for the CWE taxonomy
			String cweFormula = "cwe_likelihood*3";

			cweTextBox.click();
			cweTextBox.sendKeys(cweFormula);
		}

		public void fillCERTTab() {
			driver.findElement(By.xpath("//li[@id='CERT_RULES']//a")).click();

			driver.findElement(By.id("cert_rules_cert_severity")).clear();
			driver.findElement(By.id("cert_rules_cert_severity")).sendKeys("2");

			driver.findElement(By.id("cert_rules_cert_remediation")).clear();
			driver.findElement(By.id("cert_rules_cert_remediation")).sendKeys("1");

			WebElement certTextBox = driver.findElement(By.id("cert_rules_txt"));


			//Formula for the CERT taxonomy
			String certFormula = "cert_severity*2+cert_remediation";

			certTextBox.click();
			certTextBox.sendKeys(certFormula);
		}

		public void modifyCERTPrioritySchemaWithUserUpload() {
			driver.findElement(By.xpath("//li[@id='CERT_RULES']//a")).click();
			WebElement certTextBox = driver.findElement(By.id("cert_rules_txt"));
			//Formula for the CERT taxonomy
			String certFormula = "cert_severity*2+cert_remediation+safeguard_countermeasure";
			certTextBox.click();
			certTextBox.clear();
			certTextBox.sendKeys(certFormula);
		}

		public void modifyCWEPrioritySchemaWithUserUpload() {
			driver.findElement(By.xpath("//li[@id='CWES']//a")).click();
			WebElement cweTextBox = driver.findElement(By.id("cwes_txt"));
			//Formula for the CWE taxonomy
			String cweFormula = "cwe_likelihood*3+safeguard_countermeasure";
			cweTextBox.click();
			cweTextBox.clear();
			cweTextBox.sendKeys(cweFormula);
		}

		public void setUserUploadWeights() {
			//set some user uploaded field weights
			driver.findElement(By.id("upload_safeguard_countermeasure")).click();
			driver.findElement(By.id("upload_safeguard_countermeasure")).clear();
			driver.findElement(By.id("upload_safeguard_countermeasure")).sendKeys("1");
			driver.findElement(By.id("upload_complexity")).click();
			driver.findElement(By.id("upload_complexity")).clear();
			driver.findElement(By.id("upload_complexity")).sendKeys("5");

		}

		public void genFormula() {
			new WebDriverWait(driver, 10).until(ExpectedConditions
												.elementToBeClickable(driver.findElement(By.id("genFormula"))));
			WebElement formulaButton = driver.findElement(By.id("genFormula"));
			formulaButton.click();
			waitForPageLoad(driver);
		}

		public void saveScheme() {
			new WebDriverWait(driver, 10).until(ExpectedConditions
												.elementToBeClickable(driver.findElement(By.id("saveScheme"))));
			driver.findElement(By.id("saveScheme")).click();
			waitForPageLoad(driver);
		}

		public void runScheme() {
			new WebDriverWait(driver, 10).until(ExpectedConditions
												.elementToBeClickable(driver.findElement(By.id("submit-priority-modal"))));
			driver.findElement(By.id("submit-priority-modal")).click();
			waitForPageLoad(driver);
			waitForAlertConditionsTableLoad();
		}

		/**
		 * upload user columns
		 *
		 * @param userUploadfPath
		 */
		public void uploadUserCols(String userUploadfPath) {
			new WebDriverWait(driver, 10).until(ExpectedConditions
												.elementToBeClickable(driver.findElement(By.linkText("Upload New Fields"))));
			driver.findElement(By.linkText("Upload New Fields")).click();
			waitForPageLoad(driver);
			new WebDriverWait(driver, 10).until(ExpectedConditions
												.elementToBeClickable(driver.findElement(By.id("column_upload"))));
			driver.findElement(By.id("column_upload")).sendKeys(userUploadfPath);
			new WebDriverWait(driver, 10).until(ExpectedConditions
												.elementToBeClickable(driver.findElement(
																						 By.xpath("//button[contains(.,'Upload')]"))));
			driver.findElement(By.xpath("//button[contains(.,'Upload')]"))
				.click();
			waitForPageLoad(driver);
		}

		/**
		 *
		 * @param priorityName
		 */
		public void openSchemeFromNav(String priorityName) {
			Actions action = new Actions(driver);
			new WebDriverWait(driver, 10).until(ExpectedConditions.elementToBeClickable(driver.findElement(By.xpath("//li[@id='priorityscheme-dropdown']//a"))));
			action.moveToElement(driver.findElement(By.xpath("//li[@id='priorityscheme-dropdown']//a"))).click().perform();
			waitForPageLoad(driver);
			new WebDriverWait(driver, 10).until(ExpectedConditions.elementToBeClickable(driver.findElement(By.linkText(priorityName))));
			action.moveToElement(driver.findElement(By.linkText(priorityName))).click().perform();
			waitForPageLoad(driver);
		}
	}

	public enum Verdict {
		True, False, Complex, Dependent, Unknown;

		public String toString() {
			return "[" + super.toString() + "]";
		}
	}

}
