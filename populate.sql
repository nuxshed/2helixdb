-- 2. Data Population Script (High Density Edition)
USE mini_world_db;

SET FOREIGN_KEY_CHECKS = 0;

-- ==========================================
-- LEVEL 1: The Stage (Sectors & Ethnicities)
-- ==========================================

INSERT INTO SECTOR (SectorName, StellarCentralCoordinates) VALUES
('Sol System', '000-00-01'),
('Outer Rim', '999-XX-00'),
('Andromeda Zone', 'AND-001-Z'),
('Proxima Region', 'CEN-004-B');

INSERT INTO ETHNICITY (Name, Tier) VALUES
('Terran (Human)', 'Tier 1'),
('Martian (Human)', 'Tier 2'),
('Belter (Human)', 'Tier 3'),
('Asari', 'Tier 1'),
('Mandalorian', 'Restricted');

-- ==========================================
-- LEVEL 2: Geography & Law
-- ==========================================

-- Planets
INSERT INTO PLANET (PlanetName, StellarCoordinates, SectorID) VALUES
('Earth', 'SOL-003', 1),
('Mars', 'SOL-004', 1),
('Tatooine', 'RIM-999', 2),
('Thessia', 'AND-050', 3),
('Ceres', 'AST-BELT', 1);

-- Stations
INSERT INTO STATION (StationName, GeographicCoordinates, PlanetID) VALUES
('Starfleet HQ', 'San Francisco', 1),             -- 1: Earth
('Olympus Mons Dock', 'North-Quadrant', 2),       -- 2: Mars
('Mos Eisley Port', 'Dune-Sea', 3),               -- 3: Tatooine
('Citadel Station', 'Nebula-Orbit', 4),           -- 4: Thessia
('Tycho Station', 'Lagrange-Point-5', 5);         -- 5: Ceres

-- Governing Offices
INSERT INTO GOVERNINGOFFICE (OfficeName, JurisdictionLevel, StationID) VALUES
('United Earth Customs', 'Planetary', 1),         -- 1
('Martian Congressional Republic', 'System', 2),  -- 2
('Hutt Cartel Admin', 'Regional', 3),             -- 3
('Outer Planets Alliance (OPA)', 'Station', 5);   -- 4

-- Laws
INSERT INTO LAW (Title, IssuingOfficeID) VALUES
('Terran Trade Agreement 404', 1),                -- 1
('Red Dust Taxation Act', 2),                     -- 2
('Restricted Cargo: Spice', 3),                   -- 3
('Salvage & Reclamation Rights', 4),              -- 4
('Diplomatic Immunity Clause', 1);                -- 5

-- Law Applicability
INSERT INTO LAW_APPLICABILITY (LawID, EthnicityID, PlanetID) VALUES
(3, 1, 3), -- Humans on Tatooine cannot hold Spice
(2, 2, 2), -- Martians on Mars pay tax
(4, 3, 5), -- Belters on Ceres have salvage rights
(1, 4, 1); -- Asari on Earth subject to trade agreement

-- ==========================================
-- LEVEL 3: The Cast (8 Citizens)
-- ==========================================

-- 1. James Holden (Terran, Captain, Good Guy)
-- 2. Boba Fett (Mandalorian, Bounty Hunter, Neutral)
-- 3. Liara Tsoni (Asari, Info Broker/Official, Powerful)
-- 4. Ellen Ripley (Terran, Hauler, Working Class)
-- 5. Camina Drummer (Belter, Official, Strict)
-- 6. Han Solo (Terran, Smuggler, Criminal)
-- 7. Jean-Luc Picard (Terran, Official, Diplomat)
-- 8. Lando Calrissian (Terran, Entrepreneur, Charismatic)

