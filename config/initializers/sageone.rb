Rails.configuration.sageone = {
    client_id: ENV['SAGEONE_CLIENT_ID'],
    client_secret: ENV['SAGEONE_SECRET'],
    signing_secret: ENV['SAGEONE_SIGNING_SECRET'],
    apim_subscription_key: ENV['SAGEONE_APIM_SUBSCRIPTION_KEY'],
    callback_url: ENV['SAGEONE_CALLBACK_URL'],
    auth_endpoint: 'https://sbcauth.sage.fr/connect/authorize',
    token_endpoint: 'https://sbcauth.sage.fr/connect/token',
    base_endpoint: 'https://api.es.active.sage.com',
}
