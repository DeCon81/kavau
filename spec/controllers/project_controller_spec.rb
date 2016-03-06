require 'rails_helper'

RSpec.describe ProjectController, type: :controller do
  before(:each){ sign_in create(:user) }

  describe "GET show" do
    it "assigns all the creditors and renders index" do
      address = create :project_address
      get :show
      expect(response).to render_template(:show)
    end

    it "renders project#show" do
      address = create :project_address
      get :show
      expect(assigns(:addresses)).to eq([address])

    end

    describe "flash warning" do
      it "sets flash warning if therere is no project society addresses" do
        create :project_address, legal_form: 'limited'
        get :show
        expect(flash[:warning]).to include('Eine Adresse für den Hausverein muß angelegt werden')
      end

      it "sets flash warning if therere is no project limited addresses" do
        create :project_address, legal_form: 'registered_society'
        get :show
        expect(flash[:warning]).to include('Eine Adresse für die Hausbesitz-Gmbh muß angelegt werden')
      end

      it "sets flash warning for contacts" do
        create :complete_project_address, legal_form: 'registered_society'
        address = create :project_address, legal_form: 'limited'
        get :show
        expect(flash[:warning].first).to include('Geschäftsführer')
      end

      it "sets flash warning for legal informations" do
        create :complete_project_address, legal_form: 'registered_society'
        address = create :project_address, :with_contacts
        get :show
        ['Sitz', 'Registergericht', 'Register-Nr', 'UST-Id-Nr', 'Steuernummer'].each do |missing|
          expect(flash[:warning].first).to include(missing)
        end
      end

      it "sets flash warning for missing tax id for limited" do
        create :complete_project_address, legal_form: 'registered_society'
        address = create :project_address, :with_contacts, legal_form: 'limited'
        get :show
        ['UST-Id-Nr', 'Steuernummer'].each do |missing|
          expect(flash[:warning].first).to include(missing)
        end
      end

      it "does not sets flash warning for missing tax id for registered_society" do
        address = create :project_address, :with_contacts, legal_form: 'registered_society'
        get :show
        ['UST-Id-Nr', 'Steuernummer'].each do |missing|
          expect(flash[:warning].first).not_to include(missing)
        end
      end

      it "sets flash warning for missing default_account" do
        create :complete_project_address, legal_form: 'registered_society'
        address = create :project_address, :with_contacts, :with_legals
        get :show
        expect(flash[:warning].first).to include('Standard-Konto')
      end

      it "sets no flash warnig if address has contacts and legal_information" do
        create :complete_project_address, legal_form: 'registered_society'
        address = create :complete_project_address
        get :show
        expect(flash[:warning]).to be_empty
      end
    end
  end
end

