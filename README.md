# Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)


##SFDX Workflow


Prequisite:
	GitHub account and repository
	Salesforce CLI (SFDX) installed
	VS Code with Salesforce extensions
	Authorized Salesforce org (sandbox or production)
	Basic knowledge of Git and GitHub Actions

1. Set Up Your Salesforce Project
	Create sfdx project folder on desktop

	Open vs code and open SFDX folder

	Open new terminal 

	Use sfdx commands to create project
	sfdx force:project:create -n MyProject

	Authorize the org 
	sfdx auth:web:login -a Source

	Now we need to create manifest folder with existing org
	cd MyProject
	sfdx project generate manifest --output-dir ./manifest --from-org Source

2. Setup Git
	git init
	Check if the branch name in vs code is same as github or else use [git branch -m main ] 
	git add .
	git remote add origin https://github.com/N-P-N-P/SFDX.git
	git push -u origin main

3. Create Self signed certificate to authorize thru JWT
	Use open ssl
	Create a Cert folder on desktop and open it with vs code and perform below operations
	Commands to create CSR and Key:
	1)openssl genrsa -des3 -passout pass:dummyPassword -out server.pass.key 2048
	2)openssl rsa -passin pass:dummyPassword -in server.pass.key -out server.key
	3)rm server.pass.key
	4)openssl req -new -key server.key -out server.csr

	Command to create CRT:

	1)openssl x509 -req -sha256 -days 365 -in server.csr -signkey server.key -out server.crt

4.Create a connected app
	1)New external client app
	2)External Client App Name: Devops_JWT, API Name : Devops_JWT, email:personal email.
	3)Enaple Oauth checkbox and put values - Callback url: sfdc://oauth/jwt/success,  oauth scope: Manage user data via APIs (api),Full access (full),Perform requests at any time (refresh_token, offline_access)
	4)In Flow Enablement section enable Enable JWT Bearer Flow and upload the certificate.
	5)In security - Require secret for Web Server Flow,Require secret for Refresh Token Flow, Require Proof Key for Code Exchange (PKCE) extension for Supported Authorization Flows,Issue JSON Web Token (JWT)-based access tokens for named users

	Once app is created go to app policy.
	Put Start Page - oAuth
	Available Profiles - system admin
	Under oAuth policy - Permited User:Admin approved users are pre approved , OAuth Start URL: https://login.salesforce.com

	App authorization
	IP Relaxation: Enforce Ip restriction, But relax for refresh token.
	Save it.

5.Create GitHub action Work flow
	name: Salesforce Deployment

	on:
	  push:
		branches:
		  - main  # or your deployment branch

	jobs:
	  deploy:
		runs-on: ubuntu-latest

		steps:
		  - name: Checkout repository
			uses: actions/checkout@v4

		  - name: Setup Node.js
			uses: actions/setup-node@v4
			with:
			  node-version: '18'

		  - name: Install Salesforce CLI
			run: npm install -g @salesforce/cli

		  - name: Authenticate with JWT
			env:
			  SFDX_JWT_KEY: ${{ secrets.SFDX_JWT_KEY }}
			  SFDX_CLIENT_ID: ${{ secrets.SFDX_CLIENT_ID }}
			  SF_USERNAME: ${{ secrets.SF_USERNAME }}
			run: |
			  echo "$SFDX_JWT_KEY" > server.key
			  sf org login jwt \
				--client-id "$SFDX_CLIENT_ID" \
				--jwt-key-file server.key \
				--username "$SF_USERNAME" \
				--alias target-org \
				--set-default
			  rm server.key

		  - name: Deploy to Salesforce
			run: |
			  sf project deploy start \
				--target-org target-org \
				--test-level RunLocalTests \
				--wait 30


6.Store Secret for repository in to github
	SFDX_JWT_KEY → your private key - server.key
	SFDX_CLIENT_ID → Consumer Key from Connected App
	SF_USERNAME → target org username



## To Have incremental deployment
name: Salesforce Delta Deployment

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Important for delta plugin to access full commit history

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'

      - name: Install Salesforce CLI via npm
        run: |
          npm install -g @salesforce/cli
          sf update
      - name: Install sfdx-git-delta plugin
        run: echo y | sf plugins install sfdx-git-delta@6.13.1

      - name: Authenticate with JWT
        env:
          SFDX_JWT_KEY: ${{ secrets.SFDX_JWT_KEY }}
          SFDX_CLIENT_ID: ${{ secrets.SFDX_CLIENT_ID }}
          SF_USERNAME: ${{ secrets.SF_USERNAME }}
        run: |
          echo "$SFDX_JWT_KEY" > server.key
          sf org login jwt \
            --client-id "$SFDX_CLIENT_ID" \
            --jwt-key-file server.key \
            --username "$SF_USERNAME" \
            --alias target-org \
            --set-default
          rm server.key
      - name: Generate delta package
        run: |
          PREVIOUS_SHA=${{ github.event.before }}
          if [ -z "$PREVIOUS_SHA" ]; then
            PREVIOUS_SHA=$(git rev-parse HEAD~1)
          fi
          mkdir delta-out
          sf sgd source delta \
            --from "$PREVIOUS_SHA" \
            --to ${{ github.sha }} \
            --generate-delta \
            --output-dir delta-out
      - name: Deploy delta metadata
        run: |
          sf project deploy start \
            --source-dir delta-out \
            --target-org target-org \
            --test-level RunLocalT

## If git is getting changes even salesforce deployment is happning then
name: Salesforce Delta Deployment

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: ⬇️ Checkout full repository history
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Ensure all commits are available for delta comparison

      - name: 🔧 Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'

      - name: 🧰 Install Salesforce CLI via npm
        run: |
          npm install -g @salesforce/cli
          sf update

      - name: 📦 Install Delta plugin (stable version)
        run: echo y | sf plugins install sfdx-git-delta@6.13.1

      - name: 🔐 Authenticate to Salesforce via JWT
        env:
          SFDX_JWT_KEY: ${{ secrets.SFDX_JWT_KEY }}
          SFDX_CLIENT_ID: ${{ secrets.SFDX_CLIENT_ID }}
          SF_USERNAME: ${{ secrets.SF_USERNAME }}
        run: |
          echo "$SFDX_JWT_KEY" > server.key
          sf org login jwt \
            --client-id "$SFDX_CLIENT_ID" \
            --jwt-key-file server.key \
            --username "$SF_USERNAME" \
            --alias target-org \
            --set-default
          rm server.key

      - name: 🔎 Generate delta package
        run: |
          PREVIOUS_SHA=${{ github.event.before }}
          if [ -z "$PREVIOUS_SHA" ]; then
            PREVIOUS_SHA=$(git rev-parse HEAD~1)
          fi

          mkdir -p delta-out

          sf sgd source delta \
            --from "$PREVIOUS_SHA" \
            --to ${{ github.sha }} \
            --generate-delta \
            --output-dir delta-out

      - name: 🚫 Stop if no delta files
        run: |
          if [ -z "$(ls -A delta-out)" ]; then
            echo "No metadata changes to deploy."
            exit 1
          fi

      - name: 🚀 Deploy changed metadata (delta)
        run: |
          sf project deploy start \
            --source-dir delta-out \
            --target-org target-org \
            --test-level RunLocalTests \
            --wait 30

      - name: 📣 Notify if deployment fails
        if: failure()
        run: echo "Deployment failed! Consider reverting or notifying the team."
