public with sharing class PreviewVFController {
    public String objectName { get; set; }
    public List<String> fields { get; set; }
    public List<Map<String,Object>> records { get; set; }

    public PreviewVFController() {
        objectName = ApexPages.currentPage().getParameters().get('objectName');
        String fieldsParam = ApexPages.currentPage().getParameters().get('fields');
        String recordsJson = ApexPages.currentPage().getParameters().get('recordsJson');

        // Split fields
        if (fieldsParam != null) {
            fields = fieldsParam.split(',');
        } else {
            fields = new List<String>();
        }

        // Initialize records
        records = new List<Map<String,Object>>();

        // Deserialize selected records safely
        if(recordsJson != null) {
            List<Object> rawList = (List<Object>) JSON.deserializeUntyped(recordsJson);
            for(Object o : rawList) {
                if(o instanceof Map<String,Object>) {
                    records.add((Map<String,Object>) o);
                }
            }
        }
    }
}