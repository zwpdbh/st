# A WorkflowRunner receive events from workflow which is a request to run a workflow with its configuration.
# It represents the handling of a workflow execution.
# A WorkflowRunner currently only handle one workflow request one at a time.
# A WorkflowRunner is 1:1 for a Workflow
# A WorkflowRunner represent a dedicated virtual person who keep observing the execution of a Workflow and decide what to do next if something happended.
# For example, if a workflow is suspended because one of its steps failed, what should be doen. There could be multiple choices for that.
# Anything needed for a workflow execution but not related with that workflow's main purpose should be hanlded here. For example, clean up, etc.
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

  def handle_events([event], _from, state) do
    # Here each event is:
    #  %{args: %{subscription: "region_dev"}, workflow_name: "workflow01"}

    # TODO:: check with resource manager to confirm the resources are available to run a workflow
    {:ok, pid} = ST.Workflow.start_link(event)
    ST.Workflow.execute(pid)
    # TODO:: process execution result here?

    {:noreply, [], state}
  end

  def terminate(reason, state) do
    IO.inspect reason
    IO.inspect state
  end
end
