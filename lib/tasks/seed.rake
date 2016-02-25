namespace :seed do

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  desc 'Create an author named John Doe'
  task johndoe: :environment do
    FactoryGirl.create(:author, first_name: 'John',
                                last_name: 'Doe',
                                email: 'john@doe.com')
  end

  desc 'Create a certain number of inquiries. (COUNT=10)'
  task inquiries: :environment do
    count = (ENV['COUNT'] || 10).to_i
    logger.info "creating #{count} inquiries"
    (0..count).each do
      i = FactoryGirl.create(:inquiry)
      logger.debug "created #{i.inspect}"
    end
  end

  desc 'Create a certain number of authors. (COUNT=10)'
  task authors: :environment do
    count = (ENV['COUNT'] || 10).to_i
    logger.info "creating #{count} authors"
    (0..count).each do
      i = FactoryGirl.create(:author)
      logger.debug "created #{i.inspect}"
    end
  end

  desc 'Create a certain number of bios (with new authors). (COUNT=10)'
  task bios: :environment do
    count = (ENV['COUNT'] || 10).to_i
    logger.info "creating #{count} bios"
    (0..count).each do
      i = FactoryGirl.create(:bio)
      logger.debug "created #{i.inspect}"
    end
  end

  desc 'Create a certain number of bios (with new authors). (COUNT=10)'
  task books: :environment do
    count = (ENV['COUNT'] || 10).to_i
    logger.info "creating #{count} books"
    (0..count).each do
      i = FactoryGirl.create(:pending_book)
      logger.debug "created #{i.inspect}"
    end
  end

  desc 'Create an administrator account'
  task administrator: :environment do
    attributes = {
      email: 'admin@cs.com',
      password: 'please01',
      password_confirmation: 'please01'
    }
    amdin = Administrator.find_by(email: 'admin@cs.com')
    if admin.present?
      logger.info "Administrator already exists"
    else
      admin = Administrator.create!(attributes)
      logger.info "created administrator account #{admin.inspect}"
    end
  end

  desc 'Create the default set of genres'
  task genres: :environment do
    [
      'Science Fiction',
      'Comedy/Humor',
      'Drama',
      'Comic',
      'Crime/Detective',
      'Fable/Fairytale',
      'Fantasy',
      'Historical Fiction',
      'Mythology',
      'Short Story',
      'Suspense/Thriller',
      'Action & Adventure',
      'Romance',
      'Mystery',
      'Horror',
      'Self Help',
      'Non- Fiction',
      'Tragedy',
      'Young- adult fiction',
      'Sports',
      'Biography',
      'Memoir',
      'Journal',
      'History',
      'Religion',
      'Supernatural',
      'Poetry',
      'Travel',
      'Health',
      'Children’s'
    ].each do |name|
      genre = Genre.new name: name
      if genre.valid?
        genre.save!
        logger.info "created genre #{genre.name}"
      else
        logger.warn "genre #{genre.name} already exists."
      end
    end
  end
end
