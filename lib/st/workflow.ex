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
    GenServer.call(pid, :execute)
  end

  def handle_call(:execute, _from, %{workflow_name: workflow_name} = workflow_instance) do
    result =
      with %{status: "ok"} <- apply(ST.Workflow, String.to_atom(workflow_name), workflow_instance) do
        Logger.info("workflow #{workflow_name} finished")
      else
        ex ->
          Logger.error("workflow #{workflow_name} failed: #{IO.inspect(ex)}")
      end

    {:reply, result, workflow_instance}
  end

  def terminate(_reason, workflow_instance) do
    Logger.error("workflow failed, #{IO.inspect workflow_instance}")
  end

  def handle_info({:update_steps, step_name}, %{execution_steps: steps} = workflow_instance) do
    {:noreply, Map.replace(workflow_instance, :execution_steps, [step_name | steps])}
  end

  def step01(params) do
    Logger.info("start step01 with params: #{inspect(params)}")

    Process.send_after(self(), {:update_steps, "step01"}, 0)
    case work() do
      true ->
        Logger.info("finished step01")
        params
      _ ->
        Logger.info("failed step01")
        Map.replace!(params, :status, "failed")
    end
  end

  def step02( params) do
    Logger.info("start step02 with params: #{inspect(params)}")
    Process.send_after(self(), {:update_steps, "step02"}, 0)

    case work() do
      true ->
        Logger.info("finished step02")
        params
      _ ->
        Logger.info("failed step02")
        Map.replace!(params, :status, "failed")
    end
  end

  def step03(params) do
    Logger.info("start step03 with params: #{inspect(params)}")
    Process.send_after(self(), {:update_steps, "step03"}, 0)    

    case work() do
      true ->
        Logger.info("finished step03")
        params
      _ ->
        Logger.info("failed step03")
        Map.replace!(params, :status, "failed")
    end
  end

  def step04(params) do
    Logger.info("start step04 with params: #{inspect(params)}")

    Process.send_after(self(), {:update_steps, "step04"}, 0)    

    case work() do
      true ->
        Logger.info("finished step04")
        params
      _ ->
        Logger.info("failed step04")
        Map.replace!(params, :status, "failed")
    end
  end

  def step05(params) do
    Logger.info("start step05 with params: #{inspect(params)}")
    Process.send_after(self(), {:update_steps, "step05"}, 0)    

    case work() do
      true ->
        Logger.info("finished step05")
        params
      _ ->
        Logger.info("failed step05")
        Map.replace!(params, :status, "failed")
    end
  end

  def workflow01(params) do
    params
    |> step01
    |> step02
    |> step03
  end

  def workflow02(params) do
    params
    |> step02
    |> step03
    |> step04
  end

  def workflow03(params) do
    params
    |> step01
    |> step02
    |> step03
    |> step04
    |> step05
  end

  def work() do
    1..5
    |> Enum.random()
    |> :timer.seconds()
    |> Process.sleep()

    Enum.random([false, true, true, true, true, true, true])
  end
end
