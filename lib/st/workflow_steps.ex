defmodule ST.WorkflowSteps do
  require Logger
  
  def step01(params)) do
    Logger.info("start step01 with params: #{inspect(params)}")                      
    case work() do
      true ->
        # Logger.info("finished step01")
        params

      _ ->
        # Logger.info("failed step01")
        Map.replace!(params, :status, "failed")
    end
  end

  def step02(params) do
    Logger.info("start step02 with params: #{inspect(params)}")

    case work() do
      true ->
        # Logger.info("finished step02")
        params

      _ ->
        # Logger.info("failed step02")
        Map.replace!(params, :status, "failed")
    end
  end

  def step03(params) do
    Logger.info("start step03 with params: #{inspect(params)}")

    case work() do
      true ->
        # Logger.info("finished step03")
        params

      _ ->
        # Logger.info("failed step03")
        Map.replace!(params, :status, "failed")
    end
  end

  def step04(params) do
    Logger.info("start step04 with params: #{inspect(params)}")

    case work() do
      true ->
        # Logger.info("finished step04")
        params

      _ ->
        # Logger.info("failed step04")
        Map.replace!(params, :status, "failed")
    end
  end

  def step05(%{workflow_pid: pid} = params) do
    Logger.info("start step05 with params: #{inspect(params)}")
    case work() do
      true ->
        # Logger.info("finished step05")
        params

      _ ->
        # Logger.info("failed step05")
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
