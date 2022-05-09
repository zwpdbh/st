defmodule ST.RestClient do
  require Logger
  
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

    with {:ok, %{"access_token" => access_token}} <- handle_post_request(url, body, headers) do
      access_token
    else
      ex -> Logger.info(ex)
    end
  end

  def handle_post_request(url, body, headers) do
    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
        |> Poison.decode()
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        %{code: 404}

      {:error, %HTTPoison.Error{reason: reason}} ->
        %{error: reason}
    end    
  end
end
