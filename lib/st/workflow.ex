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

  def execute(pid) do
    GenServer.cast(pid, :execute)
  end

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

  def handle_info({:update_steps, step_name}, %{execution_steps: steps} = workflow_instance) do
    {:noreply, Map.replace(workflow_instance, :execution_steps, [step_name | steps])}
  end
end
