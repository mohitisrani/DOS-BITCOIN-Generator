defmodule Test do
    
    def main(args \\ []) do
        IO.puts "#{inspect args}"
        # pid = 
        #     spawn(fn ->
        #         IO.puts "Waiting for messages"
        #         receive do
        #             msg -> IO.puts "Received #{inspect msg}"
        #         end
        #     end)
        
        # send(pid, "Hello Process!")
    end    

    # https://elixirforum.com/t/how-to-get-the-server-ip-address/1700
    def get_ip() do
        {:ok, ifs} = :inet.getif()
        {a,b,c,d} =
            Enum.filter(ifs , fn({{ip, _, _, _} , _t, _net_mask}) -> ip != 127 end)
            |> Enum.map(fn {ip, _broadaddr, _mask} -> ip end)
            |>List.last
        "#{a}.#{b}.#{c}.#{d}"        
    end


end


    
    # iex> :net_adm.localhost
    # 'Mohit'