Rails.application.config.middleware.use OmniAuth::Builder do
  provider :linked_in, 
            OMNIAUTH_CONFIG[:linked_in]["key"], 
            OMNIAUTH_CONFIG[:linked_in]["secret"]
  
  provider :twitter, 
            OMNIAUTH_CONFIG[:twitter]["key"], 
            OMNIAUTH_CONFIG[:twitter]["secret"]
  
  provider :facebook, 
            OMNIAUTH_CONFIG[:facebook]["key"], 
            OMNIAUTH_CONFIG[:facebook]["secret"],
            :scope => OMNIAUTH_CONFIG[:facebook]["scope"]
end