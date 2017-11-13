#Encapsulates the Mixpanel API as a Ruby (Rails) model.
#See http://www.bingocardcreator.com/articles/tracking-with-mixpanel.htm for usage notes.
#This code is copyright Patrick McKenzie, 2009.
#It is released under the MIT license (same as Rails).
#Short version: do whatever you want, just don't sue me.
#Long version: http://www.opensource.org/licenses/mit-license.php

class Mp
  require 'net/http'

  TOKEN = ENV['MIXPANEL_PROJECT']  #See your Mixpanel dashboard

  @queue = 'mixpanel'
  
  attr_accessor :options
  attr_accessor :people
  attr_accessor :event

  #This is the URL for the mixpanel API call.  It is frozen when track! is called on this object.
  #The reasons for this are subtle, and mostly related to delayed_job serialization.
  attr_accessor :saved_url

  def self.logger
    defined?(Resque) ? Resque.logger : Rails.logger
  end
  
  def self.perform(people, options, event, optional_params, method)
    self.logger.debug "Mixpanel perform: #{people.inspect}, #{options.inspect}, #{event.inspect}, #{method.inspect}"
    mp = Mp.new
    mp.options = options
    mp.people = people
    mp.event = event
    mp.optional_params = optional_params
    mp.send method
  end

  def self.people_set(user, ip, ignore_time=false, event=nil) 
    return if user.guest?
    opts = {id: user.id, ip: ip}
    optional_params = {}
    if ignore_time
      optional_params["$ignore_time"] = true
    end
    logged_event = Mp.new(user, opts, optional_params)
    logged_event.event = event
    Rails.logger.debug "Mixpanel people_set: #{logged_event.inspect}, #{logged_event.options}"
    logged_event.people_set!
  end

  def self.people_delete(user_id)
    opts = {distinct_id: user_id}
    logged_event = Mp.new(nil, opts, nil)
    Rails.logger.debug "Mixpanel people_delete: #{logged_event.inspect}, #{logged_event.options}"
    logged_event.people_delete!
  end

  def self.log_event(event, user, ip, opts = {})
    opts.merge!({:event => event, :id => user.guest? ? 'Guest' : user.id, :ip => ip})
    logged_event = Mp.new(user, opts)
    Rails.logger.debug "Mixpanel: #{logged_event.inspect}, #{logged_event.options}"
    logged_event.track!
  end

  def self.log_funnel(funnel_name, step_number, step_name, user, ip, opts = {})
    funnel_opts = opts.merge({:funnel => funnel_name, :step => step_number, :goal => step_name})
    self.log_event("mp_funnel", user, ip, funnel_opts)
  end

  def self.track_charge(user, ip, amount, opts = {})
    opts.merge!({:event => 'Payment', :id => user.id, :ip => ip, :amount => amount})
    logged_event = Mp.new(user, opts, nil)
    Rails.logger.debug "Mixpanel track_charge: #{logged_event.inspect}, #{logged_event.options}"
    logged_event.track_charge!
  end

  def options=(options)
    @options = options
  end

  def optional_params=(optional_params)
    @optional_params = optional_params
  end
  
  def people=(people)
    @people = people
  end
  
  def event=(event)
    @event = event
  end

  def initialize(user=nil, opts = {}, optional_params = {})
    if user.is_a? User
      @people = {
          '$distinct_id'  => user.id,
          '$name'         => user.name,
          '$email'        => user.email_address.to_s,
          '$created'      => user.created_at,
          'language'      => user.language,
          'subscriptions' => user.subscriptions_count,
          'timezone'      => user.timezone,
          'tutorial_step' => user.tutorial_step,
          'last_seen_at'  => user.last_seen_at,
          'from_invitation' => user.from_invitation,
          'trial_ends_at' => user.trial_ends_at,
          'owned_companies' => Company.unscoped.where('creator_id = ? and deleted_at is null', user.id).count,
          'companies'     => UserCompany.unscoped.where('user_id': user.id).count
      }
    end
    @options = {}
    @options['ip'] = opts[:ip] unless opts[:ip].nil?
    @options['time'] = Time.now.to_i
    @options['token'] = ENV['MIXPANEL_PROJECT']
    @options['distinct_id'] = opts[:id] unless opts[:id].blank?
    @event = opts[:event] unless opts[:event].nil?
    opts.each do |key, value|
      unless [:ip, :id, :event, :step].include? key
        @options[key.to_s] = value.to_s
      end
      if [:step].include? key
        @options[key.to_s] = value.to_i
      end
    end
    @optional_params = optional_params
  end

  

  def track!()
    return if Rails.configuration.mixpanel_disable || !defined?(Mixpanel)
    #If you have Resque installed, this will use it, otherwise it fires the request *immediately*.
    #This is a very bad idea for most uses because it will result in *your* site blocking while waiting
    #for the Mixpanel API to return.  Be smart: install Resque.
    if defined?(Resque)
      Resque.enqueue(Mp, @people, @options, @event, @optional_params, :track_access_api)
    else
      track_access_api
    end
  end
  
  def people_set!()
    return if Rails.configuration.mixpanel_disable || !defined?(Mixpanel)
    #If you have Resque installed, this will use it, otherwise it fires the request *immediately*.
    #This is a very bad idea for most uses because it will result in *your* site blocking while waiting
    #for the Mixpanel API to return.  Be smart: install Resque.
    if defined?(Resque)
      Resque.enqueue(Mp, @people, @options, @event, @optional_params, :people_set_access_api)
    else
      people_set_access_api
    end
  end

  def track_charge!()
    return if Rails.configuration.mixpanel_disable || !defined?(Mixpanel)
    #If you have Resque installed, this will use it, otherwise it fires the request *immediately*.
    #This is a very bad idea for most uses because it will result in *your* site blocking while waiting
    #for the Mixpanel API to return.  Be smart: install Resque.
    if defined?(Resque)
      Resque.enqueue(Mp, @people, @options, @event, @optional_params, :track_charge_access_api)
    else
      track_charge_access_api
    end
  end

  def people_delete!()
    return if Rails.configuration.mixpanel_disable || !defined?(Mixpanel)
    #If you have Resque installed, this will use it, otherwise it fires the request *immediately*.
    #This is a very bad idea for most uses because it will result in *your* site blocking while waiting
    #for the Mixpanel API to return.  Be smart: install Resque.
    if defined?(Resque)
      Resque.enqueue(Mp, @people, @options, @event, @optional_params, :people_delete_access_api)
    else
      people_delete_access_api
    end
  end

  def people_set_access_api
    return if Rails.configuration.mixpanel_disable || !defined?(Mixpanel)
    tracker = ::Mixpanel::Tracker.new(TOKEN)
    Mp.logger.debug "Mixpanel people_set: #{@options['distinct_id']}, #{@options.inspect}, #{@people.inspect}, #{@optional_params.inspect}"
    tracker.people.set(@options['distinct_id'], @people, @options[:ip], @optional_params || {})
    if @event.present?
      track_access_api
    end
  end

  def people_delete_access_api
    return if Rails.configuration.mixpanel_disable || !defined?(Mixpanel)
    tracker = ::Mixpanel::Tracker.new(TOKEN)
    Mp.logger.debug "Mixpanel people_delete: #{@options['distinct_id']}, #{@options.inspect}"
    tracker.people.delete_user(@options['distinct_id'], @optional_params || {})
    if @event.present?
      track_access_api
    end
  end

  def track_charge_access_api
    return if Rails.configuration.mixpanel_disable || !defined?(Mixpanel)
    amount = @options['amount'] || 0
    tracker = ::Mixpanel::Tracker.new(TOKEN)
    Mp.logger.debug "Mixpanel track_charge: #{@options['distinct_id']}, #{@options.inspect}"
    tracker.people.track_charge(@options['distinct_id'], amount, @options, @options[:ip], @optional_params || {})
    if @event.present?
      track_access_api
    end
  end

  def track_access_api
    return if Rails.configuration.mixpanel_disable || !defined?(Mixpanel)
    tracker = ::Mixpanel::Tracker.new(TOKEN)
    Mp.logger.debug "Mixpanel track: distinct_id=#{@options['distinct_id']}, options=#{@options.inspect}, event=#{@event.inspect}"
    fail "Null event" unless @event.present?
    tracker.track(@options['distinct_id'], @event, @options, @options[:ip])
  end
end

