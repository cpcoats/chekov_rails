class Role < ActiveRecord::Base
  include Enumable
  validates :name, :presence => true, :uniqueness => true, :on => :create
  has_and_belongs_to_many :users
end
