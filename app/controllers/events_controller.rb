class EventsController < ApplicationController
  def index
    @events = policy_scope(Event)

    # @markers = @events.geocoded.map do |event|
    #   {
    #     lat: event.latitude,
    #     lng: event.longitude
    #   }
    # end
  end

  def show
    set_event
    @booking = Booking.new
    authorize @event

    @markers = [
      {
        lat: @event.latitude,
        lng: @event.longitude,
        marker_html: render_to_string(partial: "marker")
      }]
  end

  def new
    @event = Event.new
    authorize @event
  end

  def create
    @event = Event.new(event_params)
    @event.user = current_user
    authorize @event
    if @event.save
      redirect_to event_path(@event)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    set_event
    authorize @event

    if @event.destroy
      redirect_to events_path, notice: "Event deleted successfully."
    else
      redirect_to event_path(@event), alert: "Failed to delete the event."
    end
  end

  def edit
    set_event
    authorize @event
  end

  def update
    set_event
    authorize @event

    if @event.update(event_params)
      redirect_to event_path(@event), notice: "Event updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_event
    @ev = Event.includes(images_attachments: :blob)
    @event = @ev.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :address, :description, :date, images: [])
  end
end
