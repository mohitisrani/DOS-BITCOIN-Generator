defmodule Bitcoin.Client do
  use GenServer
  alias Bitcoin.Server

  def main(sip \\ "192.168.0.105") do
    System.cmd("epmd", ["-daemon"])
    Bitcoin.get_ip()
    |> start_client(sip)
  end

  def start_client(ip,sip) do
    name=
      String.split("ABCDEFGHIJKLMNOPQRSTUVWXYZ","", trim: true)
      |>to_charlist
      |>Enum.take_random(5)
      |>to_string
    client_name= 
      "#{name}@#{ip}"
      |>String.to_atom
    Node.start(client_name)
    Node.set_cookie(:"mohit")
    server_name=
      "master@"<>sip
      |>String.to_atom
    Node.connect(server_name)
    Node.spawn_link(server_name, Server, :client_main, [client_name])
    IO.puts "Client #{inspect client_name} is now working for Server #{inspect server_name}."
    Process.sleep(:infinity)
  end
end