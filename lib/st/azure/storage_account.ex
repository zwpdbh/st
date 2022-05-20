defmodule ST.Azure.StorageAccount do
  alias ST.RestClient
  
  def list_storage_accounts(%{"token" => token, }) do
    url =
      "https://management.azure.com/subscriptions/33922553-c28a-4d50-ac93-a5c682692168/providers/Microsoft.Storage/storageAccounts?api-version=2021-09-01"

    headers = RestClient.init_headers()
    |> RestClient.set_auth_bearer_token(token)
    
    headers = [
      {"Content-type", "application/json"},
      {"Authorization", "Bearer #{token}"},
      {"accept", "text/plain"}
    ]

    HTTPoison.get(url, headers)
  end
end
