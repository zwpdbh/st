defmodule ST.Troubleshooting do
  use GenServer
  @me __MODULE__
  def start_link(_args) do
    known_issues = ST.Handbook.get_deployment_service_known_issues()

    GenServer.start_link(
      __MODULE__,
      known_issues,
      name: @me
    )
  end

  def init(known_issues) do
    {:ok, known_issues}
  end

  def troubleshooting_detail(
        %{
          "id" => id,
          "executionPointers" => executionPointers,
          "definitionName" => definition_name,
          "reference" => %{"exceptionMessages" => messages}
        } = _
      ) do
    %{"StepName" => step_name} =
      Poison.decode!(executionPointers)
      |> List.last()

    GenServer.call(
      @me,
      {:troubleshooting,
       %{id: id, definition_name: definition_name, step_name: step_name, messages: messages}}
    )
  end

  # known_message is the message from handbook.ex
  def is_messages_matched(known_message, [head | tail]) do
    case String.contains?(head, known_message) do
      false -> is_messages_matched(known_message, tail)
      true -> known_message
    end
  end

  def is_messages_matched(_, []) do
    "unknown_error"
  end

  def handle_call(
        {:troubleshooting,
         %{id: id, definition_name: definition_name, step_name: step_name, messages: messages}},
        _from,
        known_issues
      ) do
    # 1. From handbook find all the records associated with a step, there could be multiple such records
    # 2. Use each record's message to find out if it exists in the messages (from workflow instance)
    # 3. At last, there should be only one record (given step_name and known_message)
    with matched_ones <-
           known_issues
           |> Enum.filter(fn %{step_name: known_step_name} -> known_step_name == step_name end)
           |> Enum.filter(fn %{message: known_message} ->
             is_messages_matched(known_message, messages) != "unknown_error"
           end),
         true <- length(matched_ones) >= 1 do
      {:reply,
       %{id: id, definition_name: definition_name, info: List.first(matched_ones), matched: true},
       known_issues}
    else
      ex ->
        {:reply, %{id: id, definition_name: definition_name, info: ex, matched: false},
         known_issues}
    end
  end
end

# How to kill it:
# Process.exit(Process.whereis(ST.Troubleshooting), :kill)
# Process.whereis(ST.Troubleshooting) is used to get the pid from a registered process by its name
