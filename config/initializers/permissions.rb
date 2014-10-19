ActiveRecord::Associations::HasManyAssociation.class_eval do

# Deletes the records according to the <tt>:dependent</tt> option.
       def delete_records(records, method)
         if method == :destroy
           records.each { |r| r.destroy }
           update_counter(-records.length) unless inverse_updates_counter_cache?
         else
           if records == :all
             scope = self.scope
           else
             scope = self.scope.where(reflection.klass.primary_key => records)
           end

           if method == :delete_all
             update_counter(-scope.delete_all)
           else
             update_counter(-scope.update_all(reflection.foreign_key => nil))
           end
         end
       end
end