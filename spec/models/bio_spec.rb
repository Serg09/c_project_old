require 'rails_helper'

RSpec.describe Bio, type: :model do
  let (:author) { FactoryGirl.create(:author) }
  let (:photo) { FactoryGirl.create(:image, author: author) }
  let (:attributes) do
    {
      author_id: author.id,
      text: 'This is some stuff about me. Dig it.',
      photo_id: photo.id,
      links_attributes: [
        {'site' => 'facebook', 'url' => 'http://www.facebook.com/john_doe' },
        {'site' => 'twitter', 'url' => 'http://www.twitter.com/doe_john' }
      ]
    }.with_indifferent_access
  end
  let (:photo_file) { Rails.root.join('spec', 'fixtures', 'files', 'author_photo.jpg') }

  it 'can be created from valid attributes' do
    bio = Bio.new(attributes)
    expect(bio).to be_valid
  end

  describe '#author_id' do
    it 'is required' do
      bio = Bio.new(attributes.except(:author_id))
      expect(bio).to have_at_least(1).error_on :author_id
    end

    it 'points to an author record' do
      bio = Bio.new(attributes)
      expect(bio.author.first_name).to eq author.first_name
    end
  end

  describe '#text' do
    it 'is required' do
      bio = Bio.new(attributes.except(:text))
      expect(bio).to have_at_least(1).error_on :text
    end
  end

  describe '#photo' do
    it 'is a reference to a photo' do
      bio = Bio.new attributes
      expect(bio.photo).not_to be_nil
    end
  end

  describe '#links' do
    it 'is a collection of links to social media sites' do
      bio = Bio.new(attributes)
      expect(bio).to have(6).links
    end
  end

  describe '#usable-links' do
    it 'is a list of links that have valid URLs' do
      bio = Bio.new(attributes)
      expect(bio).to have(2).usable_links
    end
  end

  describe '#status' do
    it 'defaults to "pending" if not specified' do
      bio = Bio.new attributes
      expect(bio).to be_pending
    end

    it 'cannot be anything besides "pending", "approved", or "rejected"' do
      bio = Bio.new attributes.merge(status: 'notvalid')
      expect(bio).to have_at_least(1).error_on :status
    end
  end

  shared_context :multiple_bios do
    let!(:p1) { FactoryGirl.create(:bio) }
    let!(:p2) { FactoryGirl.create(:bio) }
    let!(:a1) { FactoryGirl.create(:approved_bio) }
    let!(:a2) { FactoryGirl.create(:approved_bio) }
    let!(:r1) { FactoryGirl.create(:rejected_bio) }
    let!(:r2) { FactoryGirl.create(:rejected_bio) }
  end

  describe '::pending' do
    include_context :multiple_bios

    it 'lists bios with a status of "pending"' do
      expect(Bio.pending.map(&:id)).to eq [p2.id, p1.id]
    end
  end

  describe '::approved' do
    include_context :multiple_bios

    it 'lists bios with a status of "approved"' do
      expect(Bio.approved.map(&:id)).to eq [a2.id, a1.id]
    end
  end

  describe '#photo_file' do
    let (:attributes) do
      {
        author_id: author.id,
        photo_file: photo_file,
        text: 'This is some stuff about me. Dig it.',
        links_attributes: [
          {'site' => 'facebook', 'url' => 'http://www.facebook.com/john_doe' },
          {'site' => 'twitter', 'url' => 'http://www.twitter.com/doe_john' }
        ]
      }.with_indifferent_access
    end

    it 'accepts an uploaded file containing a photo for the bio' do
      bio = Bio.new attributes
      expect(bio.photo_file).not_to be_nil
    end

    it 'creates an image record on save' do
      expect do
        bio = Bio.new attributes
        bio.save
      end.to change(Image, :count).by(1)
    end

    it 'creates an image binary record on save' do
      expect do
        bio = Bio.new attributes
        bio.save
      end.to change(ImageBinary, :count).by(1)
    end

    it 'updates photo_id to point to the image record' do
      bio = Bio.new attributes
      bio.save
      expect(bio.photo_id).to be Image.last.id
    end
  end
end