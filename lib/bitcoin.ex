defmodule Bitcoin do
  use GenServer
  alias Bitcoin.Box

  # Decides based on the command line argument whether the system
  # is a server or client
  def main(args \\ ["4"]) do
    [arg] = args
    case String.contains?(arg, ".") do
      true -> Bitcoin.Client.main(arg)
      false -> 
        {k,_} = Integer.parse(arg)
        Bitcoin.Server.main(k)
    end
  end

  @doc """
  Mines for Bitcoins.
  Checks if the hashed value of coin contains required number of starting zeros.
  """
  def print_if_bitcoins(%Box{ ufid: ufid , k: k, zero: zero, x: x}) do
      input = ufid<>";"<>x
      sha=:crypto.hash(:sha256,input) |> Base.encode16 |> String.downcase   
      case String.slice(sha, 0, k) do
        ^zero -> IO.puts input<>" "<>sha
        _default   -> ""
      end
      x
  end

   @doc false
  def mine(%Box{ coins: coins, elements: elements, k: _k} = list) do    
    coins_new=
      for x <- coins, y <-elements do
        print_if_bitcoins(%Box{ list | x: x<>y})
      end    
    mine(%Box{ list | coins: Enum.take_random(coins_new, 10000) })
  end

   @doc false
  def master(%Box{x: x} = list, threads \\ 4) do
    chunk_size = round(Float.ceil(length(x)/threads))
    Enum.chunk_every(x, chunk_size)
    |>Enum.each( fn(l) -> Task.start_link(Bitcoin, :mine, [%Box{ list | coins: l}]) end)
    list
  end

   @doc false
  def start(%Box{ k: k } = list) do  #sets elements list and zero string
    client_elements = String.split("ABCDEFGHIJKLMNOPQRSTUVWXYZ","", trim: true)
    server_elements = String.split("0123456789abcdefghijklmnopqrstuvwxyz","", trim: true)
    elements = server_elements ++ client_elements
    %Box{ list | self_state: :server,
                          zero: :binary.copy("0", k), 
                          elements: elements,
                          x: server_elements,
                          client_elements: client_elements }  
  end

  @doc """
  Obtains ip of the system

  ## Examples

      iex> MainModule.get_ip
      "192.168.0.9"

  """
  def get_ip() do
    {:ok, ifs} = :inet.getif()
    {a,b,c,d} =
      Enum.filter(ifs , fn({{ip, _, _, _} , _t, _net_mask}) -> ip != 127 end)
      |> Enum.map(fn {ip, _broadaddr, _mask} -> ip end)
      |>List.last
    "#{a}.#{b}.#{c}.#{d}"        
  end
end