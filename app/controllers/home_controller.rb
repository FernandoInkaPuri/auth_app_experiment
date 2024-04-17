require 'net/http'
class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    uri = URI('http://graphql_api:3001/graphql')
    body = {
      query: "query {
        policies {
          dataEmissao
          segurado {
            nome
            cpf
          }
        }
      }"
    }
    headers = { 'Content-Type' => 'application/json' }

    begin
      response = Net::HTTP.post(uri, body.to_json, headers)
      @policies = JSON.parse(response.body)
    rescue StandardError => error
      @error_message = "Ocorreu um erro e não foi possível fazer a consulta das apólices. Erro: #{error}"
      Rails.logger.warn(@message)
    else
      @request_completed = true
    end
  end
end
