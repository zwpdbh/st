defmodule ST.RestClient do
  require Logger

  def handle_post_request(url, body, headers) when is_map(headers) do
    case HTTPoison.post(url, body, Enum.to_list(headers)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Poison.decode(body)

      {:ok, %HTTPoison.Response{status_code: _} = response} ->
        response

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        %{code: 404}

      {:error, %HTTPoison.Error{reason: reason}} ->
        %{error: reason}
    end
  end

  def handle_put_request(url, body, headers) when is_map(headers) do
    case HTTPoison.put(url, body, Enum.to_list(headers)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Poison.decode(body)

      {:ok, %HTTPoison.Response{status_code: _} = response} ->
        response

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        %{code: 404}

      {:error, %HTTPoison.Error{reason: reason}} ->
        %{error: reason}
    end
  end

  def handle_get_request(url, headers) when is_map(headers) do
    case HTTPoison.get(url, Enum.to_list(headers)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Poison.decode(body)

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        %{code: 404}

      {:error, %HTTPoison.Error{reason: reason}} ->
        %{error: reason}
    end
  end

  def set_auth_bearer_token(header_map, token) do
    header_map
    |> Map.put_new("Authorization", "Bearer #{token}")
  end

  def init_headers() do
    %{}
    |> Map.put_new("Content-type", "application/json")
    |> Map.put_new("accept", "text/plain")
  end
end
