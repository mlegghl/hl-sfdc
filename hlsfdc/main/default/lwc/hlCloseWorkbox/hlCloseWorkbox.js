import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class HlCloseWorkbox extends LightningModal {
  _workboxInfo;
  
  @api
  get workboxInfo() {
    return this._workboxInfo;
  }
  set workboxInfo(value) {
    if (value && value.customFields) {
      // this seems hacky, but LWC doesn't allow expressions in the template
      // to get around this, we can add a new property to the data object
      const resp = {
        ...value,
        customFields: value.customFields?.reverse().map((cf) => ({
          ...cf,
          value: null,
          required: cf.mandatory === "MANDATORY_ON_CREATION" || cf.mandatory === "MANDATORY_ON_CLOSE",
          isText: cf.type === "TEXT",
          isBoolean: cf.type === "BOOLEAN",
          isList: cf.type === "LIST" && cf.multiSelect === false,
          isMultiList: cf.type === "LIST" && cf.multiSelect === true,
        }))
      };
      this._workboxInfo = resp;
    }
  }

  @api
  get isSaveDisabled() {
    return this.workboxInfo?.customFields?.some((cf) => cf.required && !cf.value);
  }

  handleInputChange(event) {
    let clone = [...this.workboxInfo.customFields];
    clone[event.target.dataset.index].value = event.detail.value;
    this._workboxInfo = { ...this._workboxInfo, customFields: clone };
  }

  handleCheckChange(event) {
    let clone = [...this.workboxInfo.customFields];
    clone[event.target.dataset.index].value = event.target.checked;
    this._workboxInfo = { ...this.workboxInfo, customFields: clone };
  }

  handleSelectChange(event) {
    let clone = [...this.workboxInfo.customFields];
    clone[event.target.dataset.index].value = parseInt(event.detail.value);
    this._workboxInfo = { ...this.workboxInfo, customFields: clone };
  }

  handleMultiSelectChange(event) {
    const selectedOptions = [];
    event.detail.data.forEach((i) => {
      if (i.selected) {
        selectedOptions.push(i.value);
      }
    });
    let clone = [...this.workboxInfo.customFields];
    clone[event.detail.index].value = selectedOptions;
    this._workboxInfo = { ...this.workboxInfo, customFields: clone };
  }
} 