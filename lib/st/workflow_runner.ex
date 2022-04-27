# WorkflowRunner module is used to
# Prepare workfow instance to run from workflow definition/name from client
# It handle a prepared workflow instance including its dependent resources/settings to run it.
# The actually running is using WorkflowModule which is GenServer
defmodule ST.WorkflowRunner do
  use GenStage
  require Logger

  def start_link(_args) do
    initial_state = %{}
    GenStage.start_link(__MODULE__, initial_state)
  end

  def init(initial_state) do
    Logger.info("WorkflowRunner init with initial_state: #{inspect(initial_state)}")

    sub_opts = [
      {:subscribe_to, [{ST.WorkflowProducer, min_demand: 0, max_demand: 1}]}
    ]

    {:consumer, initial_state, sub_opts}
  end

  def handle_events([%{workflow_name: workflow_name, params: params}], _from, state) do
    # Here each event currently is:
    #  %{args: %{subscription: "region_dev"}, workflow_name: "workflow01"}

    # TODO:: check with resource manager to confirm the resources are available to run a workflow
    params =
      params
      |> Map.put_new(:execution_steps, [])
      |> Map.put_new(:status, "ok")

    with %{status: "ok"} <- apply(ST.Workflow, String.to_atom(workflow_name), [params]) do
      Logger.info("workflow #{workflow_name} finished")
    else
      ex -> 
      Logger.error("workflow #{workflow_name} failed: #{IO.inspect ex}")
    end

    {:noreply, [], state}
  end
end
