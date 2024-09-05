defmodule SongAssociation do
  # Este modulo contem as funcoes necessarias para o jogo SongAssociation Game

  @doc """
    Funcao responsavel por iniciar e rodar o jogo SongAssociation
  """
  def start() do
    IO.puts("""
    ────█▀█▄▄▄▄─────██▄───────────────────────
    ────█▀▄▄▄▄█─────█▀▀█──╔══╦╦╦═╦╦═╗────────
    ─▄▄▄█─────█──▄▄▄█─────║║║║║║╚╣║╔╝───────
    ██▀▄█─▄██▀█─███▀█─────║║║║║╠╗║║╚╗─────
    ─▀▀▀──▀█▄█▀─▀█▄█▀─────╚╩╩╩═╩═╩╩═╝───
    ──────────────────────────────────
    """)

    IO.puts("Bem-vindo ao SongAssociation Game!")
    IO.puts("Vamos começar!")

    # Cadastra os jogadores
    qtd_jogadores = getQuantidadeJogadores()
    jogadores = cadastraJogadores(qtd_jogadores, qtd_jogadores)

    # Mostra os jogadores cadastrados e suas pontuacoes
    IO.puts("\nJogadores cadastrados: ")
    Enum.each(jogadores, fn player -> IO.puts(player) end)

    # Inicia a rodada
    startRound(jogadores)
  end

  defp getQuantidadeJogadores() do
    IO.puts("\nDigite a quantidade de jogadores [2-10]")
    qtd_jogadores = IO.gets("> ") |> String.trim() |> String.to_integer()

    if qtd_jogadores < 2 or qtd_jogadores > 10 do
      IO.puts("Valor Inválido! Por favor, insira um número dentro do intervalo [2-10]\n")
      getQuantidadeJogadores()
    else
      qtd_jogadores
    end
  end

  defp cadastraJogadores(_org, 0), do: []

  defp cadastraJogadores(org, x) do
    IO.puts("Digite o nome do jogador #{org-x+1}: ")
    nome = IO.gets("> ") |> String.trim()

    if nome == "" do
      IO.puts("Nome inválido! Por favor, insira um nome válido.")
      IO.puts("Reiniciaremos o cadastro de jogadores.")
      cadastraJogadores(org, org)
    else
      [nome | cadastraJogadores(org, x - 1)]
    end
  end

  defp removeEnter(contentin) do
    Enum.map(contentin, fn word -> String.replace(word, "\\r\\n", "") end)
  end

  defp readArchive() do
    # Construir o caminho relativo do arquivo
    caminho = Path.join([__DIR__, "words.txt"])

    # Imprimir o caminho para debug
    IO.puts("Tentando ler o arquivo no caminho: #{caminho}")

    # Tenta ler o arquivo de palavras
    case File.read(caminho) do
      {:ok, contentin} ->
        contentin
        |> String.split("\n")
        |> Enum.map(&String.trim/1)
        |> removeEnter()

      {:error, reason} ->
        IO.puts("Erro ao ler o arquivo: #{reason}")
        {:error}
    end
  end

  def askWord(palavra, nome, points) do
    IO.puts("\nPalavra: #{palavra}")
    IO.puts("Digite o artista: ")
    artista = IO.gets("> ") |> String.trim()
    IO.puts("Digite o nome da música: ")
    nome_musica = IO.gets("> ") |> String.trim()

    input = "#{artista} - #{nome_musica}"

    if artista == "" or nome_musica == "" do
      IO.puts("\n----------------------------------------------------\n")
      IO.puts(String.upcase("Entrada inválida, digite artistas/músicas válidos. Rodada perdida."))
      IO.puts("\n----------------------------------------------------\n")
      points + 0
    else
      case SongApp.get_lyrics(input) do
        {:error, message} ->
          IO.puts("#{message}. Rodada perdida.")
          points + 0

        {:ok, lyricsin} ->
          lyrics = String.downcase(lyricsin)
          if String.contains?(lyrics, palavra) do
            IO.puts("\n----------------------------------------------------\n")
            IO.puts(String.upcase("Palavra válida! +1 ponto para #{nome}"))
            IO.puts("\n----------------------------------------------------\n")
            points + 1
          else
            IO.puts("\n----------------------------------------------------\n")
            IO.puts(String.upcase("#{palavra} não foi encontrada na letra! #{String.upcase(nome)} perdeu a rodada."))
            IO.puts("\n----------------------------------------------------\n")
            points + 0
          end

      end
    end
  end

  defp porJogador(palavras_jogadores) do
    jogadores =
      Enum.map(palavras_jogadores, fn mapa ->
        %{
          nome: mapa[:nome],
          palavras: mapa[:palavras],
          pontos: 0
        }
      end)

    tabela_pontos = Enum.reduce(jogadores, [], fn map, lista ->
        IO.puts("\nVez de #{map[:nome]}!")

        points = Enum.reduce(map[:palavras], 0, fn (palavra, acumulador) -> askWord(palavra, map[:nome], acumulador) end)



        lista ++ [%{
              nome: map[:nome],
              pontos: map[:pontos] + points,
              palavras: map[:palavras]
            }]

      end)

      IO.inspect(tabela_pontos)

    tabela_pontos
  end

  defp startRound(jogadores) do
    IO.puts("\n\nRodada iniciada!")

    banco = readArchive()
    # Monta um array de mapas de jogadores[nome-palavras], sem repetições de palavras
    {palavras_j, _} =
      Enum.map_reduce(jogadores, banco, fn nome, acc ->
        {palavras, novo_banco} = Enum.split(acc |> Enum.shuffle(), 5)
        {%{nome => palavras}, novo_banco}
      end)

    palavras_jogadores =
      Enum.map(palavras_j, fn pj ->
        [head | _] =
          Enum.map(pj, fn {chave, valor} ->
            %{nome: chave, palavras: valor}
          end)

        head
      end)

    op = IO.gets("\nDeseja ver o mapa Jogador-Palavra[s/n]? ") |> String.trim
    if op == "s", do: IO.inspect(palavras_jogadores)

    placar_final = porJogador(palavras_jogadores)
    # IO.inspect(placar_final)

    ranking = Enum.sort_by(placar_final, &(&1.pontos), :desc)

    IO.puts("\n\nRanking Final:")
    Enum.each(ranking, fn mapa ->
      IO.puts("#{String.upcase(mapa[:nome])} - #{mapa[:pontos]} pontos")
    end)
  end
end
