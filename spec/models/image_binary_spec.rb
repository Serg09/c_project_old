require 'rails_helper'

RSpec.describe ImageBinary, type: :model do
  let (:data) { Rails.root.join('spec', 'fixtures', 'files', 'author_photo.jpg').read }
  let (:attributes) do
    {
      data: data
    }
  end

  it 'can be created from valid attributes' do
    image_binary = ImageBinary.new attributes
    expect(image_binary).to be_valid
  end

  describe '#data' do
    it 'is required' do
      image_binary = ImageBinary.new attributes.except(:data)
      expect(image_binary).to have_at_least(1).error_on :data
    end
  end
end
