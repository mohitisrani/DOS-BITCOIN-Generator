defmodule Bitcoin.Server do
  @moduledoc """
  Recieves requests from processes to assign work.
  Also responsible for printing the mined coins.
  """
  use GenServer
  alias Bitcoin.Box
  
  @doc """
  Gets arguments from the server.
  Based on the input from user, determines if the machine is server or client 
  and then allocates respectively.

  Else, the program can also be run as an executable.

  ## Examples

      ➤ ./bitcoin 4
      Server started as : master@10.136.193.159
      misrani;iVu 0000e21208c4476bb69748cee27e9c42de877ca12539c82bc04e051da4a4f36c
      misrani;4clA 000050b4f388f61047d6be88ff847be1e9f54b31da555c8e0b2e6912197d4070
      misrani;7THn 00008f6eb55f659a5b34d9fefc79812f8baa7eb3846fa64f5bf805e5b2e3029b
      misrani;8IjZ 00009cce482f25e3cc8d956c7b6e5b3481cb762c2b37b1a8323b4bf687e2bd39
      misrani;sTrw 0000b2a7373e1bb6f48d098f2d64fc80af94ed5d08587aada8c32bb4d42813f6
      misrani;nlH2 00002a29964c0f747f7cb840c1c04f2cc52ab805af3b1ef20ac76bed65a1be2b
      misrani;1EWb 0000832f5f7653e127ed55005f827db380cbbed13d4220afc71b848286fdb47e
      misrani;fNPi 00008271bd50fc512849f59c2748dc83c7af89e4b2e3ffb5805a54680c5caec1
      misrani;2DeX 00008c2e20e63e8ab6d26dc771de11700444aad4f37087b5c4fa57c4e061b527

  """
  def main(k \\ 1) do
    System.cmd("epmd", ["-daemon"])
    sip = Bitcoin.get_ip()
    IO.puts("Server started as : master@#{sip}")
    Process.sleep(1500)
    serv_add = "master@#{sip}" |>String.to_atom  
    Node.start(serv_add)
    Node.set_cookie(:"mohit")
    listener(serv_add,k)
  end 

  @doc false
  def init( list ) do 
    {:ok, list}
  end

    @doc """
  Provides prefix that the Bitcoins mined by the Client should have 
  on request at `start_client`.
  """
  def handle_cast({:request_work, client_name}, %Box{elements: elements, client_elements: [x|client_elements]} = list) do
    client_list =
      for y <- elements do
        x<>y
      end
    Node.spawn_link(client_name,Bitcoin, :master, [ %Box{ list |self_state: :client, x: client_list } ])
    {:noreply, %Box{ list | client_elements: client_elements }}
  end  

  @doc false
  def listener(serv_add, k ) do
    list=
      %Box{ k: k ,serv_add: serv_add, ufid: "misrani"}
      |>Bitcoin.start
      |>Bitcoin.master
    {:ok, pid} = GenServer.start_link(Bitcoin.Server, list, name: MyServer)
    :global.sync()
    :global.register_name(:server, pid)
    Process.sleep(:infinity)
  end
end