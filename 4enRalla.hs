import System.IO
import Data.List
import System.Random

-------- Tipus de Dades 

type Tauler = [Fila]        -- Llista de Files
type Posicio = String       -- Posicio en format String, representant un nombre de 2 xifres
type Fila = [Posicio]       -- Llista on cada element es una posicio de una fila


data Arbre a = Arbre a [Arbre a] deriving (Show,Eq,Ord)         -- El fem servir per a l'estrategia Smart
data Jugador = Persona | Maquina | Ningu deriving (Show,Eq)     -- El fem servir per a identificar accions








------------------------   Configuracio    ------------------------


-- Assignem quantes fitxes seguides iguales son considerades una linia
linia :: Int
linia = 4








------------------------    Programes Principals    ------------------------

-- Recollim les dades inicials i decidim qui tira primer de manera aleatoria
main :: IO()
main = do
    putStrLn "\n\nBENVINGUT AL 4 EN RATLLA by MARC DOMENECH\n"
    
    -- Llegim les dades necessaries per a poder jugar
    putStrLn "Introdueixi el nombre de files: "
    f <- getLine

    putStrLn "Introdueixi el nombre de columnes: "
    c <- getLine

    putStrLn "Introdueixi la dificultat:\n0: Facil\n1: Dificil\n2: Super Dificil\n"
    d <- getLine

    let files = read f
    let columnes = read c
    let dificultat = read d
    let opcionsInicials = (novesOpcionsIni files columnes)

    -- Si les dades introduides son erronies, tornem a demanarles, sino comencem a jugar
    if files < linia || columnes < linia || dificultat > 2 then do 
        putStrLn "Files ha de ser >= a 4\nColumnes ha de ser >= 4\nDificultat ha de ser <= 2"
        main
    else do
        putStrLn "\nLa teva fitxa es -> XX\n"

        -- Definim l'estrategia i el tauler inicial
        let taulerIni = (taulerInicialDif files columnes)
        let estrategia = case dificultat of
                            0 -> aleatoriIO
                            1 -> greedyIO
                            2 -> smartIO

        -- Pintem el tauler buit
        putStrLn (pintaTauler taulerIni)

        -- Decidim qui tira primer
        r1 <- randInt 0 1
        if r1 == 0 
            then mouPersona estrategia opcionsInicials taulerIni
            else mouMaquina estrategia opcionsInicials taulerIni
    return ()


-- Donada una estrategia per a la Maquina, unes opcions i el tauler, la Persona mou fitxa
mouPersona :: ([Posicio] -> Tauler -> IO String) -> [Posicio] -> Tauler ->  IO()
mouPersona estrategia opcions tauler = do

    putStrLn "-> Et toca Jugar!"
    putStrLn "-> Tria la columna on vols deixar caure la teva fitxa (La teva fitxa es -> XX): "

    -- Calculem la posicio que vol marcar l'usuari
    x <- getLine
    let pos = calcularPos (addZero x) opcions

    -- Si la posicio es valida aleshores calculem el nou tauler
    if pucMarcar pos opcions then do
        let nouTauler = replace' pos "XX" tauler
        let opcionsActualitzadas = (novesOpcions pos opcions)
        
        putStrLn "\n"
        putStrLn (pintaTauler nouTauler)

        -- Comprovem que la partida no hagi acabat, sino seguim jugant
        if (tablas opcionsActualitzadas) then guanyaPartida Ningu 
        else if (partidaGuanyada pos Persona nouTauler) then guanyaPartida Persona 
        else mouMaquina estrategia opcionsActualitzadas nouTauler

    else do
        putStrLn "!!!! No pots marcara aquesta fila, selecciona una altra !!!!\n"
        mouPersona estrategia opcions tauler
    return ()


