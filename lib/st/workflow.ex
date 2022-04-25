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

  def work() do
    1..5
    |> Enum.random()
    |> :timer.seconds
    |> Process.sleep()
  end
end
