import System.IO
import Data.List
import System.Random

-------- Tipus de Dades 

type Tauler = [[String]]
type Posicio = String
type Fila = [String]

data Jugador = Persona | Maquina | Ningu deriving (Show,Eq)
data Nivell = Facil | Dificil | Impossible deriving (Show,Eq)


--------    Arbres
data Arbre a = Arbre a [Arbre a] deriving (Show,Eq,Ord) 





--------    Programes Principals

-- Programa Principal
main :: IO()
main = do
    putStrLn "\n"
    putStrLn "BENVINGUT AL 4 EN RATLLA by MARC DOMENECH\n"
    putStrLn "Introdueixi el nombre de files: "

    f <- getLine
    putStrLn "Introdueixi el nombre de columnes: "

    c <- getLine

    putStrLn "Introdueixi la dificultat:\n0: Facil\n1: Dificil\n2: Impossible\n"

    d <- getLine
    let dificultat = if (read d) == 0 then Facil else if (read d) == 1 then Dificil else Impossible

    let files = read f
    let columnes = read c
    if files < 4 || columnes < 4 then do
        putStrLn "!!!!  Tauler massa petit  !!!!"
        main
    else do
        putStrLn "\n"
        putStrLn "La teva fitxa es -> XX "
        let taulerIni = (taulerInicialDif files columnes)
        putStrLn "\n"
        putStrLn (pintaTauler taulerIni)
        moureFitxa dificultat Persona (novesOpcionsIni files columnes) taulerIni 
        return ()


-- Programa per anar movent fitxes
moureFitxa :: Nivell -> Jugador -> [Posicio] -> Tauler ->  IO()
moureFitxa dificultat j opcions tauler = do

    if j == Persona then do
        putStrLn "-> Et toca Jugar!"
        putStr "-> Tria la fila que vols marcar: "
        x <- getLine
        --print opcions
        let pos =  addZeroString( calcularPos (addZeroString x) opcions)

        if pucMarcar pos opcions then do
            --putStrLn "-> Puc Marcar la casella"
            let nouTauler = replace' pos "XX" tauler
            let opcionsActualitzadas = (novesOpcions pos opcions)
            

            putStrLn "\n"
            putStrLn (pintaTauler nouTauler)
            if (tablas opcionsActualitzadas) then acabaPartida Ningu else if (partidaGuanyada pos Persona nouTauler) then acabaPartida Persona else moureFitxa dificultat Maquina opcionsActualitzadas nouTauler
        else do
            putStrLn "!!!! No pots marcara aquesta fila, selecciona una altra !!!!\n"
            moureFitxa dificultat Persona opcions tauler
        return ()
        
    else do
        r1 <- randInt 0 ((length opcions)-1)
        --let pos =  addZeroString(calcularPos(addZeroString (show r1)) opcions)
        --print opcions
        --print (greedy opcions tauler)
        let pos = if dificultat == Dificil then (greedy opcions tauler) else if dificultat == Impossible then (smart opcions tauler) else addZeroString(calcularPos(addZeroString (show r1)) opcions)
        print "-> Estat de la partida"
        --print (maxim opcions tauler)

        if pucMarcar pos opcions then do
            putStrLn "-> Juga la Maquina"
            --putStrLn ("-> La Maquina marca la fila: " ++ (show r1))
            putStrLn ("-> La Maquina marca la fila: " ++ (show ((read pos) `mod` (length opcions))))
            --print opcions
            let nouTauler = replace' pos "··" tauler
            let opcionsActualitzadas = (novesOpcions pos opcions)
            putStrLn "\n"
            putStrLn (pintaTauler nouTauler)
            putStrLn "\n"
            if (tablas opcionsActualitzadas) then acabaPartida Ningu else if (partidaGuanyada pos Maquina nouTauler) then acabaPartida Maquina else moureFitxa dificultat Persona opcionsActualitzadas nouTauler
            
        else do
            --putStrLn "\t-> La maquina no ha pogut marcar la casella "
            --putStrLn (show r1)
            --putStrLn "\n"
            moureFitxa dificultat Maquina opcions tauler

        return ()



--------    Funcions de Estrategia Smart

maxim :: [Posicio] -> Tauler -> [Int]
maxim opcions tauler =  heuristicsFills where 
    arbre = crearArbre 0 opcions tauler 0 []
    heuristicsFills = map arrelArbre (fillsArbre arbre)
    max = maximum heuristicsFills

