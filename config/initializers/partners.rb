class PartnersDynamicRouter
  def self.load
    Hoshinplan::Application.routes.draw do
      begin
        Partner.all.each do |partner|
          Rails.logger.debug "Routing #{partner.slug}"
          get "/#{partner.slug}" => "users#signup", :slug => partner.slug
        end
      rescue ActiveRecord::StatementInvalid => e
      end
    end
  end

  def self.reload
    Hoshinplan::Application.routes_reloader.reload!
  end
end
