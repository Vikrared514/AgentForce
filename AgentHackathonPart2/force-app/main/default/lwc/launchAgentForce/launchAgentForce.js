import { LightningElement, track } from 'lwc';
import agentForceApi from '@salesforce/apex/AgentForceController.agentForceApi';

export default class LaunchAgentForce extends LightningElement {
    @track inputVal;
    @track isLoading = false;
    response;
    resMessage;
    textAreaStyle = 'height: auto;';

    handleChange(event) {
        this.inputVal = event.target.value;
    }
    

    handleSent() {
        console.log('this.inputVal == ' + this.inputVal);
        this.isLoading = true;

        agentForceApi({ messageText: this.inputVal })
            .then(result => {
              const parsedResult = JSON.parse(result);  // Parse the JSON string if necessary
                console.log('Parsed Result:', parsedResult);

                // Extract message from the first object in the "messages" array
                if (parsedResult.messages && parsedResult.messages.length > 0) {
                    this.resMessage = parsedResult.messages[0].message;
                } else {
                    this.resMessage = 'No message received.';
                }
                console.log('this.resMessage=='+this.resMessage);
            })
            .catch(error => {
                console.error('Error:', JSON.stringify(error));
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
}