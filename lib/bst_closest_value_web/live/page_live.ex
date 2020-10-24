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
    # send(self(), :current_value)
    findClosestValueInBst(socket, BST.new([4, 5, 6, -7, -3]).root, 6)
    {:ok, assign(socket, query: "", tree: tree, value: -3, results: %{})}
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
  def handle_event("search_for_closest_value", _params, socket) do
    findClosestValueInBst(socket, BST.new([4, 5, 6, -7, -3]).root, 6)
    {:noreply, socket}
  end

  def findClosestValueInBst(socket, tree, target) do
    findClosestValueInBstHelper(socket, tree, target, tree.data)
  end

  def get_closest(target, closest, current) do
    if abs(target - closest) > abs(target - current) do
      current
    else
      closest
    end
  end

  def findClosestValueInBstHelper(socket, tree, target, closest) do
    Process.sleep(2000)

    new_closest = get_closest(target, closest, tree.data)
    send(self(), :current_value)
    IO.puts(new_closest)

    cond do
      tree == nil ->
        closest

      target < tree.data ->
        findClosestValueInBstHelper(socket, tree.left, target, new_closest)

      target > tree.data ->
        findClosestValueInBstHelper(socket, tree.right, target, new_closest)

      true ->
        closest
    end
  end
end
