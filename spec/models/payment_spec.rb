require 'rails_helper'

RSpec.describe Payment, type: :model do
  let (:contribution) { FactoryGirl.create(:contribution) }
  let (:attributes) do
    {
      contribution_id: contribution.id,
      external_id: 'PAY-17S8410768582940NKEE66EQ',
      state: 'approved',
      credit_card_number: '4111111111111111',
      credit_card_type: 'visa',
      expiration_month: '03',
      expiration_year: '2020',
      cvv: '123',
      billing_address_1: '1234 Main St',
      billing_address_2: 'Apt 227',
      billing_city: 'Dallas',
      billing_state: 'TX',
      billing_postal_code: '75200',
      billing_country_code: 'US'
    }
  end

  it 'can be created from valid attributes' do
    payment = Payment.new attributes
    expect(payment).to be_valid
  end

  describe '#contribution_id' do
    it 'is required' do
      payment = Payment.new attributes.except(:contribution_id)
      expect(payment).to have_at_least(1).error_on :contribution_id
    end
  end

  describe '#contribution' do
    it 'is a reference to the contribution to which the payment belongs' do
      payment = Payment.new attributes
      expect(payment.contribution.id).to be contribution.id
    end
  end

  describe '#external_id' do
    it 'is unique' do
      p1 = Payment.create! attributes
      p2 = Payment.new attributes
      expect(p2).to have_at_least(1).error_on :external_id
    end

    it 'ignores null values' do
      p1 = Payment.create! attributes.except :external_id
      p2 = Payment.new attributes.except :external_id
      expect(p2).to be_valid
    end
  end

  describe '#state' do
    it 'defaults to "pending"' do
      payment = Payment.new attributes.except(:state)
      expect(payment).to be_valid
      expect(payment).to be_pending
    end
  end

  describe '#transactions' do
    let (:payment) { FactoryGirl.create(:approved_payment) }
    it 'contains a list of transactions with the payment provider' do
      expect(payment.transactions.count).to eq 1
    end
  end

  describe '#sale_id' do
    let (:payment) { FactoryGirl.create(:approved_payment, sale_id: 'ABC123') }
    it 'returns the first sale ID found  in the transaction content' do
      expect(payment.sale_id).to eq 'ABC123'
    end
  end

  describe '#credit_card_number' do
    it 'is required' do
      payment = Payment.new attributes.except(:credit_card_number)
      expect(payment).to have_at_least(1).error_on :credit_card_number
    end
  end

  describe '#credit_card_type' do
    it 'is required' do
      payment = Payment.new attributes.except(:credit_card_type)
      expect(payment).to have_at_least(1).error_on :credit_card_type
    end
  end

  describe '#cvv' do
    it 'is required' do
      payment = Payment.new attributes.except(:cvv)
      expect(payment).to have_at_least(1).error_on :cvv
    end
  end

  describe '#billing_address_1' do
    it 'is required' do
      payment = Payment.new attributes.except(:billing_address_1)
      expect(payment).to have_at_least(1).error_on :billing_address_1
    end
  end

  describe '#billing_city' do
    it 'is required' do
      payment = Payment.new attributes.except(:billing_city)
      expect(payment).to have_at_least(1).error_on :billing_city
    end
  end

  describe '#billing_state' do
    it 'is required' do
      payment = Payment.new attributes.except(:billing_state)
      expect(payment).to have_at_least(1).error_on :billing_state
    end
  end

  describe '#billing_postal_code' do
    it 'is required' do
      payment = Payment.new attributes.except(:billing_postal_code)
      expect(payment).to have_at_least(1).error_on :billing_postal_code
    end
  end

  describe '#billing_country_code' do
    it 'is required' do
      payment = Payment.new attributes.except(:billing_country_code)
      expect(payment).to have_at_least(1).error_on :billing_country_code
    end
  end

  shared_examples 'a non-executable payment' do
    it 'does not call the payment provider' do
      expect(PAYMENT_PROVIDER).not_to receive(:execute_payment)
      payment.execute!
    end

    it 'does not create a transaction record' do
      expect do
        payment.execute!
      end.not_to change(PaymentTransaction, :count)
    end

    it 'does not change the state' do
      expect do
        payment.execute!
      end.not_to change(payment, :state)
    end
  end

  shared_examples 'a refundable payment' do
    it 'calls the payment provider to refund the payment, less an administrative fee' do
      expect(PAYMENT_PROVIDER).to \
        receive(:refund_payment).
        # TODO Fix this, add amount to payment and put specific values in the test
        with(payment, payment.contribution.amount).
        and_return(payment_refund_response(state: :completed))
      payment.refund!
    end

    context 'on success' do
      it 'creates a transaction record' do
        expect do
          payment.refund!
        end.to change(payment.transactions, :count).by(1)
      end

      it 'changes the state to "refunded"' do
        expect do
          payment.refund!
        end.to change(payment, :state).to('refunded')
      end
    end
  end

  shared_examples 'a non-refundable payment' do
    it 'does not call the payment provider' do
      expect(PAYMENT_PROVIDER).not_to \
        receive(:refund_payment)
      payment.refund!
    end

    it 'does not create a transaction record' do
      expect do
        payment.refund!
      end.not_to change(PaymentTransaction, :count)
    end

    it 'does not change the state' do
      expect do
        payment.refund!
      end.not_to change(payment, :state)
    end
  end

  context 'for a pending payment' do
    let (:payment) { FactoryGirl.create(:pending_payment) }

    describe '#execute!' do
      it 'calls the payment provider to execute the payment' do
        expect(PAYMENT_PROVIDER).to \
          receive(:execute_payment).
          with(payment).
          and_return(payment_create_response(state: :approved))
        payment.execute!
      end

      context 'on success' do
        before(:each) do
          expect(PAYMENT_PROVIDER).to \
            receive(:execute_payment).
            with(payment).
            and_return(payment_create_response(state: :approved))
        end

        it 'changes the state to "approved"' do
          expect do
            payment.execute!
          end.to change(payment, :state).from('pending').to('approved')
        end

        it 'creates a transaction record' do
          expect do
            payment.execute!
          end.to change(payment.transactions, :count).by(1)
        end
      end

      context 'on failure' do
        before(:each) do
          expect(PAYMENT_PROVIDER).to \
            receive(:execute_payment).
            with(payment).
            and_return(payment_create_response(state: :failed))
        end

        it 'changes the state to "failed"' do
          expect do
            payment.execute!
          end.to change(payment, :state).from('pending').to('failed')
        end

        it 'creates a transaction record' do
          expect do
            payment.execute!
          end.to change(payment.transactions, :count).by(1)
        end
      end

      context 'on error' do
        before(:each) do
          expect(PAYMENT_PROVIDER).to \
            receive(:execute_payment).
            with(payment).
            and_raise('induced error')
        end

        it 'does not change the state' do
          expect do
            payment.execute!
          end.not_to change(payment, :state)
        end

        it 'does not create a transaction record' do
          expect do
            payment.execute!
          end.not_to change(payment.transactions, :count)
        end
      end
    end

    describe '#refund' do
      it_behaves_like 'a non-refundable payment' do
        let!(:payment) { FactoryGirl.create(:pending_payment) }
      end
    end
  end

  context 'for an approved payment' do
    describe '#execute' do
      it_behaves_like 'a non-executable payment' do
        let!(:payment) { FactoryGirl.create(:approved_payment) }
      end
    end

    describe '#refund' do
      it_behaves_like 'a refundable payment' do
        let!(:payment) { FactoryGirl.create(:approved_payment) }
      end
    end
  end

  context 'for a completed payment' do
    let!(:payment) { FactoryGirl.create(:completed_payment) }

    describe '#execute' do
      it_behaves_like 'a non-executable payment' do
        # TODO Fix this, add amount to payment and put specific values in the test
        let!(:payment) { FactoryGirl.create(:completed_payment) }
      end
    end

    describe '#refund' do
      it_behaves_like 'a refundable payment' do
        let!(:payment) { FactoryGirl.create(:completed_payment) }
      end
    end
  end

  context 'for a failed payment' do
    describe '#execute' do
      it_behaves_like 'a non-executable payment' do
        let!(:payment) { FactoryGirl.create(:failed_payment) }
      end
    end

    describe '#refund' do
      it_behaves_like 'a non-refundable payment' do
        let!(:payment) { FactoryGirl.create(:failed_payment) }
      end
    end
  end

  shared_context :stateful_payments do
    let!(:pending1) { FactoryGirl.create(:pending_payment) }
    let!(:pending2) { FactoryGirl.create(:pending_payment) }
    let!(:approved1) { FactoryGirl.create(:approved_payment) }
    let!(:approved2) { FactoryGirl.create(:approved_payment) }
    let!(:failed1) { FactoryGirl.create(:failed_payment) }
    let!(:failed2) { FactoryGirl.create(:failed_payment) }
  end

  describe '::pending' do
    include_context :stateful_payments

    it 'returns all payments where the state is "pending"' do
      expect(Payment.pending.map(&:id)).to eq [pending1.id, pending2.id]
    end
  end

  describe '::approved' do
    include_context :stateful_payments

    it 'returns all payments where the state is "approved"' do
      expect(Payment.approved.map(&:id)).to eq [approved1.id, approved2.id]
    end
  end

  describe '::failed' do
    include_context :stateful_payments

    it 'returns all payments where the state is "failed"' do
      expect(Payment.failed.map(&:id)).to eq [failed1.id, failed2.id]
    end
  end
end
