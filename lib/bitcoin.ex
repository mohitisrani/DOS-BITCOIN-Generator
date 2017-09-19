defmodule Bitcoin do
  use GenServer
  alias Bitcoin.Box

  def main(args \\ ["4"]) do
    [arg] = args
    case String.contains?(arg, ".") do
      true -> Bitcoin.Client.main(arg)
      false -> 
        {k,_} = Integer.parse(arg)
        Bitcoin.Server.main(k)
    end
  end

  def get_ip() do
    {:ok, ifs} = :inet.getif()
    {a,b,c,d} =
      Enum.filter(ifs , fn({{ip, _, _, _} , _t, _net_mask}) -> ip != 127 end)
      |> Enum.map(fn {ip, _broadaddr, _mask} -> ip end)
      |>List.last
    "#{a}.#{b}.#{c}.#{d}"        
  end

  def hash(%Box{ ufid: ufid , k: k, zero: zero, x: x}) do
      input = ufid<>";"<>x
      sha=
        :crypto.hash(:sha256,input) |> Base.encode16 |> String.downcase   
      case String.slice(sha, 0, k) do
        ^zero -> { x, input<>" "<>sha}
        _default   -> { x, "" }
      end
  end

  def master(%Box{x: x} = list, threads \\ 4) do
    chunk_size = round(Float.ceil(length(x)/threads))
    Enum.chunk_every(x, chunk_size)
    |>Enum.each( fn(l) -> Task.start_link(Bitcoin, :mine, [%Box{ list | coins: l}]) end)
    list
  end

  def mine(%Box{ coins: coins, elements: elements, k: _k} = list) do    
    all_search=
      for x <- coins, y <-elements do
        hash(%Box{ list | x: x<>y})
      end
    coins_new = Enum.map(all_search, fn({a,_b}) ->a end )
    new_bitcoins = 
      Enum.map(all_search, fn({_a,b}) -> b<>"\n" end )
      |>Enum.filter( fn(b) -> b != "\n" end)
    Task.start(Bitcoin,:pre_printing, ["", [""] ++ new_bitcoins, list])
    num=10000
    mine(%Box{ list | coins: Enum.take_random(coins_new, num)})
  end

  def pre_printing(init_string, [h|t], list) do
    case t do
      [] -> 
        to_print = init_string<>String.trim_trailing(h)
        %Box{ self_state: self_state } = list
        case self_state do
          :server -> IO.puts("#{to_print}")
          :client ->
            :global.sync()
            :global.registered_names
            pid = :global.whereis_name(:server)
            GenServer.cast(pid, {:bitcoins_client, to_print})
        end
       _ ->
        init_string<>h
        |>pre_printing(t, list)
    end
  end

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
end