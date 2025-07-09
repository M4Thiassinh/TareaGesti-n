--//////////////////////////
--Creacion de las tablas raw
--//////////////////////////

CREATE TABLE raw_matricula (
    anio INT,
    cod_institucion VARCHAR(10),
    nombre_institucion VARCHAR(255),
    tipo_institucion VARCHAR(100),
    comuna VARCHAR(100),
    nombre_region VARCHAR(100),
    cod_carrera VARCHAR(20),
    carrera_generica VARCHAR(255),
    area_conocimiento VARCHAR(100),
    m1_hombres INT,
    m1_mujeres INT,
    total_hombres INT,
    total_mujeres INT
);

CREATE TABLE raw_infraestructura (
    tipo_institucion VARCHAR(100),
    cod_institucion VARCHAR(10),
    nombre_institucion VARCHAR(255),
    anio_proceso INT,
    n_laboratorios INT,
    m2_construido DECIMAL(10,2),
    pc_para_alumnos INT,
    pc_con_internet INT
);

--//////////////////////////
--Poblar las tablas raw
--//////////////////////////

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/matricula.csv'
INTO TABLE raw_matricula
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
  anio,
  cod_institucion,
  nombre_institucion,
  tipo_institucion,
  comuna,
  nombre_region,
  cod_carrera,
  carrera_generica,
  area_conocimiento,
  @m1_hombres,
  @m1_mujeres,
  @total_hombres,
  @total_mujeres
)
SET
  m1_hombres = NULLIF(@m1_hombres, ''),
  m1_mujeres = NULLIF(@m1_mujeres, ''),
  total_hombres = NULLIF(@total_hombres, ''),
  total_mujeres = NULLIF(@total_mujeres, '');


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/infraestructura.csv'
INTO TABLE raw_infraestructura
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
  tipo_institucion,
  cod_institucion,
  nombre_institucion,
  anio_proceso,
  @n_laboratorios,
  @m2_construido,
  @pc_para_alumnos,
  @pc_con_internet
)
SET
  n_laboratorios   = CASE WHEN @n_laboratorios IN ('', 's/i') THEN NULL ELSE @n_laboratorios END,
  m2_construido    = CASE WHEN @m2_construido IN ('', 's/i') THEN NULL ELSE @m2_construido END,
  pc_para_alumnos  = CASE WHEN @pc_para_alumnos IN ('', 's/i') THEN NULL ELSE @pc_para_alumnos END,
  pc_con_internet  = CASE WHEN @pc_con_internet IN ('', 's/i') THEN NULL ELSE @pc_con_internet END;


--///////////////////////////
--creacion de las dimensiones y tablas de hehos
--//////////////////////////
CREATE TABLE dim_tiempo (
  id_tiempo INT PRIMARY KEY AUTO_INCREMENT,
  anio INT
);

CREATE TABLE dim_institucion (
  id_institucion INT PRIMARY KEY AUTO_INCREMENT,
  cod_institucion VARCHAR(10),
  nombre_institucion VARCHAR(255),
  tipo_institucion VARCHAR(100)
);

CREATE TABLE dim_region_comuna (
  id_region_comuna INT PRIMARY KEY AUTO_INCREMENT,
  nombre_region VARCHAR(100),
  comuna VARCHAR(100)
);

CREATE TABLE dim_carrera (
  id_carrera INT PRIMARY KEY AUTO_INCREMENT,
  cod_carrera VARCHAR(20),
  carrera_generica VARCHAR(255),
  area_conocimiento VARCHAR(100)
);

CREATE TABLE fact_matricula (
  id_tiempo INT,
  id_institucion INT,
  id_region_comuna INT,
  id_carrera INT,
  m1_hombres INT,
  m1_mujeres INT,
  total_hombres INT,
  total_mujeres INT,
  FOREIGN KEY (id_tiempo) REFERENCES dim_tiempo(id_tiempo),
  FOREIGN KEY (id_institucion) REFERENCES dim_institucion(id_institucion),
  FOREIGN KEY (id_region_comuna) REFERENCES dim_region_comuna(id_region_comuna),
  FOREIGN KEY (id_carrera) REFERENCES dim_carrera(id_carrera)
);

CREATE TABLE fact_infraestructura (
  id_tiempo INT,
  id_institucion INT,
  m2_construido DECIMAL(10,2),
  n_laboratorios INT,
  pc_para_alumnos INT,
  pc_con_internet INT,
  FOREIGN KEY (id_tiempo) REFERENCES dim_tiempo(id_tiempo),
  FOREIGN KEY (id_institucion) REFERENCES dim_institucion(id_institucion)
);


--//////////////////////////
--Población de las dimensiones y las tablas de hechos
--//////////////////////////
INSERT INTO dim_tiempo (anio)
SELECT DISTINCT anio
FROM raw_matricula
WHERE anio IS NOT NULL;

INSERT INTO dim_institucion (cod_institucion, nombre_institucion, tipo_institucion)
SELECT DISTINCT cod_institucion, nombre_institucion, tipo_institucion
FROM raw_matricula
WHERE cod_institucion IS NOT NULL;

INSERT INTO dim_region_comuna (nombre_region, comuna)
SELECT DISTINCT nombre_region, comuna
FROM raw_matricula
WHERE nombre_region IS NOT NULL AND comuna IS NOT NULL;

INSERT INTO dim_carrera (cod_carrera, carrera_generica, area_conocimiento)
SELECT DISTINCT cod_carrera, carrera_generica, area_conocimiento
FROM raw_matricula
WHERE cod_carrera IS NOT NULL;


INSERT INTO fact_matricula (
  id_tiempo,
  id_institucion,
  id_region_comuna,
  id_carrera,
  m1_hombres,
  m1_mujeres,
  total_hombres,
  total_mujeres
)
SELECT
  dt.id_tiempo,
  di.id_institucion,
  drc.id_region_comuna,
  dc.id_carrera,
  rm.m1_hombres,
  rm.m1_mujeres,
  rm.total_hombres,
  rm.total_mujeres
FROM raw_matricula rm
JOIN dim_tiempo dt ON dt.anio = rm.anio
JOIN dim_institucion di ON di.cod_institucion = rm.cod_institucion
JOIN dim_region_comuna drc ON drc.nombre_region = rm.nombre_region AND drc.comuna = rm.comuna
JOIN dim_carrera dc ON dc.cod_carrera = rm.cod_carrera;


INSERT INTO fact_infraestructura (
  id_tiempo,
  id_institucion,
  m2_construido,
  n_laboratorios,
  pc_para_alumnos,
  pc_con_internet
)
SELECT
  dt.id_tiempo,
  di.id_institucion,
  ri.m2_construido,
  ri.n_laboratorios,
  ri.pc_para_alumnos,
  ri.pc_con_internet
FROM raw_infraestructura ri
JOIN dim_tiempo dt ON dt.anio = ri.anio_proceso
JOIN dim_institucion di ON di.cod_institucion = ri.cod_institucion;

