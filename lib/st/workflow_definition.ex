# This module is responsible to build workflow from existing workflow_steps
defmodule ST.WorkflowDefinition do
  use GenServer
  @me __MODULE__
  
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: @me)
  end

  def init(_args) do
    # Load definition from DB in future
    definitions = %{
      "workflow01" => ["step01", "step02", "step03"],
      "workflow02" => ["step02", "step03", "step04"],
      "workflow03" => ["step01", "step02", "step03", "step04", "step05"]
    }
    {:ok, definitions}
  end

  def parse(input) when is_binary(input) do
    # TODO:: how to parse ??
  end
end