INSERT INTO CITIZEN (FirstName, LastName, DateOfBirth, BiometricHash, EthnicityID, HomeStationID) VALUES
('James', 'Holden', '2350-05-04', 'a1b2c3d4e5f678901234567890abcdef1234567890abcdef1234567890abcde0', 1, 1),
('Boba', 'Fett', '2340-11-15', 'f0e1d2c3b4a596871234567890abcdef1234567890abcdef1234567890abcde1', 5, 3),
('Liara', 'Tsoni', '2280-03-22', '9876543210fedcba1234567890abcdef1234567890abcdef1234567890abcde2', 4, 4),
('Ellen', 'Ripley', '2092-01-07', '11223344556677881234567890abcdef1234567890abcdef1234567890abcde3', 1, 5),
('Camina', 'Drummer', '2355-08-12', 'aabbccddeeff00111234567890abcdef1234567890abcdef1234567890abcde4', 3, 5),
('Han', 'Solo', '2335-09-10', '554433221100aa991234567890abcdef1234567890abcdef1234567890abcde5', 1, 3),
('Jean-Luc', 'Picard', '2305-07-13', '12312312312312341234567890abcdef1234567890abcdef1234567890abcde6', 1, 1),
('Lando', 'Calrissian', '2336-04-06', '99887766554433221234567890abcdef1234567890abcdef1234567890abcde7', 1, 3);

-- Officials (Linked to Citizens)
-- Picard (Earth), Drummer (OPA/Belt), Liara (Citadel)
INSERT INTO OFFICIAL (CitizenID, RankTitle, SecurityClearance, OfficeID) VALUES
(7, 'Admiral', 10, 1),
(5, 'Station Commander', 8, 4),
(3, 'Information Broker', 9, 2); -- Liara has influence in Mars politics too

-- Dependents
INSERT INTO DEPENDENT (FirstName, LastName, DependeeID, RelationshipType) VALUES
('Newt', 'Jorden', 4, 'Adoptee'), -- Ripley's kid
('Ben', 'Solo', 6, 'Son'),         -- Han's kid
('Naomi', 'Nagata', 1, 'Partner'); -- Holden's partner

-- ==========================================
-- LEVEL 4: The Economy (Assets & Transactions)
-- ==========================================

-- 20 Assets
INSERT INTO ASSET (AssetType) VALUES
('Rocinante (Corvette Class)'),         -- 1
('Slave I (Patrol Craft)'),             -- 2
('Millennium Falcon (Freighter)'),      -- 3
('Nostromo (Towing Vehicle)'),          -- 4
('Luxury Yacht "Lady Luck"'),           -- 5
('T-16 Skyhopper'),                     -- 6
('Phase Plasma Rifle'),                 -- 7
('Beskar Armor Plating'),               -- 8
('Ancient Prothean Artifact'),          -- 9
('Cargo: Refined Dilithium (10T)'),     -- 10
('Cargo: Raw Spice (500kg)'),           -- 11
('Mining Permit: Sector 7'),            -- 12
('Cloud City Deed'),                    -- 13
('Earl Grey Tea (Vintage Crate)'),      -- 14
('Hydroponic Farm Unit'),               -- 15
('Navigational Computer Core'),         -- 16
('Smugglers Compartment Mod'),          -- 17
('Diplomatic Shuttle'),                 -- 18
('Exoskeleton Loader'),                 -- 19
('Alien Egg (Stasis Pod)');             -- 20 (DANGER)

