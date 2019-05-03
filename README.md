# Help Lightning Salesforce Component

This is a Salesforce Lightning component that integrates making Help
Lightning calls through Salesforce. It integrates into the Cases and
WorkOrder objects, allowing the Salesforce user to directly call their
contact. It also records the Help Lightning call and associates it
with the corresponding Case or WorkOrder.

## Setting up a Scratch Environment

To do anything, you must first install the sfdx tools:
https://developer.salesforce.com/tools/sfdxcli

For development, we use a Salesforce DX environment to create
temporary scratch environments. First, have an administrator create an
account in our `ISV` org: `helplightning@isvedition.org`. Once you
have an account, connect it using the sfdx command. You need to alias
it as `ISV`.

`sfdx force:auth:web:login -a ISV -d`

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
resource, configure the permissions, then print out a Login
URL. Clicking on the URL will open up the scratch environment and
automatically log you in.

### Configuring the new Scratch Environment

Once you are in your scratch environment, you need to configure it. There are two things we need to configure:
1. The Help Lightning enterprise and partner key
1. Adding the component to Cases and WorkOrders

First to configure the Help Lightning Enterprise and Partner Key:

1. Go to `Setup` > `Custom Code` > `Visualforce Pages`
1. Find `HelpLightingSetup` and click on the icon of two sqaures with an arrorw, just to the right of Security. This will open a preview of the page in a new tab.
1. For `Enterprise Id`, you will need the Help Lightning Id of your enterprise in production. This can be found in crunch.
1. For `Private Key`, you will need a private key for your enterprise. If you don't have one, you can manually create one using the Galdr admin api. *Be careful doing this, as creating a new key removes any existing keys!*
1. Press `Save` and close the tab.

Second, configure the Cases and WordOrders to show the Help Lightning Component.

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

To develop on the code, Using your favorite editor, make changes
locally, save them, then push them to your scratch environment using
the following command:

`sfdx force:source:push -u SCRATCH_ENV_NAME`

Then reload your web browser. *Sometime you have to reload multiple
times for your changes to take effect! During development, I often put
a print statement at the beginning with a number in it, that I
increase everytime I push, that way I can view the browser's console
log and verify the new version is running*

While it is possible to edit code in Salesforce using its built in
code editor, it is not recommended, as syncing changes back locally
can be frustrating at time.

Salesforce also requires 90+% code coverage, or you cannot distribute
your package. Please make sure all new apex code has valid unit
tests. You can run all the tests using the following command:

`sfdx force:apex:test:run -u SCRATCH_ENV_NAME -c -r human --wait 10`

## Making a Release

*Warning: All of this is tied to Marcus Dillavou's Salesforce Development environment*

In sfdx, make sure you have added an org named `Standard`. This org
must be a developer org, part of our ISV, AND have the `helplightning`
namespace registered. Currently, this is only Marcus Dillavou's
development org, as I am not sure how to make others!

The first step is to push all the resources to the `Standard`
development org. Since the development org isn't a DX org, we have to
use the special `./scripts/push-to-standard` script.

1. ./scripts/push-to-standard
1. Log into the `Standard` org
1. Go to Setup > Package Manager
1. Select the `Help Lightning` package
1. Under the `Components` tab, click `Add`. Make sure all of our components have been added. This includes: *Warning: Once you add these and release a managed package, you can never remove them!*
  - Apex Classes
  - Lightning Pages
  - Custom Object
  - Custom Field
  - Custom Setting
  - Permission Set
  - Aura Component Bundle
  - Visualforce Page
  - Remote Site
1. Click `Upload`
1. Enter the `Version Name` and `Version Number`. We use our version number for both, i.e.: `2.0`
1. Select `Managed - Released` as the `Release Type`
1. For `Release Notes` leave it as `None`
1. For `Post Install Instruction` change it to `Visualforce Page` and select `HelpLightningSetup [helplightning__HelpLightningSetup]`
1. For `Description` leave it empty
1. Leave everything else alone, and choose `Upload`

(I have had some issues with HLRequestTest2 failing and causing issues
during the upload. Therefore, you may want to make sure it is removed
from the `Components` tab.)

Once the upload is complete, it is possible to push this to the app
store. However, at this time, we are typically just getting the
`Installation URL` from the package and directly giving that to
customers.

