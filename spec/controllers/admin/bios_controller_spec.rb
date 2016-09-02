require 'rails_helper'

RSpec.describe Admin::BiosController, type: :controller do
  let (:user) { FactoryGirl.create(:user) }
  let (:author) { FactoryGirl.create(:author) }
  let (:pending_bio) { FactoryGirl.create(:pending_bio, author: user) }
  let (:approved_bio) { FactoryGirl.create(:approved_bio, author: user) }
  let (:author_bio) { FactoryGirl.create(:author_bio, author: author) }
  let (:attributes) do
    {
      text: 'This is some stuff about me',
      links_attributes: [
        { 'site' => 'facebook', 'url' => 'http://www.facebook.com/some_dude' },
        { 'site' => 'twitter',   'url' => 'http://www.twitter.com/some_dude' }
      ]
    }
  end

  context 'for an authenticated administrator' do
    let (:admin) { FactoryGirl.create(:administrator) }
    before(:each) { sign_in admin }

    describe 'get :index' do
      it 'is successful' do
        get :index
        expect(response).to have_http_status :success
      end
    end

    describe 'get :new' do
      it 'is successful' do
        get :new, author_id: author
        expect(response).to have_http_status :success
      end
    end

    describe 'post :create' do
      it 'redirects to the author index page' do
        post :create, author_id: author, bio: attributes
        expect(response).to redirect_to admin_authors_path
      end

      it 'creates a bio record' do
        expect do
          post :create, author_id: author, bio: attributes
        end.to change(Bio, :count).by(1)
      end
    end

    describe 'get :edit' do
      it 'is successful' do
        get :edit, id: author_bio
        expect(response).to have_http_status :success
      end
    end

    describe 'patch :update' do
      it 'redirects to the author index page' do
        patch :update, id: author_bio, bio: attributes
        expect(response).to redirect_to admin_authors_path
      end

      it 'updates the bio record' do
        expect do
          patch :update, id: author_bio, bio: attributes
          author_bio.reload
        end.to change(author_bio, :text).to('This is some stuff about me')
      end
    end

    context 'and an unapproved bio' do
      describe 'patch :approve' do
        it 'redirects to the bio index page' do
          patch :approve, id: pending_bio
          expect(response).to redirect_to bios_path
        end

        it 'updates the bio' do
          expect do
            patch :approve, id: pending_bio
            pending_bio.reload
          end.to change(pending_bio, :status).to 'approved'
        end

        it 'sends an email to the author' do
          patch :approve, id: pending_bio
          expect(pending_bio.author.email).to receive_an_email_with_subject("Bio approved!")
        end
      end
      describe 'patch :reject' do
        it 'redirects to the bio index page' do
          patch :reject, id: pending_bio
          expect(response).to redirect_to bios_path
        end

        it 'updates the bio' do
          expect do
            patch :reject, id: pending_bio
            pending_bio.reload
          end.to change(pending_bio, :status).from('pending').to('rejected')
        end

        it 'sends an email to the author' do
          patch :reject, id: pending_bio
          expect(pending_bio.author.email).to receive_an_email_with_subject("Bio rejected")
        end
      end
    end
  end

  context 'for an unauthenticated user' do
    describe 'get :index' do
      it 'redirects to the home page' do
        get :index
        expect(response).to redirect_to root_path
      end
    end

    describe 'get :new' do
      it 'redirects to the home page' do
        get :new, author_id: author
        expect(response).to redirect_to root_path
      end
    end

    describe 'post :create' do
      it 'redirects to the home page' do
        post :create, author_id: author, bio: attributes
        expect(response).to redirect_to root_path
      end

      it 'does not create a bio record' do
        expect do
          post :create, author_id: author, bio: attributes
        end.not_to change(Bio, :count)
      end
    end

    describe 'get :edit' do
      it 'redirects to the home page' do
        get :edit, id: author_bio
        expect(response).to redirect_to root_path
      end
    end

    describe 'patch :update' do
      it 'redirects to the home page' do
        patch :update, id: author_bio, bio: attributes
        expect(response).to redirect_to root_path
      end

      it 'does not update the bio record' do
        expect do
          patch :update, id: author_bio, bio: attributes
          author_bio.reload
        end.not_to change(author_bio, :text)
      end
    end

    context 'and an unapproved bio' do
      describe 'patch :approve' do
        it 'redirects the sign in page' do
          patch :approve, id: pending_bio
          expect(response).to redirect_to root_path
        end

        it 'does not update the bio' do
          expect do
            patch :approve, id: pending_bio
            pending_bio.reload
          end.not_to change(pending_bio, :status)
        end
      end

      describe 'patch :reject' do
        it 'redirects to the sign in page' do
          patch :reject, id: pending_bio
          expect(response).to redirect_to root_path
        end

        it 'does not update the bio' do
          expect do
            patch :reject, id: pending_bio
            pending_bio.reload
          end.not_to change(pending_bio, :status)
        end
      end
    end
  end
end
