# PSBulkAction
A component providing a declarative "bulk action" editor for Einstein Analytics dashboard table components. The component receives the SAQL query from the Einstein Analytics dashboard component and provides the following:
- Can operate on any sobject as identified by one of the columns in the SAQL (should contain record ids)
- Ability to update every record returned by SAQL via a configurable list of fields
- Ability to create chatter posts for all records returned by the SAQL
- Ability to create tasks for all records returned by the SAQL
- Display of the data returned from the SAQL statement
- Display of the actual SAQL query.

<b>WARNING: THIS COMPONENT WILL EDIT, CREATE CHATTER POSTS, OR CREATE TASKS FOR EVERY RECORD RETURNED BY THE SAQL QUERY. THE SOBJECT AND NUMBER OF RECORDS IS IDENTIFIED AT THE TOP OF THE COMPONENT SO MAKE SURE THOSE VALUES ARE CORRECT BEFORE APPLYING CHANGES.</b>

![alt text](https://github.com/thedges/PSBulkAction/blob/master/PSBulkAction.gif "Demo Image")

Here is a walk through of each tab in the component.

<b>Bulk Edit Tab</b><br/>

Bulk editor screen that will apply all settings to every record returned by the SAQL query. The edit fields shown on the page are dynamic and are driven by the 'PSBulkActionConfig' record configuration as defined in step #3 below.

![alt text](https://github.com/thedges/PSBulkAction/blob/master/PSBulkAction-BulkEdit.png "Bulk Edit")

<b>Chatter Tab</b><br/>

   Editor screen to create chatter posts for every record returned by  the SAQL query. You have the following options:

   - <b>Users</b> - select users to @mention
   - <b>Groups</b> - select chatter groups to @mention
   - <b>@mention record owner</b> - for every record, @mention the record owner
   - <b>Chatter Message</b> - the text message to send as main body of the chatter post
   
   ![alt text](https://github.com/thedges/PSBulkAction/blob/master/PSBulkAction-Chatter.png "Chatter")

<b>Tasks Tab</b><br/>

   Editor screen to create tasks for every record returned by the SAQL query. You have the following options:

   - <b>Subject</b> - the subject for the task
   - <b>Description</b> - the description for the task
   - <b>Due Date</b> - the date that every task is due by
   - <b>Owner</b> - select one specific user to be the owner of all created tasks...or
   - <b>Assign record owner</b> - assign the owner of each task to the owner of the current records
   - <b>Type</b> - the task type
   - <b>Status</b> - the task status
   - <b>Priority</b> - the task priority
   
   ![alt text](https://github.com/thedges/PSBulkAction/blob/master/PSBulkAction-Tasks.png "Tasks")

<b>Data Tab</b><br/>

   Simple read-only table view of data returned by the SAQL query sent from the Einstein Analytics dashboard
   
   ![alt text](https://github.com/thedges/PSBulkAction/blob/master/PSBulkAction-Data.png "Data")

<b>SAQL Query Tab</b><br/>

   Read-only view of the SAQL query sent from the Einstein Analytics dashboard

   ![alt text](https://github.com/thedges/PSBulkAction/blob/master/PSBulkAction-SAQL.png "SAQL")

<b>Follow these steps to install and configure this component:</b>
1. Install the component via the deploy button below. Make sure to install any pre-reqs. 
2. Assign the 'PSBulkActionEditor' permission set to any users using this component.
3. Go to the 'PSBulkActionConfig' tab and create a configuration record for your specific configuration. Below is sample screen and field definitions: ![alt text](https://github.com/thedges/PSBulkAction/blob/master/PSBulkAction-Record.png "Record")

   - <b>Config Name</b> - provide a logical name for the configuration; this is the value to be used in step 4
   - <b>SAQL ID Field</b> - the field in the SAQL query that identifies the sobject IDs to for the sobject to bulk edit
   - <b>Bulk Edit Fields</b> - a comma-separated list of sobject field API names to allow editing for
   - <b>Show Bulk Edit</b> - show the Bulk Edit tab
   - <b>Show Chatter</b> - show the Chatter tab
   - <b>Show Task</b> - show the Task tab
   - <b>Show Data</b> - show the Data tab
   - <b>Show SAQL</b> - show the SAQL tab
   
4. For the Einstein Analytics dashboard table component that you want to add 'bulk edit' capability to, perform the following:
   - Open your dashboard in Analytics Studio
   - Switch to edit mode for your dashboard
   - Select the table component in your dashboard
   - In configuration window on right side of screen, set following config properties:
     - <b>Custom Action Label</b> - a string value to show as menu option for your table; example: 'Bulk Edit'
     - <b>Visualforce Page Name</b> - set exactly to 'PSBulkActionHandler'
   - Next we need to modify the actual table component SAQL. Select the table component and click the pencil icon that pops up below it.
   - In top-right of next screen, select the SAQL edit option/button.
   - Lastly, edit the SAQL code to include a comment line that will tell the bulk editor component which configuration setting (created in step #3) to use.  Edit the table component SAQL to create a comment line as the first row. The comment line should be in the form 
   '--bulkconfig=<configuration_name>'. An example is below,
   
   ![alt text](https://github.com/thedges/PSBulkAction/blob/master/PSBulkAction-SAQL.png "SAQL")
   
That's it! You should now be able to perform bulk editing on your table component and perform custom field edits, chatter posts and task creations.

<b>Dependency:</b> Install the [LightningStrike.io](https://github.com/thedges/Lightning-Strike) package first.

<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

