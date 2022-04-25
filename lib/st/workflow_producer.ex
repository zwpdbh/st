defmodule ST.WorkflowProducer do
  use GenStage
  
  require Logger

  def start_link(_args) do
    initial_state = []
    GenStage.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def init(initial_state) do
    Logger.info("WorkflowProducer init")
    {:producer, initial_state}
  end

  def handle_demand(demand, state) do
    Logger.info("Receive demand for #{inspect demand} workflows with state: #{inspect state}")
    events = []
    {:noreply, events, state}
  end

  def execute_workflows(workflows) when is_list(workflows) do
    workflows = workflows |> Enum.map(fn each ->
      Map.update!(
        each,
        :params,
        fn params -> Map.put_new(params, :id, UUID.uuid4()) end)
    end)
    
    GenStage.cast(__MODULE__, {:workflows, workflows})
  end

  def handle_cast({:workflows, workflows}, state) do
    {:noreply, workflows, state}
  end

  # ST.WorkflowProducer.test
  def test do
    workflows = [
      %{workflow_name: "workflow01", params: %{subscription: "region_dev"}},
      %{workflow_name: "workflow02", params: %{subscription: "region_prod"}},
      %{workflow_name: "workflow03", params: %{subscription: "region_dev"}},
      %{workflow_name: "workflow04", params: %{subscription: "region_prod"}},
      %{workflow_name: "workflow05", params: %{subscription: "region_dev"}},
      %{workflow_name: "workflow06", params: %{subscription: "region_prod"}},
      %{workflow_name: "workflow07", params: %{subscription: "region_dev"}}      
    ]

    execute_workflows(workflows)
  end
end
