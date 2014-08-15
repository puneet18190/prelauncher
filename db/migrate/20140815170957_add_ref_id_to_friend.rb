class AddRefIdToFriend < ActiveRecord::Migration
  def change
    add_column :friends, :ref_id, :string
  end
end
