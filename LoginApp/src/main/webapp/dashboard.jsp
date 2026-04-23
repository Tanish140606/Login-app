<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.loginapp.servlets.DBConnection" %>
<%
    // Session check
    String username = (String) session.getAttribute("username");
    String email    = (String) session.getAttribute("email");
    Integer isAdmin = (Integer) session.getAttribute("isAdmin");
    Timestamp lastLogin = (Timestamp) session.getAttribute("lastLogin");

    if (username == null) {
        response.sendRedirect("login.html");
        return;
    }

    String lastLoginStr = (lastLogin != null) ? lastLogin.toString().substring(0, 19) : "First Login";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - LoginApp</title>
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

        .btn-admin {
            background: #ffd700;
            color: #333;
        }

        .btn-admin:hover { background: #ffc200; transform: translateY(-1px); }

        .btn-logout {
            background: rgba(255,255,255,0.2);
            color: #fff;
            border: 1px solid rgba(255,255,255,0.4);
        }

        .btn-logout:hover { background: rgba(255,255,255,0.3); transform: translateY(-1px); }

        /* Cards Row */
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
            font-size: 1.15rem;
            font-weight: 700;
            word-break: break-all;
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
    </style>
</head>
<body>
<div class="container">

    <!-- Top Bar -->
    <div class="topbar">
        <h1>🏠 Dashboard</h1>
        <div class="topbar-actions">
            <% if (isAdmin != null && isAdmin == 1) { %>
                <a href="admin.jsp" class="btn btn-admin">⚙️ Admin Panel</a>
            <% } %>
            <a href="LogoutServlet" class="btn btn-logout">🚪 Logout</a>
        </div>
    </div>

    <!-- Info Cards -->
    <div class="cards-row">
        <div class="card">
            <div class="icon">👤</div>
            <div class="label">Username</div>
            <div class="value"><%= username %></div>
        </div>
        <div class="card">
            <div class="icon">📧</div>
            <div class="label">Email</div>
            <div class="value"><%= email %></div>
        </div>
        <div class="card">
            <div class="icon">🕐</div>
            <div class="label">Last Login</div>
            <div class="value"><%= lastLoginStr %></div>
        </div>
    </div>

    <!-- All Users Table -->
    <div class="section">
        <h2>👥 All Registered Users</h2>
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Username</th>
                    <th>Email</th>
                    <th>Role</th>
                    <th>Last Login</th>
                    <th>Joined</th>
                </tr>
            </thead>
            <tbody>
            <%
                try (Connection conn = DBConnection.getConnection()) {
                    String sql = "SELECT id, username, email, is_admin, last_login, created_at FROM users ORDER BY created_at ASC";
                    PreparedStatement ps = conn.prepareStatement(sql);
                    ResultSet rs = ps.executeQuery();

                    while (rs.next()) {
                        String rowUser    = rs.getString("username");
                        String rowEmail   = rs.getString("email");
                        int    rowAdmin   = rs.getInt("is_admin");
                        String rowJoined  = rs.getString("created_at") != null ? rs.getString("created_at").substring(0, 10) : "-";
                        String rowLogin   = rs.getString("last_login")  != null ? rs.getString("last_login").substring(0, 19)  : "Never";
                        boolean isYou     = rowUser.equals(username);
            %>
                <tr>
                    <td><%= rs.getInt("id") %></td>
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