class User < ActiveRecord::Base
  belongs_to :role
  belongs_to :team
  belongs_to :permission

  scope :assignees, -> { where(:role_id => [ 1, 4 ]) }
  scope :reporters, -> { where(:role_id => [ 2, 4 ]) }
  scope :commenters, -> { where(:role_id => [ 3, 4 ]) }
   # all users except for the "nobody"/"unassigned" user at id: 1
  scope :reals, -> { where 'id > 1' }

  has_many :roles
  has_many :assignments, :class_name => "Task", :foreign_key => :assignee_id
  has_many :reported, :class_name => "Task", :foreign_key => :reporter_id
  has_many :comments, :class_name => "Comment", :foreign_key => :commenter_id
  has_many :commented, :class_name => "Task", :through => :comments, :source => :task

  validates :username, :presence => true, :uniqueness => true, :on => :create
  validates :first_name, :presence => true, :on => :save
  validates :last_name, :presence => true, :on => :save
  validates :role, :presence => true, :on => :save
  validates :team, :presence => true, :on => :save
  validates :permission, :presence => true, :on => :save

  def is_nobody?
  	id == 1
  end

  def able
    RolePermissionsStrategy.for_user(self)
  end

  def self.nobody
    User.find(1)
  end

  # only authentication needed for this app is that
  # a proper username is chosen as current user
  def self.authenticate(username)
    User.find_by(:username => username)
  end

end
