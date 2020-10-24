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
    list = findClosestValueInBst(BST.new([4, 5, 6, -7, -3]).root, -4)
    send(self(), :current_value)
    {:ok, assign(socket, query: "", tree: tree, value: -3, list: list, results: %{})}
  end

  def handle_info(
        :initialize_tree,
        %{assigns: %{tree: tree}} = socket
      ) do
    {:noreply, push_event(socket, "scores", %{tree: tree})}
  end

  def handle_info(
        :current_value,
        %{assigns: %{list: list}} = socket
      ) do
    {:noreply, push_event(socket, "current_value", %{list: list})}
  end

  @impl true
  def handle_event("search_for_closest_value", _params, socket) do
    # findClosestValueInBst(BST.new([4, 5, 6, -7, -3]).root, 6)
    {:noreply, socket}
  end

  def findClosestValueInBst(tree, target) do
    findClosestValueInBstHelper(tree, target, tree.data, [])
  end

  def get_closest(target, closest, current) do
    if abs(target - closest) > abs(target - current) do
      current
    else
      closest
    end
  end

  def findClosestValueInBstHelper(tree, target, closest, history) do
    current_value = if tree == nil, do: 0, else: tree.data

    new_closest = get_closest(target, closest, current_value)

    cond do
      tree == nil ->
        history

      target < tree.data ->
        findClosestValueInBstHelper(tree.left, target, new_closest, history ++ [new_closest])

      target > tree.data ->
        findClosestValueInBstHelper(tree.right, target, new_closest, history ++ [new_closest])

      true ->
        history ++ [new_closest]
    end
  end
end
