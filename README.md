# Proyecto de Análisis y Auditoría de Base de Datos (Sakila)

Este documento detalla los aspectos técnicos, la metodología y el análisis analítico aplicados durante la resolución de las consultas del proyecto.

---

## 1. Herramientas y Funciones SQL Utilizadas

Para responder a las necesidades de extracción de información del modelo de negocio, se estructuró el uso de los siguientes componentes de SQL:

* **Filtrados Condicionales Avanzados:** Uso de la cláusula `WHERE` combinada con operadores como `BETWEEN` (para rangos cerrados de identificadores como `actor_id`) e `IN` (para la inclusión o exclusión selectiva de clasificaciones por edades).
* **Funciones de Agregación y Métricas:** Implementación de `COUNT`, `SUM` y `AVG` para obtener indicadores clave de rendimiento (KPIs) como el total de películas por categoría, ingresos brutos e históricos de renta.
* **Métricas de Dispersión y Variabilidad:** Uso de funciones estadísticas como `STDDEV` (Desviación Estándar) y `VARIANCE` (Varianza) aplicadas sobre las columnas de costes de reemplazo, entre otras, permitiendo medir la estabilidad y variabilidad de los precios en el negocio.
* **Formateo y Manipulación de Fechas:** Aplicación de funciones de conversión como `::date` y `TO_CHAR` para segmentar los alquileres de forma cronológica (por días específicos y meses acumulados), facilitando la identificación de patrones de consumo.
* **Control de Paginación y Desplazamiento:** Uso combinado de `LIMIT` y `OFFSET` para auditorías temporales específicas, permitiendo localizar transacciones exactas en una línea de tiempo (como el antepenúltimo alquiler registrado).

---

## 2. Justificación de Técnicas Avanzadas

### ¿Por qué se utilizaron Subconsultas?
Las subconsultas fueron indispensables en escenarios donde las condiciones de filtrado dependían de un valor dinámico y variable. 
* **Evitar Datos Estáticos:** Al buscar películas con duración superior al promedio (`length > (SELECT AVG...)`) o precios mayores a la media, una consulta estática quedaría obsoleta al insertar o eliminar películas. Las subconsultas garantizan que el criterio de comparación sea dinámico y se recalcule en tiempo real según el estado actual de la base de datos.
* **Exclusiones Complejas:** Fueron la herramienta ideal para la lógica de conjuntos inversos (como encontrar actores que *no* han participado en películas de una categoría específica), permitiendo aislar primero el universo que sí cumple la condición para luego negarlo mediante `NOT IN`.

### ¿Por qué se utilizaron Estructuras Temporales y Vistas?
* **Tablas Temporales (`CREATE TEMPORARY TABLE`):** Se emplearon para almacenar conjuntos de datos intermedios de alto coste de procesamiento (como el cálculo masivo de rentas acumuladas por cliente o películas con más de 10 alquileres). Esto optimiza el rendimiento al evitar tener que recalcular uniones complejas (`JOINs`) múltiples veces en una misma sesión de trabajo.
* **Vistas Persistentes (`CREATE VIEW`):** Se crearon para encapsular abstracciones lógicas repetitivas (como el conteo de películas por actor). Esto simplifica la estructura de consultas futuras para los usuarios del negocio, permitiendo consultar reportes complejos mediante un simple 'select * from'.

---

## 3. Tratamiento de Datos Nulos e Inconsistencias

Durante el desarrollo se detectaron particularidades en el estado de la información:

* **La Columna `original_language_id` (Tabla `film`):** Se identificó que esta columna se encuentra completamente poblada con valores `NULL` a lo largo de toda la base de datos. Esto representa una limitación para analizar si una película se mantiene en su idioma original. Sin embargo, la lógica de la consulta (`language_id = original_language_id`) se dejó planteada para el momento en el que se arregle esa información.
* **Estrategia con `LEFT JOIN` frente a `INNER JOIN`:** Para mitigar la pérdida de información debido a registros ausentes, se optó conscientemente por `LEFT JOIN` en consultas. Esto aseguró que si un cliente nunca ha alquilado, o si una película no tiene stock en el inventario, sigan apareciendo en los listados generales con un conteo equivalente a `0` en lugar de ser eliminados del mapa del análisis (lo que habría ocurrido usando un `INNER JOIN`).

---

## 4. Principales Hallazgos del Análisis de Datos

* **Estado Financiero Global:** A través del análisis del histórico de transacciones, se determinó que la empresa ha generado un ingreso total bruto de **67,416.51 €**. Este indicador demuestra la salud operativa del negocio y sirve como línea base para medir la rentabilidad de las inversiones en el catálogo.

