public with sharing class EmailServiceController {
    @AuraEnabled
    public static String sendEmailWithPdf(String toAddresses, String ccAddresses, String subject, String body, String objectName, List<String> fields, List<Map<String, Object>> records) {
        try {
            if (String.isBlank(toAddresses)) {
                return 'Please provide at least one recipient email address.';
            }

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            List<String> toList = new List<String>();
            if (toAddresses.contains(',')) {
                toList = toAddresses.split(',');
            } else {
                toList.add(toAddresses);
            }
            email.setToAddresses(toList);

            if (!String.isBlank(ccAddresses)) {
                List<String> ccList = new List<String>();
                if (ccAddresses.contains(',')) {
                    ccList = ccAddresses.split(',');
                } else {
                    ccList.add(ccAddresses);
                }
                email.setCcAddresses(ccList);
            }

            if (String.isBlank(subject)) {
                subject = 'Record Preview - ' + objectName;
            }
            if (String.isBlank(body)) {
                body = 'Please find attached the preview PDF for ' + objectName + ' records.';
            }

            email.setSubject(subject);
            email.setPlainTextBody(body);

            PageReference pdfPage = Page.PreviewVF;
            pdfPage.getParameters().put('objectName', objectName);
            pdfPage.getParameters().put('fields', String.join(fields, ','));
            pdfPage.getParameters().put('recordsJson', JSON.serialize(records));

            Blob pdfBlob;
            if (Test.isRunningTest()) {
                pdfBlob = Blob.valueOf('Test PDF Content'); // Mock PDF in test
            } else {
                pdfBlob = pdfPage.getContentAsPDF();
            }


            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('Preview_' + objectName + '.pdf');
            attachment.setBody(pdfBlob);
            attachment.setContentType('application/pdf');
            email.setFileAttachments(new List<Messaging.EmailFileAttachment>{attachment});

            email.setReplyTo(UserInfo.getUserEmail());
            email.setSenderDisplayName(UserInfo.getName());
            email.setUseSignature(true);
            email.setBccSender(false);
            email.setSaveAsActivity(true);

            Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
            try {
                Email_Audit_Log__c log = new Email_Audit_Log__c(
                    Email_Action__c = 'Sent',
                    Recipients__c = String.join(email.getToAddresses(), ','),
                    Subject__c = email.getSubject(),
                    Body_Preview__c = email.getPlainTextBody(),
                    Object_Name__c = objectName,
                    Status__c = 'Success',
                    Timestamp__c = System.now(),
                    Sent_By__c = UserInfo.getUserId()
                );
                insert log;
            } catch (Exception e) {
                Email_Audit_Log__c log = new Email_Audit_Log__c(
                    Email_Action__c = 'Failed',
                    Recipients__c = String.join(email.getToAddresses(), ','),
                    Subject__c = subject,
                    Object_Name__c = objectName,
                    Status__c = 'Failed',
                    Timestamp__c = System.now(),
                    Sent_By__c = UserInfo.getUserId(),
                    Body_Preview__c = email.getPlainTextBody()
                );
                insert log;

                System.debug('Error sending email: ' + e.getMessage());
            }

            if (results != null && results.size() > 0 && results[0].isSuccess()) {
                return 'Email sent successfully with PDF attached!';
            } else {
                return 'Failed to send email. Please check email settings.';
            }

        } catch (Exception e) {
            return 'Unexpected Error: ' + e.getMessage();
        }
    }


    @AuraEnabled
    public static String savePdfToUser(String objectName, List<String> fields, List<Map<String, Object>> records) {
        try {
            
            PageReference pdfPage = Page.PreviewVF;
            pdfPage.getParameters().put('objectName', objectName);
            pdfPage.getParameters().put('fields', String.join(fields, ','));
            pdfPage.getParameters().put('recordsJson', JSON.serialize(records));

            Blob pdfBlob;
            if (Test.isRunningTest()) {
                pdfBlob = Blob.valueOf('Test PDF Content'); // Mock PDF in test
            } else {
                pdfBlob = pdfPage.getContentAsPDF();
            }


            
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Preview_' + objectName + '_' + Datetime.now().format('yyyyMMdd_HHmmss');
            cv.PathOnClient = cv.Title + '.pdf';
            cv.VersionData = pdfBlob;
            cv.FirstPublishLocationId = UserInfo.getUserId();
            insert cv;

            Id contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
            List<ContentDocumentLink> existingLinks = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId = :contentDocId AND LinkedEntityId = :UserInfo.getUserId()];

            
            if (existingLinks.isEmpty()) {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = contentDocId;
                cdl.LinkedEntityId = UserInfo.getUserId();
                cdl.ShareType = 'I'; 
                cdl.LinkedEntityId = UserInfo.getUserId();
                insert cdl;
            }

            
            Email_Audit_Log__c log = new Email_Audit_Log__c(
                Email_Action__c = 'Saved_as_PDF',
                Object_Name__c = objectName,
                Status__c = 'Success',
                Timestamp__c = System.now(),
                Sent_By__c = UserInfo.getUserId(),
                Body_Preview__c = 'PDF successfully saved under your User Files.'
            );
            insert log;

            return 'PDF successfully saved under your User Files!';

        } catch (Exception e) {
            return 'Error saving PDF: ' + e.getMessage();
        }
    }
}