class RemoveContentFromPayments < ActiveRecord::Migration
  def up
    Payment.all.each do |payment|
      PaymentTransaction.create! payment_id: payment.id,
                                 intent: 'sale',
                                 state: payment.state,
                                 response: payment.content
    end
    remove_column :payments, :content
  end

  def down
    add_column :payments, :content, :text
    PaymentTransaction.all.each do |tx|
      tx.payment.content = tx.response
      tx.payment.save!
    end
    change_column :payments, :content, :text, null: false
  end
end
