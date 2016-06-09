require 'rails_helper'

RSpec.describe Admin::BiosController, type: :controller do
  let (:author) { FactoryGirl.create(:user) }
  let (:pending_bio) { FactoryGirl.create(:pending_bio, author: author) }
  let (:approved_bio) { FactoryGirl.create(:approved_bio, author: author) }
  let (:attributes) do
    {
      text: 'This is some stuff about me',
      links_attributes: [
        { 'site' => 'facebook', 'url' => 'http://www.facebook.com/some_dude' },
        { 'site' => 'twitter',   'url' => 'http://www.twitter.com/some_dude' }
      ]
    }
  end

  context 'for an authenticated user' do
    describe 'get :index' do
      it 'redirects to the user home page' do
        sign_in author
        get :index
        expect(response).to redirect_to root_path
      end
    end

    context 'that owns the bio' do
      before(:each) { sign_in author }

      context 'that is approved' do
        describe 'patch :approve' do
          it 'redirects to the user home page' do
            patch :approve, id: approved_bio
            expect(response).to redirect_to root_path
          end

          it 'does not update the bio' do
            expect do
              patch :approve, id: approved_bio
              approved_bio.reload
            end.not_to change(approved_bio, :status)
          end
        end
        describe 'patch :reject' do
          it 'redirects to the user home page' do
            patch :reject, id: approved_bio
            expect(response).to redirect_to root_path
          end

          it 'does not update the bio' do
            expect do
              patch :reject, id: approved_bio
              approved_bio.reload
            end.not_to change(approved_bio, :status)
          end
        end
      end

      context 'that is pending approval' do
        describe 'patch :approve' do
          it 'redirects to the show bio page' do
            patch :approve, id: pending_bio
            expect(response).to redirect_to root_path
          end

          it 'does not update the bio' do
            expect do
              patch :approve, id: pending_bio
              approved_bio.reload
            end.not_to change(approved_bio, :status)
          end
        end

        describe 'patch :reject' do
          it 'redirects to the show bio page' do
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

    context 'that does not own the bio' do
      let (:other_user) { FactoryGirl.create(:user) }
      before(:each) { sign_in other_user }

      context 'that is approved' do
        describe 'patch :approve' do
          it 'redirects to the show bio page' do
            patch :approve, id: approved_bio
            expect(response).to redirect_to root_path
          end

          it 'does not update the bio' do
            expect do
              patch :approve, id: approved_bio
              approved_bio.reload
            end.not_to change(approved_bio, :status)
          end
        end

        describe 'patch :reject' do
          it 'redirects to the user home page' do
            patch :reject, id: approved_bio
            expect(response).to redirect_to root_path
          end

          it 'does not update the bio' do
            expect do
              patch :reject, id: approved_bio
              approved_bio.reload
            end.not_to change(approved_bio, :status)
          end
        end
      end
    end
  end

  context 'for an authenticated administrator' do
    let (:admin) { FactoryGirl.create(:administrator) }
    before(:each) { sign_in admin }

    describe 'get :index' do
      it 'is successful' do
        get :index, author_id: author
        expect(response).to have_http_status :success
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
          end.to change(pending_bio, :status).to Bio.REJECTED
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
        get :index, author_id: author
        expect(response).to redirect_to root_path
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
