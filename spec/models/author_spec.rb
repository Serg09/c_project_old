require 'rails_helper'

RSpec.describe Author, type: :model do
  let (:author) { FactoryGirl.create(:author) }

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
    author = Author.new(attributes)
    expect(author).to be_valid
  end

  describe '#email' do
    it 'is required' do
      author = Author.new(attributes.except(:email))
      expect(author).to have_at_least(1).error_on :email
    end

    it 'must be a valid email address' do
      author = Author.new(attributes.merge(email: 'notavalidemail'))
      expect(author).to have_at_least(1).error_on :email
    end

    it 'must be unique' do
      a1 = Author.create!(attributes)
      a2 = Author.new(attributes)
      expect(a2).to have_at_least(1).error_on :email
    end
  end

  describe '#password' do
    it 'is required' do
      author = Author.new(attributes.except(:password))
      expect(author).to have_at_least(1).error_on :password
    end
  end

  describe '#password_confirmation' do
    it 'must match #password' do
      author = Author.new(attributes.merge(password_confirmation: 'notamatch'))
      expect(author).to have_at_least(1).error_on :password_confirmation
    end
  end

  describe '#first_name' do
    it 'is required' do
      author = Author.new attributes.except(:first_name)
      expect(author).to have_at_least(1).error_on :first_name
    end
  end

  describe '#last_name' do
    it 'is required' do
      author = Author.new attributes.except(:last_name)
      expect(author).to have_at_least(1).error_on :last_name
    end
  end

  describe '#contactable' do
    it 'defaults to false' do
      author = Author.new attributes.except(:contactable)
      expect(author).not_to be_contactable
    end
  end

  describe '#username' do
    it 'is required' do
      author = Author.new attributes.except(:username)
      expect(author).to have_at_least(1).error_on :username
    end

    it 'must be unique' do
      a1 = Author.create! attributes
      a2 = Author.new attributes
      expect(a2).to have_at_least(1).error_on :username
    end
  end

  describe '#status' do
    it 'defaults to "pending"' do
      author = Author.new attributes
      expect(author.status).to eq 'pending'
      expect(author).to be_pending
    end

    context 'when set to "pending"' do
      it 'can be set to "accepted"' do
        author = Author.create! attributes
        author.status = Author.ACCEPTED
        expect(author).to be_valid
      end

      it 'can be set to "rejected"' do
        author = Author.create! attributes
        author.status = Author.REJECTED
        expect(author).to be_valid
      end

      it 'cannot be set to anything except "accepted" or "rejected"' do
        author = Author.create! attributes
        author.status = 'notvalid'
        expect(author).to have_at_least(1).error_on :status
      end
    end
  end

  describe '#full_name' do
    it 'concatenates the first and last names' do
      author = Author.new attributes.merge(first_name: 'John', last_name: 'Doe')
      expect(author.full_name).to eq 'John Doe'
    end
  end

  shared_context :multi_status do
    let!(:p1) { FactoryGirl.create(:author, first_name: 'John', status: Author.PENDING) }
    let!(:p2) { FactoryGirl.create(:author, first_name: 'Jake', status: Author.PENDING) }
    let!(:a1) { FactoryGirl.create(:author, first_name: 'Mike', status: Author.ACCEPTED) }
    let!(:a2) { FactoryGirl.create(:author, first_name: 'Mark', status: Author.ACCEPTED) }
    let!(:r1) { FactoryGirl.create(:author, first_name: 'Fred', status: Author.REJECTED) }
    let!(:r2) { FactoryGirl.create(:author, first_name: 'Ferb', status: Author.REJECTED) }
  end

  describe '::pending' do
    include_context :multi_status
    it 'lists the authors in pending status' do
      authors = Author.pending.map(&:first_name)
      expect(authors).to eq %w(John Jake)
    end
  end

  describe '::accepted' do
    include_context :multi_status
    it 'lists the authors in accepted status' do
      authors = Author.accepted.map(&:first_name)
      expect(authors).to eq %w(Mike Mark)
    end
  end

  describe '::rejected' do
    include_context :multi_status
    it 'lists the authors in rejected status' do
      authors = Author.accepted.map(&:first_name)
      expect(authors).to eq %w(Mike Mark)
    end
  end

  describe '#bios' do
    it 'lists the bios for the author' do
      author = Author.new(attributes)
      expect(author).to have(0).bios
    end
  end

  describe '#working_bio' do
    context 'when the author has no bios' do
      it 'returns null' do
        expect(author.working_bio).to be_nil
      end
    end

    context 'when the author has an approved bio' do
      let!(:bio) { FactoryGirl.create(:approved_bio, author: author) }

      it 'returns the approved bio' do
        expect(author.working_bio.try(:id)).to eq(bio.id)
      end
    end

    context 'when the author has a pending bio' do
      let!(:bio) { FactoryGirl.create(:pending_bio, author: author) }

      it 'returns the pending bio' do
        expect(author.working_bio.try(:id)).to eq(bio.id)
      end
    end

    context 'when the author has an approved bio and a more recent pending bio' do
      let!(:a) { FactoryGirl.create(:approved_bio, author: author) }
      let!(:p) { FactoryGirl.create(:pending_bio, author: author) }

      it 'returns the pending bio' do
        expect(author.working_bio.try(:id)).to eq p.id
      end
    end
    context 'when the author has a rejected bio' do
      let!(:bio) { FactoryGirl.create(:rejected_bio, author: author) }

      it 'returns nil' do
        expect(author.working_bio).to be_nil
      end
    end
  end

  describe '#active_bio' do
    context 'for an author with no bios' do
      it 'returns nil' do
        expect(author.active_bio).to be_nil
      end
    end

    context 'for an author with an approved bio' do
      let!(:bio) { FactoryGirl.create(:approved_bio, author: author) }

      it 'returns the approved bio' do
        expect(author.active_bio.try(:id)).to eq(bio.id)
      end
    end

    context 'for an author with multiple approved bios' do
      let!(:b1) { FactoryGirl.create(:approved_bio, author: author) }
      let!(:b2) { FactoryGirl.create(:approved_bio, author: author) }

      it 'returns the must recently approved bio' do
        expect(author.active_bio.try(:id)).to eq b2.id
      end
    end
  end

  describe '#pending_bio' do
    context 'for an author with no bios' do
      it 'returns nil' do
        expect(author.pending_bio).to be_nil
      end
    end
    context 'for an author with a pending bio' do
      let!(:bio) { FactoryGirl.create(:pending_bio, author: author) }

      it 'returns the pending bio' do
        expect(author.pending_bio.try(:id)).to eq bio.id
      end
    end
    # An author should never have more than one pending bio, as updating 
    # a pending bio should update the one that already exists and updating
    # an approved bio creates a pending bio
  end
end
