public with sharing class objectDataController {
    @AuraEnabled(cacheable=true)
    public static Boolean hasComponentPermission(){
            return FeatureManagement.checkPermission('Object_Data');
    }
}