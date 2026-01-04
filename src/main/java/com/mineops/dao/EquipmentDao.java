package com.mineops.dao;

import org.hibernate.Session;
import org.hibernate.Transaction;

import com.mineops.entity.Equipment;
import com.mineops.util.HibernateUtil;

public class EquipmentDao {

    /**
     * Check if equipment exists by equipment ID
     */
    public boolean isEquipmentExists(int equipmentId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Equipment eq = session.get(Equipment.class, equipmentId);
            return eq != null;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Check if equipment belongs to a specific mine
     */
    public boolean isEquipmentInMine(int equipmentId, int mineId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Equipment eq = session.find(Equipment.class, equipmentId);

            if (eq == null) {
                return false;
            }

            return eq.getMineId() == mineId;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Check if equipment is in BROKEN status
     */
    public boolean isEquipmentBroken(int equipmentId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Equipment eq = session.get(Equipment.class, equipmentId);

            if (eq != null && "BROKEN".equalsIgnoreCase(eq.getStatus())) {
                return true;
            }

            return false;
        } catch (Exception e) {
            e.printStackTrace();
            return true; // safe default → block transfer
        }
    }

    /**
     * Transfer equipment to a new mine
     */
    public boolean transferEquipment(int equipmentId, int newMineId) {
        Transaction tx = null;

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            tx = session.beginTransaction();
            Equipment eq = session.get(Equipment.class, equipmentId);

            if (eq == null) {
                return false;
            }

            // Update mineId
            eq.setMineId(newMineId);
            session.update(eq);

            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx != null) {
                tx.rollback();
            }
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Register new equipment
     */
    public boolean registerEquipment(Equipment equipment) {
        Transaction tx = null;

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Equipment existing = session.get(Equipment.class, equipment.getEquipmentId());
            if (existing != null) {
                System.out.println("❌ Equipment ID already exists");
                return false;
            }

            tx = session.beginTransaction();
            session.save(equipment);
            tx.commit();

            System.out.println("✅ Equipment registered successfully");
            return true;
        } catch (Exception e) {
            if (tx != null) {
                tx.rollback();
            }
            e.printStackTrace();
            return false;
        }
    }
}
