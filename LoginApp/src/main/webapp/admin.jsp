<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.loginapp.servlets.DBConnection" %>
<%
    // Admin access check
    String username = (String) session.getAttribute("username");
    Integer isAdmin = (Integer) session.getAttribute("isAdmin");

    if (username == null) {
        response.sendRedirect("login.html");
        return;
    }

    if (isAdmin == null || isAdmin != 1) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Panel - LoginApp</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 30px 20px;
        }

        .container {
            max-width: 960px;
            margin: 0 auto;
        }

        /* Top Bar */
        .topbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: rgba(255,255,255,0.15);
            backdrop-filter: blur(10px);
            border-radius: 16px;
            padding: 16px 28px;
            margin-bottom: 28px;
            border: 1px solid rgba(255,255,255,0.25);
        }

        .topbar h1 {
            color: #fff;
            font-size: 1.5rem;
            letter-spacing: 1px;
        }

        .topbar-actions {
            display: flex;
            gap: 12px;
            align-items: center;
        }

        .btn {
            padding: 9px 20px;
            border-radius: 8px;
            font-size: 0.9rem;
            font-weight: 600;
            text-decoration: none;
            border: none;
            cursor: pointer;
            transition: all 0.2s;
        }

        .btn-dashboard {
            background: rgba(255,255,255,0.2);
            color: #fff;
            border: 1px solid rgba(255,255,255,0.4);
        }

        .btn-dashboard:hover { background: rgba(255,255,255,0.3); transform: translateY(-1px); }

        .btn-logout {
            background: rgba(255,255,255,0.2);
            color: #fff;
            border: 1px solid rgba(255,255,255,0.4);
        }

        .btn-logout:hover { background: rgba(255,255,255,0.3); transform: translateY(-1px); }

        /* Stats Row */
        .cards-row {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-bottom: 28px;
        }

        .card {
            background: rgba(255,255,255,0.15);
            backdrop-filter: blur(10px);
            border-radius: 16px;
            padding: 24px;
            border: 1px solid rgba(255,255,255,0.25);
            color: #fff;
        }

        .card .label {
            font-size: 0.78rem;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            opacity: 0.75;
            margin-bottom: 8px;
        }

        .card .value {
            font-size: 2rem;
            font-weight: 700;
        }

        .card .icon {
            font-size: 1.8rem;
            margin-bottom: 10px;
        }

        /* Table Section */
        .section {
            background: rgba(255,255,255,0.15);
            backdrop-filter: blur(10px);
            border-radius: 16px;
            padding: 28px;
            border: 1px solid rgba(255,255,255,0.25);
        }

        .section h2 {
            color: #fff;
            margin-bottom: 20px;
            font-size: 1.2rem;
            letter-spacing: 0.5px;
        }

        /* Success / Error message */
        .msg {
            padding: 12px 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            font-weight: 600;
            font-size: 0.92rem;
        }

        .msg-success { background: rgba(72, 199, 142, 0.3); color: #d4f5e9; border: 1px solid rgba(72,199,142,0.5); }
        .msg-error   { background: rgba(255, 99,  99, 0.3); color: #ffd5d5; border: 1px solid rgba(255,99,99,0.5); }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        thead tr {
            background: rgba(255,255,255,0.2);
        }

        th {
            padding: 12px 16px;
            text-align: left;
            color: #fff;
            font-size: 0.82rem;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        td {
            padding: 12px 16px;
            color: rgba(255,255,255,0.9);
            font-size: 0.92rem;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }

        tbody tr:hover {
            background: rgba(255,255,255,0.08);
        }

        .badge {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 700;
        }

        .badge-admin { background: #ffd700; color: #333; }
        .badge-user  { background: rgba(255,255,255,0.2); color: #fff; }

        .you-tag {
            font-size: 0.72rem;
            background: rgba(255,255,255,0.25);
            padding: 2px 8px;
            border-radius: 10px;
            margin-left: 6px;
            color: #fff;
        }

        /* Delete button */
        .btn-delete {
            background: rgba(255, 80, 80, 0.3);
            color: #ffd5d5;
            border: 1px solid rgba(255, 80, 80, 0.5);
            padding: 6px 14px;
            border-radius: 7px;
            font-size: 0.82rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
        }

        .btn-delete:hover {
            background: rgba(255, 80, 80, 0.6);
            transform: translateY(-1px);
        }

        .btn-delete:disabled {
            opacity: 0.35;
            cursor: not-allowed;
            transform: none;
        }
    </style>
</head>
<body>
<div class="container">

    <!-- Top Bar -->
    <div class="topbar">
        <h1>⚙️ Admin Panel</h1>
        <div class="topbar-actions">
            <a href="dashboard.jsp" class="btn btn-dashboard">🏠 Dashboard</a>
            <a href="LogoutServlet" class="btn btn-logout">🚪 Logout</a>
        </div>
    </div>

    <%-- Show success / error message after delete --%>
    <%
        String msg     = request.getParameter("msg");
        String msgType = request.getParameter("type");
        if (msg != null) {
    %>
        <div class="msg msg-<%= msgType %>"><%= msg %></div>
    <%
        }
    %>

    <%-- Fetch stats and users --%>
    <%
        int totalUsers = 0;
        int totalAdmins = 0;
        int totalRegular = 0;

        try (Connection conn = DBConnection.getConnection()) {
            // Count stats
            PreparedStatement countStmt = conn.prepareStatement("SELECT COUNT(*) AS total, SUM(is_admin) AS admins FROM users");
            ResultSet countRs = countStmt.executeQuery();
            if (countRs.next()) {
                totalUsers   = countRs.getInt("total");
                totalAdmins  = countRs.getInt("admins");
                totalRegular = totalUsers - totalAdmins;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    %>

    <!-- Stats Cards -->
    <div class="cards-row">
        <div class="card">
            <div class="icon">👥</div>
            <div class="label">Total Users</div>
            <div class="value"><%= totalUsers %></div>
        </div>
        <div class="card">
            <div class="icon">🔐</div>
            <div class="label">Admins</div>
            <div class="value"><%= totalAdmins %></div>
        </div>
        <div class="card">
            <div class="icon">👤</div>
            <div class="label">Regular Users</div>
            <div class="value"><%= totalRegular %></div>
        </div>
    </div>

    <!-- Users Table -->
    <div class="section">
        <h2>🗂️ Manage Users</h2>
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Username</th>
                    <th>Email</th>
                    <th>Role</th>
                    <th>Last Login</th>
                    <th>Joined</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
            <%
                try (Connection conn = DBConnection.getConnection()) {
                    String sql = "SELECT id, username, email, is_admin, last_login, created_at FROM users ORDER BY created_at ASC";
                    PreparedStatement ps = conn.prepareStatement(sql);
                    ResultSet rs = ps.executeQuery();

                    while (rs.next()) {
                        int    rowId    = rs.getInt("id");
                        String rowUser  = rs.getString("username");
                        String rowEmail = rs.getString("email");
                        int    rowAdmin = rs.getInt("is_admin");
                        String rowJoined = rs.getString("created_at") != null ? rs.getString("created_at").substring(0, 10) : "-";
                        String rowLogin  = rs.getString("last_login")  != null ? rs.getString("last_login").substring(0, 19)  : "Never";
                        boolean isYou    = rowUser.equals(username);
            %>
                <tr>
                    <td><%= rowId %></td>
                    <td>
                        <%= rowUser %>
                        <% if (isYou) { %><span class="you-tag">You</span><% } %>
                    </td>
                    <td><%= rowEmail %></td>
                    <td>
                        <span class="badge <%= rowAdmin == 1 ? "badge-admin" : "badge-user" %>">
                            <%= rowAdmin == 1 ? "Admin" : "User" %>
                        </span>
                    </td>
                    <td><%= rowLogin %></td>
                    <td><%= rowJoined %></td>
                    <td>
                        <% if (isYou) { %>
                            <button class="btn-delete" disabled title="Cannot delete yourself">🚫 You</button>
                        <% } else { %>
                            <form method="post" action="AdminServlet"
                                  onsubmit="return confirm('Delete user <%= rowUser %>? This cannot be undone.');">
                                <input type="hidden" name="action"  value="delete" />
                                <input type="hidden" name="userId"  value="<%= rowId %>" />
                                <button type="submit" class="btn-delete">🗑️ Delete</button>
                            </form>
                        <% } %>
                    </td>
                </tr>
            <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            %>
            </tbody>
        </table>
    </div>

</div>
</body>
</html>