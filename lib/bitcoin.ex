defmodule Bitcoin do

  def main(k \\ 1) do
    %Bitcoin.List{ k: k , ufid: "misrani", coins: [""] }
    |>init
    |>master
  end

  def hash(%Bitcoin.List{ ufid: ufid , k: k, zero: zero, x: x}) do
      input = ufid<>";"<>x
      sha=
        :crypto.hash(:sha256,input) |> Base.encode16 |> String.downcase   
      case String.slice(sha, 0, k) do
        ^zero -> IO.puts(input<>" "<>sha)
        _default   -> ""
      end
      x
  end

  def master(%Bitcoin.List{server_elements: server_elements} = list) do
    for x <- server_elements  do
      Task.start_link(Bitcoin, :mine, [%Bitcoin.List{ list | coins: [x]}]) 
    end
  end

  def mine(%Bitcoin.List{ coins: coins, elements: elements,} = list) do    
    coins_new=
      for x <- coins, y <-elements do
        hash(%Bitcoin.List{ list | x: x<>y})
      end    
    mine(%Bitcoin.List{ list | coins: coins_new})  
  end

  def init(%Bitcoin.List{ k: k } = list) do  #sets elements list and zero string
    client_elements = String.split("ABCDEFGHIJKLMNOPQRSTUVWXYZ","", trim: true)
    server_elements = String.split("0123456789abcdefghijklmnopqrstuvwxyz","", trim: true)
    elements = server_elements ++ client_elements
    %Bitcoin.List{ list | zero: :binary.copy("0", k), 
                          elements: elements,
                          server_elements: server_elements,
                          client_elements: client_elements }  
  end
end