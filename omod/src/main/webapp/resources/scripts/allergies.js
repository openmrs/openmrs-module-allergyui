var removeAllergyDialog = null;

$(document).ready( function() {
    
    removeAllergyDialog = emr.setupConfirmationDialog({
        selector: '#allergyui-remove-allergy-dialog',
        actions: {
            cancel: function() {
            	removeAllergyDialog.close();
            }
        }
    });

});

function showRemoveAllergyDialog() {
    removeAllergyDialog.show();
}

function removeAllergy(allergy, id) {
    jq("#allergyId").val(id);
    jq("#removeAllergyMessage").text(jq("#removeAllergyMessageTemplate").val().replace("{0}", allergy));
    showRemoveAllergyDialog(allergy, id);
}
