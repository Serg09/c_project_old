class Admin::BiosController < ApplicationController
  before_filter :safe_authenticate_administrator!
  before_filter :load_bio, only: [:approve, :reject]
  layout 'admin'
  respond_to :html

  def index
    authorize! :index, Bio
    @bios = bios_by_status
    respond_with @bios
  end

  def approve
    authorize! :approve, @bio
    @bio.status = Bio.APPROVED
    if @bio.save
      redirect_to bios_path, notice: "The bio has been approved successfully."
    else
      render :show
    end
  end

  def reject
    authorize! :reject, @bio
    @bio.status = Bio.REJECTED
    if @bio.save
      redirect_to bios_path, notice: "The bio has been rejected successfully."
    else
      render :show
    end
  end

  private

  def bios_by_status
    Bio.where(status: params[:status] || :pending)
  end

  def load_bio
    @bio = Bio.find(params[:id])
  end
end
