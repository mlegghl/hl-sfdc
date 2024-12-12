import { LightningElement, api } from 'lwc';
import hllogo from '@salesforce/resourceUrl/hllogo';

export default class HlLogo extends LightningElement {
    @api title;
    hllogoUrl = hllogo;
}
