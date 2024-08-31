defmodule Songapp do
  @moduledoc """
  Módulo Songapp

  Este módulo é um projeto que utiliza a API do site Genius para buscar informações sobre músicas, incluindo letras e rankings diários.

  Funções principais:
  - `search_song/1`: Busca informações sobre uma música específica.
  - `get_lyrics/1`: Retorna a letra de uma música.
  - `ranking_hoje/0`: Obtém o ranking de hoje de músicas do site Genius.
  """

  @api_url "https://api.genius.com/search"
  @api_key "KA4XOUPd0ERQumuJmB2lE1j24oRF_MOLVjBzB_2QSPibp4d0OEv1awCUsnJSuo0b"
  @header [{"Authorization", "Bearer #{@api_key}"}]

  #Tentativa de outra biblioteca:
  @api_url2 "https://api.lyrics.ovh/v1"

  def get_lyrics2(input) do
    {_flag, response} = search_song(input)
    artist = response[:artist]
    title = response[:title]
    url = "#{@api_url2}/#{URI.encode(artist)}/#{URI.encode(title)}"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
        |> Jason.decode!()
        |> handle_response()

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

defp handle_response(%{
        "lyrics" => %{
          "lyrics_body" => lyrics
        }
      }
  ) do
      # Se a letra está em ASCII, converta para texto legível
      lyrics
      |> String.to_charlist()        # Converte a string de ASCII para uma lista de inteiros
      |> Enum.map(&(&1))             # Converte cada inteiro ASCII para seu caractere correspondente
      |> List.to_string()            # Converte a lista de caracteres para uma string
      |> IO.puts()                   # Exibe a letra convertida

      {:ok, lyrics}
  end

  defp handle_response(%{"lyrics" => lyrics}) do
    {:ok, lyrics}
  end

  defp handle_response(_), do: {:error, "Letra não encontrada"}


  def search_song(query) do
    search_song(query, [], 0)
  end

  defp search_song(_query, _retrieved_songs, attempts) when attempts >= 8 do
    IO.puts("Número máximo de tentativas atingido. Por gentileza, tente ser mais específico na próxima vez.")
    {:error, "Número máximo de tentativas atingido. Não foi possível encontrar uma música correspondente."}
  end

  defp search_song(query, retrieved_songs, attempts) do
    encoded_query = URI.encode(query)
    url = "#{@api_url}?q=#{encoded_query}"

    case HTTPoison.get(url, @header, follow_redirect: true) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, decoded_body} ->
            songs = extract_song_info(decoded_body)

            case find_new_song(songs, retrieved_songs) do
              {:ok, song} ->
                IO.puts("Encontrei a música: #{song[:title]} - #{song[:artist]}")
                IO.puts("Esta é a música que você procurava? (s/n)")
                case IO.gets("> ") |> String.trim() do
                  "s" -> {:ok, song}
                  "n" ->
                    IO.puts("Procurando outra música...")
                    search_song(query, [song | retrieved_songs], attempts + 1)
                  _ ->
                    IO.puts("Resposta inválida. Tente novamente.")
                    search_song(query, retrieved_songs, attempts)
                end

              :error ->
                IO.puts("Nenhuma nova música encontrada. Tentando novamente...")
                search_song(query, retrieved_songs, attempts + 1)
            end

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

  defp find_new_song(songs, retrieved_songs) do
    case Enum.find(songs, fn song -> song not in retrieved_songs end) do
      nil -> :error
      song -> {:ok, song}
    end
  end

  defp extract_song_info(%{"response" => %{"hits" => hits}}) do
    Enum.map(hits, fn hit ->
      result = hit["result"]
      %{
        title: result["title"],
        artist: result["primary_artist"]["name"],
        release_date: result["release_date_for_display"],
        song_url: result["url"]
      }
    end)
  end

  defp extract_song_info(_), do: []

  # def search_song(query) do
  #   encoded_query = URI.encode(query)
  #   url = "#{@api_url}?q=#{encoded_query}"

  #   case HTTPoison.get(url, @header, follow_redirect: true) do
  #     {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
  #       case Poison.decode(body) do
  #         {:ok, decoded_body} ->
  #           extract_song_info(decoded_body)
  #         {:error, error} ->
  #           IO.puts("Erro ao decodificar JSON: #{inspect(error)}")
  #           {:error, {:invalid_json, error}}
  #       end

  #     {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
  #       IO.puts("Erro HTTP: #{status_code}")
  #       IO.puts("Corpo da Resposta: #{body}")
  #       {:error, {:http_error, status_code, body}}

  #     {:error, error} ->
  #       IO.puts("Falha na requisição: #{inspect(error)}")
  #       {:error, {:request_failed, error}}
  #   end
  # end

  defp extract_song_info2(%{"response" => %{"hits" => [hit | _]}}) do
    result = hit["result"]

    %{
      title: result["title"],
      artist: result["primary_artist"]["name"],
      release_date: result["release_date_for_display"],
      song_url: result["url"],
    }
  end

  @doc """
  Retorna a letra da música
  """
  def get_lyrics(song_name) do
    {:ok, mp} = search_song(song_name)
    song_name = mp[:title] <> " " <> mp[:artist]

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
          [lyrics_final1 | _] = String.split(lyrics_final1, regex2, parts: 2)
          [lyrics_final1 | _] = String.split(lyrics_final1, "[Outro]", parts: 2)
          [lyrics_final1 | _] = String.split(lyrics_final1, "Read More", parts: 2)

          mapa = extract_song_info2(decoded_body)

          IO.puts("\n\nArtista: #{mapa[:artist]}")
          IO.puts("Título: #{mapa[:title]}")
          IO.puts("\nLetra:\n\n #{lyrics_final1}")

          {:ok, lyrics_final1}
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

  @doc """
  Obtém o ranking de hoje de músicas do site Genius.

  Exemplo:
  iex> Songapp.ranking_hoje
  [
    %{
      rank: "1",
      title: "Song Title 1",
      artist: "Artist 1",
      url: "https://genius.com/song-title-1-lyrics"
    },
    %{
      rank: "2",
      title: "Song Title 2",
      artist: "Artist 2",
      url: "https://genius.com/song-title-2-lyrics"
    },
    ...
  ]
  """
  def ranking_hoje do
    url = "https://genius.com"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{body: body}} ->
            Regex.scan(~r/<a href="([^"]+)" class="PageGriddesktop-hg04e9-0 ChartItemdesktop__Row-sc-3bmioe-0 [^"]+">.*?<div class="ChartItemdesktop__Rank-sc-3bmioe-1 [^"]+">([^<]+)<\/div>.*?<div class="ChartSongdesktop__Title-sc-18658hh-3 [^"]+">([^<]+)<\/div>.*?<h4 class="ChartSongdesktop__Artist-sc-18658hh-5 [^"]+">([^<]+)<\/h4>/s, body)
            |> map(fn [_, link, rank, song_name, artist] ->
              [
                rank: String.trim(rank),
                song_name: String.trim(song_name),
                artist: String.replace(artist, "&amp;", "&") |> String.trim(),
                link: link
              ]
            end)
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Failed to fetch the page: #{reason}"}
    end
  end

  defp map([], _f), do: []
  defp map([head | tail], f), do: [f.(head) | map(tail, f)]
end
