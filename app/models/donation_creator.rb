class DonationCreator
  include ActiveModel::Validations

  attr_accessor :campaign,
                :amount,
                :email,
                :credit_card,
                :cvv,
                :expiration_month,
                :expiration_year,
                :first_name,
                :last_name,
                :address_1,
                :address_2,
                :city,
                :state,
                :postal_code,
                :payment,
                :donation

  validates_presence_of :campaign,
                        :amount,
                        :email,
                        :credit_card,
                        :cvv,
                        :expiration_month,
                        :expiration_year,
                        :first_name,
                        :last_name,
                        :address_1,
                        :address_2,
                        :city,
                        :state,
                        :postal_code

  def create!
    Donation.transaction do
      create_payment_with_provider
      create_payment
      create_donation
    end
  end

  def initialize(attributes = {}, options = {})
    attributes ||= {}
    self.campaign = attributes[:campaign]
    self.amount = attributes[:amount]
    self.email = attributes[:email]
    self.credit_card = attributes[:credit_card]
    self.cvv = attributes[:cvv]
    self.expiration_month = attributes[:expiration_month]
    self.expiration_year = attributes[:expiration_year]
    self.first_name = attributes[:first_name]
    self.last_name = attributes[:last_name]
    self.address_1 = attributes[:address_1]
    self.address_2 = attributes[:address_2]
    self.city = attributes[:city]
    self.state = attributes[:state]
    self.postal_code = attributes[:postal_code]

    options ||= {}
    @payment_provider = options.fetch(:payment_provider, PAYMENT_PROVIDER)
  end

  private

  def create_payment_with_provider
    @provider_response = @payment_provider.create_payment(provider_payment_attributes)
  end

  def create_payment
  end

  def create_donation
  end

  def provider_payment_attributes
    {
      amount: amount,
      credit_card: credit_card,
      cvv: cvv,
      expirection_month: expiration_month,
      expiration_year: expiration_year,
      first_name: first_name,
      last__name: last_name,
      address_1: address_1,
      address_2: address_2,
      city: city,
      state: state,
      postal_code: postal_code
    }
  end
end
