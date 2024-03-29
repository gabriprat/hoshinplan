module RestController

  def self.included(klass)
    klass.class_eval do
      web_method :recover

      def recover(*args, &b)
        options = args.extract_options!
        ActiveRecord::Base.transaction do
          self.this = find_instance_with_deleted
          if self.this.respond_to? :objective_id
            objective = Objective.with_deleted.find_by_id(self.this.objective_id)
            if objective&.deleted?
              objective.restore
              area = Area.with_deleted.find_by_id(objective.area_id)
              this.area_id = objective.area_id
              this.save
              if area&.deleted?
                area.restore
                flash_notice ht(:"area.messages.recover.also", :default => ["The belonging area was also recovered"])
              end
              flash_notice ht(:"objective.messages.recover.also", :default => ["The belonging objective was also recovered"])
            end
          elsif self.this.respond_to? :area_id
            area = Area.with_deleted.find_by_id(self.this.area_id)
            if area&.deleted?
              area.restore
              flash_notice ht(:"area.messages.recover.also", :default => ["The belonging area was also recovered"])
            end
          end
          self.this.restore
        end
        flash_notice ht(:"#{model.to_s.underscore}.messages.recover.success", :default => ["The #{model.name.titleize.downcase} was recovered"])
        response_block(&b) || destroy_response(options, &b)
      end

      def permission_denied(error)
        self.this = true # Otherwise this gets sent user_view
        logger.info "Hobo: Permission Denied! (#{error.inspect})"
        @permission_error = error

        respond_to do |wants|
          wants.html do
            if render :permission_denied, :status => 403
              # job done
            else
              render :text => t("hobo.messages.permission_denied", :default => ["Permission Denied"]), :status => 403
            end
          end
          wants.js do
            render :text => t("hobo.messages.permission_denied", :default => ["Permission Denied"]), :status => 403
          end
          wants.json do
            render :json => {status: 403, message: t("hobo.messages.permission_denied", :default => ["Permission Denied"])}, :status => 403
          end
        end
      end
    end
  end

  def find_instance_with_deleted(options = {})
    model.user_find_with_deleted(current_user, params[:id]) do |record|
      yield record if block_given?
    end
  end

  def hobo_show
    if request.xhr?
      super
    else
      super do |format|
        format.js {super}
        format.json {render :json => find_instance.to_json}
        format.xml {render :xml => find_instance.to_xml}
        format.html {super}
        format.pdf {render :layout => false}
      end
    end
  end

  def index_response
    respond_to do |format|
      format.js {super}
      format.json {render :json => self.this.to_json}
      format.xml {render :xml => self.this.to_xml}
      format.html {super}
      format.pdf {render :layout => false}
    end
  end

  def update_response(valid=nil, options={})
    respond_to do |format|
      format.js {super}
      format.json {render :json => self.this.to_json}
      format.xml {render :xml => self.this.to_xml}
      format.html {super}
      format.pdf {render :layout => false}
    end
  end

  def create_response(valid=nil, options={})
    respond_to do |format|
      format.js {super}
      format.json {render :json => self.this.to_json}
      format.xml {render :xml => self.this.to_xml}
      format.html {super}
      format.pdf {render :layout => false}
    end
  end

  def hobo_index(*args, &b)
    super do |format|
      format.js {super}
      format.json {
        options = args.extract_options!
        finder = args.first || model
        self.this ||= find_or_paginate(finder, options)
        render :json => self.this.to_json
      }
      format.xml {
        options = args.extract_options!
        finder = args.first || model
        self.this ||= find_or_paginate(finder, options)
        render :xml => self.this.to_xml
      }
      format.html {
        super
      }
    end
  end
end