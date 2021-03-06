require 'concerns/building_block'

class BalancePdf < ApplicationPdf
  include BuildingBlock

  def initialize(balance)
    @balance = balance
    @document = self
    super @balance.project_address, @balance.creditor
  end

  private
  def content
    balance_heading
    move_down 20
    balance_table
    annotations
  end

  def annotations
    move_down(30)
    font_size(10) do
      text config[:content][:saldo_information]
    end
  end

  def balance_heading
    heading [credit_agreement_number, balance_year].join(' - ')
  end

  def credit_agreement_number
    [
      CreditAgreement.model_name.human, 
      CreditAgreement.human_attribute_name(:number), 
      CreditAgreementPresenter.new(@balance.credit_agreement, self).number
    ].join(' ')
  end

  def balance_year
    I18n.t(@balance.class.to_s.underscore, scope: 'pdf.balance', year: @balance.date.year)
  end

  def balance_table
    PdfTable.new(self, table_data, table_options).draw
  end

  def table_data
    table_header + table_content
  end

  def table_options
    { right_align: 2..4, bold_rows: [1, -1], thick_border_rows: [1, -1] }
  end

  def table_header
    [ [
      Balance.human_attribute_name(:date),
      '',
      Balance.human_attribute_name(:interest_days),
      Balance.human_attribute_name(:interest_calculation),
      CreditAgreement.human_attribute_name(:amount)
    ] ]
  end

  def table_content
    table_items.map{ |item| item_fields(item) }
  end

  def table_items
    [
      @balance.send(:last_years_balance),
      @balance.payments,
      @balance.interest_spans, 
      @balance
    ].flatten.sort_by(&:date).map{|item| presenter(item) }
  end

  def presenter(item)
    presenter_class(item).new(item, self)
  end

  def presenter_class(item)
    "#{item.class}Presenter".constantize
  end

  def item_fields(item)
    [
      item.date,
      item.name,
      item.respond_to?(:interest_days) ? item.interest_days : '',
      item.respond_to?(:calculation) ? item.calculation : '',
      item.amount,
    ]
  end
end

