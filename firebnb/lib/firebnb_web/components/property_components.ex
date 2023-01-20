defmodule FirebnbWeb.PropertyComponents do
  use Phoenix.Component

  def price(assigns) do
    ~H"""
    <span class="text-lg font-bold text-gray-700 dark:text-gray-200 md:text-xl">
      <%= render_slot(@inner_block) %>
    </span>
    """
  end
end
