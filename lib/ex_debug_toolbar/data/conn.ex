alias ExDebugToolbar.Data.Collection

defimpl Collection, for: Plug.Conn do
  def add(_, %Plug.Conn{} = conn), do: %{conn | resp_body: nil}
end
