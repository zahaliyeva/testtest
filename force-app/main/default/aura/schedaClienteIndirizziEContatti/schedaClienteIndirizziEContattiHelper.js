({
    manageAddress : function(component) {
          /*
            {
            "city": "AGRIGENTO",
            "country": "Italy",
            "countryCode": "IT",
            "geocodeAccuracy": null,
            "latitude": null,
            "longitude": null,
            "postalCode": "92100",
            "state": "Agrigento",
            "stateCode": "AG",
            "street": "VIA ROMA, 1"
            }
            */   
        try {
            let isPF = component.get('v.wrapper.isPerson');
            let address = "";
            if(isPF){
                address = component.get('v.wrapper.account.PersonMailingAddress'); 
            } else {
                address = component.get('v.wrapper.account.BillingAddress'); 
            }
            //let fullAddr =  address.street + ", " + address.postalCode + ", " + address.city + " (" + address.stateCode + ")";
            
            let fullAddr = typeof address.street !== 'undefined' ? "<div class='txt-caps'>" + address.street + "</div>" : "";
            fullAddr += typeof address.city !== 'undefined' ? "<div class='txt-caps'>" + address.city + "</div>" : "";
            fullAddr += typeof address.state !== 'undefined' ? "<div>" + address.state + "</div>" : "";
            fullAddr += typeof address.postalCode !== 'undefined' ? "<div>" + address.postalCode + "</div>" : "";
            fullAddr += typeof address.country !== 'undefined' ? "<div>" + address.country + "</div>" : "";

		    component.set("v.fullAddress", fullAddr);
        
        } catch (e) {
            // Error handling
            console.error(e);
        }
    }
})