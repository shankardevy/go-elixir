defmodule FirebnbWeb.HomeLive.Index do
  use FirebnbWeb, :live_view

  import FirebnbWeb.PropertyComponents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

end
