class RemoveContributionIdFromPayments < ActiveRecord::Migration
  def up
    create_table :contributions_payments, id: false do |t|
      t.integer :contribution_id, null: false
      t.integer :payment_id, null: false
      t.index :contribution_id
      t.index :payment_id, unique: true
    end
    add_column :payments, :amount, :decimal, precision: 9, scale: 2

    id_sql = <<-sql
      insert into contributions_payments (
        contribution_id,
        payment_id
      )
      select contribution_id, id
      from payments
    sql
    amount_sql = <<-sql
      update payments set
        amount = c.amount
      from contributions c
      where c.id = payments.contribution_id
    sql
    ActiveRecord::Base.connection.execute(id_sql)
    ActiveRecord::Base.connection.execute(amount_sql)

    change_column :payments, :amount, :decimal, precision: 9, scale: 2, null: false
    remove_column :payments, :contribution_id
  end

  def down
    add_column :payments, :contribution_id, :integer
    remove_column :payments, :amount

    sql = <<-sql
      update payments set
        contribution_id = cp.contribution_id
      from contributions_payments cp
      where payments.id = cp.payment_id
    sql
    ActiveRecord::Base.connection.execute(sql)

    change_column :payments, :contribution_id, :integer, null: false
    drop_table :contributions_payments
  end
end
