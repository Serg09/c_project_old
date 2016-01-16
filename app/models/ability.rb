class Ability
  include CanCan::Ability

  def initialize(author)
    author ||= Author.new
    can :manage, Author, id: author.id
  end
end
