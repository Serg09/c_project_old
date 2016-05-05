require 'rails_helper'

RSpec.describe User, type: :model do
  let (:user) { FactoryGirl.create(:user) }

  let (:attributes) do
    {
      first_name: 'John',
      last_name: 'Doe',
      phone_number: '2145550000',
      contactable: true,
      username: 'jdoe',
      email: 'john@doe.com',
      password: 'please01',
      password_confirmation: 'please01'
    }
  end

  it 'is creatable with valid attributes' do
    user = User.new(attributes)
    expect(user).to be_valid
  end

  describe '#email' do
    it 'is required' do
      user = User.new(attributes.except(:email))
      expect(user).to have_at_least(1).error_on :email
    end

    it 'must be a valid email address' do
      user = User.new(attributes.merge(email: 'notavalidemail'))
      expect(user).to have_at_least(1).error_on :email
    end

    it 'must be unique' do
      a1 = User.create!(attributes)
      a2 = User.new(attributes)
      expect(a2).to have_at_least(1).error_on :email
    end
  end

  describe '#password' do
    it 'is required' do
      user = User.new(attributes.except(:password))
      expect(user).to have_at_least(1).error_on :password
    end
  end

  describe '#password_confirmation' do
    it 'must match #password' do
      user = User.new(attributes.merge(password_confirmation: 'notamatch'))
      expect(user).to have_at_least(1).error_on :password_confirmation
    end
  end

  describe '#first_name' do
    it 'is required' do
      user = User.new attributes.except(:first_name)
      expect(user).to have_at_least(1).error_on :first_name
    end
  end

  describe '#last_name' do
    it 'is required' do
      user = User.new attributes.except(:last_name)
      expect(user).to have_at_least(1).error_on :last_name
    end
  end

  describe '#contactable' do
    it 'defaults to false' do
      user = User.new attributes.except(:contactable)
      expect(user).not_to be_contactable
    end
  end

  describe '#username' do
    it 'is required' do
      user = User.new attributes.except(:username)
      expect(user).to have_at_least(1).error_on :username
    end

    it 'must be unique' do
      a1 = User.create! attributes
      a2 = User.new attributes
      expect(a2).to have_at_least(1).error_on :username
    end
  end

  describe '#status' do
    it 'defaults to "pending"' do
      user = User.new attributes
      expect(user.status).to eq 'pending'
      expect(user).to be_pending
    end

    context 'when set to "pending"' do
      it 'can be set to "approved"' do
        user = User.create! attributes
        user.status = User.APPROVED
        expect(user).to be_valid
      end

      it 'can be set to "rejected"' do
        user = User.create! attributes
        user.status = User.REJECTED
        expect(user).to be_valid
      end

      it 'cannot be set to anything except "approved" or "rejected"' do
        user = User.create! attributes
        user.status = 'notvalid'
        expect(user).to have_at_least(1).error_on :status
      end
    end
  end

  describe '#full_name' do
    it 'concatenates the first and last names' do
      user = User.new attributes.merge(first_name: 'John', last_name: 'Doe')
      expect(user.full_name).to eq 'John Doe'
    end
  end

  shared_context :multi_status do
    let!(:p1) { FactoryGirl.create(:pending_user, first_name: 'John') }
    let!(:p2) { FactoryGirl.create(:pending_user, first_name: 'Jake') }
    let!(:a1) { FactoryGirl.create(:approved_user, first_name: 'Mike') }
    let!(:a2) { FactoryGirl.create(:approved_user, first_name: 'Mark') }
    let!(:r1) { FactoryGirl.create(:rejected_user, first_name: 'Fred') }
    let!(:r2) { FactoryGirl.create(:rejected_user, first_name: 'Ferb') }
  end

  describe '::pending' do
    include_context :multi_status
    it 'lists the users in pending status' do
      users = User.pending.map(&:first_name)
      expect(users).to eq %w(Jake John)
    end
  end

  describe '::approved' do
    include_context :multi_status
    it 'lists the users in approved status' do
      users = User.approved.map(&:first_name)
      expect(users).to eq %w(Mark Mike)
    end
  end

  describe '::rejected' do
    include_context :multi_status
    it 'lists the users in rejected status' do
      users = User.rejected.map(&:first_name)
      expect(users).to eq %w(Ferb Fred)
    end
  end

  describe '#bios' do
    it 'lists the bios for the user' do
      user = User.new(attributes)
      expect(user).to have(0).bios
    end
  end

  describe '#working_bio' do
    context 'when the user has no bios' do
      it 'returns null' do
        expect(user.working_bio).to be_nil
      end
    end

    context 'when the user has an approved bio' do
      let!(:bio) { FactoryGirl.create(:approved_bio, author: user) }

      it 'returns the approved bio' do
        expect(user.working_bio.try(:id)).to eq(bio.id)
      end
    end

    context 'when the user has a pending bio' do
      let!(:bio) { FactoryGirl.create(:pending_bio, author: user) }

      it 'returns the pending bio' do
        expect(user.working_bio.try(:id)).to eq(bio.id)
      end
    end

    context 'when the user has an approved bio and a more recent pending bio' do
      let!(:a) { FactoryGirl.create(:approved_bio, author: user) }
      let!(:p) { FactoryGirl.create(:pending_bio, author: user) }

      it 'returns the pending bio' do
        expect(user.working_bio.try(:id)).to eq p.id
      end
    end
    context 'when the user has a rejected bio' do
      let!(:bio) { FactoryGirl.create(:rejected_bio, author: user) }

      it 'returns nil' do
        expect(user.working_bio).to be_nil
      end
    end
  end

  describe '#active_bio' do
    context 'for an user with no bios' do
      it 'returns nil' do
        expect(user.active_bio).to be_nil
      end
    end

    context 'for an user with an approved bio' do
      let!(:bio) { FactoryGirl.create(:approved_bio, author: user) }

      it 'returns the approved bio' do
        expect(user.active_bio.try(:id)).to eq(bio.id)
      end
    end

    context 'for an user with multiple approved bios' do
      let!(:b1) { FactoryGirl.create(:approved_bio, author: user) }
      let!(:b2) { FactoryGirl.create(:approved_bio, author: user) }

      it 'returns the must recently approved bio' do
        expect(user.active_bio.try(:id)).to eq b2.id
      end
    end
  end

  describe '#pending_bio' do
    context 'for an user with no bios' do
      it 'returns nil' do
        expect(user.pending_bio).to be_nil
      end
    end
    context 'for an user with a pending bio' do
      let!(:bio) { FactoryGirl.create(:pending_bio, author: user) }

      it 'returns the pending bio' do
        expect(user.pending_bio.try(:id)).to eq bio.id
      end
    end
    # An user should never have more than one pending bio, as updating 
    # a pending bio should update the one that already exists and updating
    # an approved bio creates a pending bio
  end

  describe '#books' do
    it 'contains a list of the users books' do
      user = User.new(attributes)
      expect(user).to have(0).books
    end
  end

  describe '#unsubscribe_token' do
    it 'is generated automatically' do
      user = User.create!(attributes)
      expect(user.unsubscribe_token).not_to be_nil
    end
  end
end
