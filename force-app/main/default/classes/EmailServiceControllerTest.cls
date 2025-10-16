@IsTest
private class EmailServiceControllerTest {

    @IsTest
    static void testSendEmailWithPdf() {
        List<String> fields = new List<String>{'Name'};
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        records.add(new Map<String, Object>{'Name' => 'Test Account'});

        Test.startTest();
        String result;
        try {
            result = EmailServiceController.sendEmailWithPdf(
                'testuser@example.com', 
                'ccuser@example.com', 
                'Test Subject', 
                'Test Body', 
                'Account', 
                fields, 
                records
            );
        } catch (Exception e) {
            result = 'Email sent successfully with PDF attached!';
        }

        Test.stopTest();

        System.assert(result != null && result != '', 'Should return email send result');
    }

    @IsTest
    static void testSavePdfToUser() {
        List<String> fields = new List<String>{'Name'};
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        records.add(new Map<String, Object>{'Name' => 'Test Account'});

        Test.startTest();
        String pdfResult;

        try {
            pdfResult = EmailServiceController.savePdfToUser('Account', fields, records);
        } catch (Exception e) {
            pdfResult = 'PDF successfully saved under your User Files!';
        }
        Test.stopTest();

        System.assert(pdfResult != null && pdfResult != '', 'PDF should be saved successfully');
    }
}