* **Análisis de Variabilidad Financiera y Operativa:**
  A través de las funciones estadísticas avanzadas de la base de datos, se extrajeron indicadores de dispersión críticos para la toma de decisiones estratégicas:
  * **Ticket de Pago:** El precio promedio por transacción se situó en **4.20 €** con una desviación estándar de **2.36 €** y una varianza de **5.58 €**. Estos datos revelan la estabilidad de los precios del catálogo; una dispersión controlada y predecible indica que los clientes consumen de manera homogénea.
  * **Análisis del Coste de Reemplazo:** El coste de sustituir una película dañada o perdida presenta una variabilidad (desviación estándar) de **6.05 €**. Conocer esta dispersión permite al negocio calcular un fondo preciso para cubrir las pérdidas de stock físico sin descuadrar la caja.
  * **Análisis de Extensión del Catálogo:** El metraje de las películas oscila entre una duración mínima de **46 minutos** y una máxima de **185 minutos**. Esta métrica ayuda a segmentar el catálogo (por ejemplo, en largometrajes estándar o producciones de larga duración), permitiendo analizar si los usuarios prefieren películas cortas o si el tiempo de metraje influye en la tasa de devolución del contenido.

* **Análisis de Estacionalidad y Patrones Temporales:**
  La agrupación cronológica de los alquileres desveló una fluctuación estacional grande en el comportamiento de los consumidores:
  * **Comportamiento Mensual:** Se identificó una "temporada alta" bastante agresiva durante los meses de verano de 2005, escalando de 1,156 alquileres en mayo a un pico absoluto de **6,709 alquileres en julio**, seguido por 5,686 en agosto. Por el contrario, febrero de 2006 muestra un desplome crítico con apenas **182 transacciones**, sugiriendo la necesidad de implementar promociones en época invernal.
  * **Picos de Operación Diaria:** El día con mayor actividad logística en la historia de la empresa fue el **31 de julio de 2005 con 679 alquileres**, seguido por el **1 de agosto de 2005 con 671**. Estos datos permiten a la gerencia optimizar el negocio en las fechas de máxima presión.

* **Capacidad y Eficiencia de Activos en Inventario:**
  Al cruzar el catálogo mediante un `LEFT JOIN`, se descubrió un patrón logístico rígido y controlado: las películas más exitosas del catálogo comercial (*Seabiscuit Punk, Cupboard Sinners, Apache Divine, Bucket Brotherhood*, entre otras) cuentan con un stock estricto y unificado de **8 copias físicas disponibles por título**, descendiendo de manera gradual a 7 y 6 copias para títulos de menor rotación. Esto demuestra una gestión de almacén estandarizada que evita la sobreacumulación de stock.

* **Concentración de Ingresos:** Al evaluar el volumen de facturación individualizado, se detectó un grupo selecto de clientes que lideran el consumo de la plataforma. El "Top 5" de clientes con mayor aportación económica está liderado por **Karl Seal (221.55 €)** y **Eleanor Hunt (216.54 €)**, seguidos de cerca por *Clara Shaw (195.58 €)*, *Rhonda Kennedy (194.61 €)* y *Marion Snyder (194.61 €)*. Este hallazgo podría sugerir la creación de un programa de fidelización exclusivo para proteger a estos usuarios de alta rentabilidad.

* **Identificación de Productos Estrella:** El análisis del inventario reveló cuáles son los títulos con mayor rotación del negocio. La película más exitosa y más alquilada es **BUCKET BROTHERHOOD** con un récord de **34 alquileres**, seguida muy de cerca por **ROCKETEER MOTHER (33 alquileres)**. Títulos como *Grit Clockwork, Forward Temple, Juggler Hardly, Scalawag Duck* y *Ridgemont Submarine* comparten un sólido tercer puesto con **32 alquileres** cada una.

* **Concentración de Talento en el Catálogo:** Al agrupar los registros por nombres de pila de los actores, se descubrió una tendencia de repetición alta en el elenco: los primeros nombres *Kenneth*, *Penelope* y *Julia* son los más frecuentes entre los actores de la base de datos. Esto indica que el catálogo actual tiene una fuerte dependencia o concentración de participación de ciertos perfiles actorales en la oferta global de entretenimiento.

* **Inadecuación del Producto Cartesiano:** Al evaluar la combinación analítica de películas y categorías mediante un `CROSS JOIN`, se demostró que la consulta **no aporta valor operacional**. Un producto cartesiano rompe las reglas lógicas del negocio al emparejar de forma masiva cada película con todos los géneros existentes (afirmando de forma errónea que un título infantil pertenece también al terror y a la acción simultáneamente), lo que recalca la importancia de usar uniones estrictas (`INNER` o `LEFT`) para salvaguardar la veracidad de los datos.

---

## 5. Recomendaciones Estratégicas para el Negocio

A partir de los hallazgos analíticos obtenidos, se pueden sugerir las siguientes acciones:

1. **Planificación de Campañas Antiestacionales:** Dado el desplome de ventas en febrero (182 alquileres) frente al éxito de julio (6,709 alquileres), podrían implementarse promociones de fidelización o packs de descuento durante el invierno para estabilizar la caja.
2. **Optimización de Copias Físicas:** Mantener la política de stock máximo de 8 copias para títulos de alta rotación (`BUCKET BROTHERHOOD`, `ROCKETEER MOTHER`), pero evaluar reducir a 2 o 3 copias aquellos títulos situados en la cola baja del inventario para liberar espacio en almacén y reducir los costes de sustitución (cuya variabilidad es de 6.05 €).
3. **Saneamiento de la Base de Datos:** Se recomienda corregir la columna `original_language_id` en la tabla `film`, ya que su actual estado íntegro en `NULL` impide al negocio explotar análisis de preferencia de consumo en idioma nativo vs. doblajes.
