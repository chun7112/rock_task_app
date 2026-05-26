const bool useLocalhost = true; // 👉 手機用 false

const String localUrl = "http://127.0.0.1:5000";
const String deviceUrl = "http://172.20.10.4:5000"; // 👉 換成你的IP

String get baseUrl => useLocalhost ? localUrl : deviceUrl;
