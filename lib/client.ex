defmodule Bitcoin.Client do
  @moduledoc """
  Collects packets of work from Server and returns back the mined 
  Bitcoins to the server to print.
  """
  use GenServer

  @doc false
  def main(sip \\ "192.168.0.105") do
    System.cmd("epmd", ["-daemon"])
    Bitcoin.get_ip()
    |> start_client(sip)
    |>keep_connection_alive()
  end

  @doc false
  def start_client(ip,sip) do
    name=String.split("ABCDEFGHIJKLMNOPQRSTUVWXYZ","", trim: true)|>to_charlist |>Enum.take_random(5) |>to_string
    client_name= "#{name}@#{ip}" |>String.to_atom
    Node.start(client_name)
    Node.set_cookie(:"mohit")
    server_name= "master@"<>sip |>String.to_atom
    Node.connect(server_name)
    :global.sync()
    :global.whereis_name(:server)
    |>GenServer.cast({:request_work, client_name})
    IO.puts "Client #{inspect client_name} is now working for Server #{inspect server_name}."
    server_name
  end

  @doc false
  def keep_connection_alive(server_name) do
    Node.connect(server_name)
    Process.sleep(10000)
    keep_connection_alive(server_name)
  end
end