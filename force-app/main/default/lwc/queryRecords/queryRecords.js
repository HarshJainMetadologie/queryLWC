import { LightningElement, track, wire } from 'lwc';
import getObjects from '@salesforce/apex/DynamicQueryController.getObjects';
import getFields from '@salesforce/apex/DynamicQueryController.getFields';
import getRecords from '@salesforce/apex/DynamicQueryController.getRecords';
import EmailPreviewModal from 'c/emailPreviewModal';
import hasComponentPermission from '@salesforce/apex/objectDataController.hasComponentPermission';

export default class QueryRecords extends LightningElement {
    @track objectOptions = [];
    @track fieldOptions = [];
    @track selectedObject = '';
    @track selectedFields = [];
    @track records = [];
    @track columns = [];
    @track noRecords = false;
    @track recordLimit = null;
    @track selectedRowIds = []; 
    @track selectedRows = [];  
    @track isAllFieldsSelected = false;
    @track isAllStandardSelected = false;
    @track isAllCustomSelected = false;
    @track isDisableAllFields = false;
    @track isDisableStandardFields = false;
    @track isDisableCustomFields = false;
    @track isDisablePermission = true;

    allStandardFields = [];
    allCustomFields = [];

    @wire(hasComponentPermission)
    hasPermission({ data, error }) {
        if (data) {
            this.isDisablePermission = !data;
            console.log('Component Permission:', data);
        } else if (error) {
            console.error('Error checking permission:', error);
        }
    }

    @wire(getObjects)
    wiredObjects({ data, error }) {
        if (data) {
            this.objectOptions = data.map(obj => ({ label: obj, value: obj }));
        } else if (error) {
            console.error('Error fetching objects:', error);
        }
    }

    @wire(getFields, { objectName: '$selectedObject' })
    wiredFields({ data, error }) {
        if (data) {
            this.allStandardFields = data.standardFields;
            this.allCustomFields = data.customFields;
            const allFields = [...this.allStandardFields, ...this.allCustomFields];
            this.fieldOptions = allFields.map(f => ({ label: f, value: f }));
            this.selectedFields = [];
        } else if (error) {
            console.error('Error fetching fields:', error);
        }
    }

    handleObjectChange(event) {
        this.selectedObject = event.detail.value;
        this.selectedFields = [];
        this.records = [];
        this.columns = [];
    }

    handleFieldChange(event) {
        this.selectedFields = event.detail.value;
    }

    handleAllFieldsChange(event) {
        this.isAllFieldsSelected = event.target.checked;
        if (this.isAllFieldsSelected) {
            this.selectedFields = [...this.allStandardFields, ...this.allCustomFields];
            this.isDisableStandardFields = true;
            this.isDisableCustomFields = true;
        } else {
            this.selectedFields = [];
            this.isDisableStandardFields = false;
            this.isDisableCustomFields = false;
        }
    }

    handleAllStandardFieldsChange(event) {
        this.isAllStandardSelected = event.target.checked;
        if (this.isAllStandardSelected) {
            this.selectedFields = [...this.allStandardFields];
            this.isDisableAllFields = true;
            this.isDisableCustomFields = true;
        } else {
            this.selectedFields = [];
            this.isDisableAllFields = false;
            this.isDisableCustomFields = false;
        }
    }

    handleAllCustomFieldsChange(event) {
        this.isAllCustomSelected = event.target.checked;
        if (this.isAllCustomSelected) {
            this.selectedFields = [...this.allCustomFields];
            this.isDisableAllFields = true;
            this.isDisableStandardFields = true;
        } else {
            this.selectedFields = [];
            this.isDisableAllFields = false;
            this.isDisableStandardFields = false;
        }
    }

    handleLimitChange(event) {
        const value = event.target.value;
        this.recordLimit = value ? parseInt(value, 10) : null;
    }

    
    handleFetch() {
        if (!this.selectedObject || this.selectedFields.length === 0) {
            this.records = [];
            this.noRecords = true;
            this.columns = [];
            return;
        }

        getRecords({
            objectName: this.selectedObject,
            fieldNames: this.selectedFields,
            limitSize: this.recordLimit
        })
            .then(result => {
                const { records, fields } = result;

                this.records = records || [];
                this.noRecords = this.records.length === 0;

                if (this.records.length > 0) {
                    this.columns = fields.map(field => ({
                        label: field,
                        fieldName: field
                    }));
                } else {
                    this.columns = [];
                }
            })
            .catch(error => {
                console.error('Error fetching records:', error);
                this.records = [];
                this.columns = [];
                this.noRecords = true;
            });
    }


    
    handleRowSelection(event) {
        this.selectedRowIds = event.detail.selectedRows.map(row => row.Id);
        this.selectedRows = event.detail.selectedRows;
    }

    
    async handleGeneratePreview() {
        if (!this.selectedObject || this.selectedFields.length === 0) {
            alert('Select an object and at least one field.');
            return;
        }

        if (this.selectedRowIds.length === 0) {
            alert('Please select at least one row to preview.');
            return;
        }

        try {
            const result = await getRecords({
                objectName: this.selectedObject,
                fieldNames: this.selectedFields,
                limitSize: null
            });

            const filteredRecords = result.filter(r => this.selectedRowIds.includes(r.Id));

            await EmailPreviewModal.open({
                size: 'large',
                objectName: this.selectedObject,
                selectedFields: Object.keys(filteredRecords[0]), 
                records: filteredRecords
            });
        } catch (error) {
            console.error('Error generating preview:', error);
        }
    }
}






