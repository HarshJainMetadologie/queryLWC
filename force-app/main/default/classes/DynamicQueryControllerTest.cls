@IsTest
public class DynamicQueryControllerTest {

    @IsTest
    static void testGetObjects() {
        // Call getObjects
        List<String> objects = DynamicQueryController.getObjects();
        
        // Basic assertion
        System.assert(objects.size() > 0, 'There should be at least one object returned');
    }

    @IsTest
    static void testGetFields() {
        // Choose a standard object for testing, e.g., Account
        String objectName = 'Account';
        
        // Call getFields
        Map<String, List<String>> fieldsMap = DynamicQueryController.getFields(objectName);
        
        // Assertions
        System.assert(fieldsMap.containsKey('standardFields'), 'Should contain standardFields key');
        System.assert(fieldsMap.containsKey('customFields'), 'Should contain customFields key');
        System.assert(fieldsMap.get('standardFields').size() > 0, 'Standard fields should not be empty for Account');
    }

    @IsTest
    static void testGetFieldsWithBlankObject() {
        // Call getFields with blank object
        Map<String, List<String>> fieldsMap = DynamicQueryController.getFields('');
        
        // Assertions
        System.assertEquals(0, fieldsMap.get('standardFields').size(), 'Standard fields should be empty');
        System.assertEquals(0, fieldsMap.get('customFields').size(), 'Custom fields should be empty');
    }

    @IsTest
    static void testGetRecords() {
        // Create test records
        Account acc1 = new Account(Name='Test Account 1');
        Account acc2 = new Account(Name='Test Account 2');
        insert new List<Account>{acc1, acc2};
        
        // Fields to query
        List<String> fieldNames = new List<String>{'Id','Name'};
        
        // Call getRecords
        List<SObject> records = DynamicQueryController.getRecords('Account', fieldNames, 2);
        
        // Assertions
        System.assert(records.size() == 2, 'Should return 2 records');
        System.assert(((Account)records[0]).Name != null, 'Name should not be null');
    }

    @IsTest
    static void testGetRecordsWithInvalidInput() {
        // Call getRecords with null field list
        List<SObject> records = DynamicQueryController.getRecords('Account', null, 10);
        System.assertEquals(0, records.size(), 'Should return empty list for null fields');

        // Call getRecords with blank object
        records = DynamicQueryController.getRecords('', new List<String>{'Id'}, 10);
        System.assertEquals(0, records.size(), 'Should return empty list for blank object');
    }
}
