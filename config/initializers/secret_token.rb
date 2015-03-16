# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
Hoshinplan::Application.config.secret_key_base = ENV['SECRET_KEY_BASE'] || '0d10cbcb9f29348d12da4e8245b4fcf10de86f2bdb723d0f0c19bb6311909b9e4a1d3f4100d77898b79dd1604a5ece2d7b0f0493aa177beb2592e564aa4e21be'

