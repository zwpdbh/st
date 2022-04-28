# This module contains pure functions which do some operations
defmodule ST.Workflow do
  use GenServer
  require Logger

  def start_link(workflow_instance) do
    GenServer.start_link(__MODULE__, workflow_instance)
  end

  def init(workflow_instance) do
    workflow_instance =
      workflow_instance
      |> Map.put_new(:execution_steps, [])
      |> Map.put_new(:status, "ok")

    {:ok, workflow_instance}
  end

  # interface function for user to call
  def execute(pid) do
    GenServer.cast(pid, :execute)
  end

  # start to execute a workflow which equals: workflow_definition + params(including context)
  def handle_cast(:execute, %{workflow_name: workflow_name} = workflow_instance) do
    with %{status: "ok"} <-
           apply(
             ST.WorkflowImpl,
             String.to_atom(workflow_name),
             [Map.put_new(workflow_instance, :workflow_pid, self())]
           ) do
      Logger.info("workflow #{workflow_name} finished")
    else
      ex ->
        Logger.error("workflow #{workflow_name} failed")
        IO.inspect(ex)
    end

    {:noreply, workflow_instance}
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
