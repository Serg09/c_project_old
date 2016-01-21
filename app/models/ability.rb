class Ability
  include CanCan::Ability

  def initialize(author)
    author ||= Author.new
    can [:show, :update, :edit], Author, id: author.id
  end
end
