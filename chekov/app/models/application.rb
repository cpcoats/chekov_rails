class Application < ActiveRecord::Base
  include Enumable
  validates :name, :presence => true, :uniqueness => true, :on => :create
end
