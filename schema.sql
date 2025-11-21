-- 1. Database Creation and Selection [cite: 24, 25]
DROP DATABASE IF EXISTS mini_world_db;
CREATE DATABASE mini_world_db;
USE mini_world_db;

-- ==========================================
-- LEVEL 1: Independent Tables (No Foreign Keys)
-- ==========================================

-- Table: SECTOR
CREATE TABLE SECTOR (
    SectorID INT AUTO_INCREMENT PRIMARY KEY,
    SectorName VARCHAR(100) NOT NULL UNIQUE,
    StellarCentralCoordinates VARCHAR(100)
);

-- Table: ETHNICITY
CREATE TABLE ETHNICITY (
    EthnicityID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Tier VARCHAR(50)
);

-- Table: ASSET
CREATE TABLE ASSET (
    AssetID INT AUTO_INCREMENT PRIMARY KEY,
    AssetType VARCHAR(100) NOT NULL
);

-- ==========================================
-- LEVEL 2: Geographic Hierarchy
-- ==========================================

-- Table: PLANET (Depends on SECTOR)
CREATE TABLE PLANET (
    PlanetID INT AUTO_INCREMENT PRIMARY KEY,
    PlanetName VARCHAR(100) NOT NULL,
    StellarCoordinates VARCHAR(100),
    SectorID INT,
    FOREIGN KEY (SectorID) REFERENCES SECTOR(SectorID) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table: STATION (Depends on PLANET)
CREATE TABLE STATION (
    StationID INT AUTO_INCREMENT PRIMARY KEY,
    StationName VARCHAR(100) NOT NULL,
    GeographicCoordinates VARCHAR(100),
    PlanetID INT,
    FOREIGN KEY (PlanetID) REFERENCES PLANET(PlanetID) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table: GOVERNINGOFFICE (Depends on STATION)
CREATE TABLE GOVERNINGOFFICE (
    OfficeID INT AUTO_INCREMENT PRIMARY KEY,
    OfficeName VARCHAR(100) NOT NULL,
    JurisdictionLevel VARCHAR(50),
    StationID INT NOT NULL,
    FOREIGN KEY (StationID) REFERENCES STATION(StationID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table: LAW (Depends on GOVERNINGOFFICE)
CREATE TABLE LAW (
    LawID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    IssuingOfficeID INT,
    FOREIGN KEY (IssuingOfficeID) REFERENCES GOVERNINGOFFICE(OfficeID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- Table: LAW_APPLICABILITY (Associative entity: LAW, ETHNICITY, PLANET)
CREATE TABLE LAW_APPLICABILITY (
    ApplicabilityID INT AUTO_INCREMENT PRIMARY KEY,
    LawID INT NOT NULL,
    EthnicityID INT,
    PlanetID INT,
    FOREIGN KEY (LawID) REFERENCES LAW(LawID) ON DELETE CASCADE,
    FOREIGN KEY (EthnicityID) REFERENCES ETHNICITY(EthnicityID) ON DELETE CASCADE,
    FOREIGN KEY (PlanetID) REFERENCES PLANET(PlanetID) ON DELETE CASCADE
);

-- ==========================================
-- LEVEL 3: People and Roles
-- ==========================================

-- Table: CITIZEN (Depends on ETHNICITY, STATION)
CREATE TABLE CITIZEN (
    CitizenID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    DateOfBirth DATE NOT NULL,
    BiometricHash VARCHAR(255) NOT NULL UNIQUE, -- Enforcing uniqueness for biometrics
    EthnicityID INT,
    HomeStationID INT,
    FOREIGN KEY (EthnicityID) REFERENCES ETHNICITY(EthnicityID) 
        ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (HomeStationID) REFERENCES STATION(StationID) 
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Table: OFFICIAL (Subclass of CITIZEN - Depends on CITIZEN, GOVERNINGOFFICE)
-- Note: CitizenID is both PK and FK here to enforce 1:1 relationship
CREATE TABLE OFFICIAL (
    CitizenID INT PRIMARY KEY,
    RankTitle VARCHAR(100),
    SecurityClearance INT CHECK (SecurityClearance BETWEEN 1 AND 10),
    OfficeID INT,
    FOREIGN KEY (CitizenID) REFERENCES CITIZEN(CitizenID) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (OfficeID) REFERENCES GOVERNINGOFFICE(OfficeID) 
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- Table: DEPENDENT (Depends on CITIZEN)
CREATE TABLE DEPENDENT (
    DependentID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    DependeeID INT NOT NULL,
    RelationshipType VARCHAR(50),
    FOREIGN KEY (DependeeID) REFERENCES CITIZEN(CitizenID) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ==========================================
-- LEVEL 4: Transactions, Logs, and Events
-- ==========================================

-- Table: ASSET_TRANSACTION (Depends on ASSET, CITIZEN)
CREATE TABLE ASSET_TRANSACTION (
    TransactionID INT AUTO_INCREMENT PRIMARY KEY,
    AssetID INT NOT NULL,
    Value DECIMAL(15, 2) NOT NULL,
    BuyerCitizenID INT,
    SellerCitizenID INT,
    FOREIGN KEY (AssetID) REFERENCES ASSET(AssetID) ON DELETE CASCADE,
    FOREIGN KEY (BuyerCitizenID) REFERENCES CITIZEN(CitizenID) ON DELETE SET NULL,
    FOREIGN KEY (SellerCitizenID) REFERENCES CITIZEN(CitizenID) ON DELETE SET NULL
);

-- Table: VISA (Depends on CITIZEN, STATION, OFFICIAL)
CREATE TABLE VISA (
    VisaID INT AUTO_INCREMENT PRIMARY KEY,
    CitizenID INT NOT NULL,
    DestID INT NOT NULL, -- Destination Station
    Status ENUM('Pending', 'Approved', 'Rejected', 'Expired') DEFAULT 'Pending',
    IssueDate DATE,
    ExpiryDate DATE,
    AuthorizingOfficialID INT,
    FOREIGN KEY (CitizenID) REFERENCES CITIZEN(CitizenID) ON DELETE CASCADE,
    FOREIGN KEY (DestID) REFERENCES STATION(StationID) ON DELETE CASCADE,
    FOREIGN KEY (AuthorizingOfficialID) REFERENCES OFFICIAL(CitizenID) ON DELETE SET NULL
);

-- Table: TRAVEL_LOG (Depends on CITIZEN, STATION)
CREATE TABLE TRAVEL_LOG (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    CitizenID INT NOT NULL,
    DepartureStationID INT,
    DepartureTimestamp DATETIME,
    ArrivalStationID INT,
    ArrivalTimestamp DATETIME,
    FOREIGN KEY (CitizenID) REFERENCES CITIZEN(CitizenID) ON DELETE CASCADE,
    FOREIGN KEY (DepartureStationID) REFERENCES STATION(StationID) ON DELETE SET NULL,
    FOREIGN KEY (ArrivalStationID) REFERENCES STATION(StationID) ON DELETE SET NULL
);

-- Table: CRIMINAL_SENTENCING (Depends on CITIZEN, LAW, OFFICIAL)
CREATE TABLE CRIMINAL_SENTENCING (
    ConvictionID INT AUTO_INCREMENT PRIMARY KEY,
    CitizenID INT NOT NULL,
    LawID INT NOT NULL,
    AuthorizingOfficialID INT,
    ConvictionDate DATE NOT NULL,
    CrimeDescription TEXT,
    FOREIGN KEY (CitizenID) REFERENCES CITIZEN(CitizenID) ON DELETE CASCADE,
    FOREIGN KEY (LawID) REFERENCES LAW(LawID) ON DELETE CASCADE,
    FOREIGN KEY (AuthorizingOfficialID) REFERENCES OFFICIAL(CitizenID) ON DELETE SET NULL
);

-- Table: ASSET_SEIZURE (Depends on ASSET, CITIZEN, LAW, OFFICIAL)
CREATE TABLE ASSET_SEIZURE (
    SeizureID INT AUTO_INCREMENT PRIMARY KEY,
    AssetID INT NOT NULL,
    CitizenID INT NOT NULL, -- The citizen the asset was seized from
    LawID INT,
    AuthorizingOfficialID INT,
    SeizureTimestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (AssetID) REFERENCES ASSET(AssetID) ON DELETE CASCADE,
    FOREIGN KEY (CitizenID) REFERENCES CITIZEN(CitizenID) ON DELETE CASCADE,
    FOREIGN KEY (LawID) REFERENCES LAW(LawID) ON DELETE SET NULL,
    FOREIGN KEY (AuthorizingOfficialID) REFERENCES OFFICIAL(CitizenID) ON DELETE SET NULL
);