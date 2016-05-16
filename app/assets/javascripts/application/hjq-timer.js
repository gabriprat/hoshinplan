/* timer */
(function($) {
    var methods = {
        init: function(annotations) {
            var options = this.hjq('getOptions', annotations);
            this.on('update', options.update);
            methods.update.call(this, options.percent, options.href)
        },
        update: function(percent, href) {
            this.timer(percent, href);
            this.trigger("update");
            $.ajax({
                beforeSend: function(request) {
                    request.setRequestHeader("X-CSRF-Token", csrf);
                    request.setRequestHeader("Accept", '*/*');
                },
                dataType: "json",
                url: '/companies/complete_users2',
                data: {id: cid, term: term}
            }).done(function (resp) {
                users = resp;
                $.each(users,function(id,name) {
                    if(name.indexOf(term) > -1) { results.push({id:id, name:name}); }
                });
                callback(results);
            }).fail(function(resp) {
                callback([]);
            });
        }
    };

    $.fn.hjq_timer = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_timer' );
        }
    };

})( jQuery );
