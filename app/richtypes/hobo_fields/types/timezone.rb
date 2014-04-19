module HoboFields
  module Types
    class Timezone < String
  
      require 'hoshinplan/timezone'
  
    	COLUMN_TYPE = :string

    	HoboFields.register_type(:timezone, self)

    	def validate	
       begin 
    	   Hoshinplan::Timezone.get(self)
       rescue
         "Not a vadid timezone"
       end
    	end
    end
  end
end