class Search < ActiveRecord::Base
  attr_accessor :save_search
  
  belongs_to :user
  has_many :searches_paths, :dependent=>:destroy
  
  validates :search_name, :presence=>true, :if => Proc.new{|s| s.save_search == true}
  validates :start_time_from, :presence=>true, :unless => Proc.new{|s| s.start_time_to.blank? }
  validates :start_time_to, :presence=>true, :unless => Proc.new{|s| s.start_time_from.blank? }
  validate :presence_one_field
  
  
  def presence_one_field
    errors[:base] << I18n.t("messages.select_any_attribute") if self.save_search.to_i == 1 && self.start_time_from.blank? && self.start_time_to.blank? && self.gender.blank? && !self.return_back && self.searches_paths.blank?
  end
  
  accepts_nested_attributes_for :searches_paths, :reject_if => proc{|attrs| attrs.all? {|k, v| v.blank?}}
end