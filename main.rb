class Marchandize
  def initialize(item,price)
    @item = item
    @price = price
  end

  def valid
    true
  end
end

class Fruit < Marchandize
  attr_reader :item,:price,:status
  def initialize(item,price,status)
    super(item,price)
    @status = status
  end

  def self.status
    ['good','bad']
  end

  def valid
    @status == 'good' ? true : false
  end
end

class Cutlery < Marchandize 
  attr_reader :item,:price
end

class Stock
  attr_reader :marchandize
  def initialize(marchandize_qty)
    @marchandize = []
    until @marchandize.length > marchandize_qty
      @marchandize << Fruit.new('apple',200,Fruit.status.sample)
      @marchandize << Fruit.new('kiwi',100,Fruit.status.sample)
      @marchandize << Fruit.new('banana',80,Fruit.status.sample)
      @marchandize << Fruit.new('kaki',100,Fruit.status.sample)
      @marchandize << Fruit.new('apple',200,Fruit.status.sample)
      @marchandize << Fruit.new('kiwi',100,Fruit.status.sample)
      @marchandize << Fruit.new('banana',80,Fruit.status.sample)
      @marchandize << Fruit.new('kaki',100,Fruit.status.sample)
      @marchandize << Cutlery.new('spoon',100)
      @marchandize << Cutlery.new('folk',100)
      @marchandize << Cutlery.new('knife',100)
    end
  end

  def all
    @marchandize.group_by{|x|x.class}.each do |key,array|
      puts "=== #{key} ==="
      uniq_item = array.uniq{|value|value.item}
      uniq_item.each do |x|
        qty = array.select {|value|value.item == x.item}
        puts "#{x.item} => price: #{x.price} JPY, qty: #{qty.length}"
      end
    end
  end

  def bad_items_removed
    @marchandize = @marchandize.select {|item|item.valid}
  end

  def item_include(item)   
    @marchandize.find {|value|value.item == item}    
  end

  def qty_enough(item,qty)
    qty <= @marchandize.select {|value|value.item == item}.length ? true : false
  end

  def qty_subtraction(item,qty)
    index = (0..qty-1).to_a
    index.each do |i| 
      @marchandize.delete_at(@marchandize.each_index.select {|i|@marchandize[i].item == item}[i])
    end
  end
  
  def item_price(item)
   @marchandize.select {|x|x.item == item}[0].price
  end
end

class Customer 
  attr_reader :name,:cart
  def initialize(name)
    @name = name
    @cart = []
  end
end

def shop
  # before store opening
  stock = Stock.new(120)
  stock.all
  stock.bad_items_removed
  purchased = []
  # store open, 2 customers came today
  2.times do
    puts "What is your first name?"
    name = gets.chomp.capitalize
    customer = Customer.new(name)
    puts "Hi #{customer.name}! This is all we have today."
    stock.all
    # customer do shopping, the shop subtracts qty from the stock
    item = ''
    qty = 0
      until item == 'c'
      subtotal = {}
      puts "What would you like to buy? if nothing, please type c."
      item = gets.chomp.downcase 
        if stock.item_include(item) 
          subtotal['item'] = item
          puts "How many of #{item} would you like?"
          qty = gets.chomp.to_i
          if stock.qty_enough(item,qty) 
            subtotal['price'] = stock.item_price(item) 
            subtotal['qty'] = qty
            subtotal['subtotal'] = subtotal['price']*subtotal['qty']
            customer.cart << subtotal
            purchased << subtotal
            stock.qty_subtraction(item,qty)   
          else
           puts "Sorry, we do not have enough qty."
          end
        elsif item != 'c'
          puts "Sorry, we don't have #{item} today."
        end
      end
    # show the bill per customer
    puts 'Thank you for your shopping! Here is your bill.'
     total = 0
     customer.cart.each do |x|
       total += x['subtotal']
       puts "#{x['item']} => price: #{x['price']} JPY, qty: #{x['qty']}, subtotal: #{x['subtotal']} JPY"
     end
      puts "total:#{total} JPY"
  end
  # store closed. show all purchased items at the end of the day
  puts "===== Today's Leftover ====="
  stock.all
  puts "===== Today's Sales ====="
  uniq_array = purchased.uniq{|value|value['item']}
  total = 0
  uniq_array.each do |x|
    item_qty_purchased = 0
    items = purchased.select {|value|value['item'] == x['item']}
    items.each do |x|
      item_qty_purchased += x['qty']
    end
    puts "#{x['item']} => price: #{x['price']} JPY x qty: #{item_qty_purchased} = #{x['price']*item_qty_purchased} JPY"
    total += x['price']*item_qty_purchased
  end
  puts "Total Sales : #{total} JPY"
end

shop