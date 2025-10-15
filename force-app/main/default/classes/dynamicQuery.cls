public with sharing class dynamicQuery {
    @AuraEnabled(cacheable=true)
    public static List<String> getAllObjects() {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        List<String> objectNames = new List<String>(gd.keySet());
        objectNames.sort();
        return objectNames;
    }
}