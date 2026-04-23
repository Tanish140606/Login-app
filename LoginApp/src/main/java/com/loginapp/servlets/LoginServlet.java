package com.loginapp.servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDateTime;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try (Connection conn = DBConnection.getConnection()) {

            // Step 1: Validate credentials
            String selectSQL = "SELECT id, username, email, is_admin FROM users WHERE username = ? AND password = ?";
            PreparedStatement selectStmt = conn.prepareStatement(selectSQL);
            selectStmt.setString(1, username);
            selectStmt.setString(2, password);
            ResultSet rs = selectStmt.executeQuery();

            if (rs.next()) {
                int userId    = rs.getInt("id");
                String dbUser = rs.getString("username");
                String dbEmail = rs.getString("email");
                int isAdmin   = rs.getInt("is_admin");

                // Step 2: Update last_login timestamp
                String updateSQL = "UPDATE users SET last_login = ? WHERE id = ?";
                PreparedStatement updateStmt = conn.prepareStatement(updateSQL);
                updateStmt.setTimestamp(1, Timestamp.valueOf(LocalDateTime.now()));
                updateStmt.setInt(2, userId);
                updateStmt.executeUpdate();

                // Step 3: Store info in session
                HttpSession session = request.getSession();
                session.setAttribute("username", dbUser);
                session.setAttribute("email", dbEmail);
                session.setAttribute("userId", userId);
                session.setAttribute("isAdmin", isAdmin);
                session.setAttribute("lastLogin", Timestamp.valueOf(LocalDateTime.now()));

                response.sendRedirect("dashboard.jsp");

            } else {
                response.sendRedirect("login.html?error=1");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.html?error=2");
        }
    }
}