<%@ page contentType="text/html;charset=UTF-8" %>
<style>
  .top-nav {
    background: #111;
    border-bottom: 1px solid #2a2a2a;
    padding: 12px 16px;
    display: flex;
    gap: 14px;
    align-items: center;
    flex-wrap: wrap;
  }

  .top-nav a {
    color: #d8d8d8;
    text-decoration: none;
    font-weight: 600;
  }

  .top-nav a:hover {
    color: #7dff8f;
  }

  .top-nav .grow {
    flex: 1;
  }
</style>

<div class="top-nav">
  <a href="live-scan">Dashboard</a>
  <a href="members">Members</a>
  <a href="payments">Payments</a>
  <a href="alerts">Alerts</a>
  <span class="grow"></span>
  <a href="logout">Logout</a>
</div>

