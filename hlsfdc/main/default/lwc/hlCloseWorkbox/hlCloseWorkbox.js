import { wire, api } from 'lwc';
import getWorkboxDetails from '@salesforce/apex/HLWorkboxDetailsController.getWorkboxDetails';
import LightningModal from 'lightning/modal';

export default class HlCloseWorkbox extends LightningModal {
  @api workboxId;
  data = null;

  @wire (getWorkboxDetails, { workboxId: "$workboxId" }) workboxDetails({data,error}){
    console.log('>>> getting details: ')
    if (data && data.customFields) {
      // this seems hacky, but LWC doesn't allow expressions in the template
      // to get around this, we can add a new property to the data object
      console.log('data: ', data)
      const resp = {
        ...data,
        customFields: data.customFields.map((cf) => ({
          ...cf,
          value: null,
          isText: cf.type === "TEXT",
          isBoolean: cf.type === "BOOLEAN",
          isList: cf.type === "LIST" && cf.multiSelect === false,
          isMultiList: cf.type === "LIST" && cf.multiSelect === true,
        }))
      };
      console.log('data res: ', JSON.parse(JSON.stringify(resp)))
      this.data = resp;
    } else if (error) {
      console.log(error);
    }
  }

  handleInputChange(event) {
    let clone = [...this.data.customFields];
    clone[event.target.dataset.index].value = event.detail.value;
    this.data = { ...this.data, customFields: clone };
  }

  handleCheckChange(event) {
    let clone = [...this.data.customFields];
    clone[event.target.dataset.index].value = event.target.checked;
    this.data = { ...this.data, customFields: clone };
  }

  handleSelectChange(event) {
    let clone = [...this.data.customFields];
    clone[event.target.dataset.index].value = parseInt(event.detail.value);
    this.data = { ...this.data, customFields: clone };
  }

  handleMultiSelectChange(event) {
    console.log('>>> handleMultiSelectChange: ', event)
    // let clone = [...this.data.customFields];
    // clone[event.target.dataset.index].value = parseInt(event.detail.value);
    // this.data = { ...this.data, customFields: clone };
  }

  handleOkay() {
    console.log('>>> handleOkay: ', this.data)
    const valueChangeEvent = new CustomEvent("closeworkbox", {});
    this.dispatchEvent(valueChangeEvent);
  }
  
  handleSave() {
    console.log('>>> handleSave: ', this.data)
    const payload = {
      parentId: this.data.workboxId,
      type: "TICKET",
      values: this.data.customFields.map((cf) => ({
        id: cf.id,
        value: cf.value
      }))
    }
    console.log('>>> handleSave: payload: ', payload)
    // const valueChangeEvent = new CustomEvent("closeworkbox", {});
    // this.dispatchEvent(valueChangeEvent);
  }

  handleClose() {
    console.log('>>> handleClose: ')
  }

} 