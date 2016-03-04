class CreateBookVersions < ActiveRecord::Migration
  def up
    # Books
    # -----
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
    end

    # Book - Genre links
    # ------------------
    records = Book.connection.execute('select book_id, genre_id from books_genres')
    rename_table :books_genres, :book_versions_genres
    rename_column :book_versions_genres, :book_id, :book_version_id
    records.each do |record|
      book = Book.find(record['book_id'])
      sql = "update book_versions_genres set book_version_id = #{book.versions.first.id} where book_version_id = #{book.id} and genre_id = #{record['genre_id']}"
      Book.connection.execute(sql)
    end
  end

  def down
    # Book - Genre links
    # ------------------
    records = Book.connection.execute('select book_version_id, genre_id from book_versions_genres')
    rename_table :book_versions_genres, :books_genres
    rename_column :books_genres, :book_version_id, :book_id
    records.each do |record|
      book_version = BookVersion.find(record['book_version_id'])
      sql = "update books_genres set book_id = #{book_version.book_id} where book_id = #{book_version.id} and genre_id = #{record['genre_id']}"
      Book.connection.execute(sql)
    end

    # Books
    # -----
    change_table :books do |t|
      t.string :title, limit: 255
      t.string :short_description, limit: 1000
      t.text :long_description
      t.integer :cover_image_id
      t.integer :sample_id
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
