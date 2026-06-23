import raylib
import random

const
  screenWidth = 960
  screenHeight = 540

type
  GameState = enum
    mainMenu, characterSelect, hub, 
    cPuzzle1, cPuzzle2, cPuzzle3, cKeyObtained,
    javaPuzzle1, javaPuzzle2, javaPuzzle3Intro, javaPuzzle3, javaKeyObtained

  Card = object
    label: string
    rect: Rectangle

var
  state = mainMenu
  selectedPlayer = 0
  hasCKey = false
  hasJavaKey = false
  hasHaskellKey = false

  playerX = 430.0
  playerY = 230.0
  playerSpeed = 4.0

  hubMessage = ""
  cErrorMessage = ""

  draggingCard = -1
  slotLabels: array[4, string]

  selectedPointer = -1
  pointerTargets: array[3, string]

  memoryUsed = 25
  freeCount = 0
  spawnTimer = 0.0
  c3Message = ""
  c3Won = false
  c3Lost = false
  c3Box = Card(label: "malloc()", rect: Rectangle(x: 400, y: 250, width: 150, height: 60))

  javaLabels: array[4, string]
  draggingJava = -1

  javaCards: array[4, Card] = [
    Card(label: "Perro", rect: Rectangle(x: 80, y: 220, width: 140, height: 60)),
    Card(label: "Auto", rect: Rectangle(x: 260, y: 220, width: 140, height: 60)),
    Card(label: "Profesor", rect: Rectangle(x: 440, y: 220, width: 140, height: 60)),
    Card(label: "Estudiante", rect: Rectangle(x: 620, y: 220, width: 140, height: 60))
  ]

  java2CurrentClass = "Animal"
  java2Score = 0
  java2Lives = 3
  java2Message = ""
  draggingJava2 = false
  java2Card = Card(label: "Perro", rect: Rectangle(x: 410, y: 220, width: 140, height: 60))

  java3Memory = 25.0
  java3Timer = 20.0
  java3GcTimer = 5.0
  java3ObjectX = 400.0
  java3ObjectY = -60.0
  java3ObjectLabel = "new Perro()"
  java3ObjectSpeed = 6.0
  java3Message = ""
  java3MessageColor = Green
  java3Won = false
  java3Lost = false


randomize()

proc spawnC3Box() =
  if rand(0..1) == 0:
    c3Box.label = "malloc()"
  else:
    c3Box.label = "free()"

  c3Box.rect.x = rand(80..730).float32
  c3Box.rect.y = rand(170..360).float32
  spawnTimer = 0.55

initWindow(screenWidth, screenHeight, "UAI Escape")
setTargetFPS(60)

let maleTexture = loadTexture("assets/characters/hombre.png")
let femaleTexture = loadTexture("assets/characters/mujer.png")

let maleRect = Rectangle(x: 250, y: 180, width: 128, height: 128)
let femaleRect = Rectangle(x: 580, y: 180, width: 128, height: 128)

let playButton = Rectangle(x: 380, y: 220, width: 200, height: 60)
let exitButton = Rectangle(x: 380, y: 320, width: 200, height: 60)
let verifyButton = Rectangle(x: 380, y: 455, width: 200, height: 50)

let cDoor = Rectangle(x: 60, y: 230, width: 120, height: 80)
let javaDoor = Rectangle(x: 420, y: 100, width: 120, height: 80)
let haskellDoor = Rectangle(x: 780, y: 230, width: 120, height: 80)
let finalDoor = Rectangle(x: 420, y: 420, width: 120, height: 80)

let cKeyTexture = loadTexture("assets/icons/key_c.png")
let javaKeyTexture = loadTexture("assets/icons/key_java.png")
let haskellKeyTexture = loadTexture("assets/icons/key_haskell.png")

let cKeyBigTexture = loadTexture("assets/icons/big_key_c.png")
#let javaKeyBigTexture = loadTexture("assets/icons/big_key_java.png")
#let haskellKeyBigTexture = loadTexture("assets/icons/big_key_haskell.png")

