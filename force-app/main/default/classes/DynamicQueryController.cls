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
    public static List<SObject> getRecords(String objectName, List<String> fieldNames, Integer limitSize) {
        if (String.isBlank(objectName) || fieldNames == null || fieldNames.isEmpty()) {
            return new List<SObject>();
        }

        String soqlQuery = 'SELECT ' + String.join(fieldNames, ',') + ' FROM ' + objectName;
        if (limitSize != null && limitSize > 0) {
            soqlQuery += ' LIMIT ' + limitSize;
        }

        List<SObject> records = Database.query(soqlQuery);

        // Filter out fields that are null in all records
        Set<String> fieldsWithData = new Set<String>();
        for (SObject rec : records) {
            for (String field : fieldNames) {
                if (rec.get(field) != null && String.valueOf(rec.get(field)).trim() != '') {
                    fieldsWithData.add(field);
                }
            }
        }

        // Only keep fields that have data
        if (!fieldsWithData.isEmpty()) {
            List<String> filteredFields = new List<String>(fieldsWithData);
            String filteredQuery = 'SELECT ' + String.join(filteredFields, ',') + ' FROM ' + objectName;
            if (limitSize != null && limitSize > 0) {
                filteredQuery += ' LIMIT ' + limitSize;
            }
            records = Database.query(filteredQuery);
        }

        return records;
    }
}