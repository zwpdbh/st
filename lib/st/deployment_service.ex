defmodule ST.DeploymentService do
  alias ST.RestAPI, as: Api
  alias ST.Azure.AzureEnvironment
  alias ST.Azure.Auth

  
  def acquire_access_token() do
    AzureEnvironment.get(:deployment_service)
    |> Auth.request_access_token
  end
  
  def create_workflow(definition_name \\ "K8sDynamicCsiResize") do
    acquire_access_token()
    |> Api.post_workflow(definition_name)
  end

  def list_stopped_workflows(including_terminated \\ false) do
    acquire_access_token()
    |> Api.get_workflows()
    |> Enum.filter(fn x ->
      if including_terminated do
        Map.get(x, "status") === "Suspended" or Map.get(x, "status") === "Terminated"
      else
        Map.get(x, "status") === "Suspended"
      end
    end)
    |> Enum.map(fn x ->
      %{
        id: Map.get(x, "id"),
        status: Map.get(x, "status"),
        definition_name: Map.get(x, "definitionName"),
        created_at: Map.get(x, "createTime")
      }
    end)
  end

  def troubleshooting(including_terminated \\ false) do
    list_stopped_workflows(including_terminated)
    |> Enum.map(fn %{id: id} -> get_workflow_detail(id) end)
    |> Enum.map(fn detail -> ST.Troubleshooting.troubleshooting_detail(detail) end)
  end

  def troubleshooting_failed_ones(ids) when is_list(ids) do
    ids
    |> Enum.map(fn id -> get_workflow_detail(id) end)
    |> Enum.map(fn detail -> ST.Troubleshooting.troubleshooting_detail(detail) end)
  end

  # Workflow.get_workflow_detail("576508bb-9257-4feb-b59b-34a5adfb29fa")
  def get_workflow_detail(workflow_id) do
    acquire_access_token()
    |> Api.get_workflow(workflow_id)
  end

  def is_resource_group_created?(
        %{
          "definitionName" => definition_name,
          "definitionVersion" => definition_version,
          "id" => id,
          "createTime" => created_time
        } = detail
      ) do
    IO.puts(
      "\ncheck rg for #{definition_name}:#{definition_version}, created at: #{created_time}, id: #{id}"
    )

    is_created =
      Poison.decode!(Map.get(detail, "executionPointers"))
      |> Enum.filter(fn x ->
        Map.get(x, "StepName") === "CreateResourceGroupStep" and
          Map.get(x, "Status") === "Complete"
      end)
      |> length > 0

    case is_created do
      true ->
        rg =
          Poison.decode!(Map.get(detail, "data"))
          |> Map.get("DeploymentName")

        {:ok, rg}

      false ->
        {:error, "no resource group available"}
    end
  end

  def terminate_workflow(workflow_id) do
    acquire_access_token()
    Api.request_access_token()
    |> Api.put_workflow_terminate(workflow_id)
  end

  def delete_az_rg(resource_group_name) do
    IO.puts("try to delete Azure resource group: #{resource_group_name}")
    System.shell("az group delete --yes --no-wait --resource-group #{resource_group_name}")
  end

  def clean_one_stopped_workflow_from_id(id) do
    with detail <- get_workflow_detail(id),
         {:ok, rg} <- is_resource_group_created?(detail) do
      case terminate_workflow(id) do
        true -> delete_az_rg(rg)
        _ -> IO.puts("terminate workflow id: #{id} failed")
      end
    else
      _ ->
        IO.puts("no need to clean up #{id}, because it doesn't create resource group yet")
    end
  end

  def clean_stopped_workflows(excluded, including_terminated \\ false) do
    num_processed =
      troubleshooting(including_terminated)
      |> Enum.filter(fn x -> x.matched == true and x.info.level == 3 end)
      |> Enum.map(fn x -> x.id end)
      |> MapSet.new()
      |> MapSet.difference(MapSet.new(excluded))
      |> MapSet.to_list()
      |> Enum.map(fn x ->
        case get_workflow_detail(x) |> is_resource_group_created? do
          {:ok, rg} ->
            case terminate_workflow(x) do
              true -> delete_az_rg(rg)
              _ -> IO.puts("terminate workflow id: #{x} failed")
            end

          _ ->
            IO.puts("no need to clean up #{x}, because it doesn't create resource group yet")
        end
      end)
      |> length

    IO.puts("Process total: #{num_processed}")
  end

  # Workflow.monitor_workflow_execution("K8sDynamicCsiResize")
  # It create and moniotor a workflow's status
  def monitor_workflow_execution(definition_name) do
    case create_workflow(definition_name) do
      {:ok, id} ->
        t1 = DateTime.utc_now()
        IO.puts("#{id} created, begin monitoring")
        check_status_loop(id)

        t2 = DateTime.utc_now()
        IO.puts("Duration: #{DateTime.diff(t2, t1)} seconds")

      {:error} ->
        IO.puts("workflow for #{definition_name} failed.")
    end
  end

  def check_status_loop(id) do
    case get_workflow_detail(id) do
      %{"status" => "Completed"} ->
        IO.puts("#{id} Completed")
        "Completed"

      %{"status" => "Suspended"} ->
        IO.puts("#{id} Suspended")
        "Suspended"

      %{"status" => status} ->
        IO.puts("#{id} is #{status}")

        :timer.sleep(2000)
        check_status_loop(id)
    end
  end

  # use Aurora_05_05.txt as example
  def get_workflows_from_aurora_log(filename) do
    path = "d:/code/elixir-programming/st/../../work-notes-for-ms/Storage_AKS_log/"
    file_full_name = Path.join([path, filename])

    case File.read(file_full_name) do
      {:ok, content} ->
        IO.puts("related workflows are:")

        content
        |> String.split("\n")
        |> Enum.map(fn x ->
          Regex.named_captures(
            ~r/.*(?<workflow_id>[0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12}).*/,
            x
          )
        end)
        |> Enum.filter(fn x ->
          case x do
            %{"workflow_id" => _} -> true
            _ -> false
          end
        end)
        |> Enum.reduce(MapSet.new(), fn %{"workflow_id" => x}, acc ->
          case MapSet.member?(acc, x) do
            true -> acc
            false -> MapSet.put(acc, x)
          end
        end)
        |> MapSet.to_list()

      {:error, reason} ->
        IO.puts(reason)
        []
    end
  end

  # ST.DeploymentService.clean_workflows_from_aurora_log("Aurora_05_08.txt")
  # Where Storage_AKS_log/Aurora_05_08.txt is from d:/code/work-notes-for-ms/
  def clean_workflows_from_aurora_log(filename) do
    get_workflows_from_aurora_log(filename)
    |> Enum.with_index
    |> Enum.each( fn {id, i} ->
      spawn(fn ->
        Process.sleep(i * 1000)
        clean_one_stopped_workflow_from_id(id)
      end)
    end)
  end
end

# currently we need to filter out: dde9d68c-ac3e-4605-a6a1-c341857efbb8
# Workflow.clean_stopped_workflows(["dde9d68c-ac3e-4605-a6a1-c341857efbb8"])
