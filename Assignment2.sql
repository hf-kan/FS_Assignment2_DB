/*
* File: Assignment2_SubmissionTemplate.sql
* 
* 1) Rename this file according to the instructions in the assignment statement.
* 2) Use this file to insert your solution.
*
*/


/*
*  Assume a user account 'fsad' with password 'fsad2022' with permission
* to create  databases already exists. You do NO need to include the commands
* to create the user nor to give it permission in you solution.
* For your testing, the following command may be used:
*
* CREATE USER fsad PASSWORD 'fsad2022' CREATEDB;
* GRANT pg_read_server_files TO fsad;
*/


/* *********************************************************
* Exercise 1. Create the Smoked Trout database
* 
************************************************************ */

-- The first time you login to execute this file with \i it may
-- be convenient to change the working directory.
  -- In PostgreSQL, folders are identified with '/'
  
-- 1) Create a database called SmokedTrout.
CREATE DATABASE "SmokedTrout"
	WITH
	OWNER = fsad
	ENCODING = 'UTF8'
	CONNECTION LIMIT = -1;

-- 2) Connect to the database
\c SmokedTrout fsad;
/* *********************************************************
* Exercise 2. Implement the given design in the Smoked Trout database
* 
************************************************************ */

-- 1) Create a new ENUM type called materialState for storing the raw material state
CREATE TYPE MaterialState AS ENUM ('Solid', 'Liquid', 'Gas', 'Plasma');
-- 2) Create a new ENUM type called materialComposition for storing whether
-- a material is Fundamental or Composite.
CREATE TYPE MaterialComposition AS ENUM ('Fundamental', 'Composite');
-- 3) Create the table TradingRoute with the corresponding attributes. 
CREATE TABLE public.TradingRoute
(
	MonitoringKey INT PRIMARY KEY,
	FleetSize INT NOT NULL,
	OperatingCompany VARCHAR(80) NOT NULL,
	LastYearRevenue DECIMAL NOT NULL
);
-- 4) Create the table Planet with the corresponding attributes.
CREATE TABLE public.Planet
(
	PlanetID INT PRIMARY KEY,
	StarSystem VARCHAR(80) NOT NULL,
	Name VARCHAR(80) NOT NULL,
	Population INT NOT NULL
);
-- 5) Create the table SpaceStation with the corresponding attributes.
CREATE TABLE public.SpaceStation
(
	StationID INT PRIMARY KEY,
	PlanetID INT NOT NULL,
	Name VARCHAR(80) NOT NULL,
	Longitude VARCHAR(10) NOT NULL,
	Latitude VARCHAR(10) NOT NULL,
	CONSTRAINT fk_planet
		FOREIGN KEY(PlanetID)
			REFERENCES public.Planet(PlanetID)
			ON UPDATE CASCADE
			ON DELETE CASCADE
);
-- 6) Create the parent table Product with the corresponding attributes.
CREATE TABLE public.Product
(
	ProductID INT PRIMARY KEY,
	Name VARCHAR(80) NOT NULL,
	VolumePerTon DECIMAL NOT NULL,
	ValuePerTon DECIMAL NOT NULL
);
-- 7) Create the child table RawMaterial with the corresponding attributes.
CREATE TABLE public.RawMaterial
(
	FundamentalOrComposite MaterialComposition NOT NULL,
	State MaterialState NOT NULL
) INHERITS(public.Product);

-- 8) Create the child table ManufacturedGood. 
CREATE TABLE public.ManufacturedGood
(
) INHERITS(public.Product);

