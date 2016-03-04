class Admin::InquiriesController < ApplicationController
  include ApplicationHelper

  before_filter :load_inquiry, only: [:show, :archive]

  respond_to :html

  layout 'admin'

  def archive
    authorize! :update, @inquiry
    @inquiry.archived = true
    flash[:notice] = 'The inquiry has been archived successfully.' if @inquiry.save
    respond_with @inquiry, location: admin_inquiries_path
  end

  def index
    authorize! :index, Inquiry
    @inquiries = requested_inquiries.paginate(page: params[:page])
    respond_with @inquiries
  end

  def show
    authorize! :show, @inquiry
    respond_with @inquiry
  end

  private

  def load_inquiry
    @inquiry = Inquiry.find(params[:id])
  end

  def requested_archived?
    html_true?(params[:archived])
  end

  def requested_inquiries
    requested_archived? ? Inquiry.archived : Inquiry.active
  end
end
