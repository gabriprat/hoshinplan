#Encapsulates the Mixpanel API as a Ruby (Rails) model.
#See http://www.bingocardcreator.com/articles/tracking-with-mixpanel.htm for usage notes.
#This code is copyright Patrick McKenzie, 2009.
#It is released under the MIT license (same as Rails).
#Short version: do whatever you want, just don't sue me.
#Long version: http://www.opensource.org/licenses/mit-license.php

class Mp
  require 'net/http'

  TOKEN = ENV['MIXPANEL_PROJECT']  #See your Mixpanel dashboard
  
  attr_accessor :options
  attr_accessor :people
  attr_accessor :event

  #This is the URL for the mixpanel API call.  It is frozen when track! is called on this object.
  #The reasons for this are subtle, and mostly related to delayed_job serialization.
  attr_accessor :saved_url

  def self.logger
    Rails.logger
  end

  def self.people_set(user, ip) 
    logged_event = Mp.new(user, {id: user.id, ip: ip})
    self.logger.debug "Mixpanel: #{logged_event.inspect}, #{logged_event.options}"
    logged_event.people_set!
  end
  
  def self.log_event(event, user, ip, opts = {})
    opts.merge!({:event => event, :id => user.id, :ip => ip})
    logged_event = Mp.new(user, opts)
    self.logger.debug "Mixpanel: #{logged_event.inspect}, #{logged_event.options}"
    logged_event.track!
  end

  def self.log_funnel(funnel_name, step_number, step_name, user, ip, opts = {})
    funnel_opts = opts.merge({:funnel => funnel_name, :step => step_number, :goal => step_name})
    self.log_event("mp_funnel", user, ip, funnel_opts)
  end

  def initialize(user, opts = {})
    @people = {
        '$distinct_id'=> user.id,
        '$name'       => user.name,
        '$email'      => user.email_address.to_s,
        '$created'    => user.created_at
    }
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
  end

  

  def track!()
    #If you have DelayedJob installed, this will use it, otherwise it fires the request *immediately*.
    #This is a very bad idea for most uses because it will result in *your* site blocking while waiting
    #for the Mixpanel API to return.  Be smart: install DelayedJob.
    if (respond_to? :send_later)
      delay.track_access_api
    else
      track_access_api
    end
  end
  
  def people_set!() 
    #If you have DelayedJob installed, this will use it, otherwise it fires the request *immediately*.
    #This is a very bad idea for most uses because it will result in *your* site blocking while waiting
    #for the Mixpanel API to return.  Be smart: install DelayedJob.
    if (respond_to? :send_later)
      delay.people_set_access_api
    else
      people_set_access_api
    end
  end

  def people_set_access_api
    return if ENV['MIXPANEL_DISABLE'] || !defined?(Mixpanel)
    tracker = Mixpanel::Tracker.new(TOKEN)
    Delayed::Worker.logger.debug "Mixpanel people_set: #{@options['distinct_id']}, #{@options}, #{@user}" 
    tracker.people.set(@options['distinct_id'], @people, @options[:ip])
  end

  def track_access_api
    return if ENV['MIXPANEL_DISABLE'] || !defined?(Mixpanel)
    tracker = Mixpanel::Tracker.new(TOKEN)
    Delayed::Worker.logger.debug "Mixpanel track: #{@options['distinct_id']}, #{@options}, #{@event}"
    tracker.track(@options['distinct_id'], @event, @options, @options[:ip])
  end
end

    