import { api, LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import closeWorkbox from '@salesforce/apex/HLWorkboxDetailsController.closeWorkbox';

export default class ButtonWrapper extends LightningElement {
  // there is a bug in Winter 23 where custom events don't work in LightningModal components
  // creating a seperate component is a workaround (https://salesforce.stackexchange.com/questions/387924/lightning-modal-custom-event-not-working-in-winter-23-release/388903#388903)

  @api disabled = false;
  @api cfdata = null;

  handleOkay() {
    this.dispatchEvent(
      new CustomEvent("close", {
        bubbles: true,
        composed: true,
        detail: {}
      })
    );
  }

  handleSave() {
    this.disabled = true;
    const payload = {
      workboxId: this.cfdata.workboxId,
      workboxToken: this.cfdata.workboxToken,
      values: this.cfdata.customFields.map((cf) => ({
        id: cf.id,
        value: cf.value
      }))
    }
    closeWorkbox({ payload: payload })
      .then((resp) => {
        const evt = new ShowToastEvent({
          message: 'Help Thread Closed Successfully',
          variant: 'success',
        });
        this.dispatchEvent(evt);
        this.handleOkay();
      })
      .catch((err) => {
        this.disabled = false;
        console.log('>>> handleSave: err: ', err)
      })
  }
}