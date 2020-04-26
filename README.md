# 4-en-Ratlla
Pràctica de Haskell de l'assignatura de Llenguatges de Programació de la Facultat d'Informàtica de Barcelona. En aquesta pràctica he realitzat el joc clàssic del 4 en Ratlla.


## Instal·lació i execució

Com compilar el programa

```
ghc 4enRalla.hs
```

Com executar el programa

```
./4enRalla
```

## Tipus de Dades

En aquest programa he fet servir diferents tipus de dades per a poder treballar més comodament.

```
type Tauler = [Fila]        -- Llista de Files
type Posicio = String       -- Posicio en format String, representant un nombre de 2 xifres
type Fila = [Posicio]       -- Llista on cada element es una posicio de una fila

data Arbre a = Arbre a [Arbre a] deriving (Show,Eq,Ord)         -- El fem servir per a l'estrategia Smart
data Jugador = Persona | Maquina | Ningu deriving (Show,Eq)     -- El fem servir per a identificar accions
```

## Començar a jugar?

Un cop d'executa el programa, es demanarà que l'usuari introdueixi el nombre de files, columnes i el nivell de dificultat amb el qual vol jugar. Un cop mostrat el tauler, el joc decidirà de manera aleatoria qui comença jugant. A partir d'aquest moment el joc anirà demanant que s'introdueixi a quina columna es vol deixar caure la nostra fitxa fins que la partida acabi.

Fitxa de l'usuari -> XX

Fitxa de la maquina -> ··

Exemple de Tauler de 6 x 7

```
  /  00  /  01  /  02  /  03  /  04  /  05  /  06  /
  - ---- - ---- - ---- - ---- - ---- - ---- - ---- -
  |      |      |      |      |      |      |      |
  - ---- - ---- - ---- - ---- - ---- - ---- - ---- -
  |      |      |      |      |      |      |      |
  - ---- - ---- - ---- - ---- - ---- - ---- - ---- -
  |      |      |      |      |      |      |      |
  - ---- - ---- - ---- - ---- - ---- - ---- - ---- -
  |      |      |      |      |      |      |      |
  - ---- - ---- - ---- - ---- - ---- - ---- - ---- -
  |      |      |      |      |      |      |      |
  - ---- - ---- - ---- - ---- - ---- - ---- - ---- -
  |      |      |      |      |      |      |      |
  - ---- - ---- - ---- - ---- - ---- - ---- - ---- -
```

## Funcionament General

El programa principal es el main. En aquest fragment de codi s'introdueixen les dades necessaries per a configurar el joc i es decideix qui comença a jugar, si la maquina o l'usuari (de manera aleatoria).

Posteriorment, les funcions mouMaquina i mouPersona s'encarreguen d'anar jugant cada torn.

En el meu cas, el Tauler es representa com una llista de llistes de Strings. Cada posició buida del tauler, internament està representada amb un nombre que l'identifica. És a dir, internament el tauler anterior es veuria de la següent forma:

```
  /  00  /  01  /  02  /  03  /  04  /  05  /  06  /
  - ---- - ---- - ---- - ---- - ---- - ---- - ---- -
  |  00  |  01  |  02  |  03  |  04  |  05  |  06  |
  - ---- - ---- - ---- - ---- - ---- - ---- - ---- -
  |  07  |  08  |  09  |  10  |  11  |  12  |  13  |
  - ---- - ---- - ---- - ---- - ---- - ---- - ---- -
  |  14  |  15  |  16  |  17  |  18  |  19  |  20  |
  - ---- - ---- - ---- - ---- - ---- - ---- - ---- -
  |  21  |  22  |  23  |  24  |  25  |  26  |  27  |
  - ---- - ---- - ---- - ---- - ---- - ---- - ---- -
  |  28  |  29  |  30  |  31  |  32  |  33  |  34  |
  - ---- - ---- - ---- - ---- - ---- - ---- - ---- -
  |  35  |  36  |  37  |  38  |  39  |  40  |  41  |
  - ---- - ---- - ---- - ---- - ---- - ---- - ---- -
```
Degut a aquesta implementació, em resulta més comode i senzill, modificar elements dins el tauler, cercar linies de 4 o més fitxes iguales, entre altres coses.


## Algorsimes interessants

### Moure fitxa
Al llarg de tota la partida, el programa treballa amb una llista de posicions. Aquesta llista de posicions (opcions) correspont a les posicions que es poden marcar en aquest moment. D'aquesta manera és més fàcil comprovar si la casella que volem marcar es pot marcar o no. A cada nova tirada, obviament, aquesta llista s'actualiza per a poder adaptar-se al nou tauler.


### Càlcul de Partida Guanyada

