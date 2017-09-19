defmodule Bitcoin.Server do
  use GenServer
  alias Bitcoin.Box
  
  def main(k \\ 1) do
    System.cmd("epmd", ["-daemon"])
    sip = Bitcoin.get_ip()
    IO.puts("Server started as : master@#{sip}")
    Process.sleep(1500)
    sip
    |> start_server
    |>server_main(k)
  end 

  def start_server(ip) do
    serv_add = 
      "master@#{ip}"
      |>String.to_atom  
      Node.start(serv_add)
    Node.set_cookie(:"mohit")
    serv_add
  end

  def server_main(serv_add, k ) do
    %Box{ k: k ,serv_add: serv_add, ufid: "misrani"}
    |>Bitcoin.start
    |>Bitcoin.master
    |>create_server
  end

  def create_server( list ) do
    {:ok, pid} = GenServer.start_link(Bitcoin.Server, list, name: MyServer)
    :global.sync()
    :global.register_name(:server, pid)
    Process.sleep(:infinity)
  end

  def init( list ) do 
    {:ok, list}
  end

  def handle_call(:for_element, _from, %Box{client_elements: [x|client_elements]} = list) do
    {:reply, %Box{ list | x: x }, %Box{ list | client_elements: client_elements }}
  end

  def handle_cast({:bitcoins_client, to_print}, state) do
    IO.puts("#{to_print}")
    {:noreply, state}
  end

  def client_main(client_name) do
    Task.start(Bitcoin.Server, :create_client, [client_name])
  end

  def create_client(client_name) do
    list = GenServer.call(MyServer, :for_element)
    %Box{ x: x, elements: elements} = list
    client_list =
      for y <- elements do
        x<>y
      end
    Node.spawn_link(client_name,Bitcoin, :master, [ %Box{ list |self_state: :client, x: client_list } ])
  end  
  
end