class AddPriceToLineItem < ActiveRecord::Migration
  def up
    add_column :line_items, :price, :decimal ,  precision:8, scale:2
    LineItem.all.each {|line_item| line_item.price=line_item.product.price}
  end
  def down
    remove_column :line_items, :price
  end
end
