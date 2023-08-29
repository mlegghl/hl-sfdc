import { wire, api } from 'lwc';
import getWorkboxDetails from '@salesforce/apex/HLWorkboxDetailsController.getWorkboxDetails';
import LightningModal from 'lightning/modal';

export default class HlCloseWorkbox extends LightningModal {
  @api workboxId;
  data = ''

  // @wire(getWorkboxDetails, { workboxId: "$workboxId" }) workboxDetails;

  @wire (getWorkboxDetails, { workboxId: "$workboxId" }) workboxDetails({data,error}){
    console.log('>>> getting details: ')
    if (data) {
      console.log(data); 
      this.data = JSON.stringify(data);
    } else if (error) {
      console.log(error);
    }
  }

  handleOkay() {
    const valueChangeEvent = new CustomEvent("closeworkbox", {});
    this.dispatchEvent(valueChangeEvent);
  }
} 