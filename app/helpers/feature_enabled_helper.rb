module FeatureEnabledHelper
  def feature_enabled(feature)
    ret = $flipper[feature].enabled? this.company if this && this.respond_to?(:company)
    ret ||= $flipper[feature].enabled? current_user
  end
end