class AdministratorAbility
  include CanCan::Ability

  def initialize
    can :manage, :all
    cannot :create, Bio
  end
end
