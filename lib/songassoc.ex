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
    case File.read("D:/Linguagem Elixir/Projeto1/projeto-1-funcional/lib/words.txt") do
      {:ok, content} ->
        content
        |> String.split("\n")
        |> Enum.filter(&(&1 != "")) # Remove linhas vazias

      {:error, reason} ->
        IO.puts("Erro ao ler o arquivo: #{reason}")
        {:error}
    end
  end

  defp porJogador(palavras_jogadores) do
  # Inicia a rodada
  jogadores = Map.new()

  Enum.each(palavras_jogadores, fn jogador ->
    Enum.each(jogador, fn {nome, palavras} ->
      IO.puts("\nVez de #{nome}!")

      Enum.each(palavras, fn palavra ->
        IO.puts("\nPalavra: #{palavra}")
        IO.puts("Digite o artista: ")
        artista = IO.gets("> ") |> String.trim()
        IO.puts("Digite o nome da música: ")
        nome_musica = IO.gets("> ") |> String.trim()

        input = "#{artista} - #{nome_musica}"
        if artista == "" or nome_musica == "" do
          IO.puts("Entrada inválida, digite artistas/músicas válidos. Rodada perdida.")
        else
          {flag, lyricsin} = Songapp.get_lyrics(input)
          if flag == :error do
            IO.puts("Erro ao obter as letras da música. Rodada perdida.")
          else
            lyrics = String.downcase(lyricsin)
            find = String.match?(lyrics, ~r/.*#{palavra}.*/)
            IO.puts("Palavra: #{palavra} | Encotrado: #{find}")
            if find do
              IO.puts("Palavra válida! +1 ponto para #{nome}")
              # Atualiza o placar do jogador
              Map.update(jogadores, nome, 1, &(&1 + 1))
            else
              IO.puts("#{palavra} não foi encontrada na letra! #{String.upcase(nome)} perdeu a rodada.")
            end
          end
        end
      end)
    end)
  end)

  end


  defp startRound(jogadores) do
    IO.puts("\n\nRodada iniciada!")

    banco = readArchive()
     # Pega 5 palavras aleatórias e sem repetições para cada jogador
    {palavras_jogadores, _} =
      Enum.map_reduce(jogadores, banco, fn nome, acc ->
        {palavras, novo_banco} = Enum.split(acc |> Enum.shuffle(), 5)
        {%{nome => palavras}, novo_banco}
      end)

    IO.puts("\nDeseja visualizar as palavras dos jogadores? [s/n]")
    visualizar = IO.gets("> ") |> String.trim()
    if visualizar == "s" do
      Enum.each(palavras_jogadores, fn jogador ->
        Enum.each(jogador, fn {nome, palavras} ->
          IO.puts("\nPalavras de #{nome}:")
          Enum.each(palavras, fn palavra -> IO.puts(palavra) end)
        end)
      end)
    end

    placar_final = porJogador(palavras_jogadores)

    # Mostra a pontuação final dos jogadores
    IO.puts("\n\nPontuação final:")
    Enum.each(placar_final, fn {nome, pontos} -> IO.puts("#{nome} - #{pontos} pontos") end)

    IO.puts("\nVencedor(es): ")
    max_pontos = Enum.max(placar_final, fn {_, pontos} -> pontos end)
    Enum.each(placar_final, fn {nome, pontos} ->
      if pontos == max_pontos do
        IO.puts("#{nome} - #{pontos} pontos")
      end
    end)

  end

end