let animalSlot = Rectangle(x: 80, y: 380, width: 180, height: 70)

let vehicleSlot = Rectangle(x: 390, y: 380, width: 180, height: 70)
let personSlot = Rectangle(x: 700, y: 380, width: 180, height: 70)

let inheritsBox = Rectangle(x: 160, y: 390, width: 220, height: 80)
let notInheritsBox = Rectangle(x: 580, y: 390, width: 220, height: 80)

var cards: array[4, Card] = [
  Card(label: "double", rect: Rectangle(x: 120, y: 230, width: 150, height: 60)),
  Card(label: "char", rect: Rectangle(x: 300, y: 230, width: 150, height: 60)),
  Card(label: "int", rect: Rectangle(x: 480, y: 230, width: 150, height: 60)),
  Card(label: "short", rect: Rectangle(x: 660, y: 230, width: 150, height: 60))
]

let slots: array[4, Rectangle] = [
  Rectangle(x: 120, y: 350, width: 150, height: 60),
  Rectangle(x: 300, y: 350, width: 150, height: 60),
  Rectangle(x: 480, y: 350, width: 150, height: 60),
  Rectangle(x: 660, y: 350, width: 150, height: 60)
]

let pointers: array[3, Card] = [
  Card(label: "p1 = &b", rect: Rectangle(x: 120, y: 220, width: 150, height: 60)),
  Card(label: "p2 = &a", rect: Rectangle(x: 120, y: 310, width: 150, height: 60)),
  Card(label: "p3 = &c", rect: Rectangle(x: 120, y: 400, width: 150, height: 60))
]

let variables: array[3, Card] = [
  Card(label: "a = 10", rect: Rectangle(x: 660, y: 220, width: 150, height: 60)),
  Card(label: "b = 20", rect: Rectangle(x: 660, y: 310, width: 150, height: 60)),
  Card(label: "c = 30", rect: Rectangle(x: 660, y: 400, width: 150, height: 60))
]

proc spawnJava2Card() =
  let options = ["Perro", "Gato", "Auto", "Moto", "Profesor", "Estudiante"]
  java2Card.label = options[rand(0..5)]
  java2Card.rect.x = 410
  java2Card.rect.y = 220

proc spawnJava3Object() =
  let options = ["new Perro()", "new Auto()", "new Profesor()", "new Estudiante()"]
  java3ObjectLabel = options[rand(0..3)]
  java3ObjectX = rand(60..720).float32
  java3ObjectY = -80

spawnC3Box()
spawnJava2Card()

