# Help Lightning Salesforce Component

This is a Salesforce Lightning component that integrates making Help
Lightning calls through Salesforce. It integrates into the Cases and
WorkOrder objects, allowing the Salesforce user to directly call their
contact. It also records the Help Lightning call and associates it
with the corresponding Case or WorkOrder.

## License

The Help Lightning Salesforce component is released under the MIT
License, copyright (c) 2025 Help Lightning Inc.

## Code Structure

This code consists of an apex backend
(`hlsfdc/main/default/classes/HLSessionController.cls`) and a
Lightning web component
(`hlsfdc/main/default/aura/hlSessions/hlSessions.cmp`).

## Namespace

This component is a managed package distributed by Help Lightning via
the Salesforce App Store.

If you are going to release internally, please change the namespace
from `helplighting__` to something different!

## Setting up a Scratch Environment

To do anything, you must first install the sf clitools:
https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_release_notes.htm

For development, we use a Salesforce DX environment to create
temporary scratch environments. We'll call this scratch envirornment
an `ISV` in the following examples.

`sf org login web -a ISV -d`

This will open your web browser and you can log into the ISV
salesforce org. Once authenticated, you can begin creating development
environments.

### Creating a new Scratch Environment

To create a new temporary scratch environment for development, run:

`./scripts/setup SCRATCH_ENV_NAME`

where `SCRATCH_ENV_NAME` can be anything you want. I typically name
them after my JIRA ticket:

`./scripts/setup SFDC-48`

This script will create the new environment, upload all the code and
resources, configure the permissions, then print out a Login
URL. Clicking on the URL will open up the scratch environment and
automatically log you in.

### Configuring the new Scratch Environment

Once you are in your scratch environment, you need to configure it. There are two things we need to configure:
1. The Help Lightning enterprise and partner key
1. Adding the Help Lightning component to Cases and WorkOrders

First to configure the Help Lightning Enterprise and Partner Key:

1. Go to `Setup` > `Custom Code` > `Visualforce Pages`
1. Find `HelpLightingSetup` and click on the icon of two squares with an arrow, just to the right of Security. This will open a preview of the page in a new tab.
1. For `Enterprise Id`, you will need the Help Lightning Id of your enterprise in production. This can be found in crunch.
1. For `Private Key`, you will need a private key for your enterprise. If you don't have one, you can manually create one using the Galdr admin api. *Be careful doing this, as creating a new key removes any existing keys!*
1. Press `Save` and close the tab.

Second, configure the Cases and WorkOrders to show the Help Lightning Component.

1. Click on the 9 dots icon in the upper left hand corner and choose `Contacts`
1. Click `New`
1. Fill in a Name and an Email address.
1. Click `Save`
1. Click on the 9 dots icon in the upper left hand corner and choose `Cases`
1. Click `New`
1. Under `Contact Name` select your contact.
1. Under `Case Origin` select any value
1. Press `Save`
1. You should now be viewing your case. In the top right, click the `Gear` icon and select `Edit Page`
1. In the menu on the left, scroll down, and under the `Custom` header, you should see `Help Lightning`
1. Click and drag `Help Lightning` and place it somewhere in the center pane. You can place it anywhere you want, although I prefer the top of the main pane.
1. Click `Save` in the top right.
1. In the pop up dialog, click `Activate`
1. In the second pop up dialog, click the `Assign as Org Default`, then `Save`
1. Press the `<- Back` in the top right corner
1. You should now see your component in your case!

Assuming you configured everything correctly in Step 1, you should be
able to Call Contact or Invite Contact. If the component is giving you
an error, please validate the following:

1. Your enterprise id was configured correctly
1. Your partner key is valid
1. Your Salesforce user's email address matches an email address in your Help Lightning enterprise. If not, go to `Setup` > `Custom Code` > `Visualforce Pages` > `HelpLightning_UserSetup`. You can verify your login and override it if necessary.

Once everything is working, follow the exact same steps for the `Work Order`.

### Development on the new Scratch Environment

To develop on the code, using your favorite editor (emacs), make changes
locally, save them, then push them to your scratch environment using
the following command:

`sf project deploy start --target-org SCRATCH_ENV_NAME`

Then reload your web browser. *Sometimes you have to reload multiple
times for your changes to take effect! During development, I often put
a print statement at the beginning with a number in it, that I
increase every time I push, that way I can view the browser's console
log and verify the new version is running*

While it is possible to edit code in Salesforce using its built in
code editor, it is not recommended, as syncing changes back locally
can be frustrating at times.

Salesforce also requires 90+% code coverage, or you cannot distribute
your package. Please make sure all new apex code has valid unit
tests. You can run all the tests using the following command:

`sf apex run test --target-org SCRATCH_ENV_NAME -c -r human --wait 10`

## Making a Release

We are now using the Second-Generation Package Management. You need to
make sure your account in our DevHUB (ISV) account has the `Package
Manager` role!

### Background

- [Basic Workflow for Second Generation
  Packages](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_dev2gp_workflow.htm)
- [Details on Generating a
  Package](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_dev2gp_create_pkg_base.htm)
- [Promoting a Package to the App Store](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_dev2gp_create_pkg_ver_promote.htm)

1. Update the ChangeLog
2. Update the sfdx-project.json. Make sure the `versionName` matches
   the ChangeLog. The `versionNumber` should be `$versionName.NEXT`
   (Salesforce auto-increments the build number for each package version created).
   
Make sure this is committed and tagged!

1. Create a new version: `sf package version create -c --package "Help Lightning" --installation-key-bypass --definition-file config/project-scratch-def.json -v ISV --wait 10`
1. A URL will be generated. You can test this in another Salesforce environment (not the ISV environment!). This can also be given to customers for testing!
1. Run a report to verify things (Note the `-` between the version and patch) `sf force package version report --package "Help Lightning@3.4.0-1" -v ISV`
1. Promote the package. This makes it available to be submitted to the App Store `sf force package version promote --package "Help Lightning@3.4.0-1" -v ISV`
1. If you forget the URL, you can use the `Subscriber Package Version Id` from the report, and append it to `https://login.salesforce.com/packaging/installPackage.apexp?p0=04t8X000000sxx1QAA`

