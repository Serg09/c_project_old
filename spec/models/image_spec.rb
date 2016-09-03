require 'rails_helper'

RSpec.describe Image, type: :model do
  let (:user) { FactoryGirl.create(:user) }
  let (:image_binary) { FactoryGirl.create(:image_binary) }
  let (:attributes) do
    {
      owner_id: user.id,
      owner_type: 'User',
      image_binary_id: image_binary.id,
      hash_id: Image.hash_id(image_binary.data),
      mime_type: 'image/jpeg'
    }
  end

  it 'can be created from valid attributes' do
    image = Image.new attributes
    expect(image).to be_valid
  end

  describe '::has_id' do
    let (:binary_data) { Rails.root.join('spec', 'fixtures', 'files', 'author_photo.jpg').read }

    it 'returns the SHA1 hash for the specified data' do
      id = Image.hash_id(binary_data)
      expect(id).not_to be_nil
      expect(id.length).to be 40
    end
  end

  describe '#owner_id' do
    it 'is required' do
      image = Image.new attributes.except(:owner_id)
      expect(image).to have_at_least(1).error_on :owner_id
    end
  end

  describe '#owner_type' do
    it 'is required' do
      image = Image.new attributes.except(:owner_type)
      expect(image).to have_at_least(1).error_on :owner_type
    end
  end

  describe '#image_binary_id' do
    it 'is required' do
      image = Image.new attributes.except(:image_binary_id)
      expect(image).to have_at_least(1).error_on :image_binary_id
    end
  end

  describe '#hash_id' do
    it 'is required' do
      image = Image.new attributes.except(:hash_id)
      expect(image).to have_at_least(1).error_on :hash_id
    end

    it 'cannot be more than 40 characters' do
      image = Image.new attributes.merge(hash_id: ("1" * 41))
      expect(image).to have_at_least(1).error_on :hash_id
    end

    it 'cannot be less than 40 characters' do
      image = Image.new attributes.merge(hash_id: ("1" * 39))
      expect(image).to have_at_least(1).error_on :hash_id
    end

    it 'must be unique' do
      i1 = Image.create! attributes
      i2 = Image.new attributes
      expect(i2).to have_at_least(1).error_on :hash_id
    end
  end

  describe '#owner' do
    it 'is a reference to the user or author that owns the image' do
      image = Image.new attributes
      expect(image.owner.full_name).to eq user.full_name
    end
  end

  describe '#bios' do
    it 'lists the bios associated with the image' do
      image = Image.new attributes
      expect(image).to have(0).bios
    end
  end

  describe '#cover_of_book_versions' do
    it 'lists the books using the image as the cover' do
      image = Image.new attributes
      expect(image).to have(0).cover_of_book_versions
    end
  end

  describe '#sample_of_book_versions' do
    it 'lists the books using the image (PDF) as a sample' do
      image = Image.new attributes
      expect(image).to have(0).sample_of_book_versions
    end
  end
end
