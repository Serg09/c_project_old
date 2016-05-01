require 'rails_helper'

RSpec.describe CampaignsController, type: :controller do
  let (:author) { FactoryGirl.create(:approved_user) }
  let (:book) { FactoryGirl.create(:approved_book, author: author) }
  let (:campaign) { FactoryGirl.create(:campaign, book: book) }
  let (:attributes) do
    {
      target_date: '4/30/2016',
      target_amount: 5_000
    }
  end

  before(:each) { Timecop.freeze(Chronic.parse('2016-03-02 12:00:00 CST')) }
  after(:each) { Timecop.return }

  context 'for an authenticated user' do
    context 'that owns the book' do
      before(:each) { sign_in author  }

      describe "get :index" do
        it "returns http success" do
          get :index, book_id: book
          expect(response).to have_http_status(:success)
        end
      end

      describe "get :new" do
        it "returns http success" do
          get :new, book_id: book
          expect(response).to have_http_status(:success)
        end
      end

      describe "post :create" do
        it "redirects to the index page" do
          post :create, book_id: book, campaign: attributes
          expect(response).to redirect_to book_campaigns_path(book)
        end

        it 'creates a new campain record' do
          expect do
            post :create, book_id: book, campaign: attributes
          end.to change(book.campaigns, :count).by(1)
        end
      end

      describe "get :show" do
        it "returns http success" do
          get :show, id: campaign
          expect(response).to have_http_status(:success)
        end
      end

      describe "get :edit" do
        it "returns http success" do
          get :edit, id: campaign
          expect(response).to have_http_status(:success)
        end
      end

      describe "patch :update" do
        it "redirects to the index page" do
          patch :update, id: campaign, campaign: attributes
          expect(response).to redirect_to book_campaigns_path(book)
        end

        it 'updates the campaign' do
          expect do
            patch :update, id: campaign, campaign: attributes
            campaign.reload
          end.to change(campaign, :target_amount).to 5_000
        end
      end

      context 'for an unstarted campaign' do
        let (:campaign) { FactoryGirl.create(:unstarted_campaign, book: book) }

        context 'with a valid start date' do
          describe 'patch :start' do
            it 'redirects to the campaign progress page' do
              patch :start, id: campaign
              expect(response).to redirect_to campaign_path(campaign)
            end

            it 'changes the state to active' do
              expect do
                patch :start, id: campaign
                campaign.reload
              end.to change(campaign, :state).from('unstarted').to('active')
            end
          end
        end

        describe 'patch :prolong' do
          it 'does not change the target date' do
            expect do
              patch :prolong, id: campaign
              campaign.reload
            end.not_to change(campaign, :target_date)
          end

          it 'does not change the prolonged flag' do
            expect do
              patch :prolong, id: campaign
              campaign.reload
            end.not_to change(campaign, :prolonged)
          end
        end

        context 'with an invalid start date' do
          let (:campaign) do
            Timecop.freeze(Chronic.parse('2016-01-15')) do
              FactoryGirl.create(:unstarted_campaign, book: book,
                                                      target_date: '2016-03-01')
            end
          end
          before(:each) { Timecop.freeze(Chronic.parse('2016-03-02')) }
          after(:each) { Timecop.return }

          it 'redirects to the index page' do
            patch :start, id: campaign
            expect(response).to redirect_to book_campaigns_path(book)
          end

          it 'does change the state' do
            expect do
              patch :start, id: campaign
              campaign.reload
            end.not_to change(campaign, :state)
          end

          it 'indicates the reason it was not started' do
            patch :start, id: campaign
            expect(flash[:alert]).to match /target date must be at least 30 days in the future/
          end
        end
      end

      context 'for an active campaign' do
        let!(:campaign) { FactoryGirl.create(:active_campaign, book: book, target_date: Date.new(2016, 4, 30)) }

        describe 'patch :collect' do
          it 'redirects to the campaign progress page' do
            patch :collect, id: campaign
            expect(response).to redirect_to campaign_path(campaign)
          end

          it 'changes the state to "collecting"' do
            expect do
              patch :collect, id: campaign
              campaign.reload
            end.to change(campaign, :state).from('active').to('collecting')
          end
        end

        describe 'patch :cancel' do
          it 'redirects to the campaign progress page' do
            patch :cancel, id: campaign
            expect(response).to redirect_to campaign_path(campaign)
          end

          it 'changes the campaign state to "cancelling"' do
            expect do
              patch :cancel, id: campaign
              campaign.reload
            end.to change(campaign, :state).from('active').to('cancelling')
          end
        end

        context 'that has not been prolonged' do
          describe 'patch :prolong' do
            it 'redirects to the campaign show page' do
              patch :prolong, id: campaign
              expect(response).to redirect_to campaign_path(campaign)
            end

            it 'changes the target date to 15 days later than before' do
              expect do
                patch :prolong, id: campaign
                campaign.reload
              end.to change(campaign, :target_date).to(Date.new(2016, 5, 15))
            end

            it 'sets the "prolonged" flag' do
              expect do
                patch :prolong, id: campaign
                campaign.reload
              end.to change(campaign, :prolonged).from(false).to(true)
            end
          end
        end

        context 'that has been prolonged' do
          let (:campaign) { FactoryGirl.create(:active_campaign, book: book, prolonged: true) }

          describe 'patch :prolong' do
            it 'redirects to the campaign show page' do
              patch :prolong, id: campaign
              expect(response).to redirect_to campaign_path(campaign)
            end

            it 'does not change the target date' do
              expect do
                patch :prolong, id: campaign
                campaign.reload
              end.not_to change(campaign, :target_date)
            end

            it 'does not change the "prolonged" flag' do
              expect do
                patch :prolong, id: campaign
                campaign.reload
              end.not_to change(campaign, :prolonged)
            end
          end
        end
      end

      describe "delete :destroy" do
        it "redirects to the index page" do
          delete :destroy, id: campaign
          expect(response).to redirect_to book_campaigns_path(book)
        end

        it 'removes the campaign record' do
          campaign #reload the campaign
          expect do
            delete :destroy, id: campaign
          end.to change(Campaign, :count).by(-1)
        end
      end
    end

    context 'that does not own the book' do
      let (:other_user) { FactoryGirl.create(:approved_user) }
      before(:each) { sign_in other_user  }

      describe "get :index" do
        it "redirects to the user root page" do
          get :index, book_id: book
          expect(response).to redirect_to user_root_path
        end
      end

      describe "get :new" do
        it "redirects to the user root page" do
          get :new, book_id: book
          expect(response).to redirect_to user_root_path
        end
      end

      describe "post :create" do
        it "redirects to the user root page" do
          post :create, book_id: book, campaign: attributes
          expect(response).to redirect_to user_root_path
        end

        it 'does not create a new campain record' do
          expect do
            begin
              post :create, book_id: book, campaign: attributes
            rescue ActiveRecord::RecordNotFound
            end
          end.not_to change(Campaign, :count)
        end
      end

      describe "get :show" do
        it "redirects to the user root page" do
          get :show, id: campaign
          expect(response).to redirect_to user_root_path
        end
      end

      describe "get :edit" do
        it "redirects to the user root page" do
            get :edit, id: campaign
          expect(response).to redirect_to user_root_path
        end
      end

      describe "patch :update" do
        it "redirects to the user root page" do
          patch :update, id: campaign, campaign: attributes
          expect(response).to redirect_to user_root_path
        end

        it 'does not update the campaign' do
          expect do
            begin
              patch :update, id: campaign, campaign: attributes
              campaign.reload
            rescue ActiveRecord::RecordNotFound
            end
          end.not_to change(campaign, :target_amount)
        end
      end

      describe 'patch :start' do
        it 'redirects to the user home page' do
          patch :start, id: campaign
          expect(response).to redirect_to user_root_path
        end

        it 'does not change the state of the campaign' do
          expect do
            patch :start, id: campaign
          end.not_to change(campaign, :state)
        end
      end

      describe 'patch :prolong' do
        it 'redirects to the user home page' do
          patch :prolong, id: campaign
          expect(response).to redirect_to user_root_path
        end

        it 'does not change the state of the campaign' do
          expect do
            patch :prolong, id: campaign
          end.not_to change(campaign, :state)
        end
      end

      describe 'patch :collect' do
        it 'redirects to the user root page' do
          patch :collect, id: campaign
          expect(response).to redirect_to user_root_path
        end

        it 'does not change the state of the campaign' do
          expect do
            patch :collect, id: campaign
          end.not_to change(campaign, :state)
        end
      end

      describe 'patch :cancel' do
        it 'redirects to the user root page' do
          patch :cancel, id: campaign
          expect(response).to redirect_to user_root_path
        end

        it 'does not change the campaign state' do
          expect do
            patch :cancel, id: campaign
            campaign.reload
          end.not_to change(campaign, :state)
        end
      end

      describe "delete :destroy" do
        it "redirects to the user root page" do
          delete :destroy, id: campaign
          expect(response).to redirect_to user_root_path
        end

        it 'does not remove the campaign record' do
          campaign #reload the campaign
          expect do
            begin
              delete :destroy, id: campaign
            rescue ActiveRecord::RecordNotFound
            end
          end.not_to change(Campaign, :count)
        end
      end
    end
  end

  context 'for an unauthenticated user' do
    describe "get :index" do
      it "redirects to the user sign in page" do
        get :index, book_id: book
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "get :new" do
      it "redirects to the user sign in page" do
        get :new, book_id: book
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "post :create" do
      it "redirects to the user sign in page" do
        post :create, book_id: book
        expect(response).to redirect_to new_user_session_path
      end

      it 'does not create a new campain record' do
        expect do
          post :create, book_id: book
        end.not_to change(Campaign, :count)
      end
    end

    describe "get :show" do
      it "redirects to the user sign in page" do
        get :show, id: campaign
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "get :edit" do
      it "redirects to the user sign in page" do
        get :edit, id: campaign
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "patch :update" do
      it "redirects to the user sign in page" do
        patch :update, id: campaign, campaign: attributes
        expect(response).to redirect_to new_user_session_path
      end

      it 'does not update the campaign' do
        expect do
          patch :update, id: campaign, campaign: attributes
          campaign.reload
        end.not_to change(campaign, :target_amount)
      end
    end

    describe 'patch :start' do
      it 'redirects to the user sign in page' do
        patch :start, id: campaign
        expect(response).to redirect_to new_user_session_path
      end

      it 'does not change the state of the campaign' do
        expect do
          patch :start, id: campaign
        end.not_to change(campaign, :state)
      end
    end

    describe 'patch :prolong' do
      it 'redirects to the user sign in page' do
        patch :prolong, id: campaign
        expect(response).to redirect_to new_user_session_path
      end

      it 'does not change the state of the campaign' do
        expect do
          patch :prolong, id: campaign
          campaign.reload
        end.not_to change(campaign, :state)
      end
    end

    describe 'patch :collect' do
      it 'redirects to the user sign in page' do
        patch :collect, id: campaign
        expect(response).to redirect_to new_user_session_path
      end

      it 'does not change the state of the campaign' do
        expect do
          patch :collect, id: campaign
        end.not_to change(campaign, :state)
      end
    end

    describe 'patch :cancel' do
      it 'redirects to the user sign in page' do
        patch :cancel, id: campaign
        expect(response).to redirect_to new_user_session_path
      end

      it 'does not change the campaign state' do
        expect do
          patch :cancel, id: campaign
          campaign.reload
        end.not_to change(campaign, :state)
      end
    end

    describe "delete :destroy" do
      it "redirects to the user sign in page" do
        delete :destroy, id: campaign
        expect(response).to redirect_to new_user_session_path
      end

      it 'does not remove the campaign record' do
        campaign #reload the campaign
        expect do
          delete :destroy, id: campaign
        end.not_to change(Campaign, :count)
      end
    end
  end
end