-- 25 Transactions (Complex Web)
INSERT INTO ASSET_TRANSACTION (AssetID, Value, BuyerCitizenID, SellerCitizenID) VALUES
-- Big Ships
(1, 5000000.00, 1, 2),      -- Holden buys Rocinante (Repo) from Fett
(3, 25000.00, 6, 8),        -- Solo wins Falcon from Lando (Low price implies a bet)
(13, 10000000.00, 8, 5),    -- Lando buys City Deed from Drummer (OPA Land)
-- Contraband & Weapons
(11, 45000.00, 8, 6),       -- Lando buys Spice from Solo
(8, 12000.00, 2, 5),        -- Fett buys Beskar from Drummer (Mining salvage)
(7, 2500.00, 4, 2),         -- Ripley buys Rifle from Fett (Protection)
-- Luxury & Tech
(14, 500.00, 7, 8),         -- Picard buys Tea from Lando
(9, 85000.00, 3, 6),        -- Liara buys Artifact from Solo (He didn't know its worth)
(16, 3000.00, 1, 4),        -- Holden buys Nav Computer from Ripley
-- Industrial
(10, 15000.00, 5, 1),       -- Drummer buys Dilithium from Holden
(19, 5500.00, 4, 5),        -- Ripley buys Exoskeleton from Drummer
(12, 5000.00, 8, 5),        -- Lando buys Mining Permit from Drummer
-- The "Incident" Chain
(20, 900.00, 6, 4),         -- Solo sells "Weird Egg" to Ripley (Mistake)
(20, 0.00, 7, 4),           -- Ripley surrenders Egg to Picard (Seizure/Handover)
(5, 2000000.00, 3, 8),      -- Liara buys Yacht from Lando
(6, 4000.00, 1, 2),         -- Holden buys Skyhopper from Fett
(15, 1200.00, 5, 7),        -- Drummer buys Farm Unit from Picard (Aid)
(17, 2500.00, 6, 5),        -- Solo buys Smuggler Mod from Drummer (She looked away)
(2, 0.00, 2, 2),            -- Fett repairs Slave I (Self-transaction log)
(18, 0.00, 7, 1),           -- Picard assigns Shuttle to Holden (Loan)
(11, 50000.00, 2, 8),       -- Fett buys Spice from Lando (Bounty bait)
(4, 150000.00, 4, 1),       -- Ripley buys Nostromo back from Holden
(1, 100.00, 1, 7),          -- Holden pays nominal fee to Picard
(9, 90000.00, 7, 3),        -- Picard buys Artifact from Liara for Museum
(8, 15000.00, 2, 6);        -- Fett buys more armor from Solo

-- ==========================================
-- LEVEL 5: Movement & Legality
-- ==========================================

-- 20 Visas (Mix of Approved, Rejected, Expired)
INSERT INTO VISA (CitizenID, DestID, Status, IssueDate, ExpiryDate, AuthorizingOfficialID) VALUES
-- Picard (Diplomatic Status - Everywhere)
(7, 2, 'Approved', '3020-01-01', '3030-01-01', 7),
(7, 5, 'Approved', '3020-01-01', '3030-01-01', 5),
-- Han Solo (Struggling with paperwork)
(6, 1, 'Rejected', '3025-01-10', '3025-01-10', 7), -- Picard rejected Solo from Earth
(6, 5, 'Pending', '3025-02-01', '3025-03-01', 5),  -- Drummer considering Solo
(6, 3, 'Approved', '3025-01-01', '3026-01-01', NULL), -- Hutt space is easy
-- Ripley (Working Visas)
(4, 5, 'Approved', '3024-06-01', '3025-06-01', 5),
(4, 1, 'Expired', '3023-01-01', '3024-01-01', 7),
-- Fett (Bounty Hunting)
(2, 1, 'Rejected', '3025-03-15', '3025-03-15', 7), -- No weapons on Earth
(2, 5, 'Approved', '3025-01-01', '3025-12-31', 5), -- OPA needs muscle
-- Holden (Diplomatic Missions)
(1, 2, 'Approved', '3025-02-01', '3025-08-01', 3), -- Liara approved Mars visit
(1, 4, 'Approved', '3025-02-01', '3025-08-01', 3),
-- Lando (Business)
(8, 5, 'Approved', '3025-01-01', '3030-01-01', 5), -- Drummer likes Lando's money
(8, 1, 'Pending', '3025-04-01', '3025-05-01', 7),
-- Liara (Official)
(3, 1, 'Approved', '3020-01-01', '3040-01-01', 7),
-- Randoms
(5, 1, 'Approved', '3025-05-01', '3025-06-01', 7), -- Drummer visiting Earth
(4, 2, 'Rejected', '3024-12-01', '3024-12-01', 3),
(1, 3, 'Expired', '3022-01-01', '3022-06-01', NULL),
(2, 2, 'Pending', '3025-04-01', '3025-05-01', 3),
(8, 4, 'Approved', '3025-03-01', '3025-09-01', 3),
(6, 4, 'Rejected', '3025-03-01', '3025-03-01', 3); -- Liara rejected Solo

-- 20 Travel Logs (Matching Visas mostly)
INSERT INTO TRAVEL_LOG (CitizenID, DepartureStationID, DepartureTimestamp, ArrivalStationID, ArrivalTimestamp) VALUES
(1, 1, '3025-01-01 08:00', 5, '3025-01-04 12:00'), -- Holden Earth -> Ceres
(1, 5, '3025-01-10 09:00', 2, '3025-01-12 14:00'), -- Holden Ceres -> Mars
(6, 3, '3025-02-01 02:00', 5, '3025-02-03 06:00'), -- Solo Tatooine -> Ceres (Smuggling)
(6, 5, '3025-02-04 23:00', 3, '3025-02-06 04:00'), -- Solo Ceres -> Tatooine (Running away)
(2, 3, '3025-03-01 10:00', 5, '3025-03-03 15:00'), -- Fett hunting Solo
(4, 5, '3024-11-01 06:00', 1, '3024-11-10 12:00'), -- Ripley long haul
(7, 1, '3025-04-01 08:00', 4, '3025-04-02 08:00'), -- Picard Earth -> Citadel (Fast)
(8, 3, '3025-01-15 12:00', 5, '3025-01-17 18:00'), -- Lando business trip
(3, 4, '3025-02-20 09:00', 1, '3025-02-22 11:00'), -- Liara Citadel -> Earth
(5, 5, '3025-05-01 08:00', 1, '3025-05-05 12:00'), -- Drummer Diplomatic mission
(2, 5, '3025-03-05 01:00', 2, '3025-03-06 05:00'), -- Fett chasing bounty
(1, 2, '3025-02-01 08:00', 1, '3025-02-02 12:00'),
(8, 5, '3025-01-20 10:00', 3, '3025-01-22 14:00'),
(4, 1, '3025-01-01 06:00', 5, '3025-01-10 18:00'),
(7, 4, '3025-04-05 09:00', 1, '3025-04-06 09:00'),
(6, 3, '3025-02-15 03:00', 4, '3025-02-18 08:00'), -- Solo tried Citadel
(6, 4, '3025-02-19 01:00', 3, '3025-02-22 05:00'), -- Solo kicked out of Citadel
(3, 1, '3025-03-01 10:00', 4, '3025-03-03 12:00'),
(1, 1, '3025-03-10 08:00', 3, '3025-03-14 16:00'),
(2, 2, '3025-03-10 02:00', 3, '3025-03-12 06:00');

-- ==========================================
-- LEVEL 6: Crime & Punishment
-- ==========================================

-- Sentencing
INSERT INTO CRIMINAL_SENTENCING (CitizenID, LawID, AuthorizingOfficialID, ConvictionDate, CrimeDescription) VALUES
(6, 3, 7, '3024-05-20', 'Transporting 500kg of Spice in Earth orbit.'),
(6, 1, 5, '3023-11-11', 'Docking violation at Tycho Station.'),
(8, 4, 5, '3022-06-15', 'Illegal salvage of Federation drone.'),
(2, 5, 3, '3021-09-01', 'Discharging weapon in Citadel Embassy.'),
(4, 4, 5, '3025-01-20', 'Failure to declare biological cargo (Xenomorph).');

-- Seizures
INSERT INTO ASSET_SEIZURE (AssetID, CitizenID, LawID, AuthorizingOfficialID, SeizureTimestamp) VALUES
(11, 6, 3, 7, '3024-05-20 10:30:00'), -- Solo lost his spice to Picard
(20, 4, 4, 7, '3025-01-20 14:00:00'), -- Ripley lost the Egg to Picard
(7, 2, 5, 3, '3021-09-01 09:00:00'); -- Fett lost his rifle on Citadel

SET FOREIGN_KEY_CHECKS = 1;
