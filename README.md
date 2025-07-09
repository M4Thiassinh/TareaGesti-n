# Tarea de Gestión de Datos

Este repositorio alberga los recursos y entregables fundamentales para el proyecto de Gestión de Datos, cubriendo un flujo completo desde la creación de la base de datos hasta el análisis y la visualización interactiva en Power BI.

---

## Estructura y Descripción de Archivos

Una guía detallada de los contenidos del repositorio:

### Scripts SQL

* **`creacion_db.sql`**
    ```sql
    -- Este script define la estructura de la base de datos
    -- Incluye CREATE TABLE, PRIMARY KEY, FOREIGN KEY, etc.
    ```
    Este archivo contiene los scripts SQL esenciales para la **creación del esquema de la base de datos**. Al ejecutarlo, se establecerán todas las tablas, relaciones, restricciones y otros elementos necesarios para inicializar la estructura de la base de datos.

* **`db_con_datos.sql`**
    ```sql
    -- Script para poblar la base de datos con datos de ejemplo/preparados
    -- Contiene sentencias INSERT INTO...
    ```
    Este script SQL está diseñado para **facilitar la importación de datos preexistentes**. Al ejecutarlo en su instancia de MySQL Workbench, la base de datos se poblará automáticamente con la información requerida para el análisis, sin necesidad de cargar CSVs manualmente si se prefiere este método.

### Archivos de Datos Limpios (CSV)

* **`matricula.csv`**
* **`infraestructura.csv`**

    Estos archivos CSV (`Comma Separated Values`) presentan los **datos limpios y preprocesados** correspondientes a la matrícula y la infraestructura, respectivamente. Están optimizados y listos para ser importados directamente a sus respectivas tablas "raw" (o de staging) dentro de la base de datos. Son el punto de partida para cualquier proceso de ETL si se opta por una carga incremental.

### Informes de Power BI

* **`Pregunta-1.pbix`**
* **`Pregunta-2.pbix`**

    Estos archivos (`.pbix`) son los **informes interactivos desarrollados en Power BI Desktop**. Cada archivo corresponde a la solución visual y analítica de una pregunta específica formulada en el informe del proyecto. Contienen los **gráficos, dashboards y visualizaciones clave** que sustentan las conclusiones, además de otras exploraciones y pruebas realizadas durante el desarrollo del análisis.
