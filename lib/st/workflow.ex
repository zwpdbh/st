# This module contains pure functions which do some operations
defmodule ST.Workflow do
  require Logger 
  def workflow01(params) do
    Logger.info("start workflow01 with params: #{inspect params}")
    work()
    Logger.info("finished workflow01")
  end


  def workflow02(params) do
    Logger.info("start workflow02 with params: #{inspect params}")
    work()
    Logger.info("finished workflow02")
  end

  def workflow03(params) do
    Logger.info("start workflow03 with params: #{inspect params}")
    work()
    Logger.info("finished workflow03")
  end

  def workflow04(params) do
    Logger.info("start workflow04 with params: #{inspect params}")
    work()
    Logger.info("finished workflow04")
  end

  def workflow05(params) do
    Logger.info("start workflow05 with params: #{inspect params}")
    work()
    Logger.info("finished workflow05")
  end

  def workflow06(params) do
    Logger.info("start workflow06 with params: #{inspect params}")
    work()
    Logger.info("finished workflow06")
  end

  def workflow07(params) do
    Logger.info("start workflow07 with params: #{inspect params}")
    work()
    Logger.info("finished workflow07")
  end    

  def work() do
    1..5
    |> Enum.random()
    |> :timer.seconds
    |> Process.sleep()
  end
end
