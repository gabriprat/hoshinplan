module CurrencyHelper 
  def get_unit(currency)
    $currencies[currency.downcase.to_sym][:symbol]
  end  
end
