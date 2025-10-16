@IsTest
public class objectDataControllerTest {

    @IsTest
    static void testHasComponentPermission() {
        Boolean hasPermission = objectDataController.hasComponentPermission();
        
        System.assert(hasPermission != null, 'The method should return a Boolean value');
    }
}
