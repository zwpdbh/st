defmodule ST.Azure.Auth do
  alias ST.RestClient
  def request_access_token(%{
        tenant_id: tenant_id,
        client_id: client_id,
        scope: scope,
        client_secret: client_secret
      }) do
    url = "https://login.microsoftonline.com/#{tenant_id}/oauth2/v2.0/token"

    body =
      %{}
      |> Map.put_new("client_id", client_id)
      |> Map.put_new("client_secret", client_secret)
      |> Map.put_new("scope", scope)
      |> Map.put_new("grant_type", "client_credentials")
      |> URI.encode_query()

    headers = %{}
    |> Map.put_new("Content-type", "application/x-www-form-urlencoded")
    |> Enum.into([])

    with {:ok, %{"access_token" => access_token}} <- RestClient.handle_post_request(url, body, headers) do
      access_token
    else
      ex -> Logger.info(ex)
    end
  end
end
