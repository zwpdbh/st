defmodule ST.RestClient do
  require Logger 

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
