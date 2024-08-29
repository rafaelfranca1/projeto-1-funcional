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

  defp extract_song_info(_), do: {:error, "Nenhuma música encontrada"}

  @doc """
  Retorna a letra da música
  """
  def get_lyrics(song_name) do
    encoded_query = URI.encode_www_form(song_name)
    url = "#{@api_url}?q=#{encoded_query}"

    IO.puts("Buscando letras para: #{song_name}")
    IO.puts("URL de busca: #{url}")

    case HTTPoison.get(url, @header, follow_redirect: true) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        with {:ok, decoded_body} <- Poison.decode(body),
             %{"response" => %{"hits" => [hit | _]}} <- decoded_body,
             result = hit["result"],
             song_url = result["url"],
             {:ok, %HTTPoison.Response{status_code: 200, body: lyrics_body}} <- HTTPoison.get(song_url),
             {:ok, document} <- Floki.parse_document(lyrics_body) do

          lyrics = extract_lyrics(document)

          regex1 = ~r/\d+\sContributors/
          regex2 = ~r/\d+Contributors/

          [lyrics_final1 | _] = String.split(lyrics, regex1, parts: 2)
          [lyrics_final2 | _] = String.split(lyrics_final1, regex2, parts: 2)
          [lyrics_final3 | _] = String.split(lyrics_final2, "[Outro]", parts: 2)

          IO.puts("\n\nLetra extraída:\n\n #{lyrics_final3}")

          # {:ok, lyrics_final}
        else
          error ->
            IO.puts("Erro ao obter as letras: #{inspect(error)}")
            {:error, "Não foi possível obter as letras."}
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

  defp extract_lyrics(document) do
    # Tentar encontrar o seletor padrão
    lyrics =
      document
      |> Floki.find(".lyrics")
      |> Floki.text()
      |> String.trim()

    # Se não encontrar, tenta o contêiner mais recente
    lyrics = if lyrics == "" do
      document
      |> Floki.find(".Lyrics__Container")
      |> Enum.map(&Floki.text/1)
      |> Enum.join("\n")
      |> String.trim()
    else
      lyrics
    end

    # Se ainda não encontrar, tenta capturar todo o texto em divs e filtrar o que parece ser letra
    lyrics = if lyrics == "" do
      document
      |> Floki.find("div")
      |> Enum.map(&Floki.text/1)
      |> Enum.filter(fn text -> String.contains?(text, "\n") end) # Filtro básico para tentar pegar blocos de letra
      |> Enum.join("\n")
      |> String.trim()
    else
      lyrics
    end

    # Filtrar textos indesejados que não fazem parte da letra
    lyrics
    |> String.split("\n")
    |> Enum.reject(&String.contains?(&1, ["Sign Up", "Get tickets", "You might also like", "See Eminem Live", "Embed", "Cancel", "How to Format Lyrics", "Type out all lyrics", "Use section headers", "Use italics", "To learn more", "About", "Genius Annotation", "Share", "Q&A", "Find answers", "Ask a question", "Genius Answer", "It won’t appear", "When did", "Who wrote", "Greatish Hits", "Expand", "Credits", "Writer", "Release Date", "Real Love Baby Covers", "Real Love Baby Translations", "Tags", "Comments", "Sign Up", "Genius is the ultimate source", "Sign In", "Do Not Sell", "Terms of Use", "Verified Artists", "All Artists", "Hot Songs"]))
    |> Enum.join("\n")
  end
  
end
