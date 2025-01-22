/*             Bienvenidos a mi proyecto: 
Creación y Analisis de una base de datos MySQL ficticia sobre torneos de ping pong*/

# Creamos la base de datos:
CREATE DATABASE tournament_PingPong;
USE tournament_PingPong;
.
# Creamos las tablas:
CREATE TABLE players (
id INT AUTO_INCREMENT PRIMARY KEY,
first_name VARCHAR(80) NOT NULL,
last_name VARCHAR(80) NOT NULL,
birth_date DATE NOT NULL,
city_id INT NOT NULL);

CREATE TABLE cities (
city_id INT AUTO_INCREMENT PRIMARY KEY,
city VARCHAR(80) NOT NULL,
country VARCHAR(80) NOT NULL);

CREATE TABLE courts (
court_id INT AUTO_INCREMENT PRIMARY KEY,
court_name VARCHAR(80) NOT NULL,
neighborhood VARCHAR(80) NOT NULL,
location VARCHAR(100) NOT NULL,
capacity INT NOT NULL);

CREATE TABLE cups (
cup_id INT AUTO_INCREMENT PRIMARY KEY,
cup_name VARCHAR(80) NOT NULL,
cup_type VARCHAR(80) NOT NULL);

CREATE TABLE winners (
winner_id INT AUTO_INCREMENT PRIMARY KEY,
player_id INT NOT NULL,
cup_id INT NOT NULL,
court_id INT NOT NULL,
win_date DATE NOT NULL);

/* Ahora para una forma mas comoda, importaremos los datos para las tablas 
   desde archivos CSV previamente creados, para eso utilizaremos la opción de 
   Table Data Import Wizard de MYSSQL Workbench*/
   
# Editamos las tablas para fijar las claves foraneas: 
ALTER TABLE players
ADD CONSTRAINT FK_CITIES FOREIGN KEY (city_id) REFERENCES cities(city_id);

ALTER TABLE winners
ADD CONSTRAINT FK_PLAYERS FOREIGN KEY (player_id) REFERENCES players(id),
ADD CONSTRAINT FK_CUPS FOREIGN KEY (cup_id) REFERENCES cups(cup_id),
ADD CONSTRAINT FK_COURTS FOREIGN KEY (court_id) REFERENCES courts(court_id);

# Ahora vamos a realizar un analisis sobre los torneos a través de consultas:

# ¿Cantidad de copas por jugador?
SELECT p.id, CONCAT(p.first_name, ' ', p.last_name) nombre_completo, 
    COUNT(w.cup_id) cantidad_copas FROM players p 
      LEFT JOIN winners w ON p.id = w.player_id
	LEFT JOIN cups c ON w.cup_id = c.cup_id
  GROUP BY p.id
ORDER BY cantidad_copas DESC;

/* Buscare a los jugadores que han ganado al menos una copa, 
y en qué fecha fue su última victoria*/
SELECT p.id, CONCAT(p.first_name, ' ', p.last_name) nombre_completo, MAX(w.win_date) ultima_copa FROM players p 
   JOIN winners w ON p.id = w.player_id
  GROUP BY p.id
ORDER BY ultima_copa DESC;

# Queremos ver los jugadores que todavia no han ganado ninguna copa
SELECT p.id, CONCAT(p.first_name, ' ', p.last_name) nombre_completo
     FROM players p 
      LEFT JOIN winners w ON p.id = w.player_id
	LEFT JOIN cups c ON w.cup_id = c.cup_id
 WHERE c.cup_name IS NULL;
 
# ¿Cuantas veces se jugo cada copa?
SELECT c.cup_id, c.cup_name, COUNT(*) cantidad
 FROM cups c 
  JOIN winners w ON c.cup_id = w.cup_id
 GROUP BY c.cup_id
ORDER BY cantidad DESC;
 
/* Buscaremos las 3 canchas donde mas se han jugado torneos,
pero si hay algún empate en el ranking no lo dejaremos por fuera*/
WITH cantidad AS (
     SELECT c.court_id, c.court_name, COUNT(*) cantidad_torneos,
      DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) ranking
/*Con DENSE_RANK nos aseguramos que si hay igualdad en la cantidad de torneos realizados,
tengan el mismo ranking*/
     FROM courts c 
    JOIN winners w ON c.court_id = w.court_id
 GROUP BY c.court_id, c.court_name
)

SELECT court_id, court_name, cantidad_torneos
 FROM cantidad
WHERE ranking <= 3;

/* Y por ultimo, los resultados de cada una de estas querys la veremos
   en un dashboard de Power BI */
   
# ¡Muchas gracias!
