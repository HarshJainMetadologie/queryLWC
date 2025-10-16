@IsTest
private class PreviewVFControllerTest {

    @IsTest
    static void testPreviewControllerWithValidParams() {
        PageReference pageRef = Page.PreviewVF;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('objectName', 'Account');
        ApexPages.currentPage().getParameters().put('fields', 'Name');
        ApexPages.currentPage().getParameters().put('recordsJson', '[{"Name":"Test Account"}]');

        PreviewVFController ctrl = new PreviewVFController();

        System.assertEquals('Account', ctrl.objectName);
        System.assert(ctrl.fields.contains('Name'), 'Fields should contain Name');
        System.assertEquals(1, ctrl.records.size(), 'Records should contain 1 record');
    }

    @IsTest
    static void testPreviewControllerWithBlankParams() {
        PageReference pageRef = Page.PreviewVF;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('recordsJson', '[]');

        PreviewVFController ctrl = new PreviewVFController();

        System.assertEquals(null, ctrl.objectName);
        System.assertEquals(0, ctrl.fields.size(), 'Fields should be empty');
        System.assertEquals(0, ctrl.records.size(), 'Records should be empty');
    }

    @IsTest
    static void testPreviewControllerWithInvalidJson() {
        PageReference pageRef = Page.PreviewVF;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('recordsJson', '{invalid json}');

        try {
            PreviewVFController ctrl = new PreviewVFController();
            System.assert(false, 'Exception should have been thrown for invalid JSON');
        } catch (System.JSONException e) {
            System.assert(true, 'Expected JSON exception caught');
        }
    }
}
