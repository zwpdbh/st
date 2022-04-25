defmodule ST.WorkflowRunner do
  use GenStage 
  require Logger

  def start_link(_args) do
    initial_state = %{}
    GenStage.start_link(__MODULE__, initial_state)
  end

  def init(initial_state) do
    Logger.info("WorkflowRunner init with initial_state: #{inspect initial_state}")

    sub_opts = [
      {:subscribe_to, [{ST.WorkflowProducer, min_demand: 0, max_demand: 1}]}
    ]
    {:consumer, initial_state, sub_opts}
  end
  
  def handle_events(events, _from, state) do
    # Here each event currently is:
    #  %{args: %{subscription: "region_dev"}, workflow_name: "workflow01"}
    events
    |> Enum.each(fn %{workflow_name: workflow_name, params: params} -> apply(ST.Workflow, String.to_atom(workflow_name), [params]) end)
    {:noreply, [], state}
  end

end
