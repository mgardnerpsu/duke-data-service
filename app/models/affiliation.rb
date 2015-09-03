class Affiliation < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :project_role

  validates :user_id, presence: true
  validates :project_id, presence: true
  validates :project_role_id, presence: true
end
