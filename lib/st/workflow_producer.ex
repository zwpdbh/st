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
    Logger.info("Receive demand for #{inspect(demand)} workflows with state: #{inspect(state)}")
    events = []
    {:noreply, events, state}
  end

  def execute_workflows(workflows) when is_list(workflows) do
    workflows =
      workflows
      |> Enum.map(fn each ->
        Map.put_new(each, :id, UUID.uuid4())
    end)

    GenStage.cast(__MODULE__, {:workflows, workflows})
  end

  def handle_cast({:workflows, workflows}, state) do
    {:noreply, workflows, state}
  end

  # ST.WorkflowProducer.demo
  def demo do
    workflows = [
      %{workflow_name: "workflow01", subscription: "region_dev"},
      # %{workflow_name: "workflow02", params: %{subscription: "region_prod"}},
      # %{workflow_name: "workflow03", params: %{subscription: "region_dev"}},
      # %{workflow_name: "workflow01", params: %{subscription: "region_prod"}},
      # %{workflow_name: "workflow02", params: %{subscription: "region_dev"}},
      # %{workflow_name: "workflow03", params: %{subscription: "region_prod"}}
    ]

    execute_workflows(workflows)
  end
end
