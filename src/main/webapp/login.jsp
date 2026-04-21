<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
  <title>Login</title>
</head>
<body>

<h2>Login</h2>

<form action="login" method="post">
  Username: <input type="text" name="username" required /><br><br>
  Password: <input type="password" name="password" required /><br><br>

  Role:
  <select name="role">
    <option value="admin">Admin</option>
    <option value="staff">Staff</option>
  </select><br><br>

  <button type="submit">Login</button>
</form>

<p style="color:red;">
  ${error}
</p>

</body>
</html>

