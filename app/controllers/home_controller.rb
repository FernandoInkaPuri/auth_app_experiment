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

  def new
  end

  def create
    uri = URI('http://graphql_api:3001/graphql')
    body = {
      query: "mutation
        createPolicy(
          input: {
            policy: {
              dataEmissao: \"#{params[:data_emissao]}\",  dataFimCobertura: \"#{params[:data_fim_cobertura]}\",
              segurado: {
                nome: \"#{params[:nome_segurado]}\",
                cpf: \"#{params[:cpf_segurado]}\",
                },
              veiculo: {
                placa: \"#{params[:placa_cobertura]}\",
                marca: \"#{params[:marca_cobertura]}\",
                modelo: \"#{params[:modelo_cobertura]}\",
                ano: #{params[:ano_cobertura]}
              }
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


    binding.pry

    response = Net::HTTP.post(uri, body.to_json, headers)
    Rails.logger.info(response)
    begin
      if response.code == "200"
        flash[:notice] = "Apólice Cadastrada com Sucesso!"
        render :index
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
end
