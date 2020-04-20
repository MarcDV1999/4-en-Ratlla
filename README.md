# 4-en-Ratlla
Pràctica de Haskell de l'assignatura de Llenguatges de Programació de la Facultat d'Informàtica de Catalunya

## Instruccions

En aquest projecte trobareu un arxiu .hs al qual podreu compilar executant la comanda ghc *.hs


## Calcul de quines son les possibles jugades a fer
Per saber en qualsevol torn quines possibilitats de jugada tenim, el que he fet ha estat tenir en tot moment una llista amb les possibles caselles que poden ser marcades. D'aquesta manera he evutat que una persona o la maquina pugui escollir moure una fitxa a una casella que no te sentit (Per exemple moure una fitxa sense estar tapada la fitxa de sota). 


## Calcul de si hem guanyat o no
Donat que aquest calcul el fem per cada moviment que fem, només cal que comprovem si la fila,columna i diagonals que fan referencia a aquesta posicio formen una linia de 4. D'aquesta manera ens estalviem haver de mirar tot el tauler i haver de comprovar tptes les fitxes.

## Introduir les dades
Alhora de jugar cal que introduim la fila en la qual volem deixar caure la nostra fitxa, el programa ja s'encarrega de deixarla caure a la posicio que li correspon

## A cada nova tirada
A cada nou moviment que fem, després de comprovar que sigui un moviment valid, actualitzem el nou llistat de possibles jugades a fer.

### Prerequisites

What things you need to install the software and how to install them

```
Give examples
```

### Installing

A step by step series of examples that tell you how to get a development env running

Say what the step will be

```
Give the example
```

And repeat

```
until finished
```

End with an example of getting some data out of the system or using it for a little demo

## Running the tests

Explain how to run the automated tests for this system

### Break down into end to end tests

Explain what these tests test and why

```
Give an example
```

### And coding style tests

Explain what these tests test and why

```
Give an example
```

## Deployment

Add additional notes about how to deploy this on a live system

## Built With

* [Dropwizard](http://www.dropwizard.io/1.0.2/docs/) - The web framework used
* [Maven](https://maven.apache.org/) - Dependency Management
* [ROME](https://rometools.github.io/rome/) - Used to generate RSS Feeds

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* **Billie Thompson** - *Initial work* - [PurpleBooth](https://github.com/PurpleBooth)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Hat tip to anyone whose code was used
* Inspiration
* etc
