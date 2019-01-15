# PSBulkAction
A component providing a declarative "bulk action" editor for Einstein Analytics. The component retrieves the SAQL query from the Einstein Analytics dashboard component and provides the following:
- Configurable list of fields to show for editing in bulk mode for all records returned by the SAQL
- Create chatter posts for all records returned by the SAQL
- Create tasks for all records returned by the SAQL
- Display of the data returned from the SAQL statement
- Display of the actual SAQL query.

![alt text](https://github.com/thedges/PSBulkAction/blob/master/PSBulkAction.gif "Demo Image")

![alt text](https://github.com/thedges/PSBulkAction/blob/master/PSBulkAction-BulkEdit.png "Bulk Edit")

![alt text](https://github.com/thedges/PSBulkAction/blob/master/PSBulkAction-Chatter.png "Chatter")

![alt text](https://github.com/thedges/PSBulkAction/blob/master/PSBulkAction-Tasks.png "Tasks")

![alt text](https://github.com/thedges/PSBulkAction/blob/master/PSBulkAction-Data.png "Data")

![alt text](https://github.com/thedges/PSBulkAction/blob/master/PSBulkAction-SAQL.png "SAQL")

<b>Follow the following steps to use this component:</b>
1. Install the component via the deploy button below. Make sure to install any pre-reqs. 
2. Assign the 'PSBulkActionEditor' permission set to any users using this component.
3. Go to the 'PSBulkActionConfig' tab and create a configuration record for your specific configuration. Below is sample screen and field definitions: ![alt text](https://github.com/thedges/PSBulkAction/blob/master/PSBulkAction-Record.png "Record")

   - <b>Config Name</b> - provide a logical name for the configuration; this is the value to be used in step XX
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

