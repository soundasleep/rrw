class PlayerItem < ActiveRecord::Base
  belongs_to :player
  belongs_to :item_type
end
