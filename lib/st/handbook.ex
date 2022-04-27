defmodule ST.Handbook do
  def get_deployment_service_known_issues do
    [
      %{
        step_name: "DeployKubernetesWindowsVmssClusterStep",
        message: "exceeding approved standardDSv4Family Cores quota",
        level: 3
      },
      %{
        step_name: "DeployKubernetesWindowsVmssClusterStep",
        message: "Input string was not in a correct format",
        level: 3
      },
      %{
        step_name: "DeployKubernetesWindowsVmssClusterStep",
        message: "Invalid input string",
        level: 3
      },
      %{
        step_name: "DeployKubernetesWindowsVmssClusterStep",
        message: "Operation is not allowed: Another operation (Creating) is in progress",
        level: 3
      },            
      %{
        step_name: "DeployKubernetesVmssClusterStep",
        message: "Input string was not in a correct format",
        level: 3,
        contact: "zhaowei@microsoft.com"
      },
      %{
        step_name: "ValidatePodStatusStep",
        message: "status Pending is not expected",
        level: 2
      },
      %{
        step_name: "AssignKubernetesMsiPermissionStep",
        message: "The fabric operation failed",
        level: 3
      }
    ]
  end
end
