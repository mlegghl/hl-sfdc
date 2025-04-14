import { api, LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import updateWorkbox from '@salesforce/apex/HLWorkboxDetailsController.updateWorkbox';

export default class ButtonWrapper extends LightningElement {
  // there is a bug in Winter 23 where custom events don't work in LightningModal components
  // creating a seperate component is a workaround (https://salesforce.stackexchange.com/questions/387924/lightning-modal-custom-event-not-working-in-winter-23-release/388903#388903)

  @api disabled = false;
  @api cfdata = null;

  handleCloseDialog() {
    this.dispatchEvent(
      new CustomEvent("close", {
        bubbles: true,
        composed: true,
        detail: {}
      })
    );
  }

  handleUpdate() {
    const payload = {
      workboxId: this.cfdata.workboxId,
      workboxToken: this.cfdata.workboxToken,
      values: this.cfdata.customFields.map((cf) => ({
        id: cf.id,
        value: cf.value
      })),
      close: false
    }
    updateWorkbox({ payload: payload })
      .then((resp) => {
        const evt = new ShowToastEvent({
          message: 'Help Thread Updated Successfully',
          variant: 'success',
        });
        this.dispatchEvent(evt);
        this.handleCloseDialog();
      })
      .catch((err) => {
        console.log('>>> updateWorkbox error: ', err);
        // Since LWC modals don't allow closing out of the modal, we need to close the dialog manually
        // I don't think we should be dependant on the update to be successful - we don't want to leave the user in a state where they can't close the dialog
        this.handleCloseDialog();
      })
  }

  handleSaveAndClose() {
    this.disabled = true;
    const payload = {
      workboxId: this.cfdata.workboxId,
      workboxToken: this.cfdata.workboxToken,
      values: this.cfdata.customFields.map((cf) => ({
        id: cf.id,
        value: cf.value
      })),
      close: true
    }
    updateWorkbox({ payload: payload })
      .then((resp) => {
        const evt = new ShowToastEvent({
          message: 'Help Thread Closed Successfully',
          variant: 'success',
        });
        this.dispatchEvent(evt);
        this.handleCloseDialog();
      })
      .catch((err) => {
        this.disabled = false;
        console.log('>>> handleSaveAndClose: err: ', err)
      })
  }
}