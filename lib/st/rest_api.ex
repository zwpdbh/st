defmodule ST.RestAPI do
  # This value is from the client secret's value
  # Client refers the application registered from Azure Active Directory --> Enterprise applications (zwpdbh)
  # That tenant is checked from: Tenant properties -- Tenant ID across multiple subscriptions
  @secret "2y~8Q~blSah_XVUIGOzQ9IAzpyCZ1PicJCiBtbUc" 
  @client_id "2470ca86-3843-4aa2-95b8-97d3a912ff69"
  @tenant "72f988bf-86f1-41af-91ab-2d7cd011db47"
  @scope "https://microsoft.onmicrosoft.com/3b4ae08b-9919-4749-bb5b-7ed4ef15964d/.default"
  @api_endpoint "https://xscndeploymentservice.westus2.cloudapp.azure.com/api"

  @moduledoc """
  A HTTP client for doing RESTful action for DeploymentService.
  """
  def request_access_token() do
    url = "https://login.microsoftonline.com/#{@tenant}/oauth2/v2.0/token"

    case HTTPoison.post(url, urlencoded_body(), header()) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
        |> Poison.decode()
        |> fetch_access_token

      # |> IO.puts

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts("Not found :(")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason)
    end
  end

  def request_access_token_for_subscription() do
    request_access_token("/subscriptions/33922553-c28a-4d50-ac93-a5c682692168/.default")
  end
  
  def request_access_token(scope) do
    url = "https://login.microsoftonline.com/#{@tenant}/oauth2/v2.0/token"

    case HTTPoison.post(url, urlencoded_body(scope), header()) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
        |> Poison.decode()
        |> fetch_access_token

      # |> IO.puts

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts("Not found :(")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason)
    end
  end

  def post_workflow(token, definition_name) do
    url = "#{@api_endpoint}/Workflow?definitionName=#{definition_name}"

    case HTTPoison.post(
           url,
           json_body(),
           [
             {"Content-type", "application/json"},
             {"Authorization", "Bearer #{token}"},
             {"accept", "text/plain"}
           ]
        ) do
      {:ok, %HTTPoison.Response{body: id}} -> {:ok, id}
      {:ok, %HTTPoison.Response{status_code: 404}} -> 
        IO.puts("Not found :(")
        {:error}  
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason)
        {:error}  
    end
  end

  def monitor_workflow_status(workflow_id) do
    url = "#{@api_endpoint}/Workflow/#{workflow_id}"
    HTTPoison.get(url)
  end

  def get_workflows(token) do
    url = "#{@api_endpoint}/Workflow"

    headers = [
      {"Content-type", "application/json"},
      {"Authorization", "Bearer #{token}"},
      {"accept", "text/plain"}
    ]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Poison.decode!(body)

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts("Not found :(")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason)
    end
  end

  def get_resource_groups(token) do
    url = "https://management.azure.com/subscriptions/33922553-c28a-4d50-ac93-a5c682692168/resourcegroups?api-version=2021-04-01"

    headers = [
      {"Content-type", "application/json"},
      {"Authorization", "Bearer #{token}"},
      {"accept", "text/plain"}
    ]

    HTTPoison.get(url, headers)
  end

  def list_storage_accounts(token) do
    url = "https://management.azure.com/subscriptions/33922553-c28a-4d50-ac93-a5c682692168/providers/Microsoft.Storage/storageAccounts?api-version=2021-09-01"

    headers = [
      {"Content-type", "application/json"},
      {"Authorization", "Bearer #{token}"},
      {"accept", "text/plain"}
    ]

    HTTPoison.get(url, headers)
    
  end

  def get_workflow(token, workflow_id) do
    url = "#{@api_endpoint}/Workflow/#{workflow_id}"

    headers = [
      {"Content-type", "application/json"},
      {"Authorization", "Bearer #{token}"},
      {"accept", "text/plain"}
    ]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Poison.decode!(body)

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts("Not found :(")

      {:ok, %HTTPoison.Response{status_code: 302}, body: body} ->
        IO.inspect body

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason)

      ex ->
        IO.puts "error when get workflow from workflow_id: #{workflow_id}"
        IO>inspect ex
    end
  end

  def put_workflow_terminate(token, workflow_id) do
    url = "#{@api_endpoint}/Workflow/#{workflow_id}/terminate"

    headers = [
      {"Content-type", "application/json"},
      {"Authorization", "Bearer #{token}"},
      {"accept", "text/plain"}
    ]

    case HTTPoison.put(url, "", headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Poison.decode!(body)

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts("Not found :(")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason)
    end
  end

  defp fetch_access_token({:ok, %{"access_token" => access_token}}) do
    access_token
  end

  def header() do
    [{"Content-type", "application/x-www-form-urlencoded"}]
  end

  def urlencoded_body() do
    %{
      "client_id" => @client_id,
      "client_secret" => @secret,
      "scope" => @scope,
      "grant_type" => "client_credentials"
    }
    |> URI.encode_query()
  end

  def urlencoded_body(scope) do
    %{
      "client_id" => @client_id,
      "client_secret" => @secret,
      "scope" => scope,
      "grant_type" => "client_credentials"
    }
    |> URI.encode_query()
  end

  def json_body() do
    %{
      SubscriptionId: "33922553-c28a-4d50-ac93-a5c682692168",
      DeploymentLocation: "East US 2 EUAP",
      Counter: "1",
      AzureDiskStorageClassAsk: "Random",
      AzureDiskPvcSize: "13"
    }
    |> Poison.encode!()
  end  
end
