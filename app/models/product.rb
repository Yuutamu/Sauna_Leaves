class Product < ApplicationRecord
  with_options presence: true do
    validates :name
    validates :description
    validates :price
    validates :stock
    validates :image
  end
  has_one_attached :image

  # MEMO: latestスコープは全モデルで使いたいので、app/models/application_record.rbに定義変更
  scope :price_high_to_low, -> { order(price: :desc) }
  scope :price_low_to_high, -> { order(price: :asc) }
  has_many :cart_items, dependent: :destroy
  has_many :order_details, dependent: :destroy
end