-- Donada una estrategia, unes opcions i el tauler, la Maquina mou fitxa
mouMaquina :: ([Posicio] -> Tauler -> IO String) -> [Posicio] -> Tauler ->  IO()
mouMaquina estrategia opcions tauler = do

    -- Calculem la posicio a marcar en base a l'estrategia que fem servir
    x <- estrategia opcions tauler
    let pos = addZero x
    
    if pucMarcar pos opcions then do
        --print (smart2 opcions tauler)

        putStrLn "-> Juga la Maquina"
        putStrLn ("-> La Maquina marca la fila: " ++ (show ((read pos) `mod` (length opcions))))

        -- Calculem el nou tauler i les noves caselles disponibles per al seguent torn
        let nouTauler = replace' pos "··" tauler
        let opcionsActualitzadas = (novesOpcions pos opcions)
        
        putStrLn "\n"
        putStrLn (pintaTauler nouTauler)
        

        -- Comprovem que la partida no hagi acabat, sino seguim jugant
        if (tablas opcionsActualitzadas) then guanyaPartida Ningu 
        else if (partidaGuanyada pos Maquina nouTauler) then guanyaPartida Maquina
        else mouPersona estrategia opcionsActualitzadas nouTauler
    
    else mouMaquina estrategia opcions tauler

    return ()








------------------------    Estrategia Random    ------------------------


-- Donat un conjunt de possibles caselles a tapar i un tauler, retorna una posicio aleatoria valida
aleatoriIO :: [Posicio] -> Tauler -> IO String
aleatoriIO opcions tauler = do
    -- Treiem una columna aleatoria
    r1 <- randInt 0 ((length opcions)-1)
    
    -- Calculem la casella que s'ha de tapar
    let r1Str = addZero $ show r1
    let pos = calcularPos r1Str opcions
    return (pos)







------------------------    Estrategia Smart    ------------------------


-- Donat un conjunt d'opcions i el tauler actual, ens retorna la millor posicio
-- utilitzant l'estrategia smart (Algorisme minMax)
smart :: [Posicio] -> Tauler -> Posicio
smart opcions tauler =  millorPos2 where 

    -- Generem el arbre inicial amb els resultats dels heuristics
    arbreIni = crearArbre 0 opcions tauler

    -- Agafem el arbre inicial i apliquem l'algorisme minMax
    arbre = minMax 0 arbreIni

    -- Obtenim els heuristics de la seguent tirada i mirem quin ens conve mes.
    heuristicsFills = map arrelArbre (fillsArbre arbre)
    heuristics  = if (length heuristicsFills > 0) then heuristicsFills else [arrelArbre arbre]
    maxim = maximum heuristics
    maxIndex = elemIndices maxim heuristics
    maxIndexFactible = if length maxIndex > 0 then [x | x <- maxIndex , (pucMarcar (opcions!!x) opcions)] else []

    -- De totes les opcions que son igual de bones, escollim aquella 
    -- que sigui millor en el estat actual
    millorsPos = if (length maxIndexFactible > 0) then map (\a -> opcions!!a) maxIndexFactible else []
    millorPos = if (length heuristics == 1) then greedy opcions tauler else greedy millorsPos tauler
    
    -- Si veiem que no tenim una millor opcio, que agafi la primera que pugui
    millorPos2 = if millorPos == "-1" then [x | x <- opcions,x /= "-1"]!!0 else millorPos


-- Aquesta funcio encapsula la funcio greedy per a que pugui ser passada per parametre posteriorment al moure una fitxa
-- Transforma el resultat String en un IO String
smartIO :: [Posicio] -> Tauler -> IO String
smartIO opcions tauler = do
    return (smart opcions tauler)


