# UAI Escape - Nim

Este repositorio contiene el código fuente de "UAI Escape", un juego interactivo y educativo desarrollado en **Nim** utilizando la biblioteca gráfica **Raylib**. El lenguaje seleccionado e inscrito para la realización de este proyecto es Nim.

## Funcionamiento del código

El programa está estructurado utilizando una **Máquina de Estados Finita** (representada por el tipo de dato enumerado `GameState`), la cual dicta qué pantalla o lógica se está ejecutando en un momento dado (menús, exploración, o puzzles específicos).

* **Lógica de Variables:** Existen variables globales que controlan el progreso del jugador (como `hasCKey` o `hasJavaKey`), las coordenadas de los elementos (`playerX`, `playerY`), los temporizadores y el estado de los componentes arrastrables (drag and drop).
* **Bucle Principal:** El ciclo `while not windowShouldClose():` es el corazón del juego. En cada iteración de fotograma (frame), el programa realiza dos tareas vitales:
1. **Actualización Lógica:** Verifica el estado actual del juego para calcular físicas, movimientos, colisiones geométricas (usando `checkCollisionRecs` y `checkCollisionPointRec`), y capturar las interacciones del teclado y mouse.
2. **Renderizado:** Mediante el bloque `beginDrawing()`, limpia la pantalla y utiliza una estructura de control `case state` para dibujar exclusivamente los rectángulos, textos y texturas pertinentes al nivel o puzzle que el usuario está jugando.


## Objetivo del Juego

El objetivo principal es escapar de las distintas "salas" o zonas temáticas resolviendo rompecabezas basados en la filosofía, sintaxis y el manejo de recursos de varios lenguajes de programación. El jugador debe demostrar conocimientos sobre el manejo de memoria, tipos de datos, punteros y programación orientada a objetos para obtener las llaves que le permitirán avanzar a la prueba final.

## Controles

El juego está diseñado para jugarse cómodamente con el teclado y el ratón:

* **Flechas del teclado (Arriba, Abajo, Izquierda, Derecha):** Permiten mover al personaje libremente por la sala central (Hub) y esquivar objetos en el minijuego de supervivencia.
* **Clic Izquierdo del Mouse:** Permite interactuar con los botones de la interfaz. Si se mantiene presionado sobre las tarjetas de código, permite arrastrarlas y soltarlas (Drag & Drop) en las casillas de respuesta.
* **Tecla ENTER:** Se utiliza para avanzar en las pantallas de victoria, leer las introducciones a los minijuegos y confirmar el inicio de ciertas etapas.

## Cómo hacer andar el programa

Para compilar y ejecutar este juego en tu máquina, necesitas tener instalado el compilador de Nim y la librería Raylib. Sigue estos pasos:

1. **Instalar Nim:** Descarga e instala el lenguaje desde su [página oficial](https://nim-lang.org/install.html).
2. **Instalar dependencias (Raylib):** Abre tu terminal o consola de comandos y ejecuta la siguiente instrucción utilizando el gestor de paquetes de Nim (`nimble`):
```bash
nimble install raylib

```


3. **Preparar los Recursos (Assets):** Asegúrate de que la carpeta de recursos llamada `assets/` (que debe contener las subcarpetas `characters/` e `icons/` con las imágenes `.png` necesarias) esté ubicada en el mismo directorio que el archivo principal de tu código.
4. **Ejecutar el juego:** En la terminal, navega hasta la ruta donde guardaste el proyecto y ejecuta el archivo principal (`main.nim`):
```bash
nim c -r main.nim

```



## Qué se puede hacer dentro del programa

El juego ofrece una progresión por niveles, permitiendo interactuar con los siguientes elementos:

* **Selección de Personaje:** Puedes comenzar tu aventura eligiendo jugar con un avatar masculino o femenino.
* **Exploración del Hub Central:** Un espacio interactivo por el que te puedes mover físicamente. Contiene puertas que actúan como "candados"; no podrás entrar a Java sin antes conquistar C, ni a Haskell sin antes dominar Java.
* **Zona C:**
* *Puzzle de Tipos:* Ordenar tipos de datos primitivos (`char`, `short`, `int`, `double`) arrastrándolos según su tamaño en memoria.
* *Puzzle de Punteros:* Conectar visualmente apuntadores (ej. `p1 = &b`) haciendo clic en la dirección de memoria de la variable correcta.
* *Puzzle de Fuga de Memoria (Memory Leak):* Un minijuego de agilidad mental donde debes hacer clic en cajas de `free()` para liberar memoria y evitar hacer clic en `malloc()` para que la barra de memoria no se llene al 100%.


* **Zona Java (Requiere la Llave de C):**
* *Puzzle de Clases:* Clasificar objetos o entidades concretas arrastrándolas a su molde correspondiente (Animal, Vehículo, Persona).
* *Puzzle de Herencia Express:* Tomar decisiones rápidas bajo presión analizando si una clase específica hereda o no hereda de un objeto padre, gestionando un contador de vidas y puntaje.
* *Supervivencia del Garbage Collector:* Un minijuego de acción donde debes mover a tu personaje para esquivar instancias de objetos creados con la palabra reservada `new` que caen en picada. Debes sobrevivir administrando la memoria ocupada hasta que el *Garbage Collector* se active y limpie la pantalla.
