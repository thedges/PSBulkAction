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
                System.debug('descField=' + JSON.serializePretty(descField));
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
                    else if (fieldType == 'reference')
                    {
                      fieldDef.referenceTo = descField.getReferenceTo()[0].getDescribe().name;
                      fieldDef.placeholderName = fieldDef.referenceTo.toLowerCase();
                      fieldDef.icon = getIconName(descField.getReferenceTo()[0].getDescribe().name);
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
                        else if (fieldDef.ftype == 'reference')
                        {
                           if (fieldDef.value.length() > 0) rec.put(fieldDef.name, fieldDef.value);
                        }
                        else {
                            rec.put(fieldDef.name, fieldDef.value);
                        }
                    }
                }
                recList.add(rec);
            }
System.debug('recList=' + JSON.serializePretty(recList));
            //if (recList != null && recList.size() > 0) update recList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static PSBulkActionConfig__c getBulkEditConfig(String configName)
    {
       PSBulkActionConfig__c config = [SELECT Id, Name, Config_Name__c, SAQL_ID_Field__c, Bulk_Edit_Fields__c,
                                              Show_Bulk_Edit__c, Show_Chatter__c, Show_Data__c,Show_SAQL__c, Show_Task__c
                                         FROM PSBulkActionConfig__c 
                                        WHERE Config_Name__c = :configName];
       return config;
    }
    

    @AuraEnabled
    public static void postChatter(String sobjectName, String users, Boolean mentionOwners, String groups, String post,  List<String> ids)
    {
        try {
            System.debug('users=' + users);
            System.debug('mentionOwners=' + mentionOwners);
            System.debug('groups=' + groups);
            System.debug('post=' + post);

            Map<String, String> ownerMap = new Map<String, String>();
          if (mentionOwners)
          {
            String queryStr = 'SELECT Id, OwnerId FROM ' + sobjectName + ' WHERE ID IN (' + convListToCSV(ids) + ')';
            List<sObject> sobjList = Database.query(queryStr);

            for (Sobject obj : sobjList)
            {
                ownerMap.put((String)obj.Id, (String)obj.get('OwnerId'));
            }
            System.debug('ownerMap=' + JSON.serializePretty(ownerMap));
          }

                List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();

    for (String id : ids) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

textSegmentInput.text = post.stripHtmlTags() + '\r\n \r\n';
messageBodyInput.messageSegments.add(textSegmentInput);

        // handle user mentions
        if (users != null && users.length() > 0)
       {
        List<String> userList = users.split(';');
        for (String u : userList)
        {
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            mentionSegmentInput.id = u;
            messageBodyInput.messageSegments.add(mentionSegmentInput);
            ConnectApi.TextSegmentInput tsi = new ConnectApi.TextSegmentInput();
            tsi.text = ' ';
            messageBodyInput.messageSegments.add(tsi);
       }
       }


       // handle group mentions
       if (groups != null && groups.length() > 0)
       {
        List<String> groupList = groups.split(';');
        for (String g : groupList)
        {
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            mentionSegmentInput.id = g;
            messageBodyInput.messageSegments.add(mentionSegmentInput);
            ConnectApi.TextSegmentInput tsi = new ConnectApi.TextSegmentInput();
            tsi.text = ' ';
            messageBodyInput.messageSegments.add(tsi);
       }
       }

       // handle record owners
        if (mentionOwners)
              {
                ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            mentionSegmentInput.id = ownerMap.get(id);
            messageBodyInput.messageSegments.add(mentionSegmentInput);
            ConnectApi.TextSegmentInput tsi = new ConnectApi.TextSegmentInput();
            tsi.text = ' ';
            messageBodyInput.messageSegments.add(tsi);
              }




feedItemInput.body = messageBodyInput;
feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
feedItemInput.subjectId = id;
        /*
        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();

        input.subjectId = id;
        
        ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
        body.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = post;

        body.messageSegments.add(textSegment);

        // handle user mentions
        List<String> userList = users.split(';');
        for (String u : userList)
        {
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            mentionSegmentInput.id = u;
            body.messageSegments.add(mentionSegmentInput);
       }

        // handle group mentions
        List<String> groupList = groups.split(';');
        for (String g : groupList)
        {
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            mentionSegmentInput.id = g;
            body.messageSegments.add(mentionSegmentInput);
       }

        input.body = body;
        */

        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
        batchInputs.add(batchInput);
        break;
    }
//System.debug('chatter=' + JSON.serializePretty(batchInputs));
    ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    private static String convListToCSV(List<String> vals)
    {
       String tmpStr = null;

       for (String str : vals)
       {
           if (tmpStr == null)
           {
               tmpStr = '\'' + str + '\'';
           }
           else
           {
               tmpStr += ',\'' + str + '\'';
           }
       }
       return tmpStr;
    }

    @AuraEnabled
    public static void createTasks(String subject, String description, String type, String ownerId, String dueDate, 
                                   String status, String priority, String sobjectName, Boolean recordOwner, List<String> ids)
    {
        try {
          List<Task> taskList = new List<Task>();

          // set task owner as record owner
          Map<String, String> ownerMap = new Map<String, String>();
          if (recordOwner)
          {
            String queryStr = 'SELECT Id, OwnerId FROM ' + sobjectName + ' WHERE ID IN (' + convListToCSV(ids) + ')';
            List<sObject> sobjList = Database.query(queryStr);

            for (Sobject obj : sobjList)
            {
                ownerMap.put((String)obj.Id, (String)obj.get('OwnerId'));
            }
            System.debug('ownerMap=' + JSON.serializePretty(ownerMap));
          }

           for (String id : ids)
            {
              Task t = new Task();

              if (recordOwner)
              {
                t.OwnerId = ownerMap.get(id);
              }
              else
              {
                if (ownerId != null) t.OwnerId = ownerId;
              }

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

            }

System.debug('taskList=' + JSON.serializePretty(taskList));
            //if (taskList != null && taskList.size() > 0) insert taskList[0];

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static String getIconName(String sObjectName){
        String u;
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
        List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
        List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();

        for(Schema.DescribeTabSetResult tsr : tabSetDesc) { tabDesc.addAll(tsr.getTabs()); }

        for(Schema.DescribeTabResult tr : tabDesc) {
            if( sObjectName == tr.getSobjectName() ) {
                if( tr.isCustom() == true ) {
                    iconDesc.addAll(tr.getIcons());
                } else {
                    u = 'standard:' + sObjectName.toLowerCase();
                }
            }
        }
        for (Schema.DescribeIconResult ir : iconDesc) {
            if (ir.getContentType() == 'image/svg+xml'){
                u = 'custom:' + ir.getUrl().substringBetween('custom/','.svg').substringBefore('_');
                break;
            }
        }
        return u;
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
        public String referenceTo;
        public String placeholderName;
        public String icon = 'standard:custom';

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