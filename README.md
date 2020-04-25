# 4-en-Ratlla
Pràctica de Haskell de l'assignatura de Llenguatges de Programació de la Facultat d'Informàtica de Barcelona

## Instruccions

En aquest projecte trobareu un arxiu .hs el qual podreu compilar i executar.

### Instal·lació i execució

Com compilar el projecte

```
ghc 4enRalla.hs
```

Per executarlo

```
./4enRalla
```

## Desenvolupament de la pràctica

### Funcionament General

#### Començar a jugar?

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


#### A cada nova tirada
A cada nou moviment que fem, després de comprovar que sigui un moviment valid, actualitzem el nou llistat de possibles jugades a fer.

#### Introduir les dades
Alhora de jugar cal que introduim la fila en la qual volem deixar caure la nostra fitxa, el programa ja s'encarrega de deixarla caure a la posicio que li correspon

#### Calcul de quines son les possibles jugades a fer
Per saber en qualsevol torn quines possibilitats de jugada tenim, el que he fet ha estat tenir en tot moment una llista amb les possibles caselles que poden ser marcades. D'aquesta manera he evutat que una persona o la maquina pugui escollir moure una fitxa a una casella que no te sentit (Per exemple moure una fitxa sense estar tapada la fitxa de sota). 


### Estratègies

#### Random

Aquí explicaré com he programat l'estratègia Random

#### Greedy

Aquí explicaré com he programat l'estratègia Greedy

#### Smart

Aquí explicaré com he programat l'estratègia Smart

### Càlcul de Partida Guanyada

#### Calcul de si hem guanyat o no

Donat que aquest càlcul el fem per cada moviment que fem, només cal que comprovem si la fila,columna i diagonals que fan referencia a aquesta posicio formen una linia de 4. D'aquesta manera ens estalviem haver de mirar tot el tauler i haver de comprovar tptes les fitxes.






## Authors

* **Marc Domènech i Vila** - *Initial work* - [MarcDV1999](https://github.com/MarcDV1999)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Gràcies al meu germà que s'ha dedicat a viciar-se al joc per a poder comprovar que tot funciona com hauria de funcionar.