-- Retorna -1 si guanya el adversari, 1 si guanyem nosaltres o 0 si no guanya ningu
heuristicSmart :: Jugador -> [Posicio] -> Tauler -> Int
heuristicSmart j opcions tauler = if j == Persona then hPersona else hMaquina where

    -- Llista amb els valors dels heuristics per cada posicio. (Exemple: [3,2,2,1] -> marcant la pos 0 conseguiria un 3 en linia)
    heuristicP = map (\a -> millorJugada a Persona tauler) opcions
    heuristicM = map (\a -> millorJugada a Maquina tauler) opcions

    -- Mirem quin es el millor resultat que podem obtenir
    millorResultatP = maximum heuristicP        
    millorResultatM = maximum heuristicM

    -- Conseguim els indexos de les posicions que ens poden conseguir aquest millor resultat
    indexosValorsP = elemIndices millorResultatP heuristicP
    indexosValorsM = elemIndices millorResultatM heuristicM

    -- Calculem quantes linies de 4 pot fer cadascu
    molestarAP = if length indexosValorsP <= 1 then True else False
    molestarAM = if length indexosValorsM <= 1 then True else False

    -- Calculem el Heuristic en funcio de qui estigui jugant
    -- Si el que juga te linia de 4 aleshores guanya ->  = 1
    -- Si el oponent te linia de 4 i no podem bloquejar totes les seves linies aleshores perdem -> = -1
    -- En qualsevol altre cas, no tenim guanyador ni perdedor
    hPersona = if (millorResultatP >= linia) then -1 else if (millorResultatM >= linia && (not molestarAM)) then 1 else 0   -- Juga Persona
    hMaquina = if (millorResultatM >= linia) then 1 else if (millorResultatP >= linia && (not molestarAP)) then -1 else 0


