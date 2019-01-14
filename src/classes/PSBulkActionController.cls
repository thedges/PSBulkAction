public class PSBulkActionController {
    @AuraEnabled
    public static String executeSAQLQuery(String query)
    {
        System.debug('executeSAQLQuery invoked...');

        try {
            query = EncodingUtil.urlDecode(query, 'UTF-8');
            System.debug('query=' + query);

            ConnectApi.LiteralJson result = ConnectApi.Wave.executeQuery(query);
            String response = result.json;
            System.debug('json=' + response);

            return response;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getFieldDefs(String sobjectPrefix, String fields)
    {
        SObjectDef objectDef = new SObjectDef();

        try {
            String objectName = getObjectName(sobjectPrefix);
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);
            if (targetType == null)
            {
                //return '[{"message":"The requested resource does not exist","errorCode":"NOT_FOUND"}]';
                System.debug('targetType is null');
            }

            Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = sobjResult.fields.getMap();

            objectDef.objectLabel = sobjResult.label;
            objectDef.objectName = sobjResult.name;
            objectDef.objectPrefix = sobjResult.keyPrefix;

            // set list of fields to describe
            List<String> keySet = null;
            keySet = parseCSVString(fields);
            if (keySet == null)
            {
                keySet = new List<String>(fieldMap.keySet());
            }

            String fld;
            String fieldKeyDef = null;

            List<FieldDef> fieldDefList = new List<FieldDef>();

            for (String key : keySet)
            {
                fld = key;

                /////////////////////////////////////////
                // get the core metadata def for field //
                /////////////////////////////////////////
                Schema.DescribeFieldResult descField = fieldMap.get(fld).getDescribe();
                if (descField != null)
                {
                    FieldDef fieldDef = new FieldDef();
                    fieldDef.label = descField.getLabel();
                    fieldDef.name = descField.getName();
                    fieldDef.ftype = descField.getType().name().toLowerCase();
                    fieldDef.value = null;

                    String fieldType = descField.getType().name().toLowerCase();

                    //if a field is a picklist, I want the values
                    if (fieldType == 'picklist' || fieldType == 'multipicklist')
                    {
                        List<Object> optionsList = new List<Object>();
                        List<Schema.PicklistEntry> pickListValues = descField.getPickListValues();

                        for (Schema.PicklistEntry plv : pickListValues)
                        {
                            fieldDef.addOption(plv.getLabel(), plv.getValue());
                        }

                    }
                    fieldDefList.add(fieldDef);
                    //objectDef.addField(fieldDef);
                }

            }

            // re-order and put checkbox at the end
            for (FieldDef def : fieldDefList)
            {
               if (def.ftype != 'boolean')
               {
                   objectDef.addField(def);
               }
            }

            if (Math.mod(objectDef.fields.size(),2) == 1)
            {
                    FieldDef fieldDef = new FieldDef();
                    fieldDef.label = 'skip';
                    fieldDef.name = 'skip';
                    fieldDef.ftype = 'skip';
                    fieldDef.value = null;
                    objectDef.addField(fieldDef);
            }
                        
            for (FieldDef def : fieldDefList)
            {
               if (def.ftype == 'boolean')
               {
                   objectDef.addField(def);
               }
            }


            return JSON.serialize(objectDef);


        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateRecords(String sobjectDef, List<String> ids)
    {
        try {
            System.debug('sobjectDef=' + sobjectDef);
            System.debug('ids=' + JSON.serializePretty(ids));

            SObjectDef def = (SObjectDef)JSON.deserialize(sobjectDef, SObjectDef.class);

            List<SObject> recList = new List<SObject>();
            for (String id : ids)
            {
                SObject rec = Schema.getGlobalDescribe().get(def.objectName).newSObject() ;
                rec.put('Id', id);

                for (FieldDef fieldDef : def.fields)
                {
                    if (fieldDef.value != null)
                    {
                        if (fieldDef.ftype == 'boolean' )
                        {
                            rec.put(fieldDef.name, Boolean.valueOf(fieldDef.value));
                        }
                        else {
                            rec.put(fieldDef.name, fieldDef.value);
                        }
                    }
                }
                recList.add(rec);
            }

            if (recList != null && recList.size() > 0) update recList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void createTasks(String subject, String description, String type, String ownerId, String dueDate, String status, String priority, List<String> ids)
    {
        try {
          List<Task> taskList = new List<Task>();
           for (String id : ids)
            {
              Task t = new Task();
              if (ownerId != null) t.OwnerId = ownerId;
              if (subject != null) t.Subject = subject;
              if (description != null) t.Description = description;
              if (dueDate != null) t.ActivityDate = Date.valueOf(dueDate);
              if (status != null) t.Status = status;
              if (priority != null) t.Priority = priority;

              if (id.startsWith('003') || id.startsWith('00Q'))   // Contacts or Leads
              {
                t.WhoId = id;
              }
              else
              {
                t.WhatId = id;
              }
              taskList.add(t);
              break;
            }

System.debug('taskList=' + JSON.serializePretty(taskList));
            if (taskList != null && taskList.size() > 0) insert taskList[0];

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<String> parseCSVString(String str)
    {
        return parseDelimitedString(str, ',');
    }

    private static List<String> parseDelimitedString(String str, String delim)
    {
        List<String> optList = new List<String>();
        for (String key : str.split(delim))
        {
            optList.add(key.trim());
        }


        return optList;
    }

    private static String getObjectName(String keyPrefix)
    {
        if(keyPrefix == null)
            return null;
        String objectAPIName = '';

        for( Schema.SObjectType obj : Schema.getGlobalDescribe().Values() ) {
            String prefix = obj.getDescribe().getKeyPrefix();
            if(prefix == keyPrefix) {
                objectAPIName = obj.getDescribe().getName();
                break;
            }
        }

        return objectAPIName;
    }

    public class SObjectDef
    {
        public String objectName;
        public String objectLabel;
        public String objectPrefix;

        public List<FieldDef> fields = null;

        public void addField(FieldDef fld)
        {
            if (fields == null) fields = new List<FieldDef>();
            fields.add(fld);
        }
    }

    public class FieldDef
    {
        public String label;
        public String name;
        public String ftype;
        public String value;

        public List<OptionDef> options = null;

        public void addOption(OptionDef opt)
        {
            if (options == null) options = new List<OptionDef>();
            options.add(opt);
        }

        public void addOption(String label, String value)
        {
            if (options == null) options = new List<OptionDef>();
            OptionDef opt = new OptionDef();
            opt.label = label;
            opt.value = value;
            options.add(opt);
        }
    }

    public class OptionDef
    {
        public String label;
        public String value;
    }
}