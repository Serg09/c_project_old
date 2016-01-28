class BiosController < ApplicationController
  before_filter :load_author
  before_filter :load_bio, only: [:edit, :update, :show, :approve, :reject]

  respond_to :html

  def new
    @bio = @author.bios.new
    authorize! :create, @bio
  end

  def create
    @bio = @author.bios.new(bio_params)
    flash[:notice] = "Your bio was saved successfully. It is now waiting for administrative approval." if @bio.save
    respond_with @bio, location: author_signed_in? ? bios_path : author_bios_path(@author)
  end

  def show
  end

  def edit
    authorize! :update, @bio
  end

  def update
    authorize! :update, @bio
    if @bio.approved?
      @bio = @author.bios.new(bio_params)
    else
      @bio.update_attributes bio_params
    end
    flash[:notice] = "Your bio has been updated successfully and is waiting for administrative approval." if @bio.save
    respond_with @bio, location: bio_path
  end

  def approve
    redirect_to author_root_path
  end

  def reject
    redirect_to author_root_path
  end

  private

  def bio_params
    params.require(:bio).permit(:text, :links_attributes)
  end

  def load_author
    @author = author_signed_in? ? current_author : Author.find(params[:author_id])
  end

  def load_bio
    @bio = Bio.find(params[:id])
  end
end
