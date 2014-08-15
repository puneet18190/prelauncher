class Friend < ActiveRecord::Base
  belongs_to :user
  attr_accessible :ref_id
  # attr_accessible :title, :body
end
