class Ability
  include CanCan::Ability

  def initialize(author)
    author ||= Author.new
    can [:show, :update, :edit], Author, id: author.id
    can [:create, :show, :update, :edit], Bio, author_id: author.id
    can :show, Image do |image|
      image.bios.approved.any?
    end
  end
end
