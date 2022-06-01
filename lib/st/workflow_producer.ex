# This module is used to produce workflow configurations which is received by workflow_runner.
# workflow producer receives request to execute some workflow, and it generate workflow settings and pass them to workflow_runner.
# workflow_producer <--> workflow_runner use GenStage to handle back presures because workflow_runner may not be able to execute a workflow fast enough.
# A dialog may like this:
# A WorkflowProducer is like some project manager, it has multiple workers(WorkflowRunner), and each Worker only does one job at a time (run a workflow).
# The producer send worker some A-job to run.
# A worker check if something is available for running such job, if not it wait or report to producer what it needs.
# A worker monitor the job's running status and ask for next one if job is finished.
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
    GenStage.cast(__MODULE__, {:workflows, workflows})
  end

  def handle_cast({:workflows, workflows}, state) do
    {:noreply, workflows, state}
  end

  # ST.WorkflowProducer.demo
  def demo do
    workflows = [
      %{workflow_name: "workflow01", subscription: "sub_01"},
      %{workflow_name: "workflow02", subscription: "sub_02"}, 
    ]

    execute_workflows(workflows)
  end
end
