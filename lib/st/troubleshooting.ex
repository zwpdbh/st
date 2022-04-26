defmodule ST.Troubleshooting do
  use GenServer
  @me __MODULE__
  def start_link(_args) do
    known_issues = [
      %{
        message: "exceeding approved standardDSv4Family Cores quota",
        step_name: "DeployKubernetesWindowsVmssClusterStep",
        level: 3
      },
      %{
        step_name: "DeployKubernetesVmssClusterStep",
        level: 3,
        message: "Input string was not in a correct format"
      },
      %{
        message: "exceeding approved standardDSv4Family Cores quota",
        step_name: "some step",
        level: 2
      },
      %{
        message: "Invalid input string",
        step_name: "DeployKubernetesWindowsVmssClusterStep",
        level: 1
      }
    ]

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
          "reference" => %{"exceptionMessages" => messages}
        } = _
      ) do
    %{"StepName" => step_name} =
      Poison.decode!(executionPointers)
      |> List.last()

    GenServer.call(@me, {:troubleshooting, %{id: id, step_name: step_name, messages: messages}})
  end

  def is_messages_matched(known_message, [head | tail]) do
    case String.contains?(head, known_message) do
      false -> is_messages_matched(known_message, tail)
      true -> {true, known_message}
    end
  end

  def is_messages_matched(_, []) do
    {false, ""}
  end

  def handle_call(
        {:troubleshooting, %{id: id, step_name: step_name, messages: messages}},
        _from,
        known_issues
      ) do
    with matched_issues <-
           known_issues
           |> Enum.filter(fn %{step_name: known_step_name} -> known_step_name == step_name end),
         true <- length(matched_issues) > 0,
         matched_ones <-
           matched_issues
           |> Enum.filter(fn %{message: known_message} ->
             {is_matched, _} = is_messages_matched(known_message, messages)
             is_matched
           end),
         true <- length(matched_ones) == 1 do
      {:reply, %{id: id, metched_issue: List.first(matched_ones)}, known_issues}
    else
      ex ->
        {:reply, %{id: id, no_matched: ex}, known_issues}
    end
  end
end
