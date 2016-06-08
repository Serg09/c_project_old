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

    if @bio.save
      flash[:notice] = "Your bio has been submitted successfully. It is now waiting for administrative approval."
      AdminMailer.bio_submission(@bio).deliver_now
    end
    respond_with @bio, location: user_signed_in? ? bios_path : author_bios_path(@author)
  end

  def index
    if user_signed_in?
      # Show the most recent non-rejected bio
      @bio = @author.working_bio
      if @bio
        render :show
      else
        redirect_to new_bio_path
      end
    elsif administrator_signed_in?
      redirect_to admin_bios_path
      return
    else
      @bio = @author.try(:active_bio)
      not_found! unless @bio
      render :show
    end
  end

  def browse
    @bios = Bio.joins(:author).order('users.last_name, users.first_name')
  end

  def show
    not_found! unless @bio.approved? || can?(:show, @bio)
    respond_with @bio do |format|
      format.html{ render :show, layout: administrator_signed_in? ? 'admin' : 'application' }
    end
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
    respond_with @bio, location: bio_path(@bio)
  end

  private

  def bio_params
    params.require(:bio).permit(:text, :photo_file, links_attributes: [:site, :url])
  end

  def load_author
    @author = case
              when @bio
                @bio.author
              when user_signed_in?
                current_user
              when params[:author_id]
                User.find(params[:author_id])
              else
                nil
              end
  end

  def load_bio
    @bio = Bio.find(params[:id])
  end
end
