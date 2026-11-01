# 🤖 Reglas de Contexto y Memoria para Agentes de IA — Chatter_Companion

> **Documento Maestro de Arquitectura y Memoria Operativa**  
> **Ámbito:** `Client\Interface\AddOns\Chatter_Companion\`  
> **Líder del Proyecto:** DarckRovert (Ingame: `Elnazzareno`)  
> **Servidor Destino:** [Project Jaina](https://darckrovert.github.io/ProjectJaina_Web/)  
> **Motor Backend:** JainaCore C++20 con módulo nativo `mod-llm-chatter`  

---

## 1. Principios Inviolables para Agentes
1. **Zero UI Taint:** NUNCA modificar frames seguros de Blizzard durante `InCombatLockdown()`.
2. **Protocolo IPC de Diálogo:** Todo intercambio con bots neurales utiliza canales de susurro o mensajes de addon serializados vía `ChatterUI.lua` y `ChatterRoster.lua`.
3. **Persistencia Segura:** Las variables guardadas residen en `ChatterDB` (`SavedVariablesPerCharacter`), almacenando memoria de diálogo y personalidades asignadas a bots.
4. **Respeto a Blizzard UI Policy:** Código 100% en texto plano (Lua 5.1). Sin binarios ni bloqueos de contenido.
