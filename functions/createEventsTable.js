const sql = require('mssql');

const config = {
    user: 'AdminWyd', // better stored in an app setting such as process.env.DB_USER
    password: 'Password1', // better stored in an app setting such as process.env.DB_PASSWORD
    server: 'wyddbtest.database.windows.net', // better stored in an app setting such as process.env.DB_SERVER
    port: 1433, // optional, defaults to 1433, better stored in an app setting such as process.env.DB_PORT
    database: 'WYD DB', // better stored in an app setting such as process.env.DB_NAME
    authentication: {
        type: 'default'
    },
    options: {
        encrypt: true
    }
}

async function createEventsTable() {
    try {
        await sql.connect(config);
        const request = new sql.Request();
        const query = `
            CREATE TABLE Events (
                ID INT IDENTITY(1,1) PRIMARY KEY,
                Name NVARCHAR(50),
                Age INT,
                Email NVARCHAR(100)
            )
        `;
        await request.query(query);
        console.log("Events table created successfully.");
        // Call function to insert sample data
        await insertSampleData();
    } catch (err) {
        console.error("Error creating Events table:", err.message);
    } finally {
        sql.close();
    }
}

async function insertSampleData() {
    try {
        const request = new sql.Request();
        const query = `
            INSERT INTO Events (Name, Age, Email)
            VALUES
                ('John Doe', 30, 'john.doe@example.com'),
                ('Jane Smith', 25, 'jane.smith@example.com')
        `;
        await request.query(query);
        console.log("Sample data inserted successfully.");
    } catch (err) {
        console.error("Error inserting sample data:", err.message);
    }
}

console.log("Creating Events table...");
createEventsTable();