-- 9) Create the table MadeOf with the corresponding attributes.
CREATE TABLE public.MadeOf
(
	ManufacturedGoodID INT NOT NULL,
	ProductID INT NOT NULL,
	PRIMARY KEY (ManufacturedGoodID, ProductID)
);
-- 10) Create the table Batch with the corresponding attributes.
CREATE TABLE public.Batch
(
	BatchID INT PRIMARY KEY,
	ProductID INT NOT NULL,
	ExtractionOrManufacturingDate DATE NOT NULL,
	PlanetID INT NOT NULL,
	CONSTRAINT fk_OriginPlanet
		FOREIGN KEY(PlanetID)
			REFERENCES public.Planet(PlanetID)
			ON UPDATE CASCADE
			ON DELETE CASCADE	
);
-- 11) Create the table Sells with the corresponding attributes.
CREATE TABLE public.Sells
(
	BatchID INT NOT NULL,
	StationID INT NOT NULL,
	CONSTRAINT fk_Batch
		FOREIGN KEY(BatchID)
			REFERENCES public.Batch(BatchID)
			ON UPDATE CASCADE
			ON DELETE CASCADE,
	CONSTRAINT fk_Station
		FOREIGN KEY(StationID)
			REFERENCES public.SpaceStation(StationID)
			ON UPDATE CASCADE
			ON DELETE CASCADE,
	PRIMARY KEY (BatchID, 	StationID)	
);
-- 12)  Create the table Buys with the corresponding attributes.
CREATE TABLE public.Buys
(
	BatchID INT NOT NULL,
	StationID INT NOT NULL,
	CONSTRAINT fk_Batch
		FOREIGN KEY(BatchID)
			REFERENCES public.Batch(BatchID)
			ON UPDATE CASCADE
			ON DELETE CASCADE,
	CONSTRAINT fk_Station
		FOREIGN KEY(StationID)
			REFERENCES public.SpaceStation(StationID)
			ON UPDATE CASCADE
			ON DELETE CASCADE,
	PRIMARY KEY (BatchID, 	StationID)
);
-- 13)  Create the table CallsAt with the corresponding attributes.
CREATE TABLE public.CallsAt
(
	MonitoringKey INT NOT NULL,
	StationID INT NOT NULL,
	VisitOrder INT NOT NULL,
	PRIMARY KEY(MonitoringKey, VisitOrder),
	CONSTRAINT fk_Station
		FOREIGN KEY(StationID)
			REFERENCES public.SpaceStation(StationID)
			ON UPDATE CASCADE
			ON DELETE CASCADE,
	CONSTRAINT fk_Monitor
		FOREIGN KEY(MonitoringKey)
			REFERENCES public.TradingRoute(MonitoringKey)
			ON UPDATE CASCADE
			ON DELETE CASCADE
);
-- 14)  Create the table Distance with the corresponding attributes.
CREATE TABLE public.Distance
(
	OriginPlanetID INT NOT NULL,
	DestinationPlanetID INT NOT NULL,
	AvgDistance DECIMAL NOT NULL,
	PRIMARY KEY (OriginPlanetID, DestinationPlanetID),
	CONSTRAINT fk_OriginPlanet
		FOREIGN KEY(OriginPlanetID)
			REFERENCES public.Planet(PlanetID)
			ON UPDATE CASCADE
			ON DELETE CASCADE,
	CONSTRAINT fk_DestinationPlanet
		FOREIGN KEY(DestinationPlanetID)
			REFERENCES public.Planet(PlanetID)
			ON UPDATE CASCADE
			ON DELETE CASCADE
);
/* *********************************************************
* Exercise 3. Populate the Smoked Trout database
* 
************************************************************ */
/* *********************************************************
* NOTE: The copy statement is NOT standard SQL.
* The copy statement does NOT permit on-the-fly renaming columns,
* hence, whenever necessary, we:
* 1) Create a dummy table with the column name as in the file
* 2) Copy from the file to the dummy table
* 3) Copy from the dummy table to the real table
* 4) Drop the dummy table (This is done further below, as I keep
*    the dummy table also to imporrt the other columns)
************************************************************ */



-- 1) Unzip all the data files in a subfolder called data from where you have your code file 
-- NO CODE GOES HERE. THIS STEP IS JUST LEFT HERE TO KEEP CONSISTENCY WITH THE ASSIGNMENT STATEMENT

