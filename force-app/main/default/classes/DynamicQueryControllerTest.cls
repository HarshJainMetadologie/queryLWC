@IsTest
public class DynamicQueryControllerTest {

    @IsTest
    static void testGetObjects() {        List<String> objects = DynamicQueryController.getObjects();
        
        System.assert(objects.size() > 0, 'There should be at least one object returned');
    }

    @IsTest
    static void testGetFields() {
        String objectName = 'Account';
        
        Map<String, List<String>> fieldsMap = DynamicQueryController.getFields(objectName);
        
        System.assert(fieldsMap.containsKey('standardFields'), 'Should contain standardFields key');
        System.assert(fieldsMap.containsKey('customFields'), 'Should contain customFields key');
        System.assert(fieldsMap.get('standardFields').size() > 0, 'Standard fields should not be empty for Account');
    }

    @IsTest
    static void testGetFieldsWithBlankObject() {
        Map<String, List<String>> fieldsMap = DynamicQueryController.getFields('');
        
        System.assertEquals(0, fieldsMap.get('standardFields').size(), 'Standard fields should be empty');
        System.assertEquals(0, fieldsMap.get('customFields').size(), 'Custom fields should be empty');
    }

    @IsTest
    static void testGetRecords() {
        List<Account> accountsToInsert = new List<Account>();
        for (Integer i = 1; i <= 2; i++) {
            accountsToInsert.add(new Account(
                Name = 'Test Account ' + i + '_' + String.valueOf(Crypto.getRandomInteger())
            ));
        }

        Test.startTest();
        insert accountsToInsert;
        Test.stopTest();
        
        List<String> fieldNames = new List<String>{'Id','Name'};
        
        List<SObject> records = DynamicQueryController.getRecords('Account', fieldNames, 2);
        
        System.assert(records.size() == 2, 'Should return 2 records');
        System.assert(((Account)records[0]).Name != null, 'Name should not be null');
    }

    @IsTest
    static void testGetRecordsWithInvalidInput() {
        List<SObject> records = DynamicQueryController.getRecords('Account', null, 10);
        System.assertEquals(0, records.size(), 'Should return empty list for null fields');

        records = DynamicQueryController.getRecords('', new List<String>{'Id'}, 10);
        System.assertEquals(0, records.size(), 'Should return empty list for blank object');
    }
}
