(function($) {
        var autoFocusInput = function() {
                $(".modal").off("shown.bs.modal.autofocus").on('shown.bs.modal.autofocus', function() {
                        $(this).find("[data-autofocus]:first").focus();
                        $(this).find("[autofocus]:first").focus();
                });
        }
        $(document).on("rapid:ajax:success", autoFocusInput);
        $(document).ready(autoFocusInput);
})(jQuery);
