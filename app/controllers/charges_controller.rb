class ChargesController < ApplicationController
  def new
    render 'charges/new'
  end

  def success
    # TODO
    # notice: "Compra bem sucedida!"
  end

  def cancel
    # TODO
    # notice: "Falha no processo de compra."
  end
end
