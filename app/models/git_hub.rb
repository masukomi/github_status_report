class GitHub < ActiveRecord::Base
  attr_accessible :api_endpoint, :client_id, :client_secret, :domain, :name
  before_save :clean_urls
  has_many :repos

  validates_presence_of :client_id, :client_secret

  def is_registered?
    return (! client_id.blank? and ! client_secret.blank?)
  end

protected

  # Protected - removes trailing slashes from urls
  def clean_urls
    if domain and domain.end_with? '/'
      domain.chop!
    end
    if api_endpoint and api_endpoint.end_with? '/'
      domain.chop!
    end
  end

end
