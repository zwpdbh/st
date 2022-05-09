defmodule ST.Azure.AuthTest do
  use ExUnit.Case, async: true

  setup do
    azure_credential = %{
      tenant_id: "72f988bf-86f1-41af-91ab-2d7cd011db47",
      client_id: "2470ca86-3843-4aa2-95b8-97d3a912ff69",
      scope: "https://management.azure.com/.default",
      client_secret: "2y~8Q~blSah_XVUIGOzQ9IAzpyCZ1PicJCiBtbUc"
    }

    {:ok,
     input01: azure_credential}
  end

  describe "client credential" do
    test "azure credential", %{input01: azure_credential} do
      IO.inspect ST.Azure.Auth.request_access_token(azure_credential)
    end
  end
end
