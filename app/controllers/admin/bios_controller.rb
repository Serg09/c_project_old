class Admin::BiosController < ApplicationController
  before_action :authenticate_administrator!
  before_action :load_bio, only: [:show, :approve, :prereject, :reject, :edit, :update]
  before_action :load_author, only: [:new, :create]
  layout 'admin'
  respond_to :html

  def index
    authorize! :index, Bio
    @bios = bios_by_status.paginate(page: params[:page])
    respond_with @bios
  end

  def new
    @bio = @author.build_bio
  end

  def create
    @bio = @author.build_bio bio_params.merge(status: 'approved')
    flash[:notice] = 'The bio was created successfully.' if @bio.save
    respond_with @bio, location: admin_authors_path
  end

  def edit
  end

  def update
    @bio.update_attributes bio_params
    flash[:notice] = 'The bio was updated successfully.' if @bio.save
    respond_with @bio, location: admin_authors_path
  end

  def approve
    authorize! :approve, @bio
    if @bio.approve!
      BioMailer.approval(@bio).deliver_now unless @bio.author.unsubscribed?
      redirect_to admin_bios_path, notice: "The bio has been approved successfully."
    else
      render :show
    end
  end

  def prereject
  end

  def reject
    authorize! :reject, @bio
    @bio.update_attributes rejection_attributes
    if @bio.reject!
      BioMailer.rejection(@bio).deliver_now unless @bio.author.unsubscribed?
      redirect_to admin_bios_path, notice: "The bio has been rejected successfully."
    else
      render :show
    end
  end

  private

  def rejection_attributes
    params.require(:bio).permit(:comments)
  end

  def bio_params
    params.require(:bio).permit(:text, :photo_file, links_attributes: [:site, :url])
  end

  def bios_by_status
    Bio.where(status: params[:status] || :pending)
  end

  def load_author
    @author = Author.find(params[:author_id])
  end

  def load_bio
    @bio = Bio.find(params[:id])
  end
end
