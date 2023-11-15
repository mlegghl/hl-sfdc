import { wire, api } from 'lwc';
import getWorkboxDetails from '@salesforce/apex/HLWorkboxDetailsController.getWorkboxDetails';
import closeWorkbox from '@salesforce/apex/HLWorkboxDetailsController.closeWorkbox';
import LightningModal from 'lightning/modal';

export default class HlCloseWorkbox extends LightningModal {
  @api workboxId;
  data = null;
  loading = true;

  @wire (getWorkboxDetails, { workboxId: "$workboxId" }) workboxDetails({data,error}){
    console.log('>>> getting details: ')
    if (data && data.customFields) {
      this.loading = false;
      // this seems hacky, but LWC doesn't allow expressions in the template
      // to get around this, we can add a new property to the data object
      const resp = {
        ...data,
        customFields: data.customFields.map((cf) => ({
          ...cf,
          value: null,
          required: cf.mandatory === "MANDATORY_ON_CREATION" || cf.mandatory === "MANDATORY_ON_CLOSE",
          isText: cf.type === "TEXT",
          isBoolean: cf.type === "BOOLEAN",
          isList: cf.type === "LIST" && cf.multiSelect === false,
          isMultiList: cf.type === "LIST" && cf.multiSelect === true,
        }))
      };
      this.data = resp;
    } else if (error) {
      console.log(error);
    }
  }

  @api
  get isSaveDisabled() {
    return this.data?.customFields?.some((cf) => cf.required && !cf.value);
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
    const selectedOptions = [];
    event.detail.data.forEach((i) => {
      if (i.selected) {
        selectedOptions.push(i.value);
      }
    });
    let clone = [...this.data.customFields];
    clone[event.detail.index].value = selectedOptions;
    this.data = { ...this.data, customFields: clone };
  }

  async handleOkay() {
    console.log('>>> handleOkay: ', this.data)
    await this.dispatchEvent(new CustomEvent("close", {
      detail: { data: this.data }
    }));
  }
  
  handleSave() {
    this.loading = true;
    const payload = {
      ticketId: this.data.workboxId,
      expert: 0,
      values: this.data.customFields.map((cf) => ({
        id: cf.id,
        value: cf.value
      }))
    }
    closeWorkbox({ payload: payload })
      .then((resp) => {
        console.log('>>> handleSave: resp: ', resp)
        this.loading = false;
      })
      .catch((err) => {
        console.log('>>> handleSave: err: ', err)
        this.loading = false;
      })
    // const valueChangeEvent = new CustomEvent("closeworkbox", {});
    // this.dispatchEvent(valueChangeEvent);
  }

  handleClose() {
    console.log('>>> handleClose: ')
  }

} 