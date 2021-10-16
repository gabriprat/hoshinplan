class ApipieController < ApplicationController

  hobo_controller

  before_action :get_doc

  def index
    if !@doc
      render 'apipie/apipies/apipie_404', :status => 404
    elsif @resource && @method
      @content = render_to_string 'apipie/apipies/method'
    elsif @resource
      @content = render_to_string 'apipie/apipies/resource'
    elsif params[:resource].present? || params[:method].present?
      @content = render_to_string 'apipie/apipies/apipie_404'
    else
      @content = render_to_string 'apipie/apipies/index'
    end
  end

  def static
    render params[:key]
  end

  private

  def get_doc
    @key = params[:key].to_s
    params[:version] ||= Apipie.configuration.default_version
    @language = get_language
    Apipie.load_documentation if Apipie.configuration.reload_controllers? || (Rails.version.to_i >= 4.0 && !Rails.application.config.eager_load)
    I18n.locale = @language
    @doc = Apipie.to_json(params[:version], nil, nil, @language)
    @doc = @doc[:docs] if @doc
    @resource = @doc[:resources][params[:resource]] if @doc && params[:resource].present?
    @method = Apipie.to_json(params[:version], params[:resource], params[:method], @language) if @doc && params[:method].present?
    @method = @method[:docs][:resources].first[:methods].first if @method
    @languages = Apipie.configuration.languages
    @sidebar = render_to_string :partial => 'apipie/sidebar'
  end

  def get_language
    return nil unless Apipie.configuration.translate
    lang = Apipie.configuration.default_locale
    [:resource, :method, :version].each do |par|
      if params[par]
        splitted = params[par].split('.')
        if splitted.length > 1 && Apipie.configuration.languages.include?(splitted.last)
          lang = splitted.last
          params[par].sub!(".#{lang}", '')
        end
      end
    end
    lang
  end
end
