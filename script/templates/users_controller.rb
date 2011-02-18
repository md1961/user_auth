class UsersController < UserAuthKuma::UsersController
  before_filter :authenticate, :only => [:change_password, :update_password]
  before_filter :authenticate_as_administrator,
                             :except => [:change_password, :update_password]
end