-- Donat una profunditat, opcions actuals i el tauler, genera el arbre de possibilitats amb una 
-- profunditat maxima i posant als nodes el valor del heuristic que correspon a cada context
crearArbre :: Int -> [Posicio] -> Tauler -> Arbre Int
crearArbre prof opcions tauler 
    | valor /= 0 = Arbre valor [] 
    | prof == profMax && even profMax = Arbre (heuristicSmart Maquina opcions tauler) [] 
    | prof == profMax && odd profMax = Arbre (heuristicSmart Persona opcions tauler) [] 
    | otherwise = Arbre valor subArbre
    where
    profMax = (maxProf columnes)
    columnes = length opcions
    j = if even prof then Maquina else Persona
    fitxa = if j == Maquina then "··" else "XX"        -- Si estem a un nivell parell esque li toca decidir a la maquina

    -- Generem el llistat de futurs taulers i opcions per tauler
    llistaNousTaulers = map (\pos -> replace' pos fitxa tauler) opcions
    llistaNovesOpcions = (map (\pos -> novesOpcions pos opcions) opcions)

    -- Creem el subarbre recursivament
    subArbre = map (\pos -> crearArbre (prof+1) (novaOpcio pos) (nouTauler pos)) opcions where
        nouTauler p =  replace' p fitxa tauler
        novaOpcio p =  novesOpcions p opcions

    -- Calculem el valor del node arrel amb l'heuristic de la Maquina o de la Persona, depenent de
    -- a quina profunditat ens trobem
    valor = if even prof then heuristicSmart Maquina opcions tauler else heuristicSmart Persona opcions tauler 


-- Donat un arbre amb els heuristics, aplica l'algorisme minmax per a recalcular els valors dels nodes
minMax :: Int -> Arbre Int -> Arbre Int
minMax _ (Arbre arrel []) = (Arbre arrel [])
minMax prof (Arbre arrel fills) = Arbre root successors where
    -- L'arrel d'un arbre la calcularem com el maxim o miniim dels fills, depenent de qui sigui el torn
    -- Els successors els calculem, cridant recursivament a la funcio
    maximFills = if length fills > 0 then maximum fills else Arbre 0 []
    minimFills = if length fills > 0 then minimum fills else Arbre 0 []
    root = (arrelArbre (if even prof then maximFills else minimFills))
    successors = map (minMax (prof+1)) fills


-- Donat un arbre, ens retorna la seva arrel
arrelArbre :: Arbre a -> a
arrelArbre (Arbre arrel _) = arrel


-- Donat un arbre ens retorna els seus fills
fillsArbre :: Arbre a -> [Arbre a]
fillsArbre (Arbre _ fills) = fills


-- Donat el nombre de columnes del tauler, calcula quina seria la profunditat maxima que podem tolerar
-- per a que el algorisme smart no trigui massa temps en decidir
maxProf :: Int -> Int
maxProf columnes
    | columnes == 4 = 7
    | columnes <= 6 = 5
    | columnes <= 8 = 4
    | columnes <= 11 = 3
    | columnes <= 20 = 2
    | otherwise = 1







------------------------    Estrategia Greedy    ------------------------

-- Donat un conjunt d'opcions i el tauler actual, ens retorna la millor posicio
-- utilitzant l'estrategia greedy (Mirant quina es la millor opcio en el context actual)
greedy :: [Posicio] -> Tauler -> Posicio
greedy opcions tauler =  if posPerGuanyar /= "-1" then posPerGuanyar else if posABloquejar == "-1" then nomesMillor else posABloquejar where

    -- Llista amb els valors dels heuristics per cada posicio. (Exemple: [3,2,2,1] -> marcant la pos 0 conseguiria un 3 en linia)
    heuristicP = map (\a -> millorJugada a Persona tauler) opcions
    heuristicM = map (\a -> millorJugada a Maquina tauler) opcions

    maxM = if maximum heuristicM > linia then maximum heuristicM else linia

    valorDecisiuM = elemIndices maxM heuristicM
    posPerGuanyar = if length valorDecisiuM > 0 then opcions!!(valorDecisiuM!!0) else "-1" -- Posicio que hauriem de marcar per fer una linia

    -- Llista per saber si el oponent esta a punt de fer una linia 
    maxP = if maximum heuristicP > linia then maximum heuristicP else linia
    valorsABloquejarP = elemIndices maxP heuristicP             -- Llista de indexos que fariesn 4 en linia
    posABloquejar = if length valorsABloquejarP > 0 then opcions!!(valorsABloquejarP!!0) else "-1" -- Posicio que hauriem de bloquejar per evitar una linia

    -- Mirem quin es el millor resultat que podem obtenir
    millorsOpcions1 = maximum heuristicP        
    millorsOpcions2 = maximum heuristicM

    -- Conseguim els indexos de les posicions que ens poden conseguir aquest millor resultat
    indexosValors1 = elemIndices millorsOpcions1 heuristicP
    indexosValors2 = elemIndices millorsOpcions2 heuristicM

    -- Llista de les millors Posicions per a conseguir la millor puntuacio
    millorsPos1 = map (\a -> opcions!!a) indexosValors1
    millorsPos2 = map (\a -> opcions!!a) indexosValors2

    -- De les millors opcions triem aquella que perjudiqui mes al rival
    millor = map (\m -> if m `elem` millorsPos1 then m else "") millorsPos2
    coincidents = [x | x <- millor, x /= ""] 

    -- Conseguim la millor opcio que permeti tenir la millor puntuacio i que perjudiqui mes al altre (en aquesta tirada)
    nomesMillor = if (length coincidents) > 0 then coincidents!!0 else millorsPos2!!0


-- Aquesta funcio encapsula la funcio greedy per a que pugui ser passada per parametre posteriorment al moure una fitxa
-- Transforma el resultat String en un IO String
greedyIO :: [Posicio] -> Tauler -> IO String
greedyIO opcions tauler =  do

   return (greedy opcions tauler)


-- Retrona la mida de la linia mes gran que podem fer posant la fitxa a la casella pos
millorJugada :: Posicio -> Jugador -> Tauler -> Int
millorJugada "-1" _ _ = -1
millorJugada pos j tauler = max (max hFila hColumna) hDiagonal where 
    fitxa = if j == Persona then "XX" else "··"
    nouTauler = replace' pos fitxa tauler

    -- Agrupo les files i em quedo nomes amb les agrupacions de les fitxes que vui mirar
    enFila = map group nouTauler                                                  
    enFilaFitxa = map (filter (==fitxa)) (concat enFila)                        
    
    -- Conto quantes agrupacions hi han de 4 o mes elements i calculem quina es la linia mes gran que podem fer en horitzontal
    enFilaLinies = reverse $ sort [x | x <- enFilaFitxa, x /= []]                        
    hFila = if (length $ enFilaLinies!!0) > 0 then length $ enFilaLinies!!0 else 0           
    
    -- Agrupo les columnes i em quedo nomes amb les agrupacions de les fitxes que vui mirar
    enCol = map (group) (transpose nouTauler)                                   
    enColFitxa = map (filter (==fitxa)) (concat enCol)                          

    -- Conto quantes agrupacions hi han de 4 o mes elements i calculem quina es la linia mes gran que podem fer en vertical
    enColLinies = reverse $ sort [x | x <- enColFitxa, x /= []]                      
    hColumna = if (length $ enColLinies!!0) > 0 then length $ enColLinies!!0 else 0   

    -- Calculem quina es la linia mes gran que podem fer en diagonal
    hDiagonal = heuristicDiagonal pos j nouTauler        








--------    Funcions de Comprovacio o actualitzacio de variables


-- Calculo quina casella volem marcar, donada la columna on volem deixar caure la fitxa
calcularPos :: Posicio -> [Posicio] -> Posicio
calcularPos pos opcions 
    | (num < columnes) = addZero $ opcions!!num
    | otherwise = "-1"
    where 
        num = read pos
        columnes = length opcions


-- Ens dona un llistat amb totes les possibles opcions noves despres de marcar la posicio pos
novesOpcions :: Posicio -> [Posicio] -> [Posicio]
novesOpcions pos opcionsActuals = map (\x -> if x == pos then novaPos else x) opcionsActuals where 
    columnes = length opcionsActuals
    num = read pos
    novaPos = if (num - columnes) < 0 then "-1" else addZero $ show (num - columnes)


-- Ens Retorna True o False en funcio de si podem marcar o no la posicio
pucMarcar :: Posicio -> [Posicio] -> Bool
pucMarcar pos opcions = if pos `elem` opcions && pos /= "-1" then True else False








------------------------    Calcul de partida guanyada    ------------------------

-- Retrona True si posant la fitxa a pos, es fa un 4 en linia en qualsevol direccio
partidaGuanyada :: Posicio -> Jugador -> Tauler -> Bool 
partidaGuanyada pos j tauler =  if any liniaDe4 enFilaFitxes || any liniaDe4 enColFitxes || enDiagonal then True else False where 
    fitxa = if j == Persona then "XX" else "··"
    liniaDe4 = (\a -> length a >= linia)

    -- Agrupo les files i em quedo nomes amb les agrupacions de les fitxes que vui mirar
    enFila = map (group) tauler                             
    enFilaFitxes = map (filter (==fitxa)) (concat enFila)        

    -- Agrupo les columnes i em quedo nomes amb les agrupacions de les fitxes que vui mirar
    enColumna = map (group) (transpose tauler)              
    enColFitxes = map (filter (==fitxa)) (concat enColumna)

    -- Calculem la linia mes gran que pot fer en diagonal
    enDiagonal = diagonal pos j tauler                      


-- Retorna una llista amb la diagonal descendent de la posicio pos del tauler
calcularDiagonalDown :: Posicio -> Tauler -> [Posicio]
calcularDiagonalDown pos tauler = result where
    num = read pos
    columnes = length (tauler!!0)
    limit = columnes
    maxElem = ((length tauler) * columnes) - 1
    offsetDown = limit + 1
    offsetUp = limit - 1
    c = num `mod` columnes
    taulerLlista = concat tauler

    -- Fem una llista amb les posicions que es troben a la diagonal per sota i a sobre de pos.
    dUp = (dropWhile (\x ->  x `mod` columnes > c) (reverse [num,num-offsetDown..0]))
    dDown = (reverse (dropWhile (\x -> x `mod` columnes < c) (reverse [num+offsetDown,num+(2*offsetDown)..maxElem])))
    
    -- Busquem les posicions anteriors en el tauler i mirem si hi han fitxes marcades en elles
    dUpString =  map (\x -> if taulerLlista!!x == "XX" then "XX" else if taulerLlista!!x == "··" then ".." else addZero $ show x) dUp
    dDownString =  map (\x -> if taulerLlista!!x == "XX" then "XX" else if taulerLlista!!x == "··" then "··" else addZero $ show x) dDown
    
    -- Tornem la diagonal ascendent amb els valors del tauler
    result = dUpString ++ dDownString


-- Retorna una llista amb la diagonal ascendent de la posicio pos del tauler
calcularDiagonalUp :: Posicio -> Tauler -> [Posicio]
calcularDiagonalUp pos tauler = result where
    num = read pos
    columnes = length (tauler!!0)
    limit = columnes
    maxElem = ((length tauler) * columnes) - 1
    offsetDown = limit + 1
    offsetUp = limit - 1
    c = num `mod` columnes
    taulerLlista = (concat tauler)

    -- Fem una llista amb les posicions que es troben a la diagonal per sota i a sobre de pos.
    dUp =  (dropWhile (\x -> x `mod` columnes < c) (reverse (take (limit-1) [num-offsetUp,num-(2*offsetUp)..0])))
    dDown =  (reverse (dropWhile (\x -> x `mod` columnes > c) (reverse (take limit ([num,num+offsetUp..maxElem])))))
    
    -- Busquem les posicions anteriors en el tauler i mirem si hi han fitxes marcades en elles
    dUpString =  map (\x -> if taulerLlista!!x == "XX" then "XX" else if taulerLlista!!x == "··" then "··" else addZero $ show x) dUp    
    dDownString =  map (\x -> if taulerLlista!!x == "XX" then "XX" else if taulerLlista!!x == "··" then "··" else addZero $ show x) dDown
   
    -- Tornem la diagonal ascendent amb els valors del tauler
    result = reverse (dUpString ++ dDownString)


-- Ens diu si hi ha alguna diagonal amb centre pos, que tingui un 4  en linia
diagonal :: Posicio -> Jugador -> Tauler -> Bool
diagonal pos j tauler = if (length dUpLinies) > 0 || (length dDownLinies) > 0 then True else False where
    fitxa = if j == Persona then "XX" else "··"

    -- Ens dona una llista de grups de fitxes seguides
    dUp = calcularDiagonalUp pos tauler                         
    dDown = calcularDiagonalDown pos tauler                     

    -- Filtro per a nomes quedarnos amb grups de 4 o mes fitxes seguides
    dUpLinies = [x | x <- (group dUp),length x >= linia]        
    dDownLinies = [x | x <- (group dDown),length x >= linia]    


-- Donada una posicio, un jugador i un tauler, ens retorna el numero maxim de fitxes en diagonal
-- que conseguiriem, posant la fitxa a la posicio pos.
heuristicDiagonal :: Posicio -> Jugador -> Tauler ->  Int
heuristicDiagonal pos j tauler = hDiagonal where 
    fitxa = if j == Persona then "XX" else "··"
    nouTauler = replace' pos fitxa tauler

    -- Agafem les posicions que es troben a la diagonal ascendent i descendent
    dUp = calcularDiagonalUp pos nouTauler                              
    dDown = calcularDiagonalDown pos nouTauler                          

    -- Agrupem les fitxes per a saber si trobarem alguna linia
    dUpLinies = [x | x <- (group dUp), x /= []]                         
    dDownLinies = [x | x <- (group dDown), x /= []]                     

    -- Nomes ens quedem amb les fitxes que ens interessin depenent de qui jugui
    dUpLiniesFitxes = map (filter(==fitxa)) dUpLinies                   
    dDownLiniesFitxes = map (filter(==fitxa)) dDownLinies               

    -- Mirem si trobem alguna linia de 4 o mes
    dUpLinia4 = any (\a -> length a >= linia) dUpLiniesFitxes           
    dDownLinia4 = any (\a -> length a >= linia) dDownLiniesFitxes       

    -- Ordenem per a que ens quedi la linia mes gran a la primera posicio
    diagonals = reverse $ sort (dUpLiniesFitxes ++ dDownLiniesFitxes)   
         
    -- Retornem la mida de la linia mes gran                                                                
    hDiagonal = if (length $ diagonals!!0) > 0                          
                    then length $ diagonals!!0 
                    else 0    






------------------------    Funcions d'inicialitzacio    ------------------------

-- Inicialitza un Tauler, on a totes les caselles els hi assigna un numero (tot i que després no es mostri)
-- Per un tauler de 4 x 4 seria [["00","01","02","03"],["04","05","06","07"],["08","09","10","11"],["12","13","14","15"]]
taulerInicialDif :: Int -> Int -> Tauler
taulerInicialDif fil col = splitEvery col (map addZero llistaPos) where 
    mida = fil*col                      
    llistaPos = map show [0..mida-1]    -- Tauler desplegat on cada element es una posicio del tauler 


-- Ens dona un llistat amb les posibles posicions on podem jugar al principi de la partida
-- Per un tauler de 4 x 4 serien la llista ["12","13","14","15"]
novesOpcionsIni :: Int -> Int -> [Posicio]
novesOpcionsIni files col =  map addZero llista where
    primer = (files * col) - col
    ultim = (files * col) - 1
    llista = (map show [x | x <- [primer..ultim]])








------------------------    Funcions per a pintar el Tauler    ------------------------


-- Donat el nombre de columnes, genera un separador de files
pintaSeparadors :: Int -> String
pintaSeparadors col = (take (mida*col) $ cycle patro) ++ "-" where 
    patro = "- ---- "
    mida = length patro


-- Donat una Fila ["1","2","3"] per exemple, el converteix per a que quedi maco "|  01  |  02  |  03  |"
pintaFila :: Fila -> String
pintaFila  s = "  |  " ++ (intercalate "  |  " x) ++ "  |" where 
    x = map (\x -> if (x /= "XX") && (x /= "··") then "  " else x) s


-- Donat un Tauler, retorna el String amb el tauler ben posat, preparat per a ser mostrar per terminal
pintaTauler :: Tauler -> String 
pintaTauler  ll = "  " ++ pintaX mida ++ separador ++ (intercalate separador valorsFila) ++ separador where 
    mida = length (ll!!0)                                   -- Mida del separador
   
    separador = "\n  " ++(pintaSeparadors $ mida)++"\n"     -- Separador entre fila i fila
    valorsFila = (map pintaFila ll)                         -- Convertim cada String en una fila ben maca
    --valorsFila = pintaY (map pintaFila ll)                -- Convertim cada String en una fila ben maca amb Indexos a l'esquerra


-- Retorna una fila on apareixen els numeros de les columnes
-- La faig servir per a afegir els indexos de les columnes a sobre el tauler
pintaX :: Int -> String
pintaX col = "/  " ++ (intercalate "  /  " fila) ++ "  /"  where 
    llistaPos = map show [0..col-1]
    fila = map addZero llistaPos 


-- Modifica la llista per a que apareguin els numero de la fila al principi ["XX·"] -> ["1XX·"]
-- Si volguessim que apareeguessin els indexs de les files caldria utilitzar aquesta funcio
pintaY :: Fila -> [String]
pintaY ll = zipWith (++) (words (toString [0..mida-1])) ll where mida = length ll








------------------------    Funcions de finalitzacio de la partida    ------------------------


-- Mostra qui ha guanyat la partida i finalitza el programa
guanyaPartida :: Jugador -> IO()
guanyaPartida j = do
    putStrLn "\nFi de la Partida"
    if j == Persona then putStrLn "HAS GUANYAT!!! ;)\n" else if (j == Ningu) then putStrLn "Heu Empatat :(\n" else putStrLn "Has perdut :(\n"
    return ()


-- Donat un conjunt de opcions, ens diu si l'ha partida ha acabat en taules o no
tablas :: [Posicio] -> Bool
tablas opcions = all (=="-1") opcions -- Hi ha taules quan totes les opcions son -1








------------------------    Estrategia Random Funcions Auxiliars


-- Retorna un nombre aleatori
randInt :: Int -> Int -> IO Int
randInt low high = do
    random <- randomIO :: IO Int
    let result = low + random `mod` (high - low + 1)
    return result


-- Donat un String, si el nombre es d'una xifra li afegeix un zero a l'esquerra, sino el deixa igual
addZero :: String -> Posicio
addZero s = if length s <= 1 then "0"++s else s


-- Donats s1 i s2 Strings substitueix tots els elements del Tauler iguals a s1 per s2
replace' :: String -> String -> Tauler -> Tauler
replace' a b ll = map (map (\x -> if (a == x) then b else x)) ll


-- Divideix la llista en una llista de subllistes de mida (arg1)
splitEvery :: Int -> [a] -> [[a]]
splitEvery _ [] = []
splitEvery n xs = as : splitEvery n bs 
  where (as,bs) = splitAt n xs


-- Donat una llista d'enters la converteix en un String
toString :: [Int] -> String 
toString s = concat (map show s)


