class AdministratorAbility
  include CanCan::Ability

  def initialize
    can :manage, :all
    cannot [:create, :update], Bio
  end
end
