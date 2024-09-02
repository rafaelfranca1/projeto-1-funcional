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

## top songs music

`Rankings.artist_top_songs(`artist name`)`

`Rankigns.artist_top_songs(`artist name, musics number`)`  
`Rankigns.artist_top_songs(`artist name`)`

## pesquisar musica

`Songapp.search_song(`artist | music | letter`)`
 - Busca informações sobre uma música específica com base em uma consulta.

`Songapp.get_lyrics(`artist | music | letter`)`
- Retorna a letra de uma música.

`Songapp.ranking_hoje()`
- Obtém o ranking de hoje de músicas do site Genius.

## jogo

`SongAssociation.start()`
