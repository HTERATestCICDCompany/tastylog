const { HOST, USERNAME, PASSWORD, DATABASE, PORT } = require("../../config/mysql.config.js");
const mysql = require("mysql2");
const WAIT = 3000;
const MAX_RETRIES = 30; // 最大30回（1.5分）

let retryCount = 0;

const con = mysql.createConnection({
  host: HOST,
  port: PORT,
  user: USERNAME,
  password: PASSWORD,
  database: DATABASE
});

var tryConnect = function () {
  console.log(`Try to connect ... ${USERNAME}@${HOST}:${PORT} ... (${retryCount + 1}/${MAX_RETRIES})`);
  
  if (retryCount >= MAX_RETRIES) {
    console.error(`Database connection failed after ${MAX_RETRIES} attempts. Exiting.`);
    process.exit(1);
  }
  
  retryCount++;
  
  global.setTimeout(() => {
    con.query("SELECT 1 FROM dual", (err) => {
      if (err) {
        console.log(`Connection failed: ${err.message}`);
        tryConnect();
      } else {
        console.log("Database connection successful!");
        con.end();
        process.exit(0);
      }
    });
  }, WAIT);
};

tryConnect();

