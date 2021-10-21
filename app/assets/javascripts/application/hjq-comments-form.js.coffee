methods =
  init: (annotations) ->
    that = $(this)
    hasContent = () ->
      val = that.find('.comment-form textarea').val()
      val && val != ''
    window.onbeforeunload = () ->
      if (hasContent())
        return 'Your unsaved data will be lost.';
    form = that.find('.comment-form')
    if form.length < 1
      return;
    parentForm = that.closest("form")
    if parentForm.size() > 0
      parentForm.submit(() ->
        if hasContent()
          form.hjq_formlet('submit')
      )
    channel = '/comment' + form.data('rapid').formlet.form_attrs.action.replace(/\/[a-z]+_comments/, '')
    button = form.find("input[type=submit]")
    input = form.find("input[name=message]")
    defText = button.val()

    if !parentForm.hasClass('subscribe')
      return;

    client = new Faye.Client('/ws')
    client.addExtension {
      outgoing: (message, callback) ->
        message.ext = message.ext || {}
        message.ext.csrfToken = $('meta[name=csrf-token]').attr('content')
        callback(message)
    }

    clientId = null
    client.addExtension {
      incoming: (message, callback) ->
        if (message.channel == '/meta/subscribe' && message.subscription == channel && message.successful)
          clientId = message.clientId
        if (message.channel == channel && clientId == message.clientId)
          callback(null)
        else
          callback(message)
    }

    client.addExtension(new FayeAuthentication(client));

    client.subscribe channel, (payload)->
      time = moment(payload.created_at).format('D/M/YYYY H:mm:ss')
      if document.getElementById('comment-' + payload.typed_id) == null
        body = '<li class="item" data-rapid-context="' + payload.typed_id + '"><div class="comment" id="comment-' + payload.typed_id + '"><a class="user-link" href="' + payload.creator_link + '" rel="nofollow"><span class="view user-name ">' + payload.creator_name + '</span></a><span class="ago">' + payload.created_at_ago + '</span><div class="view objective-comment-body ">' + payload.body + '</div></div></li>'
        that.find('ul.collection').append(body);
      button.val(defText)
      button.removeAttr('disabled')

$.fn.hjq_comments_form = (method) ->
  if methods[method]
    return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ))
  else if typeof method == 'object' || ! method
    return methods.init.apply( this, arguments )
  else
    $.error( 'Method ' +  method + ' does not exist on hjq_comments_form' )
