class PagesController < ApplicationController
  def home
    set_events
    if user_signed_in?
      set_users_for_home
      set_photos_for_home
      @com_members = @users.where(community_id: current_user.community_id)
      @com_galleries = Gallery.where(user_id: @com_members)
      @com_photos = @photos.where(gallery_id: @com_galleries)
      @sorted_photos = @com_photos.sort_by { |ph| ph.likes.length }
      @exerpt = @sorted_photos.reverse.first(12)
    else
      @exerpt = Photo.all.first(12)
    end
  end

  def show
    @user = User.find(params[:id])
    @galleries = Gallery.all
    @my_galleries = Gallery.where(user_id: params[:id])
    @events = Event.all
    @my_events = Event.where(user_id: params[:id])
  end

  def profile
    if user_signed_in?
      @user = current_user
      @my_galleries = Gallery.where(user_id: current_user.id)
      @events = Event.all
      @my_events = Event.where(user_id: current_user.id)
      @gallery = Gallery.new
      @bookings = Booking.where(user_id: current_user)
    else
      redirect_to new_user_session_path
    end
  end

  def search
    set_users_for_search
    if params[:query].present?
      @results = PgSearch.multisearch(params[:query])
      photo_results if params[:photos].present?
      user_results if params[:users].present?

      if params[:users].blank? && params[:photos].blank?
        photo_results
        user_results
      end

      if params[:query].present? && @results.blank?
        @message = "Sorry, no results found. Have a look at our recommendations for you!"
        @photo_results = set_photos_for_search
        set_users_for_search
        @user_results = @users.where(community_id: current_user.community_id)
      end

    else
      @message = "New in your community:"
      set_photos_for_search
      @photo_results = @photos.last(20)
      set_users_for_search
      @user_results = @users.where(community_id: current_user.community_id).last(4)
    end
  end

  def community
    set_users_for_community
    set_events
    set_hotspots
    if user_signed_in?
      @community = Community.find(current_user.community_id)
      @com_members = @users.where(community_id: @community)
      @com_events = @events.where(user_id: @com_members)
      @com_hot_spots = @hotspots.where(user_id: @com_members)
      set_markers
      @hot_spot = HotSpot.new
      authorize @hot_spot
    else
      redirect_to new_user_session_path
    end
  end

  private

  def set_users_for_home
    @users = User.includes(:community, photo_attachment: :blob)
  end

  def set_users_for_search
    @users = User.includes(photo_attachment: :blob)
  end

  def set_users_for_community
    @users = User.includes(photo_attachment: :blob, banner_photo_attachment: :blob)
  end

  def set_photos_for_home
    @photos = Photo.includes(:likes, gallery: [user: [photo_attachment: :blob]], photo_attachment: :blob)
  end

  def set_photos_for_search
    @photos = Photo.includes(:likes, :comments, photo_attachment: :blob)
  end

  def set_events
    @events = Event.includes(:user, images_attachments: :blob)
  end

  def set_hotspots
    @hotspots = HotSpot.includes(user: [photo_attachment: :blob], photo_attachment: :blob)
  end

  def set_markers
    @markers = @com_hot_spots.geocoded.map do |hot_spot|
      {
        lat: hot_spot.latitude,
        lng: hot_spot.longitude,
        info_window_html: render_to_string(partial: "info_window", locals: {hot_spot: hot_spot}),
        marker_html: render_to_string(partial: "marker")
      }
    end
  end

  def photo_results
    @photo_results = @results.select do |result|
      result.searchable_type == "Photo"
    end
  end

  def user_results
    @user_results = @results.select do |result|
      result.searchable_type == "User"
    end
  end
end
