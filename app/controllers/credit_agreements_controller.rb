class CreditAgreementsController < ApplicationController
  before_action :set_type, except: :index
  before_action :set_creditor, except: :index
  include Authorized

  def index
    @credit_agreements = policy_scope(CreditAgreement)
    authorize @credit_agreements
    respond_with @credit_agreements
  end

  def show
    respond_with @credit_agreement
  end

  def new
    respond_with @credit_agreement
  end

  def edit
    respond_with @credit_agreement
  end

  def create
    @credit_agreement.save
    respond_with @credit_agreement, location: @credit_agreement.creditor
  end

  def update
    @credit_agreement.update(credit_agreement_params)
    respond_with @credit_agreement, location: -> { after_action_path }
  end

  def destroy
    @credit_agreement.destroy
    respond_with @credit_agreement, location: -> { after_action_path }
  end

  private
    def credit_agreement_params
      params[:credit_agreement].permit(policy(@credit_agreement || CreditAgreement.new).permitted_params)
    end

    def create_params
      credit_agreement_params.merge(creditor: @creditor)
    end

    def set_creditor
      @creditor = @type.find(get_creditor_id)
    end

    def set_type
      @type = type.constantize
    end

    def type
      params[:type]
    end

    def get_creditor_id
      params["#{type.underscore}_id"]
    end

    def after_action_path
      session[:back_url] || credit_agreements_path
    end
end
