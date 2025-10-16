@IsTest
public class objectDataControllerTest {

    @IsTest
    static void testHasComponentPermission() {
        // Mocking the permission check using Test.startTest/stopTest is optional
        // Call the method
        Boolean hasPermission = objectDataController.hasComponentPermission();
        
        // Assertion (it will be true if permission exists, false if not)
        System.assert(hasPermission != null, 'The method should return a Boolean value');
    }
}
