# 💻 Especificación de API y Red — Chatter_Companion

Documento técnico de arquitectura de software y protocolo conversacional para **Chatter_Companion** en el ecosistema **Project Jaina**.

---

## 1. Namespace Global
El addon expone la tabla global `Chatter` en el entorno Lua del cliente 3.3.5a:
* `Chatter:RegisterBot(guid, name, personality)`: Registra un bot táctico en el roster de diálogo local.
* `Chatter:SendMessage(guid, text)`: Envía un estímulo conversacional al bot via canal de susurro privado o protocolo de addon.
* `Chatter:GetHistory(guid)`: Retorna la memoria reciente de interacción con el PNJ o Playerbot.
* `Chatter:ToggleUI()`: Abre o cierra la interfaz de configuración de tono, rol y memoria de IA.

---

## 2. Eventos Manejados
* `CHAT_MSG_WHISPER`: Intercepción y renderizado cinemático de respuestas narrativas generadas por `mod-llm-chatter`.
* `CHAT_MSG_WHISPER_INFORM`: Registro de mensajes emitidos por el jugador al historial de contexto.
* `PLAYER_ENTERING_WORLD`: Inicialización del roster y sincronización con el estado de `ChatterDB`.
