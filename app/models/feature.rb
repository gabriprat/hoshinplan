class Feature

  def self.enabled?(feature)
    ret = $flipper[feature].enabled? Company.current_company if Company.current_company
    ret ||= $flipper[feature].enabled? User.current_user
  end

end