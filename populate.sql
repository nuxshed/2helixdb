-- 2. Data Population Script
USE mini_world_db;

-- ==========================================
-- LEVEL 1: Independent Tables
-- ==========================================

-- Insert Sectors
INSERT INTO SECTOR (SectorName, StellarCentralCoordinates) VALUES
('Alpha Quadrant', '001-23-99'),
('Beta Ring', '450-11-22'),
('Outer Rim', '999-00-00');

-- Insert Ethnicities
INSERT INTO ETHNICITY (Name, Tier) VALUES
('Terran (Human)', 'Tier 1'),
('Martian', 'Tier 2'),
('Proximan', 'Tier 3'),
('Andromedan', 'Tier 1');

-- Insert Assets (Generic Types for now)
INSERT INTO ASSET (AssetType) VALUES
('Class A Starship'),
('Quantum Generator'),
('Cargo Container: Dilithium'),
('Personal Transport Pod'),
('Residential Module 4F'),
('Mining Droid');

-- ==========================================
-- LEVEL 2: Geographic Hierarchy
-- ==========================================

-- Insert Planets (Linking to Sectors)
INSERT INTO PLANET (PlanetName, StellarCoordinates, SectorID) VALUES
('Earth', 'SOL-003', 1),
('Mars', 'SOL-004', 1),
('Proxima B', 'CEN-001', 2),
('Kepler-186f', 'KEP-186', 3);

-- Insert Stations (Linking to Planets)
INSERT INTO STATION (StationName, GeographicCoordinates, PlanetID) VALUES
('ISS Vanguard', 'Orbit-Low-Earth', 1),
('Olympus Mons Outpost', 'Surface-North', 2),
('Deep Space Gateway', 'Lagrange-Point-2', 3),
('Rim Station Alpha', 'Orbit-Geo', 4);

-- Insert Governing Offices (Linking to Stations)
INSERT INTO GOVERNINGOFFICE (OfficeName, JurisdictionLevel, StationID) VALUES
('Earth Customs Authority', 'Planetary', 1),
('Martian Security Force', 'Regional', 2),
('Proxima Trade Commission', 'Interstellar', 3);

-- Insert Laws (Linking to Offices)
INSERT INTO LAW (Title, IssuingOfficeID) VALUES
('Galactic Trade Regulation 101', 3),
('Restricted Airspace Act', 2),
('Contraband Control 44B', 1),
('Visa Overstay Penalty', 1),
('Unlicensed Mining Prohibition', 2);

-- Insert Law Applicability (Linking Law, Ethnicity, Planet)
-- Example: "Restricted Airspace Act" applies to Humans on Mars
INSERT INTO LAW_APPLICABILITY (LawID, EthnicityID, PlanetID) VALUES
(2, 1, 2),
(1, 3, 3),
(3, 2, 1);

-- ==========================================
-- LEVEL 3: People and Roles
-- ==========================================

-- Insert Citizens (Linking to Ethnicity, Station)
INSERT INTO CITIZEN (FirstName, LastName, DateOfBirth, BiometricHash, EthnicityID, HomeStationID) VALUES
('John', 'Shepard', '2980-11-07', 'HASH1111', 1, 1), -- Citizen 1
('Liara', 'Tsoni', '2890-03-22', 'HASH2222', 4, 3),    -- Citizen 2
('Garrus', 'Vakarian', '2975-05-15', 'HASH3333', 2, 2), -- Citizen 3
('Tali', 'Zorah', '2992-08-10', 'HASH4444', 3, 4),      -- Citizen 4
('Urdnot', 'Wrex', '2750-01-01', 'HASH5555', 2, 2),     -- Citizen 5
('Sarah', 'Connor', '2965-05-12', 'HASH6666', 1, 1),    -- Citizen 6 (Will be Official)
('James', 'Holden', '2985-09-14', 'HASH7777', 1, 3),    -- Citizen 7 (Will be Official)
('Boba', 'Fett', '2960-12-25', 'HASH8888', 1, 4);       -- Citizen 8 (Criminal)

-- Insert Officials (Subclass of Citizens)
-- Sarah Connor (ID 6) is an officer at Earth Customs
-- James Holden (ID 7) is an officer at Proxima Trade
INSERT INTO OFFICIAL (CitizenID, RankTitle, SecurityClearance, OfficeID) VALUES
(6, 'Senior Inspector', 8, 1),
(7, 'Trade Negotiator', 6, 3);

-- Insert Dependents (Linking to Citizen)
INSERT INTO DEPENDENT (FirstName, LastName, DependeeID, RelationshipType) VALUES
('Grunt', 'Vakarian', 3, 'Child'),
('Mordin', 'Shepard', 1, 'Spouse');

-- ==========================================
-- LEVEL 4: Transactions, Logs, and Events
-- ==========================================

-- Insert Asset Transactions (Sales)
INSERT INTO ASSET_TRANSACTION (AssetID, Value, BuyerCitizenID, SellerCitizenID) VALUES
(1, 500000.00, 1, 2), -- Shepard bought Starship from Liara
(4, 1500.00, 3, 5),   -- Garrus bought Transport Pod from Wrex
(6, 25000.00, 5, 4);  -- Wrex bought Mining Droid from Tali

-- Insert Visas (Travel Documents)
INSERT INTO VISA (CitizenID, DestID, Status, IssueDate, ExpiryDate, AuthorizingOfficialID) VALUES
(2, 1, 'Approved', '3025-01-01', '3025-06-01', 6),  -- Liara visiting Earth (Approved by Sarah)
(4, 2, 'Pending', '3025-02-15', '3025-08-15', NULL),-- Tali visiting Mars (Pending)
(5, 1, 'Rejected', '3024-12-01', '3024-12-01', 6);  -- Wrex rejected from Earth

-- Insert Travel Logs (Movement History)
INSERT INTO TRAVEL_LOG (CitizenID, DepartureStationID, DepartureTimestamp, ArrivalStationID, ArrivalTimestamp) VALUES
(1, 1, '3025-03-10 08:00:00', 2, '3025-03-10 14:00:00'),
(2, 3, '3025-03-11 09:00:00', 1, '3025-03-12 12:00:00'),
(8, 4, '3025-03-15 01:00:00', 2, '3025-03-15 06:30:00');

-- Insert Criminal Sentencing
INSERT INTO CRIMINAL_SENTENCING (CitizenID, LawID, AuthorizingOfficialID, ConvictionDate, CrimeDescription) VALUES
(8, 3, 6, '3024-05-20', 'Caught smuggling unauthorized Dilithium crystals.'),
(5, 5, 7, '3023-11-11', 'Illegal mining operation in Proxima sector.');

-- Insert Asset Seizure
-- Boba Fett (ID 8) had a Cargo Container (Asset 3) seized
INSERT INTO ASSET_SEIZURE (AssetID, CitizenID, LawID, AuthorizingOfficialID, SeizureTimestamp) VALUES
(3, 8, 3, 6, '3024-05-20 10:30:00');