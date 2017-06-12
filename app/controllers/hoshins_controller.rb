class HoshinsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :lifecycle, :except => [:index]
  
  auto_actions_for :company, [:new, :create]
  
  show_action :health, :kanban, :charts, :map
  
  web_method :kanban_update
  web_method :sort_by_deadline
  web_method :request_access

  include RestController
  
  cache_sweeper :hoshins_sweeper
  
  def_param_group :hoshin do
    param :name, String
    param :header, String, 'Can be used to write the mission/vision or some description of the Hoshin'
  end
  
  

  def create
    if params["new-company-name"]
      company = Company.new
      company.name = params["new-company-name"]
      company.save!
      params["hoshin"]["company_id"] = company.id
    end
    hobo_create
    log_event("Create hoshin", {objid: @this.id, name: @this.name})
  end
  
  api :DELETE, '/hoshins/:id', 'Delete a hoshin'
  param_group :hoshin
  def destroy
    hobo_destroy
    log_event("Delete hoshin", {objid: @this.id, name: @this.name})
  end
  
  api :POST, '/companies/:company_id/hoshins', 'Create a hoshin for the given company'
  param_group :hoshin
  def create_for_company
    hobo_create
    log_event("Create hoshin", {objid: @this.id, name: @this.name})
  end
  
  api :PUT, '/hoshins/:id', 'Update a hoshin'
  param_group :hoshin
  def update
    begin
      hobo_update
    rescue RuntimeError
      #ignore "No update specified in params" errors
    end
    log_event("Update hoshin", {objid: @this.id, name: @this.name})
  end
  
  api :GET, '/hoshins/:id', 'Get a hoshin'
  def show
    begin
      self.this = find_instance
    rescue ActiveRecord::RecordNotFound => e
      Hoshin.current_hoshin = Hoshin.unscoped.find(params[:id])
      if Hoshin.current_hoshin
        raise Hobo::PermissionDeniedError
      else
        raise e
      end
    end
    Hoshin.current_hoshin = self.this
    if request.xhr?
      hobo_ajax_response
    else
      if is_pdf
        Nr.set_transaction_name('HoshinsController#pdf')
      end
      hobo_show do |format|
            format.json { hobo_show }
            format.xml { hobo_show }
            format.html {
              current_user.all_companies
              if this.hoshins_count > 0
                ActiveRecord::Associations::Preloader.new.preload(self.this, 
                [{:areas => [:objectives, :indicators, :tasks, :child_tasks, :child_indicators]}, :goals])
              else
                ActiveRecord::Associations::Preloader.new.preload(self.this, 
                [{:areas => [:objectives, :indicators, :tasks]}, :goals])
              end
              Company.current_company = current_user.all_companies.find { |c| c.id == self.this.company_id }
              Company.current_company.comp_users
              self.this.all_tags_hashes
              hobo_show
            }
      end
    end
  end
  
  def health
    if request.xhr?
      hobo_ajax_response
    else
      hobo_show
    end
  end
  
  def charts
    @this = Hoshin.where(id: params[:id]).includes(:areas).first
    hobo_show
  end
  
  def kanban_update    
    task = Task.find(params[:item_id])
    state = params[:lane_id]
    position = params[:item_position].to_i + 1
    task.insert_at(position)
    task.lifecycle.send("to_" + state + "!", current_user)
    task.save!
    render :json => { result: :success }
  end
  
  def kanban
    @this = find_instance
    Hoshin.current_hoshin = @this
    @lanes = Task::Lifecycle.states.keys
    if request.xhr?
      hobo_ajax_response
    end
  end
  
  def map
    raise Hobo::PermissionDeniedError unless Feature.enabled? :map
    @this = find_instance
    @lanes = Task::Lifecycle.states.keys
    @objectives = Objective.joins(:area).where( 
        Task.unscoped.where(
          Task.arel_table[:objective_id].eq(Objective.arel_table[:id])
            .and(Task.arel_table[:hoshin_id].eq(@this.id))
        ).exists
      ).references(:area).order("areas.id, obj_pos")
    if request.xhr?
      hobo_ajax_response
    end
  end
  
  def do_clone
    do_transition_action :clone do
      if valid?
        redirect_to self.this.company
      end
    end
  end

  def sort_by_deadline
    @this = find_instance
    @this.sort_by_deadline(params[:lane]) if params[:lane]
    if request.xhr?
      hobo_ajax_response
    else
      redirect_to @this, action: :kanban
    end
  end

  def request_access
    @this = Hoshin.unscoped.find(params[:id])
    @done = true
    UserCompanyMailer.request_access(User.current_user, @this.creator, @this).deliver_later if @this
    hobo_ajax_response
  end

end
