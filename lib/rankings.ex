defmodule Rankings do
  use Tesla

  @base_url "https://api.genius.com"
  @access_token "5qqiVyeOD6A2nstHW96vUe-_QOKxr_qka10ILsotoIhoZnNQQhq3qVB4-6c0-Qp-"

  plug Tesla.Middleware.BaseUrl, @base_url
  plug Tesla.Middleware.Headers, [{"Authorization", "Bearer #{@access_token}"}]
  plug Tesla.Middleware.JSON

  # Função para buscar músicas pelo nome do artista
  def search_song(artist_name) do
    get("/search", query: [q: artist_name])
  end

  # Função para buscar o ID do artista
  def search_artist(artist_name) do
    with {:ok, %Tesla.Env{status: 200, body: %{"response" => %{"hits" => hits}}}} <- search_song(artist_name),
        [%{"result" => %{"primary_artist" => %{"id" => artist_id}}} | _] <- hits do
      {:ok, artist_id}
    else
      _ -> {:error, "Artista não encontrado"}
    end
  end


  @doc """
    Retorna as x musicas mais populares do artista
  """
  def artist_top_songs(_artist, x) when x <= 0 do
    IO.puts("Número inválido")
  end

  def artist_top_songs(artist_name, x) when is_integer(x) and x > 0 do
    with {:ok, artist_id} <- search_artist(artist_name),
    {:ok, %Tesla.Env{status: 200, body: %{"response" => %{"songs" => songs}}}} <- list_songs(artist_id) do
    songs
    |> Enum.sort_by(& &1["stats"]["pageviews"], :desc)
    |> Enum.take(x)
    |> Enum.map(& &1["full_title"])
    else
    _ -> {:error, "Não foi possível obter as músicas"}
    end
  end
#quanto nenhum valor for passado para o numero de musicas a funcao retorna5 musicas
def artist_top_songs(artist_name) do
  with {:ok, artist_id} <- search_artist(artist_name),
    {:ok, %Tesla.Env{status: 200, body: %{"response" => %{"songs" => songs}}}} <- list_songs(artist_id) do
    songs
    |> Enum.sort_by(& &1["stats"]["pageviews"], :desc)
    |> Enum.take(5)
    |> Enum.map(& &1["full_title"])
    else
    _ -> {:error, "Não foi possível obter as músicas"}
    end
end


  # Função auxiliar para listar as músicas de um artista
  defp list_songs(artist_id) do
    get("/artists/#{artist_id}/songs", query: [per_page: 50, sort: "popularity"])
  end
end
