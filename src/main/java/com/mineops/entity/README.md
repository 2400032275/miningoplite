# MineOps Lite - Mining Operations Logbook

A Hibernate-based Java console application for managing mining operations with CRUD operations and advanced HQL reporting.

## Project Structure

```
miningoplite/
├── database/
│   └── schema.sql           # MySQL database schema with 7 tables
├── src/main/java/com/mineops/
│   ├── entity/              # Hibernate entity classes
│   │   ├── MineSite.java
│   │   ├── Equipment.java
│   │   ├── Worker.java
│   │   ├── ShiftLog.java
│   │   ├── ProductionLog.java
│   │   ├── EquipmentUsage.java
│   │   └── SafetyIncident.java
│   ├── dao/                 # Data Access Objects
│   │   ├── HibernateUtil.java
│   │   ├── MineSiteDAO.java
│   │   ├── EquipmentDAO.java
│   │   ├── WorkerDAO.java
│   │   ├── ShiftLogDAO.java
│   │   ├── ProductionLogDAO.java
│   │   ├── EquipmentUsageDAO.java
│   │   └── SafetyIncidentDAO.java
│   ├── service/             # Business Logic
│   │   ├── MineService.java
│   │   ├── EquipmentService.java
│   │   ├── ReportingService.java
│   │   └── ValidationService.java
│   ├── util/                # Utilities
│   │   ├── Constants.java
│   │   ├── DateUtils.java
│   │   └── InputValidator.java
│   └── main/
│       └── MineOpsApp.java  # Main console application
├── resources/
│   └── hibernate.cfg.xml    # Hibernate configuration
└── README.md
```

## Database Schema

### Tables
1. **MineSite** - Core mine locations (mineId, name, location, status)
2. **Equipment** - Mining equipment/vehicles (equipmentId, mineId, name, type, status)
3. **Worker** - Employees (workerId, mineId, name, role, phone)
4. **ShiftLog** - Daily shifts (shiftId, mineId, shiftDate, shiftType, supervisorId)
5. **ProductionLog** - Production output (prodId, mineId, shiftId, logDate, tonnes, grade)
6. **EquipmentUsage** - Equipment tracking (usageId, mineId, equipmentId, usageDate, runningHours, breakdown, downtimeHours)
7. **SafetyIncident** - Safety records (incidentId, mineId, equipmentId, workerId, incidentDate, type, severity, cost, status)

## Key Features

### CRUD Operations (UC-CRUD-01 to UC-CRUD-10)
- Register mine sites
- Update mine status
- Register and manage equipment
- Transfer equipment between mines
- Register workers
- Create shift logs
- Record daily production
- Track equipment usage
- Report safety incidents
- Close safety incidents

### HQL Reporting (RPT-01 to RPT-12)
- Monthly production ranking
- Production with mine names
- Grade quality leaderboard
- High-volume mines filter
- Safety severity heatmap
- Open incidents queue
- Top incident cost hotspots
- Equipment breakdown leaderboard
- Downtime hours leaderboard
- Equipment names with breakdown count
- Latest incidents with paging
- Bulk maintenance update

## Entity Class Structure (No Associations)

Each entity contains only primitive fields and IDs:

```java
@Entity
@Table(name = "MineSite")
public class MineSite {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer mineId;
    
    @Column(nullable = false, unique = true)
    private String name;
    
    @Column(nullable = false)
    private String location;
    
    @Column(columnDefinition = "ENUM('ACTIVE','INACTIVE')")
    private String status;
    
    // Timestamp fields
    @Temporal(TemporalType.TIMESTAMP)
    private Date createdAt;
    
    @Temporal(TemporalType.TIMESTAMP)
    private Date updatedAt;
}
```

All entities follow the same pattern with getter/setter methods.

## DAO Pattern

```java
public class MineSiteDAO {
    private SessionFactory sessionFactory;
    
    // CREATE
    public Integer saveSite(MineSite site) {
        Session session = sessionFactory.openSession();
        Transaction tx = session.beginTransaction();
        Integer id = (Integer) session.save(site);
        tx.commit();
        session.close();
        return id;
    }
    
    // READ
    public MineSite getSiteById(Integer id) {
        Session session = sessionFactory.openSession();
        MineSite site = session.get(MineSite.class, id);
        session.close();
        return site;
    }
    
    // UPDATE
    public void updateSite(MineSite site) {
        Session session = sessionFactory.openSession();
        Transaction tx = session.beginTransaction();
        session.merge(site);
        tx.commit();
        session.close();
    }
    
    // DELETE
    public void deleteSite(Integer id) {
        Session session = sessionFactory.openSession();
        Transaction tx = session.beginTransaction();
        MineSite site = session.get(MineSite.class, id);
        if (site != null) {
            session.delete(site);
        }
        tx.commit();
        session.close();
    }
    
    // LIST ALL
    public List<MineSite> getAllSites() {
        Session session = sessionFactory.openSession();
        List<MineSite> sites = session.createQuery(
            "FROM MineSite", MineSite.class).list();
        session.close();
        return sites;
    }
}
```

## HQL Reporting Examples

### Production Ranking
```hql
SELECT p.mineId, SUM(p.tonnes) 
FROM ProductionLog p 
WHERE MONTH(p.logDate) = :month 
AND YEAR(p.logDate) = :year 
GROUP BY p.mineId 
ORDER BY SUM(p.tonnes) DESC
```

### Equipment Breakdown Report
```hql
SELECT e.name, COUNT(u.usageId) 
FROM Equipment e, EquipmentUsage u 
WHERE e.equipmentId = u.equipmentId 
AND e.mineId = :mineId 
AND u.breakdown = 'Y' 
GROUP BY e.name 
ORDER BY COUNT(u.usageId) DESC
```

### Open Incidents
```hql
FROM SafetyIncident s 
WHERE s.mineId = :mineId 
AND s.status = 'OPEN' 
ORDER BY s.incidentDate DESC
```

## Usage

### Setup
1. Import database schema from `database/schema.sql` into MySQL
2. Configure database connection in `hibernate.cfg.xml`
3. Build with Maven: `mvn clean install`
4. Run: `java -cp target/miningoplite-1.0-SNAPSHOT.jar com.mineops.main.MineOpsApp`

### Menu Options
1. Register Mine Site
2. Update Mine Status
3. Register Equipment
4. Transfer Equipment
5. Register Worker
6. Create Shift Log
7. Record Production
8. Track Equipment Usage
9. Report Safety Incident
10. Close Safety Incident
11. View Reports
12. Exit

## Technology Stack
- **Language:** Java 8+
- **ORM:** Hibernate 5.x
- **Database:** MySQL 5.7+
- **Build:** Maven
- **IDE:** Eclipse/IntelliJ IDEA

## Validation Rules
- `mineId` must exist before creating related records
- `equipmentId` must exist and belong to correct mine
- Production `tonnes` must be positive
- Production `grade` must be 0-100
- Safety `severity` must be 1-5
- Equipment `status`: WORKING, MAINTENANCE, or BROKEN
- Shift `type`: DAY or NIGHT
- Incident `status`: OPEN or CLOSED

## Sample Data
Database includes sample data with 3 mines, 5 equipment items, 5 workers, and 13 incidents for testing.

## Author
Student ID: 2400032275
Course: Database Management & Hibernate
