import { api, LightningElement } from 'lwc';

export default class MultiListItem extends LightningElement {
  /**
   * Single selectable item received from the multi select combobox parent component.
   * @type {Object}
   */
  @api item;

  get itemClass() {
    return `slds-listbox__item ${this.item.selected ? 'slds-is-selected' : ''}`;
  }

  handleClick() {
    this.dispatchEvent(
      new CustomEvent('change', {
        detail: { item: this.item, selected: !this.item.selected }
      })
    );
  }
}