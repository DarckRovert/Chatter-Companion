# 🛡️ Política de Seguridad — Chatter_Companion

1. **Sanitización de Texto:** Todos los mensajes procesados pasan por filtros que remueven secuencias de escape de formato ilegales (`|T`, `|H`, `|K`) para prevenir taints o caídas del cliente.
2. **Protección contra Inundación:** Limitador de frecuencia de emisión para evitar desconexiones por flood de paquetes al servidor.
3. **Reporte de Vulnerabilidades:** Para reportar vulnerabilidades de seguridad, contacta al equipo de Project Jaina a través de GitHub.