// import { LightningElement, track, wire } from 'lwc';
// import getObjects from '@salesforce/apex/DynamicQueryController.getObjects';
// import getFields from '@salesforce/apex/DynamicQueryController.getFields';
// import getRecords from '@salesforce/apex/DynamicQueryController.getRecords';
// import EmailPreviewModal from 'c/emailPreviewModal';
// import hasComponentPermission from '@salesforce/apex/objectDataController.hasComponentPermission';

// export default class QueryRecords extends LightningElement {
//     @track objectOptions = [];
//     @track fieldOptions = [];
//     @track selectedObject = '';
//     @track selectedFields = [];
//     @track records = [];
//     @track columns = [];
//     @track noRecords = false;
//     @track recordLimit = null;
//     @track selectedRowIds = []; 
//     @track selectedRows = [];  
//     @track isAllFieldsSelected = false;
//     @track isAllStandardSelected = false;
//     @track isAllCustomSelected = false;
//     @track isDiableAllFields = false;
//     @track isDiableStandardFields = false;
//     @track isDiableCustomFields = false;
//     @track isDiablePermission = true;

//     allStandardFields = [];
//     allCustomFields = [];

//     @wire(hasComponentPermission)
//     hasPermission({ data, error }) {
//         if (data) {
//             this.isDiablePermission = !data;
//             console.log('hasPermission', data);
//         }
//         else if (error) {
//             console.error('Error checking permission:', error);
//         }
//     }    

//     @wire(getObjects)
//     wiredObjects({ data, error }) {
//         if (data) {
//             this.objectOptions = data.map(obj => ({ label: obj, value: obj }));
//         }
//     }

//     @wire(getFields, { objectName: '$selectedObject' })
//     wiredFields({ data, error }) {
//         if (data) {
//             this.allStandardFields = data.standardFields;
//             this.allCustomFields = data.customFields;
//             const allFields = [...this.allStandardFields, ...this.allCustomFields];
//             this.fieldOptions = allFields.map(f => ({ label: f, value: f }));
//             this.selectedFields = [];
//         }
//     }

//     handleObjectChange(event) {
//         this.selectedObject = event.detail.value;
//         this.selectedFields = [];
//         this.records = [];
//     }

//     handleFieldChange(event) {
//         this.selectedFields = event.detail.value;
//     }

//     handleAllFieldsChange(event) {
//         this.isAllFieldsSelected = event.target.checked;
//         if (this.isAllFieldsSelected) {
//             this.selectedFields = [...this.allStandardFields, ...this.allCustomFields];
//             this.isDiableStandardFields = true;
//             this.isDiableCustomFields = true;
//         } else {
//             this.selectedFields = [];
//             this.isDiableStandardFields = false;
//             this.isDiableCustomFields = false;
//         }
//     }

//     handleAllStandardFieldsChange(event) {
//         this.isAllStandardSelected = event.target.checked;
//         if (this.isAllStandardSelected) {
//             this.selectedFields = [...this.allStandardFields];
//             this.isDiableAllFields = true;
//             this.isDiableCustomFields = true;
//         } else {
//             this.selectedFields = [];
//             this.isDiableAllFields = false;
//             this.isDiableCustomFields = false;
//         }
//     }

//     handleAllCustomFieldsChange(event) {
//         this.isAllCustomSelected = event.target.checked;
//         if (this.isAllCustomSelected) {
//             this.selectedFields = [...this.allCustomFields];
//             this.isDiableAllFields = true;
//             this.isDiableStandardFields = true;
//         } else {
//             this.selectedFields = [];
//             this.isDiableAllFields = false;
//             this.isDiableStandardFields = false;
//         }
//     }

//     handleLimitChange(event) {
//         const value = event.target.value;
//         this.recordLimit = value ? parseInt(value, 10) : null;
//     }

//     handleFetch() {
//         if (!this.selectedObject || this.selectedFields.length === 0) {
//             this.records = [];
//             this.noRecords = true;
//             return;
//         }

//         getRecords({
//             objectName: this.selectedObject,
//             fieldNames: this.selectedFields,
//             limitSize: this.recordLimit
//         }).then(result => {
//             this.records = result;
//             this.noRecords = result.length === 0;
//             this.columns = this.selectedFields.map(f => ({ label: f, fieldName: f }));
//         });
//     }

//     handleRowSelection(event) {
//         this.selectedRowIds = event.detail.selectedRows.map(row => row.Id);
//         this.selectedRows = event.detail.selectedRows;
//     }

//     async handleGeneratePreview() {
//     if (!this.selectedObject || this.selectedFields.length === 0) {
//         alert('Select object and at least one field.');
//         return;
//     }

//     if (this.selectedRowIds.length === 0) {
//         alert('Please select at least one row to preview.');
//         return;
//     }


//     // Fetch full record details using selected Ids and fields
//     const selectedRecordIds = this.selectedRowIds;
//     const result = await getRecords({
//         objectName: this.selectedObject,
//         fieldNames: this.selectedFields,
//         limitSize: null // not needed here
//     });

//     const filteredRecords = result.filter(r => selectedRecordIds.includes(r.Id));

//     await EmailPreviewModal.open({
//         size: 'large',
//         objectName: this.selectedObject,
//         selectedFields: this.selectedFields,
//         records: filteredRecords
//     });
// }

// }