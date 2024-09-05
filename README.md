# Song App
────█▀█▄▄▄▄─────██▄───────────────────────  
────█▀▄▄▄▄█─────█▀▀█──╔══╦╦╦═╦╦═╗────────  
─▄▄▄█─────█──▄▄▄█─────║║║║║║╚╣║╔╝───────  
██▀▄█─▄██▀█─███▀█─────║║║║║╠╗║║╚╗─────  
─▀▀▀──▀█▄█▀─▀█▄█▀─────╚╩╩╩═╩═╩╩═╝───  
──────────────────────────────────  
## Descrição

Projeto que utiliza a API do site Genius para buscar informações sobre músicas.

## Autores

Conheça os desenvolvedores por trás do SongApp e do SongAssociation Game:

- [João Marcos](https://github.com/j4marcos)
- [Kaique Bezerra](https://github.com/KaiqueSantos2004)
- [Lucas Gabriel](https://github.com/LucasGabrielFontes)
- [Luis Reis](https://github.com/LuisReis09)
- [Rafael de França](https://github.com/rafaelfranca1)

## Get started 

`mix deps.get`

`iex -S mix`

## Funcionalidades 

### Pesquisar Música

* Busque informações sobre uma música específica com base em uma consulta:  
`SongApp.search_song("artist | music | letter")` 

* Retorne a letra de uma música:  
`SongApp.get_lyrics("artist | music | letter")` 

### Rankings

* Obtenha as músicas mais populares de um artista:  
`Rankings.artist_top_songs("artist name")` 

* Obtenha um número específico de músicas populares de um artista:  
`Rankings.artist_top_songs("artist name", music_number)`

* Obtenha o ranking de músicas do dia no Genius:  
`SongApp.ranking_hoje()` 

### Jogo

* Inicie o Song Association Game:  
`SongAssociation.start()`

## Configuração da Chave da API

Para utilizar o SongApp, você precisa configurar a variável de ambiente `GENIUS_API_KEY` com a sua chave da API do Genius. 

### Como configurar

1. Obtenha a chave da API do Genius [aqui](https://genius.com/api-clients).
2. Defina a variável de ambiente `GENIUS_API_KEY` com a chave obtida.