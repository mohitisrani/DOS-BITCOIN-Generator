defmodule Bitcoin do
  @moduledoc """
  Documentation for Bitcoin.
  """

  def main(ufid \\ "misrani" ,k \\ 1, length \\ -1) do
    %Bitcoin.List{ k: k ,k_init: k, ufid: ufid, coins: [""] ,length: length }
    |>zeros
    |>elements
    |>distribute
    |> complete
  end

  # def timed(args) do
  #   {time, result} = :timer.tc(Bitcoin, :main, args)
  #   IO.puts "Time: #{time}ms"
  #   IO.puts "Result: #{result}"
  # end

  def complete(_trash) do
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

  def distribute(%Bitcoin.List{ coins: coins, elements: elements} = list) do
    for x <- coins, y <- elements  do
      Task.start_link(Bitcoin, :list_init, [%Bitcoin.List{ list | coins: [x<>y]}])
    #for x <- coins, y <- elements, z <- elements  do
    #  Task.async(Bitcoin, :list_init, [%Bitcoin.List{ list | coins: [x<>y<>z]}])      
    end
  end

  def list_init(%Bitcoin.List{ coins: coins, length: length} = list) do
    for x <- coins do
      hash(%Bitcoin.List{ list | x: x})
      list(%Bitcoin.List{ list | length: length - String.length(x)})
    end  
  end

  def list(%Bitcoin.List{ coins: coins, elements: elements, length: length} = list) do    
    case length do
      0 -> ""
      _->
        coins_new=
          for x <- coins, y <-elements do
            hash(%Bitcoin.List{ list | x: x<>y})
          end    
        list(%Bitcoin.List{ list | coins: coins_new, length: length - 1})
    end    
  end

  def elements(%Bitcoin.List{} = list) do
    elements=
      "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      |> String.downcase() 
      |> String.split("", trim: true)
      #|> Enum.with_index
      %Bitcoin.List{ list | elements: elements}
      
  end
end