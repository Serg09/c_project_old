class ImagesController < ApplicationController
  before_filter :load_image

  def show
    if can? :show, @image
      send_data @image.image_binary.data, type: @image.mime_type,
                                          filename: 'author_photo.jpg', # TODO get the right extension
                                          disposition: 'inline'
    else
      render nothing: true, status: :not_found
    end
  end

  private 

  def load_image
    @image = Image.find(params[:id])
  end
end
