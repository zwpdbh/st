# A Workflow is a GenServer Process its state includes
# 1) a seriece of workflow steps
# 2) currently which step is running its state (waiting, running, failed or succeed)
# A Workflow is 1:1 mapping for a WorkflowRunner.
# While a WorkflowRunner represent a single person whose job is to run a workflow one at a time, a Workflow represent the object of such a job.
# A persion run a Worflow by running some steps and observing the result and run next other steps.
defmodule ST.Workflow do
  use GenServer
  require Logger

  def start_link(workflow_instance) do
    GenServer.start_link(__MODULE__, workflow_instance)
  end

  def init(%{workflow_name: workflow_name} = workflow_instance) do
    workflow_steps =  workflow_name
    |> ST.WorkflowDefinition.parse
    |> Enum.with_index
    |> Enum.map(fn {step_name, index} -> %{step_name => "todo", "index" => index}  end)
    
    updated_workflow_instance =
      workflow_instance
      |> Map.put_new(:execution_steps, workflow_steps)

    {:ok, updated_workflow_instance}
  end

  # interface function for user to call
  def execute(pid) do
    GenServer.call(pid, :execute)
  end

  def handle_call(:execute, _from, workflow_instance) do
    {:reply, workflow_instance, "updated_workflow_instance"}
  end

  def terminate(_reason, workflow_instance) do
    IO.inspect(workflow_instance)
  end


  
  # The reason this doens't work is because the GenServer's state is only got udpated between GenServer's callbacks.
  # So, when the execute workflow is executed, its state will not be modified for GenServer.
  # def handle_info({:update_steps, step_name}, %{execution_steps: steps} = workflow_instance) do
  #   Logger.info("update_step: #{step_name}")
  #   workflow_instance = Map.replace(workflow_instance, :execution_steps, [step_name | steps])
  #   Logger.info("updated_steps: #{Map.fetch!(workflow_instance, :execution_steps)}")
    
  #   {:noreply, workflow_instance}
  # end
end
