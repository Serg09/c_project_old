class CreateBookVersions < ActiveRecord::Migration
  def up
    create_table :book_versions do |t|
      t.integer :book_id, null: false
      t.string :title, null: false, limit: 255
      t.string :short_description, null: false, limit: 1000
      t.text :long_description
      t.integer :cover_image_id
      t.integer :sample_id
      t.string :status, null: false, default: 'pending'

      t.timestamps null: false
    end

    sql = <<-SQL
      insert into book_versions(
        book_id,
        title,
        short_description,
        long_description,
        cover_image_id,
        sample_id,
        status,
        created_at,
        updated_at
      )
      select
        id,
        title,
        short_description,
        long_description,
        cover_image_id,
        sample_id,
        status,
        created_at,
        updated_at
      from books
    SQL
    Book.connection.execute(sql)

    change_table :books do |t|
      t.remove :title
      t.remove :short_description
      t.remove :long_description
      t.remove :cover_image_id
      t.remove :sample_id
      t.remove :status
    end
  end

  def down
    change_table :books do |t|
      t.string :title, limit: 255
      t.string :short_description, limit: 1000
      t.text :long_description
      t.integer :cover_image_id
      t.integer :sample_id
      t.string :status, null: false, default: 'pending'
    end

    sql = <<-SQL
      select
        book_id,
        title,
        short_description,
        long_description,
        cover_image_id,
        sample_id,
        status
      from book_versions
    SQL
    records = Book.connection.execute(sql)
    records.each do |record|
      book = Book.find(record['book_id'])
      book.title = record['title']
      book.short_description = record['short_description']
      book.long_description = record['long_description']
      book.cover_image_id = record['cover_image_id']
      book.sample_id = record['sample_id']
      book.save!
    end

    change_column :books, :title, :string, null: false, limit: 255
    change_column :books, :short_description, :string, null: false, limit: 1000

    drop_table :book_versions
  end
end
