defmodule GingerTea.JsonResponse do
  @moduledoc """
  This module is reponsiple for crafting json responses in
  response to a client request.
  """

  @doc """
  Used when the client request is a success
  """
  def notify(:ok, msg) do
    %{
      status_code: "ok",
      msg: msg
    }
  end

  @doc """
  Used when the client request is a failure
  """
  def notify(:error, msg) do
    %{
      status_code: "error",
      msg: msg
    }
  end
end
