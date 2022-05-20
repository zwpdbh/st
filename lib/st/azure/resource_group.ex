defmodule ST.Azure.ResourceGroup do
  def list_resource_groups_from_subscription(token, subscription_id) do
    url = "https://management.azure.com/subscriptions/#{subscription_id}/resourcegroups?api-version=2021-04-01"

    headers = [
      {"Content-type", "application/json"},
      {"Authorization", "Bearer #{token}"},
      {"accept", "text/plain"}
    ]

    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.get(url, headers)
    body
  end

  
end
