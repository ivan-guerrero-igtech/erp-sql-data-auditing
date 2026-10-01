# erp-sql-data-auditing
Script en T-SQL para auditar y conciliar discrepancias de stock y facturación en módulos logísticos de ERP (SAP B1)
# 📊 Conciliación de Inventario y Facturación en ERP (SAP B1) mediante T-SQL

Este repositorio contiene una herramienta de auditoría y pruebas de datos (**Database Testing**) desarrollada en **T-SQL** para sistemas SAP Business One.

### 🔍 El Escenario Operativo
En talleres automotrices o de servicios técnicos de gran envergadura (como Grupo Timbo), el flujo de repuestos para las Órdenes de Trabajo (OT) requiere un control estricto. Los insumos se trasladan desde depósitos centrales hacia los almacenes de los mecánicos.

### 🚨 El Problema que Resuelve
El error humano en las devoluciones manuales de repuestos sobrantes o desajustes de carga genera descalces contables. Este script automatiza la detección de:
1. **Fugas de cobro:** Materiales que salieron físicamente de los almacenes pero nunca fueron facturados al cliente.
2. **Facturación sin respaldo:** Repuestos cobrados en la factura que no registran una salida física real de inventario.

---

### 🛠️ Arquitectura del Script (Estrategia Técnica)
El desarrollo utiliza **Expresiones de Tabla Comunes (CTEs)** para procesar los datos en memoria de forma altamente eficiente:
* **`CTE_Traslados`:** Consolida los movimientos e ingresos físicos por artículo y almacén.
* **`CTE_Facturacion` & `CTE_NotasCredito`:** Calculan el balance neto de lo cobrado financieramente.
* **`FULL OUTER JOIN` & `COALESCE`:** Cruzan todo el universo de artículos asegurando que ningún ítem quede fuera de la matriz de datos.

### ⚙️ Reglas de Validación Automatizadas (QA Assertions)
El script evalúa dinámicamente el comportamiento de los datos mediante lógica condicional:
* **Exclusión de Almacenes Base:** Aísla automáticamente los depósitos troncales (`FIXIT-01` al `07`) para analizar solo la interacción en el taller.
* **Filtro de Mano de Obra:** Identifica los códigos de servicio (`CAR-%`) para evitar falsos positivos, ya que los servicios no requieren movimientos de stock.

---
### 💼 Habilidades Técnicas Demostradas
* **Database Testing:** Estructuración de consultas optimizadas (CTEs, Joins Complejos).
* **Análisis Funcional Financiero:** Control de reglas de negocio integrando inventario y facturación.
* **Uso de IA como Copiloto:** Elaborado e iterado con asistencia de OpenAI para la optimización de la estructura SQL.
