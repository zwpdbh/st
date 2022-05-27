# This module is responsible to build workflow from existing workflow_steps
# It should parse user input and produce valid workflow steps and their sequence to be run inside a workflow.
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

  # From user input workflow definitions to get actual steps which are needed to be executed.
  def parse(input) when is_binary(input) do
    GenServer.call(@me, {:workflow_definition, input})
  end

  # TODO parse it properly
  def handle_call({:workflow_definition, workflow_name}, _from , state) do
    {:reply, Map.get(state, workflow_name)}
  end
  
end
