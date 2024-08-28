defmodule Songapp do
  @api_url "https://genius.com/api-clients"
  @api_key "KA4XOUPd0ERQumuJmB2lE1j24oRF_MOLVjBzB_2QSPibp4d0OEv1awCUsnJSuo0b"
  @header [{"Authorization", "Bearer #{@api_key}"}]

  def teste() do
    case  HTTPoison.get(@api_url, @header, follow_redirect: true) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, parse_response(body)}

      {:ok, %HTTPoison.Response{status_code: 302, headers: headers}} ->
        new_url = get_location(headers)
        HTTPoison.get(new_url, headers)

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Failed to fetch data. Status code: #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Request failed: #{reason}"}
    end
  end

  defp parse_response(body) do
    body
    |> Poison.decode!()
    |> Enum.map(&song_to_map/1)
  end

  defp song_to_map(issue) do
    %{
      title: issue["title"],
      url: issue["html_url"],
      state: issue["state"]
    }
  end

  defp get_location(headers) do
    headers
    |> Enum.find(fn {key, _value} -> key == "Location" end)
    |> elem(1)
  end
end
