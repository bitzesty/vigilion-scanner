class Account < ActiveRecord::Base
  validates_presence_of :name

  has_many :projects
end
