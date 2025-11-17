/*
 * SCRIPT: Create tables for the 'Aethelgard Imperium' database
 * NOTE: Tables are created in dependency order.
 */

-- ==== BASE ENTITIES (No foreign keys) ====

CREATE TABLE SECTOR (
    SectorID INT PRIMARY KEY,
    SectorName VARCHAR(255) NOT NULL,
    StellarCentralCoordinates VARCHAR(100)
);

CREATE TABLE ETHNICITY (
    EthnicityID INT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Tier VARCHAR(50)
);

CREATE TABLE ASSET (
    AssetID INT PRIMARY KEY,
    AssetType VARCHAR(100) NOT NULL
);

-- ==== LEVEL 1 DEPENDENCIES ====

CREATE TABLE PLANET (
    PlanetID INT PRIMARY KEY,
    PlanetName VARCHAR(255) NOT NULL,
    StellarCoordinates VARCHAR(100),
    SectorID INT NOT NULL,
    FOREIGN KEY (SectorID) REFERENCES SECTOR(SectorID)
);

-- ==== LEVEL 2 DEPENDENCIES ====

CREATE TABLE STATION (
    StationID INT PRIMARY KEY,
    StationName VARCHAR(255) NOT NULL,
    GeographicCoordinates VARCHAR(100),
    PlanetID INT NOT NULL,
    FOREIGN KEY (PlanetID) REFERENCES PLANET(PlanetID)
);

-- ==== LEVEL 3 DEPENDENCIES ====

CREATE TABLE GOVERNINGOFFICE (
    OfficeID INT PRIMARY KEY,
    OfficeName VARCHAR(255) NOT NULL,
    JurisdictionLevel VARCHAR(100),
    StationID INT NOT NULL,
    FOREIGN KEY (StationID) REFERENCES STATION(StationID)
);

CREATE TABLE CITIZEN (
    CitizenID INT PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    DateOfBirth DATE,
    BiometricHash VARCHAR(128),
    EthnicityID INT NOT NULL,
    HomeStationID INT NOT NULL,
    FOREIGN KEY (EthnicityID) REFERENCES ETHNICITY(EthnicityID),
    FOREIGN KEY (HomeStationID) REFERENCES STATION(StationID)
);

-- ==== LEVEL 4 DEPENDENCIES (Depend on previous tables) ====

CREATE TABLE LAW (
    LawID INT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    IssuingOfficeID INT NOT NULL,
    FOREIGN KEY (IssuingOfficeID) REFERENCES GOVERNINGOFFICE(OfficeID)
);

CREATE TABLE OFFICIAL (
    CitizenID INT PRIMARY KEY, -- This is both PK and FK
    RankTitle VARCHAR(100) NOT NULL,
    SecurityClearance VARCHAR(50),
    OfficeID INT NOT NULL,
    FOREIGN KEY (CitizenID) REFERENCES CITIZEN(CitizenID),
    FOREIGN KEY (OfficeID) REFERENCES GOVERNINGOFFICE(OfficeID)
);

CREATE TABLE DEPENDENT (
    DependentID INT PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    DependeeID INT NOT NULL, -- The Citizen this person depends on
    RelationshipType VARCHAR(50),
    FOREIGN KEY (DependeeID) REFERENCES CITIZEN(CitizenID)
);

CREATE TABLE ASSET_TRANSACTION (
    TransactionID INT PRIMARY KEY,
    AssetID INT NOT NULL,
    Value DECIMAL(18, 2),
    BuyerCitizenID INT NOT NULL,
    SellerCitizenID INT NOT NULL,
    FOREIGN KEY (AssetID) REFERENCES ASSET(AssetID),
    FOREIGN KEY (BuyerCitizenID) REFERENCES CITIZEN(CitizenID),
    FOREIGN KEY (SellerCitizenID) REFERENCES CITIZEN(CitizenID)
);

CREATE TABLE TRAVEL_LOG (
    LogID INT PRIMARY KEY,
    CitizenID INT NOT NULL,
    DepartureStationID INT NOT NULL,
    DepartureTimestamp TIMESTAMP,
    ArrivalStationID INT NOT NULL,
    ArrivalTimestamp TIMESTAMP,
    FOREIGN KEY (CitizenID) REFERENCES CITIZEN(CitizenID),
    FOREIGN KEY (DepartureStationID) REFERENCES STATION(StationID),
    FOREIGN KEY (ArrivalStationID) REFERENCES STATION(StationID)
);

CREATE TABLE LAW_APPLICABILITY (
    ApplicabilityID INT PRIMARY KEY,
    LawID INT NOT NULL,
    EthnicityID INT NOT NULL,
    PlanetID INT NOT NULL,
    FOREIGN KEY (LawID) REFERENCES LAW(LawID),
    FOREIGN KEY (EthnicityID) REFERENCES ETHNICITY(EthnicityID),
    FOREIGN KEY (PlanetID) REFERENCES PLANET(PlanetID)
);


-- ==== LEVEL 5 DEPENDENCIES (Depend on OFFICIAL and other tables) ====

CREATE TABLE ASSET_SEIZURE (
    SeizureID INT PRIMARY KEY,
    AssetID INT NOT NULL,
    CitizenID INT NOT NULL, -- The citizen whose asset was seized
    LawID INT NOT NULL,
    AuthorizingOfficialID INT NOT NULL,
    SeizureTimestamp TIMESTAMP,
    FOREIGN KEY (AssetID) REFERENCES ASSET(AssetID),
    FOREIGN KEY (CitizenID) REFERENCES CITIZEN(CitizenID),
    FOREIGN KEY (LawID) REFERENCES LAW(LawID),
    FOREIGN KEY (AuthorizingOfficialID) REFERENCES OFFICIAL(CitizenID)
);

CREATE TABLE CRIMINAL_SENTENCING (
    ConvictionID INT PRIMARY KEY,
    CitizenID INT NOT NULL,
    LawID INT NOT NULL,
    AuthorizingOfficialID INT NOT NULL,
    ConvictionDate DATE,
    CrimeDescription TEXT,
    FOREIGN KEY (CitizenID) REFERENCES CITIZEN(CitizenID),
    FOREIGN KEY (LawID) REFERENCES LAW(LawID),
    FOREIGN KEY (AuthorizingOfficialID) REFERENCES OFFICIAL(CitizenID)
);

CREATE TABLE VISA (
    VisaID INT PRIMARY KEY,
    CitizenID INT NOT NULL,
    DestID INT NOT NULL, -- This is the destination StationID
    Status VARCHAR(50),
    IssueDate DATE,
    ExpiryDate DATE,
    AuthorizingOfficialID INT NOT NULL,
    FOREIGN KEY (CitizenID) REFERENCES CITIZEN(CitizenID),
    FOREIGN KEY (DestID) REFERENCES STATION(StationID),
    FOREIGN KEY (AuthorizingOfficialID) REFERENCES OFFICIAL(CitizenID)
);
