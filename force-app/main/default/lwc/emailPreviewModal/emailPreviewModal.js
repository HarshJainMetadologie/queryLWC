import { LightningElement, api } from 'lwc';
import LightningModal from 'lightning/modal';
import sendEmailWithPdf from '@salesforce/apex/EmailServiceController.sendEmailWithPdf';
import savePdfToUser from '@salesforce/apex/EmailServiceController.savePdfToUser';

export default class EmailPreviewModal extends LightningModal {
    @api objectName;
    @api selectedFields;
    @api recordLimit;
    @api records;

    toAddresses = '';
    ccAddresses = '';
    emailBody = '';
    vfPageUrl = '';

    connectedCallback() {
        const fieldsParam = encodeURIComponent(this.selectedFields.join(','));
        const recordsJson = encodeURIComponent(JSON.stringify(this.records));
        this.vfPageUrl = `/apex/PreviewVF?objectName=${this.objectName}&fields=${fieldsParam}&recordsJson=${recordsJson}`;
    }


    handleToChange(event) {
        this.toAddresses = event.target.value;
    }

    handleCcChange(event) {
        this.ccAddresses = event.target.value;
    }

    handleBodyChange(event) {
        this.emailBody = event.target.value;
    }

    sendEmail() {
        sendEmailWithPdf({
            toAddresses: this.toAddresses,
            ccAddresses: this.ccAddresses,
            subject: 'Record Preview - ' + this.objectName,
            body: this.emailBody,
            objectName: this.objectName,
            fields: this.selectedFields,
            records: this.records,
        })
        .then(result => {
            alert(result); 
        })
        .catch(error => {
            alert('Error sending email: ' + error.body.message);
        });
    }

    handleSavePdfClick = async () => {
        try {
            const result = await savePdfToUser({
                objectName: this.objectName,
                fields: this.selectedFields,
                records: this.records
            });
            alert(result);
        } catch (error) {
            console.error('Error saving PDF:', error);
            alert('Error saving PDF. Check console for details.');
        }
    }

}
