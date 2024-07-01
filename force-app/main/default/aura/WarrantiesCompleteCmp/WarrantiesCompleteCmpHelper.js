({
    startSpinner: function (cmp) {
        var spinner = cmp.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        console.log("SPINNER START");
    },
    stopSpinner: function (cmp) {
        var spinner = cmp.find("mySpinner");
        $A.util.addClass(spinner, 'slds-hide');
        console.log("SPINNER STOP");
    },
	setDataTable : function(component) {

        this.startSpinner(component);
		var action = component.get("c.getDataComplete");
		action.setParams({"recordId" : component.get('v.recordId')});
		action.setCallback(this, function(response1) {
            
            var state1 = response1.getState();
            if (state1 === "SUCCESS") {
                console.log('Success state');
                console.log('Data:' + JSON.stringify(response1.getReturnValue()));

                var resp = response1.getReturnValue();
                console.log('Data: ');
                console.log(resp);
				component.set('v.data', resp);
            }
            else if (state1 === "INCOMPLETE") {
                console.log('Incomplete state');
            }
            else if (state1 === "ERROR") {
                var errors = response1.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            this.stopSpinner(component);
        });  
        $A.enqueueAction(action);
	},

    back : function(component){

        var pathName = window.location.pathname;
        var pathCrm = pathName.includes("crm");
        if(pathCrm){
           window.history.back();     
        }else{

        var url = "https://" + window.location.hostname + "/" + component.get('v.recordId');

        console.log(url);

        window.open(url, "_parent", "resizable=no,top=200,left=500,width=500,height=200");
        }

    }
})