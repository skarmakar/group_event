class Api::V1::GroupEventsController < ApplicationController
  before_action :find_group_event, only: [:show, :update, :destroy]

  # TODO - handle pagination
  def index
    group_events = GroupEvent.non_deleted
    render json: group_events
  end

  def show
    render json: @group_event
  end

  def create
    group_event = GroupEvent.new(group_event_params.merge(user_id: current_user_id))
    
    if group_event.save
      render json: group_event, status: :created
    else
      respond_with_errors(group_event)
    end
  end

  def update
    if @group_event.update(group_event_params)
      render json: @group_event, status: :ok
    else
      respond_with_errors(@group_event)
    end
  end

  def destroy
    if @group_event.destroy
      head :no_content
    else
      head :bad_request
    end
  end

  protected

  # TODO - if user object is present, use association
  def find_group_event
    @group_event = GroupEvent.non_deleted.where(user_id: current_user_id).find(params[:id])
  end

  def group_event_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(
      params, 
      only: [:id, :name, :description, :start_date, :end_date, :duration, :location_name, :is_published]
    )
  end

  # dummy method to get user id
  # authentication can be handle here
  def current_user_id
    1
  end
end
