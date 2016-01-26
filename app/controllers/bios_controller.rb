class BiosController < ApplicationController
  before_filter :load_author

  respond_to :html

  def new
  end

  def create
    @bio = @author.bios.new(bio_params)
    flash[:notice] = "Your bio was saved successfully. It is now waiting for administrative approval." if @bio.save
    respond_with @bio, location: author_signed_in? ? bios_path : author_bios_path(@author)
  end

  def show
  end

  def edit
  end

  private

  def bio_params
    params.require(:bio).permit(:text, :links_attributes)
  end

  def load_author
    @author = author_signed_in? ? current_author : Author.find(params[:author_id])
  end
end