-- 2) Populate the table TradingRoute with the data in the file TradeRoutes.csv.
\copy public.TradingRoute FROM './data/TradeRoutes.csv' DELIMITER ',' CSV HEADER;
-- 3) Populate the table Planet with the data in the file Planets.csv.
\copy public.Planet FROM './data/Planets.csv' DELIMITER ',' CSV HEADER;
-- 4) Populate the table SpaceStation with the data in the file SpaceStations.csv.
\copy public.SpaceStation FROM './data/SpaceStations.csv' DELIMITER ',' CSV HEADER;
-- 5) Populate the tables RawMaterial and Product with the data in the file Products_Raw.csv.
CREATE TABLE Dummy
(
	ProductID INT NOT NULL,
	ProductName VARCHAR(80) NOT NULL,
	Composite BOOLEAN NOT NULL,
	VolumePerTon DECIMAL NOT NULL,
	ValuePerTon DECIMAL NOT NULL,
	State MaterialState NOT NULL
);

\copy Dummy (ProductID, ProductName, Composite, VolumePerTon, ValuePerTon, State) FROM './data/Products_Raw.csv' DELIMITER ',' CSV HEADER; 

INSERT INTO public.RawMaterial
SELECT ProductID, ProductName, VolumePerTon, ValuePerTon, 'Fundamental'::MaterialComposition, State
FROM Dummy
WHERE Composite = FALSE
UNION
SELECT ProductID, ProductName, VolumePerTon, ValuePerTon, 'Composite'::MaterialComposition, State
FROM Dummy
WHERE Composite = TRUE;

DROP TABLE IF EXISTS Dummy;
-- 6) Populate the tables ManufacturedGood and Product with the data in the file  Products_Manufactured.csv.
\copy public.ManufacturedGood FROM './data/Products_Manufactured.csv' DELIMITER ',' CSV HEADER;
-- 7) Populate the table MadeOf with the data in the file MadeOf.csv.
\copy public.MadeOf FROM './data/MadeOf.csv' DELIMITER ',' CSV HEADER;
-- 8) Populate the table Batch with the data in the file Batches.csv.
\copy public.Batch FROM './data/Batches.csv' DELIMITER ',' CSV HEADER;
-- 9) Populate the table Sells with the data in the file Sells.csv.
\copy public.Sells FROM './data/Sells.csv' DELIMITER ',' CSV HEADER;
-- 10) Populate the table Buys with the data in the file Buys.csv.
\copy public.Buys FROM './data/Buys.csv' DELIMITER ',' CSV HEADER;
-- 11) Populate the table CallsAt with the data in the file CallsAt.csv.
\copy public.CallsAt FROM './data/CallsAt.csv' DELIMITER ',' CSV HEADER;
-- 12) Populate the table Distance with the data in the file PlanetDistances.csv.
\copy public.Distance FROM './data/PlanetDistances.csv' DELIMITER ',' CSV HEADER;

/* *********************************************************
* Exercise 4. Query the database
* 
************************************************************ */

-- 4.1 Report last year taxes per company

-- 1) Add an attribute Taxes to table TradingRoute
ALTER TABLE public.TradingRoute
--ADD COLUMN Taxes DECIMAL GENERATED ALWAYS AS (LastYearRevenue * 0.12) STORED;
ADD COLUMN Taxes DECIMAL;

-- 2) Set the derived attribute taxes as 12% of LastYearRevenue
UPDATE public.TradingRoute
SET Taxes = LastYearRevenue * 0.12;

-- 3) Report the operating company and the sum of its taxes group by company.
SELECT OperatingCompany, SUM(Taxes) AS "TotalTaxes"
FROM public.TradingRoute
GROUP BY OperatingCompany;

-- 4.2 What's the longest trading route in parsecs?

