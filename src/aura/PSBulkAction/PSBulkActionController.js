({
	doInit : function(component, event, helper) {
		var query = decodeURIComponent(component.get("v.query")).replace(/\+/g, ' ').replace(/; /g, ';').replace(/;/g, ';\r\n');
		component.set("v.query", decodeURIComponent(query));

		helper.loadConfig(component);
		//helper.executeSAQLQuery(component);
	},
	onBulkUpdate: function(component, event, helper) {
		helper.updateRecords(component);
	},
	onBulkClear: function(component, event, helper) {
		helper.clearBulkEdit(component);
	},
	onTasksCreate: function(component, event, helper) {
		helper.createTasks(component);
	},
	onTaskClear: function(component, event, helper) {
		helper.clearTasksEdit(component);
	},
	onChatterClear: function(component, event, helper) {
		helper.clearChatterEdit(component);
	},
	onChatterPost: function(component, event, helper) {
		helper.postChatter(component);
	},
	handleTaskOwnerCheck: function(component, event, helper) {
		var isChecked = component.find("TaskAttachOwner").get("v.checked");
		component.set("v.taskRecordOwner", isChecked);
		
	},
	handleChatterOwnerCheck: function(component, event, helper) {
		var isChecked = component.find("ChatterMentionOwner").get("v.checked");
		component.set("v.chatterMentionOwner", isChecked);
		
	}
})