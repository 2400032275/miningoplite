-- ===================================================================
-- MineOps Lite - Database Schema
-- No Associations: All IDs stored as numeric columns
-- ===================================================================

-- Drop existing tables (if any)
DROP TABLE IF EXISTS SafetyIncident;
DROP TABLE IF EXISTS EquipmentUsage;
DROP TABLE IF EXISTS ProductionLog;
DROP TABLE IF EXISTS ShiftLog;
DROP TABLE IF EXISTS Equipment;
DROP TABLE IF EXISTS Worker;
DROP TABLE IF EXISTS MineSite;

-- ===================================================================
-- 1. MineSite - Core mine location
-- ===================================================================
CREATE TABLE MineSite (
    mineId INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(150) NOT NULL,
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE',
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ===================================================================
-- 2. Equipment - Mining equipment/vehicles
-- ===================================================================
CREATE TABLE Equipment (
    equipmentId INT PRIMARY KEY AUTO_INCREMENT,
    mineId INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50),
    status ENUM('WORKING', 'MAINTENANCE', 'BROKEN') DEFAULT 'WORKING',
    purchaseDate DATE,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_equipment_mine FOREIGN KEY (mineId) REFERENCES MineSite(mineId) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ===================================================================
-- 3. Worker - Mine employees
-- ===================================================================
CREATE TABLE Worker (
    workerId INT PRIMARY KEY AUTO_INCREMENT,
    mineId INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    role VARCHAR(50),
    phone VARCHAR(20),
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_worker_mine FOREIGN KEY (mineId) REFERENCES MineSite(mineId) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ===================================================================
-- 4. ShiftLog - Daily shift records
-- ===================================================================
CREATE TABLE ShiftLog (
    shiftId INT PRIMARY KEY AUTO_INCREMENT,
    mineId INT NOT NULL,
    shiftDate DATE NOT NULL,
    shiftType ENUM('DAY', 'NIGHT') DEFAULT 'DAY',
    supervisorId INT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_shift_mine FOREIGN KEY (mineId) REFERENCES MineSite(mineId) ON DELETE CASCADE,
    CONSTRAINT fk_shift_supervisor FOREIGN KEY (supervisorId) REFERENCES Worker(workerId) ON DELETE SET NULL,
    UNIQUE KEY unique_shift (mineId, shiftDate, shiftType)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ===================================================================
-- 5. ProductionLog - Daily production output
-- ===================================================================
CREATE TABLE ProductionLog (
    prodId INT PRIMARY KEY AUTO_INCREMENT,
    mineId INT NOT NULL,
    shiftId INT,
    logDate DATE NOT NULL,
    tonnes DECIMAL(10, 2) NOT NULL,
    grade DECIMAL(5, 2),
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_prod_mine FOREIGN KEY (mineId) REFERENCES MineSite(mineId) ON DELETE CASCADE,
    CONSTRAINT fk_prod_shift FOREIGN KEY (shiftId) REFERENCES ShiftLog(shiftId) ON DELETE SET NULL,
    CHECK (tonnes >= 0),
    CHECK (grade >= 0 AND grade <= 100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ===================================================================
-- 6. EquipmentUsage - Equipment usage and breakdown tracking
-- ===================================================================
CREATE TABLE EquipmentUsage (
    usageId INT PRIMARY KEY AUTO_INCREMENT,
    mineId INT NOT NULL,
    equipmentId INT NOT NULL,
    usageDate DATE NOT NULL,
    runningHours DECIMAL(8, 2),
    breakdown CHAR(1) DEFAULT 'N',
    downtimeHours DECIMAL(8, 2) DEFAULT 0,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_usage_mine FOREIGN KEY (mineId) REFERENCES MineSite(mineId) ON DELETE CASCADE,
    CONSTRAINT fk_usage_equipment FOREIGN KEY (equipmentId) REFERENCES Equipment(equipmentId) ON DELETE CASCADE,
    CHECK (breakdown IN ('Y', 'N')),
    CHECK (runningHours >= 0),
    CHECK (downtimeHours >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ===================================================================
-- 7. SafetyIncident - Safety incidents and accidents
-- ===================================================================
CREATE TABLE SafetyIncident (
    incidentId INT PRIMARY KEY AUTO_INCREMENT,
    mineId INT NOT NULL,
    equipmentId INT,
    workerId INT,
    incidentDate DATE NOT NULL,
    type VARCHAR(100),
    severity INT,
    cost DECIMAL(12, 2),
    status ENUM('OPEN', 'CLOSED') DEFAULT 'OPEN',
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_incident_mine FOREIGN KEY (mineId) REFERENCES MineSite(mineId) ON DELETE CASCADE,
    CONSTRAINT fk_incident_equipment FOREIGN KEY (equipmentId) REFERENCES Equipment(equipmentId) ON DELETE SET NULL,
    CONSTRAINT fk_incident_worker FOREIGN KEY (workerId) REFERENCES Worker(workerId) ON DELETE SET NULL,
    CHECK (severity >= 1 AND severity <= 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ===================================================================
-- SAMPLE DATA
-- ===================================================================

INSERT INTO MineSite (name, location, status) VALUES
('Coal Mine Alpha', 'Odisha', 'ACTIVE'),
('Iron Ore Beta', 'Karnataka', 'ACTIVE'),
('Copper Gamma', 'Jharkhand', 'INACTIVE');

INSERT INTO Equipment (mineId, name, type, status, purchaseDate) VALUES
(1, 'Excavator E1', 'Excavator', 'WORKING', '2023-01-15'),
(1, 'Truck T1', 'Transport', 'WORKING', '2022-06-10'),
(1, 'Drill D1', 'Drilling', 'BROKEN', '2021-03-20'),
(2, 'Excavator E2', 'Excavator', 'MAINTENANCE', '2023-05-12'),
(2, 'Truck T2', 'Transport', 'WORKING', '2023-02-28');

INSERT INTO Worker (mineId, name, role, phone) VALUES
(1, 'Raj Kumar', 'Supervisor', '9000000001'),
(1, 'Arjun Singh', 'Operator', '9000000002'),
(1, 'Priya Devi', 'Safety Officer', '9000000003'),
(2, 'Amit Patel', 'Supervisor', '9000000004'),
(2, 'Ravi Gupta', 'Operator', '9000000005');

INSERT INTO ShiftLog (mineId, shiftDate, shiftType, supervisorId) VALUES
(1, '2026-01-01', 'DAY', 1),
(1, '2026-01-01', 'NIGHT', 1),
(1, '2026-01-02', 'DAY', 1),
(2, '2026-01-01', 'DAY', 4),
(2, '2026-01-02', 'DAY', 4);

INSERT INTO ProductionLog (mineId, shiftId, logDate, tonnes, grade) VALUES
(1, 1, '2026-01-01', 250.50, 85.50),
(1, 2, '2026-01-01', 220.75, 83.25),
(1, 3, '2026-01-02', 265.25, 87.00),
(2, 4, '2026-01-01', 180.00, 72.50),
(2, 5, '2026-01-02', 195.50, 75.00);

INSERT INTO EquipmentUsage (mineId, equipmentId, usageDate, runningHours, breakdown, downtimeHours) VALUES
(1, 1, '2026-01-01', 16.5, 'N', 0),
(1, 2, '2026-01-01', 14.75, 'N', 0),
(1, 3, '2026-01-01', 0, 'Y', 8),
(2, 4, '2026-01-01', 12.5, 'N', 0),
(2, 5, '2026-01-01', 15.25, 'Y', 2.5);

INSERT INTO SafetyIncident (mineId, equipmentId, workerId, incidentDate, type, severity, cost, status) VALUES
(1, 1, 2, '2026-01-01', 'Minor Cut', 1, 500, 'CLOSED'),
(1, 3, NULL, '2025-12-28', 'Equipment Breakdown', 3, 15000, 'OPEN'),
(2, 4, 5, '2025-12-30', 'Near Miss', 2, 1000, 'OPEN'),
(1, NULL, 3, '2025-12-29', 'Safety Drill', 1, 0, 'CLOSED');

-- ===================================================================
-- INDEXES FOR PERFORMANCE
-- ===================================================================

CREATE INDEX idx_equipment_mine ON Equipment(mineId);
CREATE INDEX idx_worker_mine ON Worker(mineId);
CREATE INDEX idx_shiftlog_mine ON ShiftLog(mineId);
CREATE INDEX idx_shiftlog_date ON ShiftLog(shiftDate);
CREATE INDEX idx_prodlog_mine ON ProductionLog(mineId);
CREATE INDEX idx_prodlog_date ON ProductionLog(logDate);
CREATE INDEX idx_equipusage_mine ON EquipmentUsage(mineId);
CREATE INDEX idx_equipusage_date ON EquipmentUsage(usageDate);
CREATE INDEX idx_incident_mine ON SafetyIncident(mineId);
CREATE INDEX idx_incident_date ON SafetyIncident(incidentDate);

COMMIT;
