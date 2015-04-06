require 'json'

DATA_PATH = File.expand_path("../../../config", __FILE__)
json = File.read("#{DATA_PATH}/currency_iso.json")
json.force_encoding(::Encoding::UTF_8) if defined?(::Encoding)
$currencies = JSON.parse(json, :symbolize_names => true)
