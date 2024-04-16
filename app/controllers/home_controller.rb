require 'net/http'
class HomeController < ApplicationController
  before_action :authenticate_user!

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
    headers = { 'Content-Type' => 'application/json' }

    response = Net::HTTP.post(uri, body.to_json, headers)
    policies_hash = JSON.parse(response.body)

    @policies = policies_hash["data"]["policies"]
  end
end
