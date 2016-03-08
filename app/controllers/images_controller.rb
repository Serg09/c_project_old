class ImagesController < ApplicationController
  before_filter :load_image

  def show
    if can? :show, @image
      send_data scaled_data, type: @image.mime_type,
                                          filename: filename(@image),
                                          disposition: 'inline'
    else
      render nothing: true, status: :not_found
    end
  end

  private 

  def filename(image)
    "binary.#{image.mime_type.split('/').last}"
  end

  def load_image
    @image = Image.find(params[:id])
  end

  def scaled_data
    return @image.image_binary.data unless params[:width] && params[:height]

    img = Magick::Image.from_blob(@image.image_binary.data).first
    img.resize_to_fit(params[:width], params[:height]).to_blob
  end
end
