# Linux Setup

This script will set you up and running after a fresh OS installation. It is made for use on Ubuntu based systems.

## Software installation and basic system configuration

Run the script with the following command line:

```bash
zsh install.sh
```

It will install and configure:

- [Firefox](https://www.mozilla.org/en-US/firefox/)
- [Simplenote](https://simplenote.com/)
- [Gnumeric](https://wiki.gnome.org/Apps/Gnumeric)
- [QGIS](https://qgis.org/)
- [XSane](https://wiki.ubuntuusers.de/XSane/)
- [Google Earth](https://www.google.com/earth/)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Oh My Zsh](https://ohmyz.sh/)
- [direnv](https://direnv.net/)
- [GitHub CLI](https://cli.github.com/)
- [Google Cloud CLI](https://cloud.google.com/sdk)
- [pyenv](https://github.com/pyenv/pyenv)
- [Python](https://www.python.org/)
- [Docker](https://www.docker.com/)


## GitHub CLI Authentication

After installation is completed, **login** to your GitHub account copy-pasting the following command in your terminal:

:warning: **DO NOT edit the `email`**

```bash
gh auth login -s 'user:email' -w
```

gh will ask you few questions:

`What is your preferred protocol for Git operations?` With the arrows, choose `SSH` and press `Enter`. SSH is a protocol to log in using SSH keys instead of the well known username/password pair.

`Generate a new SSH key to add to your GitHub account?` Press `Enter` to ask gh to generate the SSH keys for you.

If you already have SSH keys, you will see instead `Upload your SSH public key to your GitHub account?` With the arrows, select your public key file path and press `Enter`.

`Enter a passphrase for your new SSH key (Optional)`. Type something you want and that you'll remember. It's a password to protect your private key stored on your hard drive. Then press `Enter`.

`Title for your SSH key`. You can leave it at the proposed "GitHub CLI", press `Enter`.

You will then get the following output:

```bash
! First copy your one-time code: 0EF9-D015
- Press Enter to open github.com in your browser...
```

Select and copy the code (`0EF9-D015` in the example), then press `Enter`.

Your browser will open and ask you to authorize GitHub CLI to use your GitHub account. Accept and wait a bit.

Come back to the terminal, press `Enter` again, and that's it.

To check that you are properly connected, type:

```bash
gh auth status
```

:heavy_check_mark: If you get `Logged in to github.com as <YOUR USERNAME> `, then all good :+1:

## GCloud CLI Authentication

Next, authenticate the `gcloud` CLI with the google account you used for GCP:

```bash
gcloud auth login
```

- Login to your Google account on the new tab opened in your web browser

- List your active account and check your email address you used for GCP is present

```bash
gcloud auth list
```

- Set your current project (replace `PROJECT_ID` with the `ID` of your project)

```bash
gcloud config set project PROJECT_ID
```

- List your active account and current project and check your project is present

```bash
gcloud config list
```

### Create a service account key 🔑

#### Go to the Service Accounts page

Navigate to the GCP service accounts page at [this link](https://console.cloud.google.com/apis/credentials/serviceaccountkey).

- Select your project in the list of recent projects if asked to.
- If not asked, make sure the right project is selected in the Project selecter list at the top of the page.

#### Create a service account

- Click on **CREATE SERVICE ACCOUNT**.
- Give your service account a name, an id and a description, and click on **CREATE AND CONTINUE**.
- Click on **Select a role** and choose `Basic` then **`Owner`**, which gives the service account full access to all resources of your GCP project.
- Click on the blue **DONE** button at the bottom of this window. We don't need to worry about the section *Grant your users access to this service account*.

#### Create a json key 🔑 for this service account

- On the service accounts page, click on the email address of the newly created service account.
- Click on the **KEYS** tab at the top of the page.
- Click on **ADD KEY** then **Create new key**.
- Select **JSON** and click on **CREATE**.
- The browser has now saved the service account json file 🔑 in your downloads directory (it is named according to your service account name, something like `le-wagon-data-123456789abc.json`).

- Store the service account json file somewhere you'll remember, for example:

``` bash
/home/LINUX_USERNAME/code/GITHUB_NICKNAME/gcp/SERVICE_ACCOUNT_JSON_FILE_CONTAINING_YOUR_SECRET_KEY.json
```

- Store the **absolute path** to the `JSON` file as an environment variable:

``` bash
echo 'export GOOGLE_APPLICATION_CREDENTIALS=/path/to/the/SERVICE_ACCOUNT_JSON_FILE_CONTAINING_YOUR_SECRET_KEY.json' >> ~/.zshrc
```
You can double check it by running:

```bash
code ~/.zshrc
```

Or restarting your terminal and running:

``` bash
echo $GOOGLE_APPLICATION_CREDENTIALS
```

The ouptut should be the following:

```bash
/some/absolute/path/to/your/gcp/SERVICE_ACCOUNT_JSON_FILE_CONTAINING_YOUR_SECRET_KEY.json
```

Now let's verify that the path to your service account json file is correct:

``` bash
cat $(echo $GOOGLE_APPLICATION_CREDENTIALS)
```

This command should display the content of your service account json file.

Now configure the service account role

- List the service accounts associated to your active account and current project

```bash
gcloud iam service-accounts list
```

- Retrieve the service account email address, e.g. `SERVICE_ACCOUNT_NAME@PROJECT_ID.iam.gserviceaccount.com`

- List the roles of the service account from the cli (replace PROJECT_ID and SERVICE_ACCOUNT_EMAIL)

```bash
gcloud projects get-iam-policy PROJECT_ID \
--flatten="bindings[].members" \
--format='table(bindings.role)' \
--filter="bindings.members:SERVICE_ACCOUNT_EMAIL"
```

- You should see that your service account has a role of `roles/owner`. If so, you're good to go! 🏁