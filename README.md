# PSBulkAction
A component providing a declarative "bulk action" editor for Einstein Analytics. The component retrieves the SAQL query from the Einstein Analytics dashboard component and provides the following:
* Configurable list of fields to show for editing in bulk for all records returned by the SAQL
* Ability to create tasks for all records returned by the SAQL
* Display of the data returned from the SAQL statement
* Display of the actual SAQL query.

![alt text](https://github.com/thedges/PSBulkAction/blob/master/PSBulkAction.gif "Demo Image")

<b>Follow the following steps to use this component:</b>
1. Install the component via the link below. 
2. Assign the 'PSBulkActionEditor' permission set to any users using this component.
3. Go to the 'PSBulkActionConfig' tab and create a configuration record for your specific configuration. Below is sample screen and field definitions:

  ![alt text](https://github.com/thedges/PSBulkAction/blob/master/PSBulkAction-Record.png "Record")

   * <b>Config Name</b> - provide a logical name for the configuration; this is the value to be used in step XX
   * <b>SAQL ID Field</b> - the field in the SAQL query that identifies the sobject IDs to for the sobject to bulk edit
   * <b>Bulk Edit Fields</b> - a comma-separated list of sobject field API names to allow editing for
   * <b>Show Bulk Edit</b> - show the Bulk Edit tab
   * <b>Show Chatter</b> - show the Chatter tab
   * <b>Show Task</b> - show the Task tab
   * <b>Show Data</b> - show the Data tab
   * <b>Show SAQL</b> - show the SAQL tab

<b>Dependency:</b> Install the [LightningStrike.io](https://github.com/thedges/Lightning-Strike) package first.

<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

