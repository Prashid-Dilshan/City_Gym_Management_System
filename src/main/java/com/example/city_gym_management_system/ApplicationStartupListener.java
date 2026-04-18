package com.example.city_gym_management_system;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

@WebListener
public class ApplicationStartupListener implements ServletContextListener {
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("[APP] Application starting...");
        MembershipCheckService.startService();
        BirthdayCheckService.startService();
        System.out.println("[APP] All services initialized");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("[APP] Shutting down services...");
        MembershipCheckService.stopService();
        BirthdayCheckService.stopService();
        System.out.println("[APP] Services stopped");
    }
}

