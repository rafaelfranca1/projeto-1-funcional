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
    jogadores = cadastraJogadores(qtd_jogadores)

    # Mostra os jogadores cadastrados e suas pontuacoes
    IO.puts("\nJogadores cadastrados:")
    Enum.each(jogadores, fn player -> IO.puts(player) end)

    # Inicia a rodada
    startRound(jogadores)
  end

  defp getQuantidadeJogadores() do
    qtd_jogadores = IO.gets("> ") |> String.trim() |> String.to_integer()

    if qtd_jogadores < 2 or qtd_jogadores > 10 do
      IO.puts("Valor Inválido! Por favor, insira um número dentro do intervalo [2-10]\n")
      getQuantidadeJogadores()
    else
      qtd_jogadores
    end
  end

  defp cadastraJogadores(_org, 0), do: nil
  defp cadastraPlayers(org, x) do
    IO.puts("Digite o nome do jogador #{x}: ")
    nome = IO.gets("> ") |> String.trim()

    if nome == "" do
      IO.puts("Nome inválido! Por favor, insira um nome válido.")
      IO.puts("Reiniciaremos o cadastro de jogadores.")
      cadastraJogadores(org, org)
    else
      [nome | cadastraJogadores(org, x-1)]
    end
  end

  defp readArchive() do
    # Tenta ler o arquivo de palavras
    case File.read("C:/Users/66666/OneDrive/Área de Trabalho/projeto-1-funcional/lib/words.txt") do
      {:ok, content} ->
        content
        |> String.split("\n")
        |> Enum.filter(&(&1 != "")) # Remove linhas vazias

      {:error, reason} ->
        IO.puts("Erro ao ler o arquivo: #{reason}")
        []
    end
  end

  defp porJogador( jogadoresData ) do
    # Inicia a rodada
    Enum.each(palavras, fn {nome, palavras} ->
      IO.puts("\nVez de #{nome}!")
      Enum.each(palavras, fn palavra ->
        IO.puts("\nPalavra: #{palavra}")
        IO.puts("Digite o artista: ")
        artista = IO.gets("> ") |> String.trim()
        IO.puts("Digite o nome da música: ")
        nome_musica = IO.gets("> ") |> String.trim()

        input = "#{artista} - #{nome_musica}"
        if artista == "" or nome_musica == "" do
          IO.puts("Entrada invalida, digite artistas/musicas validos. Rodada perdida.")
        else
          {flag, lyricsin} = Songapp.get_lyrics2(input)
          lyrics = String.downcase(lyricsin)
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
        end
      end)
    end)

    if palavras.len > 0  do
      porJogador({
        ...jogadores,
        jogadores[jogadores|0] + 1
      })
    end
  end


  defp startRound(jogadores) do
    IO.puts("\n\nRodada iniciada!")

    banco = readArchive()
    # Pega 5 palavras aleatórias e sem repetições para cada jogador
    palavras_jogadores = Enum.reduce(jogadores, %{}, fn {nome, _}, acc ->
      palavras = Enum.take_random(banco, 5, & &1)
      Map.put(acc, nome, palavras)
    end)


    IO.puts("\nDeseja visualizar as palavras dos jogadores? [s/n]")
    visualizar = IO.gets("> ") |> String.trim()
    if visualizar == "s" do
      Enum.each(palavras_jogadores, fn {nome, palavras} ->
        IO.puts("\nPalavras de #{nome}:")
        Enum.each(palavras, fn palavra -> IO.puts(palavra) end)
      end)
    end


    jogadoresData = palavras_jogadores.map(fn {nome, palavras} -> nome : {nome, 0} end)

    {
"luis" : {
pontos: 0,
palavras: ['palavra1', 'palavra2', 'palavra3', 'palavra4', 'palavra5']
    }
    "luis" : {
pontos: 0,
palavras: ['palavra1', 'palavra2', 'palavra3', 'palavra4', 'palavra5']
    }
    "luis" : {
pontos: 0,
palavras: ['palavra1', 'palavra2', 'palavra3', 'palavra4', 'palavra5']
    }
    }
    pontuação_final = porJogador( palavras_jogadores)

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
