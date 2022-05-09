defmodule ST.Azure.AzureEnvironment do

  def get(:deployment_service) do
    deployment_service_sp()
  end

  def get(:zwpdbh) do
    zwpdbh_sp()
  end

  defp zwpdbh_sp do
    %{
      tenant_id: "72f988bf-86f1-41af-91ab-2d7cd011db47",
      client_id: "2470ca86-3843-4aa2-95b8-97d3a912ff69",
      scope: "https://management.azure.com/.default",
      client_secret: "2y~8Q~blSah_XVUIGOzQ9IAzpyCZ1PicJCiBtbUc"
    }
  end

  defp deployment_service_sp do
    %{
      tenant_id: "72f988bf-86f1-41af-91ab-2d7cd011db47",
      client_id: "2470ca86-3843-4aa2-95b8-97d3a912ff69",
      client_secret: "2y~8Q~blSah_XVUIGOzQ9IAzpyCZ1PicJCiBtbUc",
      scope: "https://microsoft.onmicrosoft.com/3b4ae08b-9919-4749-bb5b-7ed4ef15964d/.default"
    }    
  end

end
