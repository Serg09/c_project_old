require 'rails_helper'

describe DonationCreator do
  let (:campaign) { FactoryGirl.create(:campaign) }
  let (:attributes) do
    {
      campaign: campaign,
      amount: 100,
      email: Faker::Internet.email,
      credit_card: '4444111144441111',
      credit_card_type: 'visa',
      expiration_month: '5',
      expiration_year: '2020',
      cvv: '123',
      first_name: 'John',
      last_name: 'Doe',
      address_1: '1234 Main Str',
      address_2: 'Apt 227',
      city: 'Dallas',
      state: 'TX',
      postal_code: '75200'
    }
  end

  it 'can be created from valid attributes' do
    creator = DonationCreator.new(attributes)
    expect(creator).to be_valid
  end

  describe '#campaign' do
    it 'is required' do
      creator = DonationCreator.new attributes.except(:campaign)
      expect(creator).to have_at_least(1).error_on :campaign
    end
  end

  describe '#amount' do
    it 'is required' do
      creator = DonationCreator.new attributes.except(:amount)
      expect(creator).to have_at_least(1).error_on :amount
    end
  end

  describe '#email' do
    it 'is required' do
      creator = DonationCreator.new attributes.except(:email)
      expect(creator).to have_at_least(1).error_on :email
    end
  end

  describe '#credit_card' do
    it 'is required' do
      creator = DonationCreator.new attributes.except(:credit_card)
      expect(creator).to have_at_least(1).error_on :credit_card
    end
  end

  describe '#cvv' do
    it 'is required' do
      creator = DonationCreator.new attributes.except(:cvv)
      expect(creator).to have_at_least(1).error_on :cvv
    end
  end

  describe '#expiration_month' do
    it 'is required' do
      creator = DonationCreator.new attributes.except(:expiration_month)
      expect(creator).to have_at_least(1).error_on :expiration_month
    end
  end

  describe '#expiration_year' do
    it 'is required' do
      creator = DonationCreator.new attributes.except(:expiration_year)
      expect(creator).to have_at_least(1).error_on :expiration_year
    end
  end

  describe '#first_name' do
    it 'is required' do
      creator = DonationCreator.new attributes.except(:first_name)
      expect(creator).to have_at_least(1).error_on :first_name
    end
  end

  describe '#last_name' do
    it 'is required' do
      creator = DonationCreator.new attributes.except(:last_name)
      expect(creator).to have_at_least(1).error_on :last_name
    end
  end

  describe '#address_1' do
    it 'is required' do
      creator = DonationCreator.new attributes.except(:address_1)
      expect(creator).to have_at_least(1).error_on :address_1
    end
  end

  # #address_2 is not required

  describe '#city' do
    it 'is required' do
      creator = DonationCreator.new attributes.except(:city)
      expect(creator).to have_at_least(1).error_on :city
    end
  end

  describe '#state' do
    it 'is required' do
      creator = DonationCreator.new attributes.except(:state)
      expect(creator).to have_at_least(1).error_on :state
    end
  end

  describe '#postal_code' do
    it 'is required' do
      creator = DonationCreator.new attributes.except(:postal_code)
      expect(creator).to have_at_least(1).error_on :postal_code
    end
  end

  context 'when the payment provider transaction succeeds' do
    let (:payment_result) { File.read(Rails.root.join('spec', 'fixtures', 'files', 'payment.json')) }
    let (:payment_provider) do
      provider = double('payment provider')
      expect(provider).to receive(:create).and_return(payment_result)
      provider
    end

    describe '#create!' do
      it 'returns true' do
        creator = DonationCreator.new(attributes, payment_provider: payment_provider)
        expect(creator.create!).to be true
      end

      it 'sets #payment to the created payment record' do
        creator = DonationCreator.new(attributes, payment_provider: payment_provider)
        creator.create!
        expect(creator.payment).not_to be_nil
        expect(creator.payment).to be_a Payment
      end

      it 'sets #donation to the created donation record' do
        creator = DonationCreator.new(attributes, payment_provider: payment_provider)
        creator.create!
        expect(creator.donation).not_to be_nil
        expect(creator.donation).to be_a Donation
      end

      it 'creates a payment record' do
        expect do
          creator = DonationCreator.new(attributes)
          payment = creator.create!
        end.to change(Payment, :count).by(1)
      end

      it 'creates a donation record' do
        expect do
          creator = DonationCreator.new(attributes)
          payment = creator.create!
        end.to change(Donation, :count).by(1)
      end
    end
  end

  context 'when the payment provider transaction fails' do
    describe '#create!' do
      it 'returns false'
      it 'does not create a payment record'
      it 'does not create a donation record'
    end
  end
end
