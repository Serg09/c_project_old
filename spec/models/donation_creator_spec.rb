require 'rails_helper'

describe DonationCreator do
  let (:payment_provider) do
    provider = double('payment provider')
    expect(provider).to receive(:create).and_return(payment_result)
    provider
  end
  let (:creator) { DonationCreator.new(attributes, payment_provider: payment_provider) }

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
      address_1: '1234 Main St',
      address_2: 'Apt 227',
      city: 'Dallas',
      state: 'TX',
      postal_code: '75200',
      ip_address: '123.456.789.012',
      user_agent: 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.87 Safari/537.36'
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

  describe '#credit_card_type' do
    it 'is required' do
      creator = DonationCreator.new attributes.except(:credit_card_type)
      expect(creator).to have_at_least(1).error_on :credit_card_type
    end

    it 'cannot be something other than the accepted types' do
      creator = DonationCreator.new attributes.merge(credit_card_type: 'notatype')
      expect(creator).to have_at_least(1).error_on :credit_card_type
    end
  end

  describe '#cvv' do
    it 'is required' do
      creator = DonationCreator.new attributes.except(:cvv)
      expect(creator).to have_at_least(1).error_on :cvv
    end

    it 'cannot be more than 4 characters' do
      creator = DonationCreator.new attributes.merge(cvv: '12345')
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

    it 'cannot have 4 digits' do
      creator = DonationCreator.new attributes.merge(postal_code: '1234')
      expect(creator).to have_at_least(1).error_on :postal_code
    end

    it 'cannot have 6 digits' do
      creator = DonationCreator.new attributes.merge(postal_code: '123456')
      expect(creator).to have_at_least(1).error_on :postal_code
    end

    it 'can have 5 digits' do
      creator = DonationCreator.new attributes.merge(postal_code: '12345')
      expect(creator).to be_valid
    end

    it 'can have 5 digits followed by a dash and 4 more digits' do
      creator = DonationCreator.new attributes.merge(postal_code: '12345-6789')
      expect(creator).to be_valid
    end
  end

  context 'when the payment provider transaction succeeds' do
    let (:payment_result) do
      path = Rails.root.join('spec', 'fixtures', 'files', 'payment.json')
      raw = File.read(path)
      JSON.parse(raw, symbolize_names: true)
    end

    describe '#create!' do
      it 'returns true' do
        expect(creator.create!).to be true
      end

      it 'sets #payment to the created payment record' do
        creator.create!
        expect(creator.payment).not_to be_nil
        expect(creator.payment).to be_a Payment
      end

      it 'sets #donation to the created donation record' do
        creator.create!
        expect(creator.donation).not_to be_nil
        expect(creator.donation).to be_a Donation
      end

      it 'creates a payment record' do
        expect do
          creator.create!
        end.to change(Payment, :count).by(1)
      end

      it 'creates a donation record' do
        expect do
          payment = creator.create!
        end.to change(Donation, :count).by(1)
      end
    end
  end

  context 'when the payment provider transaction fails' do
    let (:payment_result) do
      path = Rails.root.join('spec', 'fixtures', 'files', 'payment_failure.json')
      raw = File.read(path)
      JSON.parse(raw, symbolize_names: true)
    end
    describe '#create!' do
      it 'returns false' do
        expect(creator.create!).to be false
      end

      it 'does not create a payment record' do
        expect do
          creator.create!
        end.not_to change(Payment, :count)
        expect(creator.payment).to be_nil
      end

      it 'does not create a donation record' do
        expect do
          creator.create!
        end.not_to change(Donation, :count)
        expect(creator.donation).to be_nil
      end

      it 'logs the error' do
        expect(Rails.logger).to receive(:warn).with(/payment for donation failed/)
        creator.create!
      end
    end
  end

  context 'when the payment provider transaction errors out' do
    let (:payment_provider) do
      provider = double('payment provider')
      expect(provider).to receive(:create).and_raise(StandardError) # TODO Get a more specific error type here
      provider
    end
    describe '#create!' do
      it 'returns false' do
        expect(creator.create!).to be false
      end

      it 'does not create a payment record' do
        expect do
          creator.create!
        end.not_to change(Payment, :count)
        expect(creator.payment).to be_nil
      end

      it 'does not create a donation record' do
        expect do
          creator.create!
        end.not_to change(Donation, :count)
        expect(creator.donation).to be_nil
      end

      it 'logs the error' do
        expect(Rails.logger).to receive(:error).with(/call to the payment provider failed/)
        creator.create!
      end

      it 'adds a messages to #exceptions' do
        creator.create!
        expect(creator).to have(1).exception
      end
    end
  end
end
