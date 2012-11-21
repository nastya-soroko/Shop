require 'test_helper'

class UsersStoriesTest < ActionDispatch::IntegrationTest

  fixtures :products

  test "buying the product " do
    LineItem.delete_all
    Order.delete_all
    ruby_book=products(:ruby)

    get "/"
    assert_response  :success
    assert_template "index"

    xml_http_request :post, '/line_items', product_id: ruby_book.id
    assert_response :success

    cart=Cart.find(session[:cart_id])
    assert_equal 1, cart.line_items.size
    assert_equal ruby_book, cart.line_items[0].product

    get "/orders/new"

    assert_response :success
    assert_template "new"

    post_via_redirect "/orders", order: { name: "Nastya" ,
                                          address: "MyText",
                                          email: "nastya@mail.ru",
                                          pay_type: "Check"}
    assert_response :success
    assert_template "index"
    cart=Cart.find(session[:cart_id])
    assert_equal 0, cart.line_items.size

    orders=Order.all
    assert_equal 1, orders.size
    order=orders[0]

    assert_equal "Nastya", order.name
    assert_equal "MyText", order.address
    assert_equal "nastya@mail.ru", order.email
    assert_equal "Check", order.pay_type

    assert_equal 1, order.line_items.size
    line_item=order.line_items[0]
    assert_equal line_item.product, ruby_book

    mail= ActionMailer::Base.deliveries.last
    assert_equal ["nastya@mail.ru"], mail.to
    assert_equal 'from@example.com', mail[:from].value
    assert_equal 'Confirmation of your order!', mail.subject

  end
end
