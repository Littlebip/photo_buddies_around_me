class PhotosController < ApplicationController

  def show
    pho = Photo.includes(likes: [user: [photo_attachment: :blob]])
    @photo = pho.find(params[:id])
    authorize @photo
    @gallery = Gallery.find(params[:gallery_id])
    @likes = @photo.likes
    @gallery_user = User.find(@gallery.user_id)
    @gallery_photos = Photo.where(gallery_id: @gallery.id)
    @photo_ids_array = []
    @gallery_photos.each do |ph|
      @photo_ids_array << ph.id
    end
    @current_photo_index = @photo_ids_array.index(@photo.id)
    @next_photo_index = @current_photo_index + 1
    @next_photo_id = @photo_ids_array.at(@next_photo_index)
    @previous_photo_index = @current_photo_index - 1
    @previous_photo_id = @photo_ids_array.at(@previous_photo_index)

    if user_signed_in?
      @like_status = Like.where(user_id: current_user.id, photo_id: @photo.id).any?
    else
      @like_status = true
    end
    @like = Like.new
    @comment = Comment.new
  end

  def create
    @photo = Photo.new(photo_params)
    @gallery = Gallery.find(params[:gallery_id])
    @photo.gallery_id = @gallery.id
    authorize @photo
    if @photo.save
      redirect_to gallery_path(@gallery), notice: "Photo successfully added to #{@gallery.name} gallery!"
    else
      redirect_to gallery_path(@gallery), notice: :unprocessable_entity
    end
  end

  def destroy
    @gallery = Gallery.find(params[:gallery_id])
    @photo = Photo.find(params[:id])
    authorize @photo
    @photo.destroy
    redirect_to profile_path
  end

  private

  def photo_params
    params.require(:photo).permit(:address, :keyword, :photo)
  end
end
