defmodule ST.Handbook do
  def get_deployment_service_known_issues do
    [
      %{
        message: "exceeding approved standardDSv4Family Cores quota",
        step_name: "DeployKubernetesWindowsVmssClusterStep",
        level: 3
      },
      %{
        step_name: "DeployKubernetesVmssClusterStep",
        level: 3,
        message: "Input string was not in a correct format",
        contact: "zhaowei@microsoft.com"
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
  end
end
