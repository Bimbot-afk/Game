# Trauma Boy - 2D Action Platformer

Juego de plataformas y acción 2D hecho en **Godot 4**. Controlas a **Trauma Boy**: avanza esquivando balas, elimina enemigos armados y junta las monedas necesarias para llegar con vida al final del nivel.

> **Jugar en el navegador:** [x-emart.itch.io/trauma-boy](https://x-emart.itch.io/trauma-boy) *(Solo PC)*

---

## Objetivo

1. Sobrevivir a los enemigos disparando tu láser y esquivando sus ráfagas.
2. Juntar al menos **80 monedas** repartidas por el mapa.
3. Llegar a la zona final (`End Game`) con la cuota completa para ganar.

---

## Cómo funciona

### Jugador (Trauma Boy)
* **Movimiento:** Control lateral con inercia, salto y agachado. La hitbox se reduce al agacharse para esquivar proyectiles por arriba.
* **Disparo:** Puedes disparar quieto, corriendo, agachado o en el aire.
* **Reaparición:** Si pierdes toda la barra de impacto pero aún tienes corazones, revives al instante en el mismo lugar consumiendo una vida.

### Enemigos
* **Comportamiento:** Patrullan y calculan distancia frente al jugador (~450 px). Si te acercas retroceden; si te alejas te persiguen.
* **Ataque:** Al fijar la distancia, se frenan y disparan una ráfaga rápida de 5 proyectiles.
* **Vida y colisión:** Aguantan **7 disparos**. Sus hitboxes cambian según la animación (caminando, disparando o muriendo).

### Salud y Vidas
El juego usa dos capas de vida con *Autoloads*:
* **Impactos directos (`GlobalLife`):** Barra de 5 golpes. Cada bala enemiga te quita 1 punto.
* **Vidas / Corazones (`Hearths`):** Empiezas con 5 corazones. Al perder los 5 impactos directos, gastas 1 corazón y reinicias los impactos. Si te quedas sin corazones, es Game Over.

### Coleccionables
* **Monedas (`coin.tscn`):** Necesitas al menos 80 para poder completar el nivel.
* **Corazones (`heath_colect.tscn`):** Recuperan 1 vida perdida (máximo 5).

---

## Controles (PC)

| Acción | Teclas | Ratón |
| :--- | :--- | :--- |
| **Moverse** | `A` / `D` o `Flechas` | — |
| **Saltar** | `W`, `Espacio` o `Flecha Arriba` | — |
| **Agacharse** | `S` o `Flecha Abajo` | — |
| **Disparar** | — | `Clic izquierdo` |

---

## Estructura del Proyecto

```text
gameee/
├── images/
│   ├── assets(tiles)/          # Tilesets y decorado
│   ├── diferent_images/        # Spritesheets (jugador, enemigos, efectos)
│   └── sounds/                 # Música y SFX
├── scenes/
│   ├── level_1.tscn            # Nivel principal
│   ├── trauma_boy.tscn         # Jugador
│   ├── enemy.tscn              # Enemigo
│   ├── bullet.tscn             # Disparo de Trauma Boy
│   ├── bullet_enemy.tscn       # Disparo enemigo
│   ├── coin.tscn               # Moneda
│   ├── heath_colect.tscn       # Corazón coleccionable
│   ├── end_game.tscn           # Meta del nivel
│   ├── win.tscn                # Pantalla de victoria
│   └── lose.tscn               # Pantalla de Game Over
├── scripts/
│   ├── trauma_boy.gd           # Movimiento, animaciones y disparo del jugador
│   ├── enemy.gd                # Distancia, ráfaga y estados del enemigo
│   ├── bullet.gd / bullet_enemy.gd # Movimiento y daño de proyectiles
│   ├── end_game.gd             # Comprobación de meta (≥ 80 monedas)
│   ├── global_coin.gd          # Autoload: total de monedas
│   ├── global_life.gd          # Autoload: puntos de impacto
│   ├── hearths.gd              # Autoload: vidas / corazones
│   └── heath_colect.gd         # Curación
├── export_presets.cfg
└── project.godot
