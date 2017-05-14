//GLOBAL JQuery Functaionality
$(function(){

    /*** CONFIRM MODAL OVERRIDE ***/
    //override the use of js alert on confirms
    //requires bootstrap3-dialog from https://github.com/nakupanda/bootstrap3-dialog
    $.rails.allowAction = function(link){
        if( !link.is('[data-confirm]') )
            return true;
        var dt = $("[data-rapid-page-data]").data('rapid-page-data');
        BootstrapDialog.show({
            type: BootstrapDialog.TYPE_DANGER,
            title: dt.confirmmsg,
            message: link.attr('data-confirm'),
            buttons: [{
                label: dt.cancelmsg,
                action: function(dialogRef){
                    dialogRef.close();
                }
            }, {
                label: dt.acceptmsg,
                cssClass: 'btn-primary',
                hotkey: 13,
                action: function(dialogRef){
                    link.removeAttr('data-confirm');
                    if (link.prop("tagName").toUpperCase() === 'FORM') {
                        link.trigger('submit.rails');
                    } else {
                        link.trigger('click.rails');
                    }
                    dialogRef.close();
                }
            }]
        });
        return false; // always stops the action since code runs asynchronously
    };
});
