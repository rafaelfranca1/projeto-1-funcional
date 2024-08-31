defmodule SongAssociation do

  import Songapp

  # Este modulo contem as funcoes necessarias para o jogo SongAssociation Game

  @doc """
    Funcao responsavel por iniciar e rodar o jogo SongAssociation
  """
  def start() do
    IO.puts("Bem-vindo ao SongAssociation Game!")
    IO.puts("Vamos começar!")

    # Cadastra os jogadores
    jogadores = cadastraPlayers()

    # Mostra os jogadores cadastrados e suas pontuacoes
    IO.puts("\nJogadores cadastrados:")
    Enum.each(jogadores, fn {nome, pontos} -> IO.puts("#{nome} - #{pontos} pontos") end)

    # Inicia a rodada
    startRound(jogadores)
  end


  defp cadastraPlayers() do
    IO.puts("Digite a quantidade de jogadores [2-10]: ")
    qtd_jogadores = IO.gets("> ") |> String.trim() |> String.to_integer()

    if qtd_jogadores < 2 or qtd_jogadores > 10 do
      IO.puts("Valor Inválido! Por favor, insira um número dentro do intervalo [2-10]\n")
      cadastraPlayers()
    else
      # Cria um mapa para armazenar os jogadores
      jogadores =
        for i <- 1..qtd_jogadores do
          IO.puts("\nDigite o nome do jogador #{i}: ")
          nome = IO.gets("> ") |> String.trim()
          {nome, 0}
        end
        |> Enum.into(%{}) # Transforma a lista de tuplas em um mapa

      jogadores
    end
  end

  defp readArchive() do
    # Tenta ler o arquivo de palavras
    case File.read("C:/Users/lucas/OneDrive/Área de Trabalho/projeto-1-funcional/lib/words.txt") do
      {:ok, content} ->
        content
        |> String.split("\n")
        |> Enum.filter(&(&1 != "")) # Remove linhas vazias

      {:error, reason} ->
        IO.puts("Erro ao ler o arquivo: #{reason}")
        []
    end
  end

  defp porRodadas(jogadores, palavras) do
    # Inicia a rodada
    Enum.each(palavras, fn {nome, palavras} ->
      IO.puts("\nVez de #{nome}!")
      Enum.each(palavras, fn palavra ->
        IO.puts("\nPalavra: #{palavra}")
        for i <- 1..7 do
          IO.puts("#{i} segundos...")
          Process.sleep(1000)
        end
        IO.puts("Digite o artista: ")
        artista = IO.gets("> ") |> String.trim()
        IO.puts("Digite o nome da música: ")
        nome_musica = IO.gets("> ") |> String.trim()

        input = "#{artista} - #{nome_musica}"
        {flag, lyrics} = get_lyrics(input)
        if flag == :error do
          IO.puts("Erro ao obter as letras da música. Rodada perdida.")
        else
          if String.contains?(lyrics, palavra) do
            IO.puts("Palavra válida! +1 ponto para #{nome}")
            Map.put(jogadores, nome, jogadores[nome] + 1)
          else
            IO.puts("Palavra inválida! #{nome} perdeu a rodada.")
            Enum.each(jogadores, fn {nome, pontos} -> IO.puts("#{nome} - #{pontos} pontos") end)
          end
        end
      end)
    end)
  end

    defp porJogador(jogadores, palavras) do
      # Inicia a rodada
      Enum.each(palavras, fn {nome, palavras} ->
        IO.puts("\nVez de #{nome}!")
        Enum.each(palavras, fn palavra ->
          IO.puts("\nPalavra: #{palavra}")
          for i <- 1..7 do
            IO.puts("#{i} segundos...")
            Process.sleep(1000)
          end
          IO.puts("Digite o artista: ")
          artista = IO.gets("> ") |> String.trim()
          IO.puts("Digite o nome da música: ")
          nome_musica = IO.gets("> ") |> String.trim()

          input = "#{artista} - #{nome_musica}"
          {flag, lyrics} = get_lyrics(input)
          if flag == :error do
            IO.puts("Erro ao obter as letras da música. Rodada perdida.")
          else
            if String.contains?(lyrics, palavra) do
              IO.puts("Palavra válida! +1 ponto para #{nome}")
              Map.put(jogadores, nome, jogadores[nome] + 1)
            else
              IO.puts("Palavra inválida! #{nome} perdeu a rodada.")
              Enum.each(jogadores, fn {nome, pontos} -> IO.puts("#{nome} - #{pontos} pontos") end)
            end
          end
        end)
      end)
    end


  defp startRound(jogadores) do
    IO.puts("\n\nRodada iniciada!")

    banco = readArchive()
    # Pega 5 palavras aleatórias e sem repetições para cada jogador
    palavras_jogadores =
      Enum.map(jogadores, fn {nome, _pontos} ->
        {nome, Enum.take_random(banco, 5)}
      end)

    IO.puts("\nDeseja visualizar as palavras dos jogadores? [s/n]")
    visualizar = IO.gets("> ") |> String.trim()
    if visualizar == "s" do
      Enum.each(palavras_jogadores, fn {nome, palavras} ->
        IO.puts("\nPalavras de #{nome}:")
        Enum.each(palavras, fn palavra -> IO.puts(palavra) end)
      end)
    end

    # Inicia a rodada
    IO.puts("\n\nVamos começar a rodada!")
    IO.puts("Quando estiver pronto, pressione 'enter' para começar!")
    ready = IO.gets("> ")

    IO.puts("\nSelecione o modo de jogo:\n1. Por rodadas (A cada rodada, 1 jogador responde 1 palavra)\n2. Por jogador (Cada jogador responde todas as palavras de uma vez)")
    modo = IO.gets("> ") |> String.trim() |> String.to_integer()

    """
      'Por rodadas': cada jogador receberá uma palavra por vez,
      intercalando suas jogadas. O jogador que não conseguir pensar
      em uma palavra ou errar a música perde a rodada.
      'Por jogador': cada jogador receberá todas as palavras de uma
      vez e terá um tempo para responder todas elas. O jogador que
      não conseguir pensar em uma palavra ou errar a música perde a rodada.
    """

    case modo do
      1 -> porRodadas(jogadores, palavras_jogadores)
      2 -> porJogador(jogadores, palavras_jogadores)
      _ ->  IO.puts("Modo inválido! Tente novamente.")
    end

    # Mostra a pontuação final dos jogadores
    IO.puts("\n\nPontuação final:")
    Enum.each(jogadores, fn {nome, pontos} -> IO.puts("#{nome} - #{pontos} pontos") end)

    IO.puts("\nVencedor(es): ")
    max_pontos = Enum.max(jogadores, fn {_, pontos} -> pontos end)
    Enum.each(jogadores, fn {nome, pontos} ->
      if pontos == max_pontos do
        IO.puts("#{nome} - #{pontos} pontos")
      end
    end)

  end

end


# SongAssociation.start()
