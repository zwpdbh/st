# This module is responsible to build workflow from existing workflow_steps
# It should parse user input and produce valid workflow steps and their sequence to be run inside a workflow.
defmodule ST.WorkflowDefinition do
  # From user input workflow definitions to get actual steps which are needed to be executed.
  def parse(input) when is_binary(input) do
    %{
      "workflow01" => ["step01", "step02", "step03"],
      "workflow02" => ["step02", "step03", "step04"],
      "workflow03" => ["step01", "step02", "step03", "step04", "step05"]
    }
    |> Map.get(input)
  end

end
