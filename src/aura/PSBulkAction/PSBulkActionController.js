({
	doInit : function(component, event, helper) {
		var query = decodeURIComponent(component.get("v.query")).replace(/\+/g, ' ').replace(/; /g, ';').replace(/;/g, ';\r\n');
		component.set("v.query", decodeURIComponent(query));

		helper.executeSAQLQuery(component);
	},
	onBulkUpdate: function(component, event, helper) {
		helper.updateRecords(component);
	},
	onBulkClear: function(component, event, helper) {
		helper.showSpinner(component);

		var sobjectDef = component.get('v.sobjectDef');
		if (sobjectDef)
		{
			for (var i=0; i<sobjectDef.fields.length; i++)
			{
				sobjectDef.fields[i].value = null;
			}
		}
		component.set('v.sobjectDef', sobjectDef);
		helper.hideSpinner(component);
	},
	onTasksCreate: function(component, event, helper) {
		helper.createTasks(component);
	},
	onTasksClear: function(component, event, helper) {
	}
})