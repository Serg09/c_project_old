require 'rails_helper'

RSpec.describe Payment, type: :model do
  let (:contribution) { FactoryGirl.create(:contribution) }
  let (:attributes) do
    {
      amount: contribution.amount,
      nonce: Faker::Number.hexadecimal(10),
      external_id: Faker::Number.hexadecimal(10),
      state: 'approved'
    }
  end

  it 'can be created from valid attributes' do
    payment = Payment.new attributes
    expect(payment).to be_valid
  end

  describe '#contributions' do
    it 'is a list of the contributions to which the payment belongs' do
      payment = Payment.new attributes
      expect(payment).to have(0).contributions
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

  describe '#provider_fee' do
    it 'cannot be less than zero' do
      payment = Payment.new attributes.merge(provider_fee: -0.01)
      expect(payment).to have(1).error_on :provider_fee
    end
  end

  describe '#nonce' do
    it 'is required' do
      payment = Payment.new attributes.except :nonce
      expect(payment).to have_at_least(1).error_on :nonce
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
    it 'calls the payment provider to refund the payment' do
      expect(PAYMENT_PROVIDER).to \
        receive(:refund_payment).
        with(payment).
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
