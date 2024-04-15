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

    response = Net::HTTP.post(uri, body.to_json, headers)
    @policies = JSON.parse(response.body)
  end
end
