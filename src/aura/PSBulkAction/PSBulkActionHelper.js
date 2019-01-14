({
    executeSAQLQuery: function (component) {
        var self = this;

        try
        {
            self.showSpinner(component);

            var action = component.get("c.executeSAQLQuery");
            action.setParams({
                "query": component.get('v.query')
            });

            action.setCallback(this, function (a) {
                var state = a.getState();
                if (state === "SUCCESS") {
                    //console.log('response=' + a.getReturnValue());

                    var idField = component.get("v.idField");
                    var idFieldFound = false;
                    var sobjectPrefixFound = false;
                    var queryResp = JSON.parse(a.getReturnValue());

                    // parse to create columns object
                    var columns = [];
                    var metadata = queryResp.results.metadata[0].lineage.projections;
                    for (var i = 0; i < metadata.length; i++) {
                        var field = metadata[i].field.id;
                        if (field.startsWith('q.')) {
                            field = field.substring(2);
                        }

                        if (idFieldFound === false && field === idField) {
                            idFieldFound = true;
                        }

                        var type = metadata[i].field.type;
                        if (type === 'numeric') {
                            type = 'number';
                        } else {
                            type = 'text';
                        }
                        columns.push({'label': field, 'fieldName': field, 'type': type});
                    }

                    columns.push({'label': ' ', 'fieldName': ' ', 'type': 'text', 'initialWidth': '10'});

                    if (idFieldFound === false) {
                        component.set('v.errorMsg', 'Object ID field [' + idField + '] not found in SAQL query')
                    } else {

                        // parse to create data object
                        var data = [];
                        var ids = [];
                        var records = queryResp.results.records;
                        for (i = 0; i < records.length; i++) {
                            var rec = {};

                            for (var j = 0; j < columns.length; j++) {
                                rec[columns[j].fieldName] = records[i][columns[j].fieldName];

                                if (columns[j].fieldName === idField) {
                                    var val = records[i][columns[j].fieldName];
                                    ids.push(val);

                                    if (sobjectPrefixFound === false) {
                                        sobjectPrefixFound = true;
                                        component.set('v.sobjectPrefix', val.substring(0, 3));
                                    }

                                }
                            }

                            data.push(rec);
                        }

                        component.set('v.columns', columns);
                        component.set('v.data', data);
                        component.set('v.ids', ids);

                        self.getFieldDefs(component);
                    }

                    component.set('v.queryResp', JSON.parse(a.getReturnValue()));
                } else {
                    self.handleErrors(component, a.getError());
                    self.hideSpinner(component);
                }

            });
            $A.enqueueAction(action);
        } catch (err) {
            self.handleErrors(component, err.message);
        }
    },
    getFieldDefs: function (component) {
        var self = this;
        try
        {
            var action = component.get("c.getFieldDefs");
            action.setParams({
                "sobjectPrefix": component.get('v.sobjectPrefix'),
                "fields": component.get('v.editFields')
            });

            action.setCallback(this, function (a) {
                var state = a.getState();
                if (state === "SUCCESS") {
                    component.set('v.sobjectDef', JSON.parse(a.getReturnValue()));
                } else {
                    self.handleErrors(component, a.getError());
                }
                self.hideSpinner(component);

            });
            $A.enqueueAction(action);
        } catch (err) {
            self.handleErrors(component, err.message);
        }
    },
    updateRecords: function (component) {
        var self = this;
        try {
            self.showSpinner(component);

            var action = component.get("c.updateRecords");
            action.setParams({
                "sobjectDef": JSON.stringify(component.get('v.sobjectDef')),
                "ids": component.get('v.ids')
            });

            action.setCallback(this, function (a) {
                var state = a.getState();
                if (state === "SUCCESS") {} else {
                    self.handleErrors(component, a.getError());
                }
                self.hideSpinner(component);

            });
            $A.enqueueAction(action);
        } catch (err) {
            self.handleErrors(component, err.message);
        }
    },
    createTasks: function (component) {
        var self = this;

        try {
            self.showSpinner(component);

            var action = component.get("c.createTasks");

            action.setParams({
                "subject": component.get('v.taskSubject'),
                "description": component.get('v.taskDescription'),
                "type": component.get('v.taskType'),
                "ownerId": component.get('v.taskOwnerId'),
                "dueDate": component.get('v.taskDueDate'),
                "status": component.get('v.taskStatus'),
                "priority": component.get('v.taskPriority'),
                "ids": component.get('v.ids')
            });

            console.log('params=' + JSON.stringify(action.getParams()));

            action.setCallback(this, function (a) {
                var state = a.getState();
                if (state === "SUCCESS") {} else {
                    self.handleErrors(component, a.getError());
                }
                self.hideSpinner(component);

            });
            $A.enqueueAction(action);
        } catch (err) {
            self.handleErrors(component, err.message);
        }

    },
    showSpinner: function (component) {
        component.set("v.IsSpinner", true);
    },
    hideSpinner: function (component) {
        component.set("v.IsSpinner", false);
    },
    handleErrors: function (component, errors) {
        var errorMsg;

        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            errorMsg = errors[0].message;
        } else {
            errorMsg = errors;
        }
        component.set("v.errorMsg", errorMsg);

    }
})