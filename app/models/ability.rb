class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    can [:show, :update, :edit], User, id: user.id
    can [:create, :show, :update, :edit], Bio, author_id: user.id
    can :show, Image do |image|
      image.can_be_viewed_by?(user)
    end
    can :show, BookVersion do |book_version|
      book_version.approved? || book_version.book.author_id == user.id
    end
    can [:version, :update, :create], Book, author_id: user.id
    can [:update, :edit], BookVersion do |book_version|
      book_version.book.author_id == user.id && book_version.pending?
    end
    can :create, BookVersion do |book_version|
      book_version.book.author_id == user.id
    end
    can :manage, Campaign do |campaign|
      campaign.book.author_id == user.id
    end
    can :show, Donation do |donation|
      donation.campaign.book.author_id == user.id
    end
    can :manage, Reward do |reward|
      reward.campaign.book.author_id == user.id
    end
    cannot :update, Reward do |reward|
      reward.donations.any?
    end
    can :fulfill, Fulfillment, reward: {campaign: {book: {author_id: user.id}}}
  end
end
