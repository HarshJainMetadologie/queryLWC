public with sharing class DynamicQueryController {

    @AuraEnabled(cacheable=true)
    public static List<String> getObjects() {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        List<String> objectNames = new List<String>(gd.keySet());
        objectNames.sort();
        return objectNames;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> getFields(String objectName) {
        Map<String, List<String>> result = new Map<String, List<String>>();
        result.put('standardFields', new List<String>());
        result.put('customFields', new List<String>());

        if (String.isBlank(objectName)) {
            return result;
        }

        Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> fieldsMap = sobjectType.getDescribe().fields.getMap();

        for (String fieldName : fieldsMap.keySet()) {
            Schema.DescribeFieldResult fieldDesc = fieldsMap.get(fieldName).getDescribe();
            if (fieldName.endsWith('__c')) {
                result.get('customFields').add(fieldDesc.getName());
            }
            if( !fieldName.endsWith('__c') ){
                result.get('standardFields').add(fieldDesc.getName());
            }
        }

        return result;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getRecords(String objectName, List<String> fieldNames, Integer limitSize) {
        Map<String, Object> response = new Map<String, Object>();
        List<Map<String, Object>> filteredRecords = new List<Map<String, Object>>();
        Set<String> nonEmptyFields = new Set<String>();

        if (String.isBlank(objectName) || fieldNames == null || fieldNames.isEmpty()) {
            response.put('records', filteredRecords);
            response.put('fields', new List<String>());
            return response;
        }
        List<String> safeFields = new List<String>();
        for (String f : fieldNames) {
            if (!f.contains('.')) safeFields.add(f);
        }

        String soqlQuery = 'SELECT ' + String.join(safeFields, ',') + ' FROM ' + objectName;
        if (limitSize != null && limitSize > 0) {
            soqlQuery += ' LIMIT ' + limitSize;
        }

        List<SObject> records = Database.query(soqlQuery);

        for (SObject record : records) {
            for (String field : safeFields) {
                Object val = record.get(field);
                if (val != null && String.valueOf(val).trim() != '') {
                    nonEmptyFields.add(field);
                }
            }
        }

        for (SObject record : records) {
            Map<String, Object> recMap = new Map<String, Object>();
            Boolean hasValue = false;

            recMap.put('Id', record.Id);

            for (String field : nonEmptyFields) {
                if (field == 'Id') continue; 
                Object val = record.get(field);
                if (val != null && String.valueOf(val).trim() != '') {
                    recMap.put(field, val);
                    hasValue = true;
                }
            }

            if (hasValue) filteredRecords.add(recMap);
        }

        response.put('records', filteredRecords);
        response.put('fields', new List<String>(nonEmptyFields));
        return response;
    }

}