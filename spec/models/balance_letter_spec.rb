require 'rails_helper'

RSpec.describe BalanceLetter, type: :model do
  before(:each){ 
    @letter = create :balance_letter, year: 2014 
    allow_any_instance_of(Deposit).to receive(:not_before_credit_agreement_starts).and_return(true) 
  }

  it "partial is letters/letter" do
    expect(@letter.to_partial_path).to eq('letters/letter')
  end

  it "knows that pdfs have not been created" do
    expect(@letter.pdfs_created?).to be_falsy
  end

  it "title is the standard title even if Subject is given" do
    @letter = create :balance_letter, year: 2014, subject: 'Subject'
    expect(@letter.title).to eq('Jahresbilanz 2014')
  end

  it "title is the standard title if no Subject is given" do
    expect(@letter.title).to eq('Jahresbilanz 2014')
  end

  it "creates pdfs for each creditor with a balance for that year" do
    allow_any_instance_of(BalanceLetter).to receive(:to_pdf).and_return(:true)
    @person = create :person
    @address = create :complete_project_address, legal_form: 'registered_society'
    @credit_agreement = create :credit_agreement, creditor: @person, account: @address.default_account
    create :deposit, credit_agreement: @credit_agreement, date: Date.new(2014,11,11)
    create :person
    expect{
      @letter.create_pdfs
    }.to change(Pdf, :count).by(1)
  end
  
  it "knows if pdfs have been created" do
    allow_any_instance_of(BalanceLetter).to receive(:to_pdf).and_return(:true)
    create :person
    create :complete_project_address, legal_form: 'registered_society'
    @letter.create_pdfs
    expect(@letter.pdfs_created?).to be_truthy
  end

  it "builds pdfs from LetterPdf" do
    person = create :person
    create :complete_project_address, legal_form: 'registered_society'
    allow(YearlyBalancePdf).to receive(:new).and_call_original
    @letter.to_pdf(person)
    expect(YearlyBalancePdf).to have_received(:new).with(person, @letter)
  end

  it "last one for a creditor is found" do
    allow_any_instance_of(BalanceLetter).to receive(:to_pdf).and_return(:true)
    @creditor = create :person
    @letter2 = create :balance_letter, year: 2013
    create :pdf, letter: @letter, creditor: @creditor
    create :pdf, letter: @letter2, creditor: @creditor
    expect(BalanceLetter.last_for(@creditor.id)).to eq(@letter)
  end
end

