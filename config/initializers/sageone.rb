Rails.configuration.sageone = {
    client_id: ENV['SAGEONE_CLIENT_ID'],
    client_secret: ENV['SAGEONE_SECRET'],
    signing_secret: ENV['SAGEONE_SIGNING_SECRET'],
    apim_subscription_key: ENV['SAGEONE_APIM_SUBSCRIPTION_KEY'],
    callback_url: ENV['SAGEONE_CALLBACK_URL'],
    auth_endpoint: 'https://www.sageone.com/oauth2/auth',
    token_endpoint: 'https://oauth.eu.sageone.com/token',
    base_endpoint: 'https://api.columbus.sage.com/es/sageone',
}
