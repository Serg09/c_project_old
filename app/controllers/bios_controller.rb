class BiosController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create, :edit, :approve, :reject]
  before_filter :load_bio, only: [:edit, :update, :show, :approve, :reject]
  before_filter :load_author

  respond_to :html

  def new
    @bio = @author.bios.new
    authorize! :create, @bio
  end

  def create
    @bio = @author.bios.new(bio_params)
    authorize! :create, @bio
    flash[:notice] = "Your bio was saved successfully. It is now waiting for administrative approval." if @bio.save
    respond_with @bio, location: author_signed_in? ? bios_path : author_bios_path(@author)
  end

  def index
    if author_signed_in?
      # Show the most recent non-rejected bio
      @bio = @author.working_bio
      render :show
    elsif administrator_signed_in?
      @bios = @author.bios
      respond_with @bios
    else
      @bio = @author.active_bio
      render :show
    end
  end

  def show
    not_found! unless @bio.approved? || can?(:show, @bio)
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
    authorize! :approve, @bio
    @bio.status = Bio.APPROVED
    if @bio.save
      redirect_to author_bios_path(@author), notice: "The bio has been approved successfully."
    else
      render :show
    end
  end

  def reject
    authorize! :reject, @bio
    @bio.status = Bio.REJECTED
    if @bio.save
      redirect_to author_bios_path(@author), notice: "The bio has been rejected successfully."
    else
      render :show
    end
  end

  private

  def bio_params
    params.require(:bio).permit(:text, :links_attributes)
  end

  def load_author
    if @bio
      @author = @bio.author
    else
      @author = author_signed_in? ?  current_author : Author.find(params[:author_id])
    end
  end

  def load_bio
    @bio = Bio.find(params[:id])
  end
end
