defmodule ExDebugToolbar.Toolbar.Config do
  alias ExDebugToolbar.Data.Timeline

  @default_config %{
    collections: %{
      ecto: [],
      logs: [],
      timeline: %Timeline{}
    }
  }

  def get_collections do
    Agent.get(__MODULE__, &Map.get(&1, :collections))
  end

  def get_collection(key) do
    get_collections() |> Map.fetch(key)
  end

  def define_collection(key, collection) do
    collections = get_collections()
    if Map.has_key?(collections, key) do
      {:error, :already_defined}
    else
      collections = Map.put(collections, key, collection)
      Agent.update(__MODULE__, &Map.put(&1, :collections, collections))
    end
  end

  def start_link do
    Agent.start_link(fn -> @default_config end, name: __MODULE__)
  end
end