smart :: [Posicio] -> Tauler -> Posicio
smart opcions tauler =  millorPos where 
    arbre = crearArbre 0 opcions tauler 0 []
    heuristicsFills = map arrelArbre (fillsArbre arbre)
    max = maximum heuristicsFills
    maxIndex = elemIndices max heuristicsFills
    maxIndexFactible = [x | x <- maxIndex , (pucMarcar (opcions!!x) opcions)]

    --millorPos = opcions!!(maxIndexFactible!!0)
    millorsPos = map (\a -> opcions!!a) maxIndexFactible
    millorPos = greedy millorsPos tauler

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
    hPersona = if (millorResultatP == 4) then -1 else if (millorResultatM == 4 && (not molestarAM)) then 1 else 0   -- Juga Persona
    hMaquina = if (millorResultatM == 4) then 1 else if (millorResultatP == 4 && (not molestarAP)) then -1 else 0

preordre :: Arbre a -> [a]
preordre (Arbre x fills) = x : concatMap preordre fills

mida :: (Num a ) => Arbre a -> a
mida (Arbre _ fills) = 1 + sum (map mida fills)


crearArbre :: Int -> [Posicio] -> Tauler -> Int -> [Int] -> Arbre Int
crearArbre 4 opcions tauler arrel _ = Arbre (heuristicSmart Maquina opcions tauler) []
crearArbre prof opcions tauler _ _ = a where

    j = if even prof then Maquina else Persona
    fitxa = if j == Maquina then "··" else "XX"        -- (CANVIARR!!!!)Si estem a un nivell parell esque li toca decidir a la maquina

    --root = heuristicSmart j opcions tauler

    llistaNousTaulers = map (\pos -> replace' pos fitxa tauler) opcions
    llistaNovesOpcions = (map (\pos -> novesOpcions pos opcions) opcions)

    opcionsValides = [x | x <- opcions, x /= "-1"]

    subArbre = map (\pos -> crearArbre (prof+1) (novaOpcio pos) (nouTauler pos) (valorFill pos) []) opcions where
        nouTauler p =  replace' p fitxa tauler
        novaOpcio p =  novesOpcions p opcions
        valorFill p = heuristicSmart j (novaOpcio p) (nouTauler p)

    root = if even prof then maximum (subArbre) else minimum (subArbre)
    valor = arrelArbre root
    --a = if root == 0 then Arbre root subArbre else Arbre root []
    a = Arbre valor subArbre


arrelArbre :: Arbre a -> a
arrelArbre (Arbre arrel _) = arrel

fillsArbre :: Arbre a -> [Arbre a]
fillsArbre (Arbre _ fills) = fills

profunditatMaxima :: Int -> Int
profunditatMaxima columnes = if columnes <= 5 then 5 else if columnes <= 7 then 3 else 2

--------    Funcions de Estrategia Greedy


greedy :: [Posicio] -> Tauler -> Posicio
greedy opcions tauler =  if posPerGuanyar /= "-1" then posPerGuanyar else if posABloquejar == "-1" then nomesMillor else posABloquejar where

    -- Llista amb els valors dels heuristics per cada posicio. (Exemple: [3,2,2,1] -> marcant la pos 0 conseguiria un 3 en linia)
    heuristic1 = map (\a -> millorJugada a Persona tauler) opcions
    heuristic2 = map (\a -> millorJugada a Maquina tauler) opcions

    valorDecisiuM = elemIndices 4 heuristic2
    posPerGuanyar = if length valorDecisiuM > 0 then opcions!!(valorDecisiuM!!0) else "-1" -- Posicio que hauriem de marcar per fer una linia

    -- Llista per saber si el oponent esta a punt de fer una linia 
    valorsABloquejarP = elemIndices 4 heuristic1             -- Llista de indexos que fariesn 4 en linia
    posABloquejar = if length valorsABloquejarP > 0 then opcions!!(valorsABloquejarP!!0) else "-1" -- Posicio que hauriem de bloquejar per evitar una linia

    -- Mirem quin es el millor resultat que podem obtenir
    millorsOpcions1 = maximum heuristic1        
    millorsOpcions2 = maximum heuristic2

    -- Conseguim els indexos de les posicions que ens poden conseguir aquest millor resultat
    indexosValors1 = elemIndices millorsOpcions1 heuristic1
    indexosValors2 = elemIndices millorsOpcions2 heuristic2

    -- Llista de les millors Posicions per a conseguir la millor puntuacio
    millorsPos1 = map (\a -> opcions!!a) indexosValors1
    millorsPos2 = map (\a -> opcions!!a) indexosValors2

    -- De les millors opcions triem aquella que perjudiqui mes al rival
    millor = map (\m -> if m `elem` millorsPos1 then m else "") millorsPos2
    coincidents = [x | x <- millor, x /= ""] 

    -- Conseguim la millor opcio que permeti tenir la millor puntuacio i que perjudiqui mes al altre (en aquesta tirada)
    nomesMillor = if (length coincidents) > 0 then coincidents!!0 else millorsPos2!!0



-- Retrona True si posant la fitxa a pos, es fa un 4 en linia
millorJugada :: Posicio -> Jugador -> Tauler -> Int
millorJugada "-1" _ _ = -1
millorJugada pos j tauler = max (max hFila hColumna) hDiagonal where 
    limit = 4
    fitxa = if j == Persona then "XX" else "··"
    nouTauler = (replace' (concat (addZero [pos])) fitxa tauler)

    enFila = map (group) nouTauler                                          -- Agrupo les files
    enFila2 =  (map (filter (==fitxa)) (concat enFila))                     -- Em quedo nomes amb les agrupacions de les fitxes que vui mirar
    enFila3 = reverse $ sort [x | x <- enFila2, x /= []]                    -- Conto quantes agrupacions hi han de 4 o mes elements
    hFila = if (length $ enFila3!!0) > 0 then length $ enFila3!!0 else 0    -- Calculem quina es la linia mes gran que podem fer en horitzontal
    
    enColumna = map (group) (transpose nouTauler)                                   -- Agrupo les columnes
    enColumna2 = map (filter (==fitxa)) (concat enColumna)                          -- Em quedo nomes amb les agrupacions de les fitxes que vui mirar
    enColumna3 = reverse $ sort [x | x <- enColumna2, x /= []]                      -- Conto quantes agrupacions hi han de 4 o mes elements
    hColumna = if (length $ enColumna3!!0) > 0 then length $ enColumna3!!0 else 0   -- Calculem quina es la linia mes gran que podem fer en vertical
    
    hDiagonal = heuristicDiagonal pos j nouTauler        -- Calculem quina es la linia mes gran que podem fer en diagonal







--------    Funcions de Comprovacio o actualitzacio de variables

-- Donada una columna i un llistat de possibles jugades, calcula quina es la casella que correspon a la fila
calcularPos :: String -> [String] -> String
calcularPos pos opcions = if (x < length opcions) then opcions!!x else "-1" where x = read pos


-- Ens dona un llistat amb totes les possibles opcions noves despres de marcar la posicio pos
novesOpcions :: Posicio -> [Posicio] -> [Posicio]
novesOpcions pos opcionsActuals = map (\x -> if x == pos then novaPos else x) opcionsActuals where 
    columnes = length opcionsActuals
    novaPos = if ((read pos) - columnes) < 0 then "-1" else addZeroString (show ((read pos) - columnes))


-- Ens Retorna True o False en funcio de si podem marcar o no aquella posicio
pucMarcar :: Posicio -> [Posicio] -> Bool
pucMarcar pos opcions = if pos `elem` opcions && pos /= "-1" then True else False








--------    Calcul de si Introduint la nova fitxa hem guanyat o perdut

-- Retrona True si posant la fitxa a pos, es fa un 4 en linia
partidaGuanyada :: Posicio -> Jugador -> Tauler -> Bool --if (length enFila3 > 0) || (length enColumna3 > 0) || (length enDiagonal > 0) then True else False
partidaGuanyada pos j tauler =  if any liniaDe4 enFila2 || any liniaDe4 enColumna2 || enDiagonal then True else False where 
    limit = 4
    fitxa = if j == Persona then "XX" else "··"
    liniaDe4 = (\a -> length a == 4)

    enFila = map (group) tauler                             -- Agrupo les files
    enFila2 = map (filter (==fitxa)) (concat enFila)        -- Em quedo nomes amb les agrupacions de les fitxes que vui mirar

    enColumna = map (group) (transpose tauler)              -- Agrupo les columnes
    enColumna2 = map (filter (==fitxa)) (concat enColumna)  -- Em quedo nomes amb les agrupacions de les fitxes que vui mirar

    enDiagonal = diagonal pos j tauler                      


-- Retorna una llista amb la diagonal descendent de la posicio pos del tauler
calcularDiagonalDown :: Posicio -> Tauler -> [Posicio]
calcularDiagonalDown pos tauler = result where
    num = read pos
    limit = 4
    columnes = length (tauler!!0)
    maxElem = ((length tauler) * columnes) - 1
    offsetDown = limit + 1
    offsetUp = limit - 1
    c = num `mod` columnes
    taulerLlista = concat tauler

    -- Fem una llista amb les posicions que es troben a la diagonal per sota i a sobre de pos.
    dUp = (dropWhile (\x ->  x `mod` columnes > c) (reverse [num,num-offsetDown..0]))
    dDown = (reverse (dropWhile (\x -> x `mod` columnes < c) (reverse [num+offsetDown,num+(2*offsetDown)..maxElem])))
    
    
    dUpInt =  map (\x -> if taulerLlista!!x == "XX" then -1 else if taulerLlista!!x == "··" then -2 else x) dUp
    dUpString = map (\x -> if x >= 0 then addZeroString (show x) else if x == -1 then "XX" else "··") dUpInt
    
    dDownInt =  map (\x -> if taulerLlista!!x == "XX" then -1 else if taulerLlista!!x == "··" then -2 else x) dDown
    dDownString = map (\x -> if x >= 0 then addZeroString (show x) else if x == -1 then "XX" else "··") dDownInt
    
    result = dUpString ++ dDownString


-- Retorna una llista amb la diagonal ascendent de la posicio pos del tauler
calcularDiagonalUp :: Posicio -> Tauler -> [String]
calcularDiagonalUp pos tauler = result where
    num = read pos
    limit = 4
    columnes = length (tauler!!0)
    maxElem = ((length tauler) * columnes) - 1
    offsetDown = limit + 1
    offsetUp = limit - 1
    c = num `mod` columnes
    taulerLlista = (concat tauler)

    dUp =  (dropWhile (\x -> x `mod` columnes < c) (reverse (take (limit-1) [num-offsetUp,num-(2*offsetUp)..0])))
    dDown =  (reverse (dropWhile (\x -> x `mod` columnes > c) (reverse (take limit ([num,num+offsetUp..maxElem])))))
    
    dUpInt =  map (\x -> if taulerLlista!!x == "XX" then -1 else if taulerLlista!!x == "··" then -2 else x) dUp
    dUpString = map (\x -> if x >= 0 then addZeroString (show x) else if x == -1 then "XX" else "··") dUpInt
    
    dDownInt =  map (\x -> if taulerLlista!!x == "XX" then -1 else if taulerLlista!!x == "··" then -2 else x) dDown
    dDownString = map (\x -> if x >= 0 then addZeroString (show x) else if x == -1 then "XX" else "··") dDownInt
   
    result = (dUpString ++ dDownString)


-- Ens diu si hi ha alguna diagonal amb centre pos, que tingui un 4  en linia
diagonal :: Posicio -> Jugador -> Tauler -> Bool
diagonal pos j tauler = if (length dUpLinies) > 0 || (length dDownLinies) > 0 then True else False where
    fitxa = if j == Persona then "XX" else "··"
    limit = 4
    dUp = calcularDiagonalUp pos tauler                         -- Ens dona una llista de grups de fitxes seguides
    dDown = calcularDiagonalDown pos tauler                     -- Ens dona una llista de grups de fitxes seguides

    dUpLinies = [x | x <- (group dUp),length x >= limit]        -- Filtre per a nomes quedarnos amb grups de 4 fitxes seguides
    dDownLinies = [x | x <- (group dDown),length x >= limit]    -- Filtre per a nomes quedarnos amb grups de 4 fitxes seguides

heuristicDiagonal :: Posicio -> Jugador -> Tauler -> Int
heuristicDiagonal pos j tauler = hDiagonal where 
    limit = 4
    fitxa = if j == Persona then "XX" else "··"
    nouTauler = (replace' (concat (addZero [pos])) fitxa tauler)

    dUp = calcularDiagonalUp pos nouTauler                         -- Ens dona una llista de grups de fitxes seguides
    dDown = calcularDiagonalDown pos nouTauler                     -- Ens dona una llista de grups de fitxes seguides

    dUpLinies = [x | x <- (group dUp), x /= []]        -- Filtre per a nomes quedarnos amb grups de 4 fitxes seguides
    dDownLinies = [x | x <- (group dDown), x /= []]    -- Filtre per a nomes quedarnos amb grups de 4 fitxes seguides

    diagonals = reverse $ sort (dUpLinies ++ dDownLinies)
    hDiagonal = if (length $ diagonals!!0) > 0 then length $ diagonals!!0 else 0





-------- Funcions d'inicialitzacio

-- Inicialitza un Tauler
taulerInicialDif :: Int -> Int -> Tauler
taulerInicialDif fil col = splitEvery col (addZero (map show [0..mida-1])) where mida = fil*col


-- Ens dona un llistat amb les posibles posicions a jugar al principi de la partida
novesOpcionsIni :: Int -> Int -> [Posicio]
novesOpcionsIni files col =  map addZeroString llista where
    primer = (files * col) - col
    ultim = (files * col) - 1
    llista = (map show [x | x <- [primer..ultim]])





--------    Funcions per Pintar el Tauler


-- Donat el nombre de columnes, genera un separador de files
pintaSeparadors :: Int -> String
pintaSeparadors col = (take (mida*col) $ cycle patro) ++ "-" where 
    patro = "- ---- "
    mida = length patro



-- Donat una Fila ["1","2","3"] per exemple, el converteix per a que quedi maco "|  01  |  02  |  03  |"
pintaFila :: Fila -> String
pintaFila  s = "  |  " ++ (intercalate "  |  " x) ++ "  |" where 
    x = map (\x -> if (x /= "XX") && (x /= "··") then "  " else x) s


-- Donat una llista de files(Strings), retorna el String amb el tauler ben posat
pintaTauler :: Tauler -> String 
pintaTauler  ll = "  " ++ pintaX mida ++ separador ++ (intercalate separador valorsFila) ++ separador where 
    mida = length (ll!!0)                                       -- Mida del separador
   
    --separador = "\n   " ++(pintaSeparadors $ mida)++"\n"        -- Separador entre fila i fila
    separador = "\n  " ++(pintaSeparadors $ mida)++"\n"        -- Separador entre fila i fila
    valorsFila = (map pintaFila ll)   
    --valorsFila = pintaY (map pintaFila ll)                      -- Convertim cada String en una fila ben maca


-- Retorna una fila on apareixen el numero de les columnes
pintaX :: Int -> String
pintaX col = stringToFila $ (addZero(map show [0..col-1]))


-- Modifica la llista per a que apareguin els numero de la fila al principi ["XX·"] -> ["1XX·"]
pintaY :: [String] -> [String]
pintaY ll = zipWith (++) (words (toString [0..mida-1])) ll where mida = length ll








--------    Funcions per finalitzar la partida 

-- Mostra qui ha guanyat la partida i finalitza el programa
acabaPartida :: Jugador -> IO()
acabaPartida j = do
    putStrLn "\nFi de la Partida"
    if j == Persona then putStrLn "HAS GUANYAT!!! ;)\n" else if (j == Ningu) then putStrLn "Heu Empatat :(\n" else putStrLn "Has perdut :(\n"
    return ()


tablas :: [Posicio] -> Bool
tablas opcions = if length (dropWhile (== "-1") opcions) == 0 then True else False







--------    Funcions Auxiliars

-- Retorna un nombre aleatori
randInt :: Int -> Int -> IO Int
randInt low high = do
    random <- randomIO :: IO Int
    let result = low + random `mod` (high - low + 1)
    return result


-- Donat una llista de Strings, retorna la mateixa llista amb tots els nombres amb 2 xifres
addZero :: [String] -> [String]
addZero s = map (\x -> if (length x) <= 1 then "0"++x else x) s

-- Donat un String, retorna el mateix String amb tots els nombres amb 2 xifres
addZeroString :: String -> String
addZeroString s = if length s <= 1 then "0"++s else s


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



-- Donada una llista de Strings retorna una fila ben posada
stringToFila :: [String] -> String
stringToFila s = "/  " ++ (intercalate "  /  " s) ++ "  /"

