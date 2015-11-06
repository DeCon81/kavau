require 'rails_helper'

RSpec.describe Payment, type: :model do
  it "valid types are disburse and deposit" do
    expect(Payment.valid_types).to eq(["Deposit", "Disburse"])
  end

  it "interest_sum over all payments is calculated" do
    @credit_agreement = create :credit_agreement, interest_rate: 2
    @deposit = create :deposit, amount: 1000, date: Date.today - 2.days
    @disburse = create :disburse, amount: 100, date: Date.today - 1.day
    expect(Payment.interest_sum).to eq(0.1)
  end

  it "updates existing older balances on being changed" do
    @credit_agreement = create :credit_agreement
    @deposit = create :deposit, credit_agreement: @credit_agreement, amount: 1000, date: '2014-12-31'
    @balance = @credit_agreement.balances.create(date: Date.new(2014,12,31))
    expect(@balance.end_amount).to eq(1000)
    expect(@balance).to be_persisted
    @deposit.update(amount: 2000)
    expect(@balance.reload.end_amount).to eq(2000)
  end

  describe "its interest" do
    it "is the interest upto the specified date for this years payments" do
      payment = create :deposit, date: Date.today
      date = Date.today + 1.day
      expect(PaymentInterest).to receive(:new).with(payment, date)
      payment.interest(date)
    end

    it "is the interest upto today for this years payments if no date is specified" do
      payment = create :deposit, date: Date.today
      expect(PaymentInterest).to receive(:new).with(payment, Date.today)
      payment.interest
    end

    it "is the interest upto the end of the year, in wich the payment has been made for past years payments" do
      payment = create :deposit, date: Date.today - 1.year
      expect(PaymentInterest).to receive(:new).with(payment, (Date.today - 1.year).end_of_year)
      payment.interest
    end
  end
end
