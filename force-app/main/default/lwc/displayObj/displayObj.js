import { LightningElement, wire } from 'lwc';
import getAllObjects from '@salesforce/apex/dynamicQuery.getAllObjects';

export default class DisplayObj extends LightningElement {
    @wire(getAllObjects)
    allObjects;
}
