require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  fixtures :products
  test "product attributes must not be empty" do
    product=Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:image_url].any?
    assert product.errors[:price].any?
  end

  test "product price must be positive" do
    product=Product.new(title: "Test tile",
                        description: "test description",
                        image_url: "test.jpg")
    product.price = -1
    assert product.invalid?
    assert_equal "must be greater than or equal to 0.01", product.errors[:price].join(';')
    product.price = 0
    assert product.invalid?
    assert_equal "must be greater than or equal to 0.01", product.errors[:price].join(';')
    product.price = 1
    assert product.valid?
  end

  def new_product(image_url)
    Product.new(title: "Test tile",
                description: "test description",
                image_url: image_url,
                price: 4)
  end

  test "image url" do
    ok = %w( qqq.jpg qqq.png qqq.gif QQQ.Jpg QQQ.PNG http://aaa.aa/e/r/t/qqq.jpg )
    bad = %w(qqq.doc qqq.jpg/ee qqq.png.eee)
    ok.each do |name|
      assert new_product(name).valid?, "#{name} shouldn't be invalid"
    end
    bad.each do |name|
      assert new_product(name).invalid?, "#{name} shouldn't be valid"
    end
  end

  test "product is nor valid without a unique title" do
    product = Product.new(title: products(:ruby).title,
                          description: "ere",
                          price: 2,
                          image_url: "www.jpg")
    assert !product.save
    assert_equal "has already been taken", product.errors[:title].join(';')
  end

end
