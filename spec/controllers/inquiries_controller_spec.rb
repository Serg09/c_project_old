require 'rails_helper'

describe InquiriesController do
  include Devise::TestHelpers
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  let (:attributes) do
    {
      first_name: 'John',
      last_name: 'Doe',
      email: 'john@doe.com',
      body: 'Does anyone know what time it is?'
    }
  end

  let (:inquiry) { FactoryGirl.create(:inquiry) }

  context 'for an unauthenticated user' do
    describe 'get :new' do
      it 'is successful' do
        get :new
        expect(response).to be_success
      end
    end

    describe 'post :create' do
      it 'creates a new inquiry' do
        expect do
          post :create, inquiry: attributes
        end.to change(Inquiry, :count).by(1)
      end

      it 'redirects to the books page' do
        post :create, inquiry: attributes
        expect(response).to redirect_to pages_books_path
      end

      it 'sends a notification email' do
        mail = spy('mail')
        expect(InquiryMailer).to receive(:submission_notification).and_return(mail)
        post :create, inquiry: attributes
        expect(mail).to have_received(:deliver_now)
      end
    end

    describe 'get :index' do
      it 'redirects to the root page' do
        get :index
        expect(response).to redirect_to root_path
      end
    end

    describe 'get :show' do
      it 'redirects to the root page' do
        get :show, id: inquiry
        expect(response).to redirect_to root_path
      end
    end

    describe 'patch :archive' do
      it 'redirects to the root page' do
        patch :archive, id: inquiry
        expect(response).to redirect_to root_path
      end

      it 'does not update the inquiry' do
        expect do
          patch :archive, id: inquiry
          inquiry.reload
        end.not_to change(inquiry, :archived)
      end
    end
  end

  context 'for an author' do
    let (:author) { FactoryGirl.create(:author) }
    before(:each) { sign_in author }

    describe 'get :new' do
      it 'is successful' do
        get :new
        expect(response).to be_success
      end
    end

    describe 'post :create' do
      it 'creates a new inquiry' do
        expect do
          post :create, inquiry: attributes
        end.to change(Inquiry, :count).by(1)
      end

      it 'redirects to the books page' do
        post :create, inquiry: attributes
        expect(response).to redirect_to pages_books_path
      end

      it 'sends a notification email' do
        mail = spy('mail')
        expect(InquiryMailer).to receive(:submission_notification).and_return(mail)
        post :create, inquiry: attributes
        expect(mail).to have_received(:deliver_now)
      end
    end

    describe 'get :index' do
      it 'redirects to the author root page' do
        get :index
        expect(response).to redirect_to author_root_path
      end
    end

    describe 'get :show' do
      it 'redirects to the author root page' do
        get :show, id: inquiry
        expect(response).to redirect_to author_root_path
      end
    end

    describe 'patch :archive' do
      it 'redirects to the author root page' do
        patch :archive, id: inquiry
        expect(response).to redirect_to author_root_path
      end

      it 'does not update the inquiry' do
        expect do
          patch :archive, id: inquiry
          inquiry.reload
        end.not_to change(inquiry, :archived)
      end
    end
  end

  context 'for an administrator' do
    let (:admin) { FactoryGirl.create(:administrator) }
    before(:each) { sign_in admin }

    describe 'get :index' do
      it 'is successful' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    describe 'get :show' do
      it 'is successful' do
        get :show, id: inquiry
        expect(response).to have_http_status(:success)
      end
    end

    describe 'patch :archive' do
      it 'redirects to the inquiry index page' do
        patch :archive, id: inquiry
        expect(response).to redirect_to inquiries_path
      end

      it 'updates the inquiry' do
        expect do
          patch :archive, id: inquiry
          inquiry.reload
        end.to change(inquiry, :archived).from(false).to(true)
      end
    end
  end
end


