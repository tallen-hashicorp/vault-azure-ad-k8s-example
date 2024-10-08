# Steps to Retrieve Azure Tenant ID, Client ID, Client Secret, and Subscription ID via Azure Portal

Here are the steps to retrieve your **Azure Tenant ID**, **Client ID**, **Client Secret**, and **Subscription ID** via the Azure portal:

### Step 1: Retrieve **Subscription ID**

1. **Log in to the Azure Portal**: Go to [https://portal.azure.com](https://portal.azure.com) and log in with your credentials.
2. **Go to "Subscriptions"**: 
   - On the home under Navigate, click **Subscriptions**. If you don’t see it, you can use the search bar at the top to search for **Subscriptions**.
3. **Select Your Subscription**: 
   - In the list of subscriptions, click on the one you want to use.
4. **Find the Subscription ID**: 
   - On the subscription overview page, you will see the **Subscription ID** listed under the subscription details. Copy this for later use.

### Step 2: Retrieve **Tenant ID**

1. **Go to "Microsoft Entra ID"**:
   - In the left-hand sidebar, click **Microsoft Entra ID**. If it’s not visible, use the search bar to find it.
2. **Find the Tenant ID**:
   - On the Microsoft Entra ID overview page, you’ll see **Tenant ID** listed under the **Basic information** section. Copy this for later use.

### Step 3: Create an App Registration to Get **Client ID** and **Client Secret**

1. **Go to "Microsoft Entra ID"** (as described in Step 2).
2. **Create a New App Registration**:
   - Click add **+ App registration** at the top of the Microsoft Entra ID view.
   - Fill out the required fields:
     - **Name**: Give your app a name (e.g., "Vault Platform Team").
     - **Supported account types**: Choose the appropriate option based on your needs (e.g., **Accounts in any organizational directory (Any Microsoft Entra ID tenant - Multitenant)**).
     - **Redirect URI**: You can leave this blank or provide one if needed for your application.
   - Click **Register** to create the app.
3. **Get the Client ID**:
   - After registering the app, you will be redirected to the app's overview page. The **Application (client) ID** will be listed on this page. Copy it for later use.
4. **Create a Client Secret**:
   - One the left bar slect **Manage**, go to **Certificates & secrets**.
   - Under **Client secrets**, click **+ New client secret**.
   - Provide a description (e.g., "Vault Secret") and choose an expiration period.
   - Click **Add**. The client secret will be generated and displayed. **Copy this immediately**, as you won’t be able to see it again after leaving this page.
5. **Select API Permisions**:
   - Select **API Permisions** on the left
   - Click **Add A Permission** in the middle
   - Select **APIs my organization uses**
   - Add the following, not sure if this is all needed however this worked for me

![API permissions](./docs/api-permissions.png)


### Step 4: Assign Proper Role to the App for Azure API Access (Optional but Necessary for Many Use Cases)

1. **Go to "Subscriptions"** (as described in Step 1).
2. **Select Your Subscription** and click on it.
3. **Go to "Access Control (IAM)"**:
   - In the subscription's sidebar, click on **Access Control (IAM)**.
4. **Add Role Assignment**:
   - Click on **+ Add** and choose **Add role assignment**.
5. **Select a Role**:
   - For this we are going to make the app an owner so it can do eveything!!
   - Select **Privileged administrator roles** at the top
   - Click **Owner**
   - **Warning** This will give this app full azure access, **not recomend for production**
6. **Assign Access To**:
   - Under **Assign access to**, choose **User, group, or service principal**. 
7. **Click Select Memebers**
8. **Search for the App**:
   - In the search bar, type the name of the app you just registered.
9. **Select Conditions**
   - Click Next and select "Allow user to assign all roles (highly privileged)"
10. **Review and Assign**:
   - Click **Review + Assign**.

This will grant your app the necessary permissions to interact with Azure resources.

**NOTE: I needed to wait up to 10 minutes after creating this for this to work in Vault**

### Step 5: Create a Resource Group in Azure

1. **Go to "Resource Groups"**:
   - In the Azure portal, navigate to **Resource Groups**. If it's not visible in the left-hand sidebar, use the search bar at the top to search for **Resource Groups**.
2. **Click on + Create**:
   - At the top of the **Resource Groups** page, click on the **+ Create** button.
3. **Select Subscription**:
   - In the **Basics** tab, under **Project Details**, select the appropriate **Subscription** where you want the resource group to reside.
4. **Enter Resource Group Name**:
   - Enter a unique name for your resource group in the **Resource Group Name** field (e.g., `azure-vault-group`).
5. **Select a Region**:
   - Under **Region**, choose the location where the resources in this group will be hosted. For example, you could choose **East US** or **West Europe**.
6. **Add Tags (Optional)**:
   - You can add tags to help organize your resources (e.g., by environment or project). This step is optional, but useful for managing resources in a structured way.
7. **Click Review + Create**:
   - Click **Review + Create** to review your settings before creating the resource group.
8. **Create Resource Group**:
   - After reviewing the information, click **Create**. Azure will create the resource group in the selected subscription and region.

### Summary:
You now have:
- **Subscription ID**: From the Subscription page (Step 1).
- **Tenant ID**: From Microsoft Entra ID (Step 2).
- **Client ID**: From the App Registration overview (Step 3).
- **Client Secret**: From Certificates & Secrets in the App Registration (Step 3).