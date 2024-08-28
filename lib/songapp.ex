defmodule Songapp do
  @api_url "https://api.genius.com/search"
  @api_key "KA4XOUPd0ERQumuJmB2lE1j24oRF_MOLVjBzB_2QSPibp4d0OEv1awCUsnJSuo0b"
  @header [{"Authorization", "Bearer #{@api_key}"}]

  def search_song(query) do
    encoded_query = URI.encode(query)
    url = "#{@api_url}?q=#{encoded_query}"

    case HTTPoison.get(url, @header, follow_redirect: true) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Poison.decode(body) do
          {:ok, decoded_body} ->
            extract_song_info(decoded_body)
          {:error, error} ->
            IO.puts("Erro ao decodificar JSON: #{inspect(error)}")
            {:error, {:invalid_json, error}}
        end

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        IO.puts("Erro HTTP: #{status_code}")
        IO.puts("Corpo da Resposta: #{body}")
        {:error, {:http_error, status_code, body}}

      {:error, error} ->
        IO.puts("Falha na requisição: #{inspect(error)}")
        {:error, {:request_failed, error}}
    end
  end

  defp extract_song_info(%{"response" => %{"hits" => [hit | _]}}) do
    result = hit["result"]

    %{
      title: result["title"],
      artist: result["primary_artist"]["name"],
      release_date: result["release_date_for_display"],
      song_url: result["url"],
    }
  end
end
