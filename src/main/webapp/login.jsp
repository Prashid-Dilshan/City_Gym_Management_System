<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
  <title>Login</title>

  <style>
    body {
      margin: 0;
      font-family: Arial, sans-serif;
      background: linear-gradient(135deg, #4facfe, #00f2fe);
      height: 100vh;
      display: flex;
      justify-content: center;
      align-items: center;
    }

    .login-box {
      background: white;
      padding: 30px;
      border-radius: 10px;
      width: 300px;
      box-shadow: 0 5px 15px rgba(0,0,0,0.2);
      text-align: center;
    }

    h2 {
      margin-bottom: 20px;
    }

    input {
      width: 100%;
      padding: 10px;
      margin: 10px 0;
      border: 1px solid #ccc;
      border-radius: 5px;
    }

    button {
      width: 100%;
      padding: 10px;
      background: #4facfe;
      border: none;
      color: white;
      font-size: 16px;
      border-radius: 5px;
      cursor: pointer;
      transition: 0.3s;
    }

    button:hover {
      background: #007bff;
    }

    .error {
      color: red;
      margin-top: 10px;
    }
  </style>
</head>

<body>

<div class="login-box">
  <h2>🔐 Login</h2>

  <form action="login" method="post">
    <input type="text" name="username" placeholder="Username" required />
    <input type="password" name="password" placeholder="Password" required />

    <button type="submit">Login</button>
  </form>

  <p class="error">
    ${error}
  </p>
</div>

</body>
</html>