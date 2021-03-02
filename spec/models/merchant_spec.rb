require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe 'relationships' do
    it { should have_many(:items) }
    it { should have_many(:invoices).through(:invoice_items)}
    it { should have_many(:transactions).through(:invoices)}
    it { should have_many(:customers).through(:invoices)}
  end

  before :each do
    @joe = Merchant.create!(name: "Joe Rogan")
    @not_joe = Merchant.create!(name: "Not Joe Rogan")
    @customer1 = Customer.create!(first_name: "Dana", last_name: "White")
    @customer2 = Customer.create!(first_name: "John", last_name: "Singer")
    @customer3 = Customer.create!(first_name: "Jack", last_name: "Berry")
    @customer4 = Customer.create!(first_name: "Jill", last_name: "Kellogg")
    @customer5 = Customer.create!(first_name: "Jason", last_name: "Sayles")
    @item1 = @joe.items.create!(name: "Basketball", description: "Bouncy", unit_price: 20)
    @item2 = @joe.items.create!(name: "Baseball", description: "Not Bouncy", unit_price: 10)
    @item3 = @joe.items.create!(name: "Hockey Puck", description: "Not Bouncy", unit_price: 2)
    @item4 = @not_joe.items.create!(name: "Not A Baseball", description: "Not Bouncy", unit_price: 10)
    @item5 = @not_joe.items.create!(name: "not A Hockey Puck", description: "Not Bouncy", unit_price: 2)
    @inv1 = @customer1.invoices.create!(status: "completed")
    @inv2 = @customer2.invoices.create!(status: "completed")
    @inv3 = @customer3.invoices.create!(status: "completed")
    @inv4 = @customer4.invoices.create!(status: "completed")
    @inv5 = @customer5.invoices.create!(status: "completed")
    @inv6 = @customer5.invoices.create!(status: "completed")
    @inv7 = @customer5.invoices.create!(status: "completed")
    @inv1.transactions.create!(result: "success")
    @inv2.transactions.create!(result: "success")
    @inv3.transactions.create!(result: "success")
    @inv4.transactions.create!(result: "success")
    @inv5.transactions.create!(result: "success")
    @inv6.transactions.create!(result: "success")
    @inv7.transactions.create!(result: "success")
    InvoiceItem.create!(invoice: @inv1, item: @item1, unit_price: 20, status: "packaged")
    InvoiceItem.create!(invoice: @inv2, item: @item2, unit_price: 10, status: "packaged")
    InvoiceItem.create!(invoice: @inv3, item: @item3, unit_price: 2, status: "shipped")
    InvoiceItem.create!(invoice: @inv4, item: @item1, unit_price: 2, status: "shipped")
    InvoiceItem.create!(invoice: @inv5, item: @item2, unit_price: 2, status: "shipped")
    InvoiceItem.create!(invoice: @inv6, item: @item4, unit_price: 2, status: "shipped")
    InvoiceItem.create!(invoice: @inv7, item: @item5, unit_price: 2, status: "shipped")
    InvoiceItem.create!(invoice: @inv7, item: @item1, unit_price: 2, status: "shipped")
  end

  describe 'methods' do
    it 'should find all unshipped items' do

      joe = Merchant.create!(name: "Joe Rogan")
      customer = Customer.create!(first_name: "Dana", last_name: "White")
      item1 = joe.items.create!(name: "Basketball", description: "Bouncy", unit_price: 20)
      item2 = joe.items.create!(name: "Baseball", description: "Not Bouncy", unit_price: 10)
      item3 = joe.items.create!(name: "Hockey Puck", description: "Not Bouncy", unit_price: 2)
      inv1 = customer.invoices.create!(status: "completed")
      InvoiceItem.create!(invoice: inv1, item: item1, unit_price: 20, status: "packaged")
      InvoiceItem.create!(invoice: inv1, item: item2, unit_price: 10, status: "packaged")
      InvoiceItem.create!(invoice: inv1, item: item3, unit_price: 2, status: "shipped")

      unshipped_items = 2

      expect(@joe.unshipped.length).to eq(unshipped_items)
    end

    it 'can find all its customers' do
      expect(@joe.customers).to include(@customer1, @customer2, @customer3, @customer4, @customer5)
    end

    it 'can find its top 5 customers' do
      5.times{@inv5.transactions.create!(result: "success")}
      4.times{@inv4.transactions.create!(result: "success")}
      3.times{@inv3.transactions.create!(result: "success")}
      2.times{@inv2.transactions.create!(result: "success")}
      @inv1.transactions.create!(result: "success")

      expect(@joe.top_five_customers).to eq([@customer5, @customer4, @customer3, @customer2, @customer1])
      expect(@joe.top_five_customers).to_not eq([@customer1, @customer4, @customer3, @customer2, @customer5])
    end

    it "#invoices" do
      expect(@joe.invoices).to eq([@inv1, @inv2, @inv3, @inv4, @inv5, @inv7])
    end

    it "can find the top five merchants by revenue" do
      merchant3 = Merchant.create!(name: "merchant 3")
      im3 = merchant3.items.create!(name: "not Basketball", description: "Bouncy", unit_price: 40)
      invmerch3 = @customer3.invoices.create!(status: "completed")
      t3 = invmerch3.transactions.create!(result: "success")
      InvoiceItem.create!(invoice: invmerch3, item: im3, unit_price: 50, quantity: 2, status: "packaged")
      merchant4 = Merchant.create!(name: "merchant 4")
      im4 = merchant4.items.create!(name: "not Basketball 2", description: "Bouncy", unit_price: 40)
      invmerch4 = @customer3.invoices.create!(status: "completed")
      t4 = invmerch4.transactions.create!(result: "success")
      InvoiceItem.create!(invoice: invmerch4, item: im4, unit_price: 75, quantity: 3, status: "packaged")
      merchant5 = Merchant.create!(name: "merchant 5")
      im5 = merchant5.items.create!(name: "not Basketball 2", description: "Bouncy", unit_price: 50)
      invmerch5 = @customer3.invoices.create!(status: "completed")
      t5 = invmerch5.transactions.create!(result: "success")
      InvoiceItem.create!(invoice: invmerch5, item: im5, unit_price: 75, quantity: 16, status: "packaged")
      
      expected = [@joe, @not_joe, merchant5, merchant4, merchant3]

      expect(Merchant.top_five_by_revenue).to eq(expected)
    end
  end

  describe "instance methods" do
    describe "##items_by_status_true" do
      it "returns all merchant items with status that is true" do
        joe = Merchant.create!(name: "Joe Rogan")
        item1 = joe.items.create!(name: "Basketball", description: "Bouncy", unit_price: 20)
        item2 = joe.items.create!(name: "Baseball", description: "Not Bouncy", unit_price: 10, status: false)
        item3 = joe.items.create!(name: "Hockey Puck", description: "Not Bouncy", unit_price: 2)

        expect(joe.items_by_status_true.count).to eq(2)
        expect(joe.items_by_status_false.count).to eq(1)
      end
    end
  end
end
