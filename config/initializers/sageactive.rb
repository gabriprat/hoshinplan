Rails.configuration.sageactive = {
    client_id: ENV['SAGEACTIVE_CLIENT_ID'],
    client_secret: ENV['SAGEACTIVE_SECRET'],
    subscription_key: ENV['SAGEACTIVE_SUBSCRIPTION_KEY'],
    callback_url: ENV['SAGEACTIVE_CALLBACK_URL'],
    auth_endpoint: 'https://sbcauth.sage.fr/connect/authorize',
    token_endpoint: 'https://sbcauth.sage.fr/connect/token',
    base_endpoint: 'https://api.es.active.sage.com',
    tenant_id: ENV['SAGEACTIVE_TENANT_ID'],
    organization_id: ENV['SAGEACTIVE_ORGANIZATION_ID']
}