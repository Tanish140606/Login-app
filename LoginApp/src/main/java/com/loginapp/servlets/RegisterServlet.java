package com.loginapp.servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get form data
        String username = request.getParameter("username");
        String email    = request.getParameter("email");
        String password = request.getParameter("password");

        // Save to database
        try {
            Connection con = DBConnection.getConnection();
            String sql = "INSERT INTO users (username, email, password) VALUES (?, ?, ?)";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, email);
            ps.setString(3, password);
            ps.executeUpdate();
            con.close();

            // Success — go to login page
            response.sendRedirect("login.html?registered=true");

        } catch (SQLException e) {
            e.printStackTrace();
            // Failed — go back to register page
            response.sendRedirect("register.html?error=true");
        }
    }
}