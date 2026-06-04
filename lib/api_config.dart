const bool useLocalhost = false;

const String localUrl = "http://127.0.0.1:5000";
// const String deviceUrl = "http://172.20.10.4:5000"; // 👉 本機
const String deviceUrl = "https://flask-api-zgmv.onrender.com"; // 👉 Render for phone

String get baseUrl => useLocalhost ? localUrl : deviceUrl;
