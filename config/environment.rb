# Load the rails application
require File.expand_path('../application', __FILE__)

#resque server ip
ip = (`/sbin/ifconfig eth0 | grep 'addr:' | awk {'print $2'} | awk -F ':' {'print $2'} 2>&1`).strip
SERVER_IP = Rails.env.development? ? 'localhost' : ip.strip

OMNIAUTH_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/omniauth.yml")[Rails.env].symbolize_keys
GRAPH_DB_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/graphdb.yml")[Rails.env].symbolize_keys
CASHU_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/cashu.yml")[Rails.env].symbolize_keys
SUPPORTED_LOCALES = ["ar","en"]
USER_PERC = 0.8
TWSEELA_PERC = 0.2
VODAFONE_NUM = "00000000000"
MOBINILE_NUM = "00000000000"
ETISALAT_NUM = "00000000000"
TWITTER_PAGE = "http://twitter.com/temporary"
FACEBOOK_PAGE = "http://www.facebook.com/temporary"


RCC_PUB = '6LeCzNcSAAAAAOdw01xxgMk0XPdjaLtKle9UkfPj'
RCC_PRIV = '6LeCzNcSAAAAAL1Vz-zPRL0M1uFzQ_gHzY_xeeaH'

CACHE_EXPIRES_IN = Proc.new{12.hours.to_i}
CACHED_CONTROLLERS = [:pages, :feedbacks]
CACHED_Actions = {:pages => [:show], :feedbacks => [:new]}

# Recaptcha::Client.new(:rcc_pub=>'6LeCzNcSAAAAAOdw01xxgMk0XPdjaLtKle9UkfPj', :rcc_priv=>'6LeCzNcSAAAAAL1Vz-zPRL0M1uFzQ_gHzY_xeeaH')
  
# Initialize the rails application
Tawseela::Application.initialize!
