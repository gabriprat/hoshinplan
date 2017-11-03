$(document).ready ->
  form = $('.comment-form.subscribe')
  if form.length < 1
    return;
  channel = '/comment' + form.attr('action').replace(/\/[a-z]+_comments/,'')
  creatorId = form.find("input[name=creatorId]").attr('value')
  button = form.find("input[type=submit]")
  input = form.find("input[name=message]")
  defText = button.val()

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
      $('.comments-part ul.collection').append(body);
    button.val(defText)
    button.removeAttr('disabled')


  form.submit (event) ->
    #button.attr('disabled', 'disabled')
    button.val(button.val() + '...')

  # in case anyone wants to play with the inspector.
  window.client = client