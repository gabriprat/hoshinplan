module Hoshinplan
  class Timezone < DelegateClass(TZInfo::Timezone)

    def initialize(tz)
      @tz = tz
      super(@tz)
    end
    
    def to_s
      "#{@tz.friendly_identifier(true)} (GMT#{self.formatted_offset})"
    end
    
    def utc_offset
      if @utc_offset
        @utc_offset
      else
        @current_period ||= @tz.try(:current_period)
        @current_period.try(:utc_offset)
      end
    end
    

    UTC_OFFSET_WITH_COLON = '%s%02d:%02d'
    UTC_OFFSET_WITHOUT_COLON = UTC_OFFSET_WITH_COLON.sub(':', '')

    # Assumes self represents an offset from UTC in seconds (as returned from Time#utc_offset)
    # and turns this into an +HH:MM formatted string. Example:
    #
    #   TimeZone.seconds_to_utc_offset(-21_600) # => "-06:00"
    def self.seconds_to_utc_offset(seconds, colon = true)
      format = colon ? UTC_OFFSET_WITH_COLON : UTC_OFFSET_WITHOUT_COLON
      sign = (seconds < 0 ? '-' : '+')
      hours = seconds.abs / 3600
      minutes = (seconds.abs % 3600) / 60
      format % [sign, hours, minutes]
    end
    # Returns the offset of this time zone as a formatted string, of the
    # format "+HH:MM".
    def formatted_offset(colon=true, alternate_utc_string = nil)
      utc_offset == 0 && alternate_utc_string || self.class.seconds_to_utc_offset(utc_offset, colon)
    end
    
    # Compare this time zone to the parameter. The two are compared first on
    # their offsets, and then by name.
    def <=>(zone)
      result = (utc_offset <=> zone.utc_offset)
      result = (name <=> zone.name) if result == 0
      result
    end
    
    class << self      
      def get(name)
        begin
          Hoshinplan::Timezone.new(TZInfo::Timezone.get(name))
        rescue
        end
      end
      def all
          @zones ||= TZInfo::Timezone.all_country_zones.map{|cz| Hoshinplan::Timezone.new(cz)}.sort
      end
    end
  end
end