defmodule Bees.Client do
  use HTTPoison.Base

  defstruct access_token: nil, client_id: nil, client_secret: nil

  @type t :: %__MODULE__{
    access_token: String.t,
    client_id: String.t,
    client_secret: String.t,
  }

  @user_agent "bees"

  def request(client, method, path, params, body, headers, authenticated) do
    params = add_default_parameters(client, params, authenticated)
    headers = add_default_headers(client, headers, authenticated)

    url = url(path, params)
    request(method, url, body, headers, [])
  end

  def get(client, path, params \\ :empty, authenticated \\ false) do
    request(client, :get, path, params, "", [], authenticated)
  end

  def post(client, path, body, params \\ :empty, authenticated \\ false) do
    request(client, :post, path, params, body, [], authenticated)
  end

  def delete(client, path, params \\ :empty, authenticated \\ false) do
    request(client, :delete, path, params, "", [], authenticated)
  end

  # Private Helpers

  defp add_default_headers(_client, headers, _authenticated) do
    [user_agent_header()] ++ headers
  end

  defp add_default_parameters(client, params, authenticated) do
    params = [ client_id: client.client_id, client_secret: client.client_secret ] ++ params
    if authenticated, do: [ oauth_token: client.access_token ] ++ params, else: params
  end

  defp user_agent_header() do
    {"User-Agent", "#{@user_agent}/#{Bees.version}"}
  end

  defp url(path, :empty), do: "https://api.foursquare.com/v2" <> path
  defp url(path, params) do
    url(path, :empty)
      |> URI.parse
      |> Map.put(:query, Plug.Conn.Query.encode(params))
      |> URI.to_string
  end
end