-- 1) Create a dummy table RouteLength to store the trading route and their lengths.
CREATE TABLE RouteLength
(
	RouteMonitoringKey INT NOT NULL,
	RouteTotalDistance DECIMAL NOT NULL
);
-- 2) Create a view EnrichedCallsAt that brings together trading route, space stations and planets.
CREATE VIEW EnrichedCallsAt AS
SELECT A.MonitoringKey, B.VisitOrder, B.StationID, D.PlanetID
FROM public.TradingRoute A 
INNER JOIN public.CallsAt B ON A.MonitoringKey = B.MonitoringKey
INNER JOIN public.SpaceStation C on B.StationID = C.StationID
INNER JOIN public.Planet D on C.PlanetID = D.PlanetID;
-- 3) Add the support to execute an anonymous code block as follows;
DO
$$
DECLARE
-- 4) Within the declare section, declare a variable of type real to store a route total distance.
	RouteDistance REAL;
-- 5) Within the declare section, declare a variable of type real to store a hop partial distance.
	HopPartialDistance REAL;
-- 6) Within the declare section, declare a variable of type record to iterate over routes.
	rRoute RECORD;
-- 7) Within the declare section, declare a variable of type record to iterate over hops.
	rHops RECORD;
-- 8) Within the declare section, declare a variable of type text to transiently build dynamic queries.
	Query TEXT;
-- 9) Within the main body section, loop over routes in TradingRoutes
BEGIN
	FOR rRoute IN SELECT MonitoringKey
	FROM public.TradingRoute
	LOOP
-- 10) Within the loop over routes, get all visited planets (in order) by this trading route.
		Query := 'CREATE VIEW PortsOfCall AS '
			|| 'SELECT PlanetID, VisitOrder '
			|| 'FROM EnrichedCallsAt '
			|| 'WHERE MonitoringKey = ' || rRoute.MonitoringKey
			|| 'ORDER BY VisitOrder';
-- 11) Within the loop over routes, execute the dynamic view
		EXECUTE Query;
-- 12) Within the loop over routes, create a view Hops for storing the hops of that route. 
		CREATE VIEW Hops AS
		SELECT A.PlanetID, B.PlanetID AS NextPlanetID
		FROM PortsOfCall A INNER JOIN PortsOfCall B on A.VisitOrder = B.VisitOrder - 1;
-- 13) Within the loop over routes, initialize the route total distance to 0.0.
		RouteDistance := 0.0;
-- 14) Within the loop over routes, create an inner loop over the hops
		FOR rHops IN SELECT *
		FROM Hops
		LOOP
-- 15) Within the loop over hops, get the partial distances of the hop. 
			Query := 'SELECT AvgDistance '
				|| 'FROM public.Distance '
				|| 'WHERE OriginPlanetID = ' || rHops.PlanetID
				|| 'AND DestinationPlanetID = ' || rHops.NextPlanetID;
-- 16)  Within the loop over hops, execute the dynamic view and store the outcome INTO the hop partial distance.
			EXECUTE Query INTO HopPartialDistance;
-- 17)  Within the loop over hops, accumulate the hop partial distance to the route total distance.
			RouteDistance := RouteDistance + HopPartialDistance;
-- 18)  Go back to the routes loop and insert into the dummy table RouteLength the pair (RouteMonitoringKey,RouteTotalDistance).
		END LOOP;
	INSERT INTO RouteLength
	SELECT rRoute.MonitoringKey, RouteDistance;
-- 19)  Within the loop over routes, drop the view for Hops (and cascade to delete dependent objects).
	DROP VIEW IF EXISTS Hops CASCADE;
-- 20)  Within the loop over routes, drop the view for PortsOfCall (and cascade to delete dependent objects).
	DROP VIEW IF EXISTS PortsOfCall CASCADE;
	END LOOP;
END;
$$;
-- 21)  Finally, just report the longest route in the dummy table RouteLength.ENUM
SELECT RouteMonitoringKey, RouteTotalDistance
FROM RouteLength 
WHERE RouteTotalDistance = 
(SELECT MAX(A.RouteTotalDistance) FROM RouteLength A);
