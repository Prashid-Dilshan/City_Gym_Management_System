package com.example.city_gym_management_system;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Utility class for database connection management
 * 
 * ⚠️ IMPORTANT: For production, consider using environment variables or a config file
 * instead of hardcoded credentials.
 */
public class DatabaseUtil {
    
    // Database configuration
    private static final String DB_URL = "jdbc:mysql://localhost:3306/gym_system";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "1234";
    private static final String DB_DRIVER = "com.mysql.cj.jdbc.Driver";
    
    // Connection timeout (10 seconds)
    private static final int CONNECTION_TIMEOUT = 10000;
    
    // Static initialization block to load the MySQL driver
    static {
        try {
            Class.forName(DB_DRIVER);
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError("Failed to load MySQL JDBC driver: " + e.getMessage());
        }
    }
    
    /**
     * Gets a database connection
     * @return Connection object
     * @throws SQLException if connection fails
     */
    public static Connection getConnection() throws SQLException {
        try {
            // Set connection timeout to prevent hanging
            DriverManager.setLoginTimeout(CONNECTION_TIMEOUT / 1000); // Convert to seconds
            
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // Verify connection is valid
            if (conn != null && !conn.isClosed()) {
                System.out.println("[DB] Connection established successfully");
                return conn;
            } else {
                throw new SQLException("Connection is null or closed");
            }
        } catch (SQLException e) {
            System.err.println("[DB ERROR] Database connection failed: " + e.getMessage());
            System.err.println("[DB ERROR] DB URL: " + DB_URL);
            System.err.println("[DB ERROR] Make sure MySQL is running and the database exists");
            throw e;
        }
    }
    
    /**
     * Closes database resources safely
     */
    public static void closeResource(AutoCloseable resource) {
        if (resource != null) {
            try {
                resource.close();
            } catch (Exception e) {
                System.err.println("[DB WARNING] Error closing resource: " + e.getMessage());
            }
        }
    }
}

