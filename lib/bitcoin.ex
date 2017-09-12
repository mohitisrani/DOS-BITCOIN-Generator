defmodule Bitcoin do
  @moduledoc """
  Documentation for Bitcoin.
  """

  def main(ufid,k) do
    ""
    |>list(2)
    |> hash(ufid,k)
    |> complete
  end

  def complete(_trash) do
    IO.puts("\n\n")
    "search complete--"
  end

  def hash(list,ufid,k) do
    zero= zeros(k)
    for x <- list do
      input = ufid<>";"<>x
      sha=
        :crypto.hash(:sha256,input) |> Base.encode16 |> String.downcase   
      if zero == String.slice(sha,0,k) do
        IO.puts(input<>" "<>sha)
      end
    end
  end

  def zeros(k) do
    case k do
      1 -> "0"
      _ -> "0"<>zeros(k-1)
    end
  end

  def list(init_list,len) do
    case len do
      1     -> elements()
      _else ->
        for x <- list(init_list,len-1) , y <- elements() do
          x<>y
        end
    end
  end

  def elements do
    "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    |> String.downcase() 
    |> String.split("", trim: true)
#    |> Enum.with_index
  end


end