while not windowShouldClose():

  let mousePos = getMousePosition()

  if state == hub:
    if isKeyDown(KeyboardKey.Right):
      playerX += playerSpeed
    if isKeyDown(KeyboardKey.Left):
      playerX -= playerSpeed
    if isKeyDown(KeyboardKey.Down):
      playerY += playerSpeed
    if isKeyDown(KeyboardKey.Up):
      playerY -= playerSpeed

    let playerRect = Rectangle(x: playerX, y: playerY, width: 128, height: 128)

    if checkCollisionRecs(playerRect, cDoor):
      if not hasCKey:
        state = cPuzzle1
        hubMessage = ""
      else:
        hubMessage = "Ya completaste la zona C."

    elif checkCollisionRecs(playerRect, javaDoor):
      if hasJavaKey:
        hubMessage = "Ya completaste Java."

      elif hasCKey:
        state = javaPuzzle1
        hubMessage = ""

      else:
        hubMessage = "Necesitas la Llave C."

    elif checkCollisionRecs(playerRect, haskellDoor):
      if hasJavaKey:
        hubMessage = "Entrando a Haskell..."
      else:
        hubMessage = "Necesitas la Llave Java."

    elif checkCollisionRecs(playerRect, finalDoor):
      if hasHaskellKey:
        hubMessage = "Entrando al quiz final..."
      else:
        hubMessage = "Necesitas la Llave Haskell."

  if state == cPuzzle3 and not c3Won and not c3Lost:
    spawnTimer -= getFrameTime()

    if spawnTimer <= 0:
      if c3Box.label == "malloc()":
        memoryUsed += 7
      spawnC3Box()

    if memoryUsed >= 100:
      memoryUsed = 100
      c3Lost = true
      c3Message = "MEMORY LEAK DETECTED"

    if freeCount >= 10:
      c3Won = true
      hasCKey = true
      state = cKeyObtained

  if isMouseButtonPressed(MouseButton.Left):
    case state
    of mainMenu:
      if checkCollisionPointRec(mousePos, playButton):
        state = characterSelect
      if checkCollisionPointRec(mousePos, exitButton):
        break

    of characterSelect:
      if checkCollisionPointRec(mousePos, maleRect):
        selectedPlayer = 1
        state = hub
      elif checkCollisionPointRec(mousePos, femaleRect):
        selectedPlayer = 2
        state = hub

    of hub:
      discard

    of cPuzzle1:
      for i in 0..3:
        if checkCollisionPointRec(mousePos, cards[i].rect):
          draggingCard = i

      if checkCollisionPointRec(mousePos, verifyButton):
        if slotLabels == ["char", "short", "int", "double"]:
          cErrorMessage = ""
          state = cPuzzle2
        else:
          cErrorMessage = "Incorrecto. Intentalo de nuevo."

    of cPuzzle2:
      for i in 0..2:
        if checkCollisionPointRec(mousePos, pointers[i].rect):
          selectedPointer = i
          cErrorMessage = "Ahora haz click en la variable correcta."

      if selectedPointer != -1:
        for i in 0..2:
          if checkCollisionPointRec(mousePos, variables[i].rect):
            pointerTargets[selectedPointer] = variables[i].label[0..0]
            selectedPointer = -1
            cErrorMessage = ""

      if checkCollisionPointRec(mousePos, verifyButton):
        if pointerTargets == ["b", "a", "c"]:
          cErrorMessage = ""
          state = cPuzzle3
        else:
          cErrorMessage = "Incorrecto. Revisa las conexiones."

    of cPuzzle3:
      if c3Lost:
        memoryUsed = 25
        freeCount = 0
        c3Lost = false
        c3Message = ""
        spawnC3Box()
      elif not c3Won:
        if checkCollisionPointRec(mousePos, c3Box.rect):
          if c3Box.label == "free()":
            memoryUsed -= 15
            if memoryUsed < 0:
              memoryUsed = 0
            freeCount += 1
            c3Message = "free() aplicado correctamente"
          else:
            memoryUsed += 12
            c3Message = "malloc() reserva mas memoria"

          spawnC3Box()

    of cKeyObtained:
      discard      

    of javaPuzzle1:

      for i in 0..3:
        if checkCollisionPointRec(mousePos, javaCards[i].rect):
            draggingJava = i   

    of javaPuzzle2:
      if checkCollisionPointRec(mousePos, java2Card.rect):
        draggingJava2 = true

    of javaPuzzle3Intro:
      discard


    of javaPuzzle3:
      if java3Lost:
        java3Memory = 30
        java3Timer = 20.0
        java3GcTimer = 4.0
        java3Lost = false
        java3Message = ""

    of javaKeyObtained:
          discard

  if state == cKeyObtained:
    if isKeyPressed(KeyboardKey.Enter):
      playerX = 430
      playerY = 230
      state = hub

  if state == javaPuzzle3Intro:
    if isKeyPressed(KeyboardKey.Enter):
      java3Memory = 25.0
      java3Timer = 20.0
      java3GcTimer = 5.0
      java3Lost = false
      java3Won = false
      java3Message = ""
      playerX = 430
      spawnJava3Object()
      state = javaPuzzle3

  if isMouseButtonDown(MouseButton.Left) and draggingCard != -1:
    cards[draggingCard].rect.x = mousePos.x - 75
    cards[draggingCard].rect.y = mousePos.y - 30

  if isMouseButtonDown(MouseButton.Left) and draggingJava != -1:
    javaCards[draggingJava].rect.x = mousePos.x - 70
    javaCards[draggingJava].rect.y = mousePos.y - 30

  if isMouseButtonDown(MouseButton.Left) and draggingJava2:
    java2Card.rect.x = mousePos.x - 70
    java2Card.rect.y = mousePos.y - 30

  if isMouseButtonReleased(MouseButton.Left) and draggingCard != -1:
    for i in 0..3:
      if checkCollisionPointRec(mousePos, slots[i]):
        cards[draggingCard].rect.x = slots[i].x
        cards[draggingCard].rect.y = slots[i].y
        slotLabels[i] = cards[draggingCard].label

    draggingCard = -1

  if isMouseButtonReleased(MouseButton.Left) and draggingJava != -1:

    if checkCollisionPointRec(mousePos, animalSlot):
      javaCards[draggingJava].rect.x = animalSlot.x
      javaCards[draggingJava].rect.y = animalSlot.y

      if javaCards[draggingJava].label == "Perro":
        javaLabels[0] = "ok"

    elif checkCollisionPointRec(mousePos, vehicleSlot):
      javaCards[draggingJava].rect.x = vehicleSlot.x
      javaCards[draggingJava].rect.y = vehicleSlot.y

      if javaCards[draggingJava].label == "Auto":
        javaLabels[1] = "ok"

    elif checkCollisionPointRec(mousePos, personSlot):
      javaCards[draggingJava].rect.x = personSlot.x
      javaCards[draggingJava].rect.y = vehicleSlot.y

      if javaCards[draggingJava].label == "Profesor":
        javaLabels[2] = "ok"

      if javaCards[draggingJava].label == "Estudiante":
        javaLabels[3] = "ok"

    draggingJava = -1

  if isMouseButtonReleased(MouseButton.Left) and draggingJava2:
    var correct = false
    var wasDroppedInBox = false

    let isAnimal = java2Card.label == "Perro" or java2Card.label == "Gato"
    let isVehicle = java2Card.label == "Auto" or java2Card.label == "Moto"
    let isPerson = java2Card.label == "Profesor" or java2Card.label == "Estudiante"

    if checkCollisionPointRec(mousePos, inheritsBox):
      wasDroppedInBox = true
      correct = (java2CurrentClass == "Animal" and isAnimal) or
                (java2CurrentClass == "Vehiculo" and isVehicle) or
                (java2CurrentClass == "Persona" and isPerson)

    elif checkCollisionPointRec(mousePos, notInheritsBox):
      wasDroppedInBox = true
      correct = not (
        (java2CurrentClass == "Animal" and isAnimal) or
        (java2CurrentClass == "Vehiculo" and isVehicle) or
        (java2CurrentClass == "Persona" and isPerson)
      )

    if wasDroppedInBox:
      if correct:
        java2Score += 1
        java2Message = "Correcto!"
      else:
        java2Lives -= 1
        java2Message = "Incorrecto!"

      if java2Score == 4:
        java2CurrentClass = "Vehiculo"
      elif java2Score == 8:
        java2CurrentClass = "Persona"
      elif java2Score >= 12:
        state = javaPuzzle3Intro

      if java2Lives <= 0:
        java2Score = 0
        java2Lives = 3
        java2CurrentClass = "Animal"
        java2Message = "Reintentando..."

      spawnJava2Card()

    else:
      java2Card.rect.x = 410
      java2Card.rect.y = 230

    draggingJava2 = false

  if state == javaPuzzle3 and not java3Won and not java3Lost:
    java3Timer -= getFrameTime()
    java3GcTimer -= getFrameTime()

    if isKeyDown(KeyboardKey.Right):
      playerX += playerSpeed
    if isKeyDown(KeyboardKey.Left):
      playerX -= playerSpeed

    java3ObjectY += java3ObjectSpeed

    let playerRect = Rectangle(x: playerX, y: 390, width: 128, height: 128)
    let objectRect = Rectangle(x: java3ObjectX, y: java3ObjectY, width: 150, height: 40)

    if checkCollisionRecs(playerRect, objectRect):
      java3Memory += 15
      java3Message = "No esquivaste el objeto!"
      java3MessageColor = Red
      spawnJava3Object()

    if java3ObjectY > screenHeight:
      java3Message = "Objeto esquivado!"
      java3MessageColor = Green
      spawnJava3Object()

    if java3GcTimer <= 0:
      java3Memory -= 30
      if java3Memory < 0:
        java3Memory = 0
      java3GcTimer = 5.0

    if java3Memory >= 100:
      java3Memory = 100
      java3Lost = true
      java3Message = "OutOfMemoryError"

    if java3Timer <= 0:
      java3Won = true
      hasJavaKey = true
      state = javaKeyObtained

  beginDrawing()

  clearBackground(RayWhite)

  case state

  of mainMenu:
    drawText("UAI ESCAPE", 320, 100, 50, Black)
    drawRectangle(380, 220, 200, 60, LightGray)
    drawRectangle(380, 320, 200, 60, LightGray)
    drawText("JUGAR", 435, 240, 30, Black)
    drawText("SALIR", 445, 340, 30, Black)

  of characterSelect:
    drawText("Elige tu personaje", 320, 80, 40, Black)
    drawTexture(maleTexture, 250, 180, White)
    drawTexture(femaleTexture, 580, 180, White)
    drawText("Hombre", 270, 330, 24, DarkGray)
    drawText("Mujer", 610, 330, 24, DarkGray)
      
  of hub:
    drawText("Sala central", 360, 30, 40, Black)

    drawRectangle(60, 230, 120, 80, LightGray)
    drawText("C", 105, 255, 35, Black)
    if hasCKey:
      drawText("COMPLETADO", 50, 320, 20, Green)

    drawRectangle(javaDoor.x.int32, javaDoor.y.int32, 120, 80, LightGray)
    drawText("JAVA", 440, 125, 28, Black)
    if hasJavaKey:
      drawText("COMPLETADO", 465, 80, 40, Green)

    drawRectangle(780, 230, 120, 80, LightGray)
    drawText("HSK", 815, 255, 30, Black)
    if hasHaskellKey:
      drawText("COMPLETADO", 825, 200, 40, Green)

    drawRectangle(420, 420, 120, 80, LightGray)
    drawText("FINAL", 440, 445, 26, Black)

    if selectedPlayer == 1:
      drawTexture(maleTexture, playerX.int32, playerY.int32, White)
    elif selectedPlayer == 2:
      drawTexture(femaleTexture, playerX.int32, playerY.int32, White)

    if hasHaskellKey:
      drawTexture(haskellKeyTexture, playerX.int32 + 90, playerY.int32 + 50, White)

    elif hasJavaKey:
      drawTexture(javaKeyTexture, playerX.int32 + 90, playerY.int32 + 50, White)

    elif hasCKey:
      drawTexture(cKeyTexture, playerX.int32 + 65, playerY.int32 + 55, White)

    drawText(hubMessage, 300, 500, 24, Red)

  of cPuzzle1:
    drawText("Zona C - Puzzle 1", 300, 60, 40, Black)
    drawText("Arrastra los tipos de datos de menor a mayor tamano", 130, 120, 26, DarkGray)

    for i in 0..3:
      drawRectangle(slots[i].x.int32, slots[i].y.int32, 150, 60, LightGray)

    for i in 0..3:
      drawRectangle(cards[i].rect.x.int32, cards[i].rect.y.int32, 150, 60, Gray)
      drawText(cards[i].label, cards[i].rect.x.int32 + 35, cards[i].rect.y.int32 + 20, 24, Black)

    drawRectangle(380, 455, 200, 50, LightGray)
    drawText("VERIFICAR", 405, 468, 24, Black)
    drawText(cErrorMessage, 300, 510, 22, Red)

  of cPuzzle2:
    drawText("Zona C - Puzzle 2", 300, 60, 40, Black)
    drawText("Conecta cada puntero con la variable correcta", 180, 120, 28, DarkGray)
    drawText("Click en un puntero y luego click en su variable", 190, 160, 24, DarkGray)

    for i in 0..2:
      if pointerTargets[i] != "":
        var targetIndex = -1
        for j in 0..2:
          if variables[j].label[0..0] == pointerTargets[i]:
            targetIndex = j

        if targetIndex != -1:
          drawLine(
            (pointers[i].rect.x + pointers[i].rect.width).int32,
            (pointers[i].rect.y + pointers[i].rect.height / 2).int32,
            variables[targetIndex].rect.x.int32,
            (variables[targetIndex].rect.y + variables[targetIndex].rect.height / 2).int32,
            Black
          )

    for i in 0..2:
      if selectedPointer == i:
        drawRectangle(pointers[i].rect.x.int32, pointers[i].rect.y.int32, 150, 60, Yellow)
      else:
        drawRectangle(pointers[i].rect.x.int32, pointers[i].rect.y.int32, 150, 60, Gray)

      drawText(pointers[i].label, pointers[i].rect.x.int32 + 18, pointers[i].rect.y.int32 + 20, 22, Black)
      drawRectangle(variables[i].rect.x.int32, variables[i].rect.y.int32, 150, 60, LightGray)
      drawText(variables[i].label, variables[i].rect.x.int32 + 25, variables[i].rect.y.int32 + 20, 22, Black)

    drawRectangle(380, 455, 200, 50, LightGray)
    drawText("VERIFICAR", 405, 468, 24, Black)
    drawText(cErrorMessage, 210, 510, 20, Red)

  of cPuzzle3:
    drawText("Zona C - Puzzle 3", 300, 45, 40, Black)
    drawText("Memory Leak: haz click en free(), evita malloc()", 170, 95, 25, DarkGray)

    drawText("Memoria usada:", 250, 140, 22, Black)
    drawRectangle(420, 140, 400, 25, LightGray)
    drawRectangle(420, 140, (memoryUsed * 4).int32, 25, Red)

    drawText(("free aplicados: " & $freeCount & "/10"), 360, 180, 24, Black)

    if c3Won:
      drawText("Zona C completada!", 300, 260, 40, Black)
    elif c3Lost:
      drawText("MEMORY LEAK DETECTED", 230, 250, 40, Red)
      drawText("Haz click para reintentar", 330, 310, 25, DarkGray)
    else:
      if c3Box.label == "free()":
        drawRectangle(c3Box.rect.x.int32, c3Box.rect.y.int32, 150, 60, Green)
      else:
        drawRectangle(c3Box.rect.x.int32, c3Box.rect.y.int32, 150, 60, Gray)

      drawText(c3Box.label, c3Box.rect.x.int32 + 25, c3Box.rect.y.int32 + 20, 24, Black)
      drawText(c3Message, 280, 470, 22, Red)

  of cKeyObtained:
    drawText("LLAVE OBTENIDA", 280, 80, 45, Black)
    drawText("Has dominado la zona C", 300, 150, 28, DarkGray)

    drawTexture(cKeyBigTexture, 400, 210, White)

    drawText(
      "Presiona ENTER para volver a la sala central",
      210,
      430,
      24,
      DarkGray
    )

  of javaPuzzle1:

    drawText("Zona Java - Puzzle 1", 260, 50, 40, Black)

    drawText(
      "Clasifica cada objeto en su clase",
      230,
      110,
      28,
      DarkGray
    )

    drawRectangle(
      animalSlot.x.int32,
      animalSlot.y.int32,
      180,
      70,
      LightGray
    )

    drawRectangle(
      vehicleSlot.x.int32,
      vehicleSlot.y.int32,
      180,
      70,
      LightGray
    )

    drawRectangle(
      personSlot.x.int32,
      personSlot.y.int32,
      180,
      70,
      LightGray
    )

    drawText("Animal", 120, 400, 26, Black)
    drawText("Vehiculo", 420, 400, 26, Black)
    drawText("Persona", 740, 400, 26, Black)

    for i in 0..3:
      drawRectangle(
        javaCards[i].rect.x.int32,
        javaCards[i].rect.y.int32,
        140,
        60,
        Gray
      )

      drawText(
        javaCards[i].label,
        javaCards[i].rect.x.int32 + 15,
        javaCards[i].rect.y.int32 + 18,
        22,
        Black
      )

    if javaLabels == ["ok", "ok", "ok", "ok"]:
      drawText(
        "Correcto! Presiona ENTER",
        280,
        500,
        28,
        Green
      )

      if isKeyPressed(KeyboardKey.Enter):
        state = javaPuzzle2

  of javaPuzzle2:
    drawText("Zona Java - Puzzle 2", 260, 45, 40, Black)
    drawText("Herencia Express", 340, 95, 30, DarkGray)

    drawText(("Clase actual: " & java2CurrentClass), 330, 145, 28, Black)
    drawText(("Puntaje: " & $java2Score & "/12"), 80, 40, 24, Black)
    drawText(("Vidas: " & $java2Lives), 760, 40, 24, Red)

    drawRectangle(java2Card.rect.x.int32, java2Card.rect.y.int32, 140, 60, Gray)
    drawText(java2Card.label, java2Card.rect.x.int32 + 15, java2Card.rect.y.int32 + 18, 22, Black)

    drawRectangle(inheritsBox.x.int32, inheritsBox.y.int32, 220, 80, LightGray)
    drawText("HEREDA", 220, 420, 28, Black)

    drawRectangle(notInheritsBox.x.int32, notInheritsBox.y.int32, 220, 80, LightGray)
    drawText("NO HEREDA", 615, 420, 28, Black)

    if java2Message == "Correcto!":
      drawText(java2Message, 385, 500, 24, Green)
    else:
      drawText(java2Message, 385, 500, 24, Red)

  of javaPuzzle3Intro:
    drawText("Java Puzzle 3", 330, 80, 40, Black)
    drawText("Garbage Collector Survival", 260, 140, 30, DarkGray)
    drawText("Esquiva los objetos creados con new.", 230, 220, 24, Black)
    drawText("Si chocan contigo, la memoria sube.", 230, 260, 24, Black)
    drawText("El Garbage Collector limpia memoria cada cierto tiempo.", 150, 300, 24, Black)
    drawText("Presiona ENTER para comenzar", 300, 400, 28, Green)


  of javaPuzzle3:
    drawText("Zona Java - Puzzle 3", 260, 35, 40, Black)
    drawText("Garbage Collector Survival", 270, 80, 28, DarkGray)

    drawText(
      "Esquiva los objetos creados con new para evitar llenar la memoria.",
      95,
      125,
      22,
      DarkGray
    )

    drawText("Memoria usada:", 250, 165, 22, Black)
    drawRectangle(420, 165, 400, 25, LightGray)
    drawRectangle(420, 165, (java3Memory * 4).int32, 25, Red)

    drawText(("Tiempo: " & $java3Timer.int & "s"), 390, 215, 28, Black)

    drawRectangle(java3ObjectX.int32, java3ObjectY.int32, 200, 70, Gray)
    drawText(java3ObjectLabel, java3ObjectX.int32 + 12, java3ObjectY.int32 + 24, 22, Black)

    if selectedPlayer == 1:
      drawTexture(maleTexture, playerX.int32, 390, White)
    elif selectedPlayer == 2:
      drawTexture(femaleTexture, playerX.int32, 390, White)

    if java3Lost:
      drawText("OutOfMemoryError", 290, 390, 40, Red)
      drawText("Haz click para reintentar", 330, 450, 24, DarkGray)
    else:
      drawText(java3Message, 250, 450, 24, java3MessageColor)

  of javaKeyObtained:
    drawText("Llave Java obtenida", 280, 240, 40, Black)
  endDrawing()

closeWindow()