package com.loginapp.servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/AdminServlet")
public class AdminServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Step 1: Session & admin check
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.html");
            return;
        }

        Integer isAdmin = (Integer) session.getAttribute("isAdmin");
        if (isAdmin == null || isAdmin != 1) {
            response.sendRedirect("dashboard.jsp");
            return;
        }

        // Step 2: Get action and userId from form
        String action = request.getParameter("action");
        String userIdParam = request.getParameter("userId");

        if ("delete".equals(action) && userIdParam != null) {

            try {
                int targetUserId   = Integer.parseInt(userIdParam);
                int currentUserId  = (Integer) session.getAttribute("userId");

                // Step 3: Prevent admin from deleting themselves
                if (targetUserId == currentUserId) {
                    response.sendRedirect("admin.jsp?msg=You+cannot+delete+your+own+account&type=error");
                    return;
                }

                // Step 4: Delete the user
                try (Connection conn = DBConnection.getConnection()) {
                    String sql = "DELETE FROM users WHERE id = ?";
                    PreparedStatement ps = conn.prepareStatement(sql);
                    ps.setInt(1, targetUserId);
                    int rows = ps.executeUpdate();

                    if (rows > 0) {
                        response.sendRedirect("admin.jsp?msg=User+deleted+successfully&type=success");
                    } else {
                        response.sendRedirect("admin.jsp?msg=User+not+found&type=error");
                    }
                }

            } catch (NumberFormatException e) {
                response.sendRedirect("admin.jsp?msg=Invalid+user+ID&type=error");

            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("admin.jsp?msg=Error+deleting+user&type=error");
            }

        } else {
            response.sendRedirect("admin.jsp?msg=Invalid+action&type=error");
        }
    }
}