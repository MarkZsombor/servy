defmodule Servy.Handler do
  @moduledoc """
    Handles HTTP requests
  """

  @pages_path Path.expand("../../pages", __DIR__)

  alias Servy.{Plugins, Parser}

  def handle(request) do
    request
    |> Parser.parse()
    |> Plugins.rewrite_path()
    |> route()
    |> Plugins.track()
    |> format_response()
  end

  def route(%{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%{method: "GET", path: "/bears"} = conv) do
    %{conv | status: 200, resp_body: "Bears"}
  end

  def route(%{method: "GET", path: "/bears" <> id} = conv) do
    %{conv | status: 200, resp_body: "Bear #{id}"}
  end

  def route(%{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%{path: path} = conv) do
    %{conv | status: 404, resp_body: "no #{path} here!"}
  end

  def handle_file({:ok, content}, conv), do: %{conv | status: 200, resp_body: content}

  def handle_file({:error, :enonet}, conv),
    do: %{conv | status: 404, resp_body: "File not found!"}

  def handle_file({:error, reason}, conv),
    do: %{conv | status: 500, resp_body: "File error: #{reason}"}

  # def route(%{method: "GET", path: "/about"} = conv) do
  #   file =
  #     Path.expand("../../pages", __DIR__)
  #     |> Path.join("about.html")

  #   case File.read(file) do
  #     {:ok, content} ->
  #       %{conv | status: 200, resp_body: content}

  #     {:error, :enoent} ->
  #       %{conv | status: 404, resp_body: "File not found!"}

  #     {:error, reason} ->
  #       %{conv | status: 500, resp_body: "File error: #{reason}"}
  #   end
  # end

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Context-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "OK",
      401 => "OK",
      403 => "OK",
      404 => "OK",
      500 => "OK"
    }[code]
  end
end
