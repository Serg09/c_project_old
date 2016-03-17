class DonationCreator
  include ActiveModel::Validations

  attr_accessor :campaign,
                :amount,
                :email,
                :credit_card,
                :credit_card_type,
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
                :donation,
                :ip_address,
                :user_agent

  validates_presence_of :campaign,
                        :amount,
                        :email,
                        :credit_card,
                        :credit_card_type,
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
  validates_inclusion_of :credit_card_type, in: Payment::CREDIT_CARD_TYPES.map{|t| t.second}
  validates_length_of :cvv, maximum: 4
  validates_format_of :postal_code, with: /\A\d{5}(?:-\d{4})?\z/

  def create!
    return false unless valid?

    Donation.transaction do
      begin
        if create_payment_with_provider
          create_donation
          create_payment
          true
        else
          Rails.logger.warn "The attempt to create the payment for donation failed. #{@provider_response.inspect}"
          false
        end
      rescue StandardError => e
        Rails.logger.error "The call to the payment provider failed. #{e}"
        exceptions << e.message
        false
      end
    end
  end

  def exceptions
    @exceptions ||= []
  end

  def initialize(attributes, options = {})
    attributes ||= {}
    self.campaign = attributes[:campaign]
    self.amount = attributes[:amount]
    self.email = attributes[:email]
    self.credit_card = attributes[:credit_card]
    self.credit_card_type = attributes[:credit_card_type]
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
    self.ip_address = attributes[:ip_address]
    self.user_agent = attributes[:user_agent]

    options ||= {}
    @payment_provider = options.fetch(:payment_provider, PAYMENT_PROVIDER)
  end

  def to_model
    @donation || (campaign.try(:donations) || Donation).new
  end

  private

  def create_payment_with_provider
    @provider_response = @payment_provider.create(provider_payment_attributes)
    @provider_response[:state] == 'approved'
  end

  def create_payment
    @payment = @donation.payments.create!(payment_attributes)
  end

  def create_donation
    @donation = campaign.donations.create!(donation_attributes)
  end

  def donation_attributes
    {
      amount: amount,
      email: email,
      ip_address: ip_address,
      user_agent: user_agent
    }
  end

  def payment_attributes
    {
      external_id: @provider_response[:id],
      state: @provider_response[:state],
      content: @provider_response
    }
  end

  def provider_payment_attributes
    {
      amount: amount,
      credit_card: credit_card,
      credit_card_type: credit_card_type,
      cvv: cvv,
      expiration_month: expiration_month,
      expiration_year: expiration_year,
      first_name: first_name,
      last_name: last_name,
      address_1: address_1,
      address_2: address_2,
      city: city,
      state: state,
      postal_code: postal_code
    }
  end
end
