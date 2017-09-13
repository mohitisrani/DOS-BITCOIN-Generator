defmodule Bitcoin do
  @moduledoc """
  Documentation for Bitcoin.
  """

  def main(ufid,k) do
    %Bitcoin.List{ k: k ,k_init: k, ufid: ufid, coins: ["0"] }
    |>zeros
    |>elements
    |>list
 #   |> complete
  end

  def complete(_trash) do
    IO.puts("\n\n")
    "search complete--"
  end

  def hash(%Bitcoin.List{ ufid: ufid , k_init: k, zero: zero, x: x}) do
      input = ufid<>";"<>x
      sha=
        :crypto.hash(:sha256,input) |> Base.encode16 |> String.downcase   
      case String.slice(sha, 0, k) do
        ^zero -> IO.puts(input<>" "<>sha)
        _default   -> ""
      end
      x

  end

  def zeros(%Bitcoin.List{ k: k} = list) do
    %Bitcoin.List{ list | zero: :binary.copy("0", k)}
  end

  def list(%Bitcoin.List{ coins: coins, elements: elements} = list) do
    
    coins_new=
      for x <- coins, y <-elements do
        hash(%Bitcoin.List{ list | x: x<>y})
      end
    
    list(%Bitcoin.List{ list | coins: coins_new})
    
  end

  def elements(%Bitcoin.List{} = list) do
    elements=
      "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      |> String.downcase() 
      |> String.split("", trim: true)
    
      %Bitcoin.List{ list | elements: elements}
#    |> Enum.with_index
  end
  


end
