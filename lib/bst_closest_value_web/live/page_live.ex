defmodule BstClosestValueWeb.PageLive do
  use BstClosestValueWeb, :live_view

  require Protocol
  Protocol.derive(Jason.Encoder, BST.Node)

  use BstClosestValueWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, tree} = BST.new([4, 5, 6, -7, -3]).root |> Jason.encode()
    # tree = BST.new([4, 5, 6, -7, -3]).root
    send(self(), :initialize_tree)
    send(self(), :current_value)
    {:ok, assign(socket, query: "", tree: tree, value: -7, results: %{})}
  end

  def handle_info(
        :initialize_tree,
        %{assigns: %{tree: tree}} = socket
      ) do
    {:noreply, push_event(socket, "scores", %{tree: tree})}
  end

  def handle_info(
        :current_value,
        %{assigns: %{value: value}} = socket
      ) do
    {:noreply, push_event(socket, "current_value", %{value: value})}
  end

  @impl true
  def handle_event("suggest", %{"q" => query}, socket) do
    {:noreply, assign(socket, results: search(query), query: query)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    case search(query) do
      %{^query => vsn} ->
        {:noreply, redirect(socket, external: "https://hexdocs.pm/#{query}/#{vsn}")}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "No dependencies found matching \"#{query}\"")
         |> assign(results: %{}, query: query)}
    end
  end

  defp search(query) do
    if not BstClosestValueWeb.Endpoint.config(:code_reloader) do
      raise "action disabled when not in development"
    end

    for {app, desc, vsn} <- Application.started_applications(),
        app = to_string(app),
        String.starts_with?(app, query) and not List.starts_with?(desc, ~c"ERTS"),
        into: %{},
        do: {app, vsn}
  end
end
