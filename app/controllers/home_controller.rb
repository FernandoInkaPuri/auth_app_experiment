require 'net/http'
class HomeController < ApplicationController
  before_action :authenticate_user!, :generate_jwt

  def index
    uri = URI('http://graphql_api:3001/graphql')
    body = {
      query: "query {
        policies {
          policyId
          dataEmissao
          status
          segurado {
            nome
            cpf
          }
          charge {
            paymentId
            paymentLink
          }
        }
      }"
    }
    headers = {
      'Content-Type' => 'application/json',
      "Authorization" => "Bearer #{@token}"
    }

    begin
      response = Net::HTTP.post(uri, body.to_json, headers)
      if response.code == "200"
        policies_hash = JSON.parse(response.body)

        # binding.pry

        @policies = policies_hash["data"]["policies"]
        @request_completed = true
      else
        raise "#{response.message}"
      end
    rescue StandardError => error
      @error_message = "Ocorreu um erro e não foi possível fazer a consulta das apólices. Erro: #{error.message}"
      Rails.logger.warn(@error_message)
    end
  end

  def new
  end

  def create
    uri = URI('http://graphql_api:3001/graphql')
    payment_session = create_payment_checkout
    body = {
      query: "mutation {
        createPolicy(
          input: {
            policy: {
              dataEmissao: \"#{params[:data_emissao]}\",
              dataFimCobertura: \"#{params[:data_fim_cobertura]}\",
              segurado: {
                nome: \"#{params[:nome_segurado]}\",
                cpf: \"#{params[:cpf_segurado]}\",
                },
              veiculo: {
                placa: \"#{params[:placa_veiculo]}\",
                marca: \"#{params[:marca_viculo]}\",
                modelo: \"#{params[:modelo_veiculo]}\",
                ano: #{params[:ano_veiculo]}
              },
              charge: {
                paymentId: \"#{payment_session.id}\",
                paymentLink: \"#{payment_session.url}\",
              },
            }
          }
        )
        {
          result
        }
      }"
    }
    headers = {
      'Content-Type' => 'application/json',
      "Authorization" => "Bearer #{@token}"
    }

    response = Net::HTTP.post(uri, body.to_json, headers)
    Rails.logger.info(response)
    begin
      if response.code == "200"
        flash[:notice] = "Apólice Cadastrada com Sucesso!"
        redirect_to root_path
      else
        raise "#{response.message}"
      end
    rescue StandardError => error
      @error_message = "Erro: #{error.message}"
      Rails.logger.warn(@error_message)
    end
  end

  private

  def generate_jwt
    @token = JWT.encode({}, ENV["JWT_KEY"], "HS256")
  end

  def create_payment_checkout
    Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        price: 'price_1PFyrsInqposUGo2WwETKIZg',
        quantity: 1,
      }],
      mode: 'payment',
      success_url:  success_charges_url,
      cancel_url: cancel_charges_url
    )
  end
end
