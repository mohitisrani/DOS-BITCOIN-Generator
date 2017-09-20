defmodule Test do
    
    def main(args \\ []) do
        IO.puts "#{inspect args}"
###makes list of all the elements as strings 
## like ./app 1 m n   
## will be accepted as ["1", "m", "n"]

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

    
        use GenServer
      
        def init() do 
          {:ok, [1,2,3]}
        end

        def start_client() do
            abs=:ImServer
            IO.puts("#{inspect abs}")
            GenServer.cast(abs, {:test, "hello"})
          end
      
        def handle_cast({:test, greeting}, a ) do
            IO.puts("#{inspect greeting}")
            IO.puts("#{inspect a}")
            {:noreply, a}
        end  
      
        def listener() do
          {:ok, _pid} = GenServer.start_link(Test, [:ssup], name: :ImServer)
        end
      


end


    
    # iex> :net_adm.localhost
    # 'Mohit'