Donat que aquest càlcul el fem per cada torn, només cal que comprovem si a la fila, columna i diagonals que fan referencia a la posició que anem a marcar, hi trobem alguna linia de 4 o més. D'aquesta manera ens estalviem haver de mirar tot el tauler i haver de comprovar totes les fitxes a cada torn. Per a comprovar si tenim una linia de 4 o més en horitzontal i vertical ha estat fàcil, ja que el tauler es defineix com una llista de files. Per tant, per a trobar les horitzontals només hem hagut de buscar la fila corresponent i buscar si teniem alguna linia, i per les verticals, hem hagut de trasposar el tauler, i mirar la columna que tocava.

Per l'altra banda, les diagonals, no han estat tan fàcils de trobar. Per això, primer he hagut calcular quines son les posicions que corresponent a les diagonals ascendent i descendent que conten la posicio en questio.

### Càlcul del Heuristic

Tant en l'estrategia Greedy com la Smart (explicades més tard), requereixen de un heuristic per a poder quantificar la calitat de la solució proposada en cada moment. En aquest cas, he utilitzat per a calcular el  heuristic el nombre màxim de fitxes consecutives que pot conseguir un jugador col·locant una fitxa en una posició donada. Gràcies a aquest heurístic podem valorar quina solució és millor que una altra. Per a poder calcular aquest estimador, he buscat la manera de que el seu valor sigui 1 sempre que la maquina pugui guanyar, sigui -1 quan la maquina està a punt de perdre i que sigui 0 quan la partida no estigui decidida encara. D'aquesta manera en el cas del Greedy, la maquina es capaç de saber quan esta a punt de guanyar o quan està a punt de perdre. Per l'altra banda, en el cas de Smart, com que explorem futures jugades, aquest algorisme es capaç de detectar quines jugades l'avoquen a una derrota, a una victoria o simplement a un altre estat de la partida sense finalitzar (ja que només explorem fins a certa profunditat, degut a les limitacions del hardware).
 

## Estratègies
Per a poder passa per parametre l'estrategia, algunes d'elles tenen una segona funció que encapsula la l'algorisme per a poder retornar el mateix tipus d'informació en totes les estrategies.

### Random

En aquesta estratègia la maquina decideix de manera aleatoria quina és la casella ha marcar. Com que aquesta funció ja retorna un IO STring no ha fet falta implementar cap funció auxiliar

```
aleatoriIO :: [Posicio] -> Tauler -> IO String
```

### Greedy

Aquesta estratègia consisteix a mirar de totes les possibles jugades que pot fer la maquina en aquest moment i triar la que millor li vagi. La diferencia entre aquesta estratègia i la smart es que aquesta última escull la millor opció en base al torn que s'està jugant, i també en base a les possibles jugades que pugui fer tant l'oponent com la pròpia maquina en un futur. 

En aquesta estratègia fem ser heurístics per a valorar la calitat de cada solució (jugada). En aquest algorisme intentem buscar un equilibri entre aquella jugada que és més beneficiosa per a la maquina i aquella que molesta més al adversari. Depenent del estat de la partida, calcula que és el que més ens convé, si sumar punts o evitar que l'oponent sumi punts.

Com que aquesta funció retornava un Posició (String) i feia falta que retornés un IO String, ha estat necessari una funció auxiliar que encapsulés el algorisme i retornés un IO String

```
greedy :: [Posicio] -> Tauler -> Posicio

greedyIO :: [Posicio] -> Tauler -> IO String
```

### Smart

Aquesta estratègia consisteix a generar un arbre de futures jugades. Depenent de la mida del tauler fixem una profunditat màxima de l'arbre o una altre. En aquest arbre trobem que cada node te un valor heuristic que evalua el estat de la partida en aquell futur tauler. 

L'heuristic és un valor que podrà ser -1,1 o 0 on -1 representa que la partida està perduda, 1 representa que la partida està guanyada i per una altra banda 0 si la partida encara no està decidida. 

Un cop he tingut l'arbre generat amb tots els heuristics, he implementat l'algorisme minmax per a poder decidir quina es la millor ruta ha seguir per a poder conseguir el millor resultat en la partida. Aquest algorisme el que fa és, recorrer per nivells de profunditat l'arbre i va modificant els valors dels nodes per a maximitzar o minimitzar els seus valors.

Com que aquesta funció retornava un Posició (String) i feia falta que retornés un IO String, ha estat necessari una funció auxiliar que encapsulés el algorisme i retornés un IO String

```
smart :: [Posicio] -> Tauler -> Posicio

smartIO :: [Posicio] -> Tauler -> IO String
```
## Observacions

Donat que el temps per a fe aquesta pràctica ha estat limitat, no he pogut implementar totes les funcionalitats que m'agradaria haver implementat si hagués tingu més temps. Per exemple m'hauria agradat portar un pas més enllà l'heuristic de les funcions greedy i smart. M'hauria agradat poder fer un heuristic que dongués encara més informació de manera que alhora de triar tingués més coses en compte, per així millorar la qualitat de la resposta.



## Authors

* **Marc Domènech i Vila** - *Initial work* - [MarcDV1999](https://github.com/MarcDV1999)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Gràcies al meu germà que s'ha dedicat a viciar-se al joc per a poder comprovar que tot funciona com hauria de funcionar.

