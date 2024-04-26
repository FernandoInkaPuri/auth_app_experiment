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
          segurado {
            nome
            cpf
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

  def generate_jwt
    @token = JWT.encode({}, ENV["JWT_KEY"], "HS256")
  end
end
