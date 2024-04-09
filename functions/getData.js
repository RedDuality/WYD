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

async function createEvent(name, age, email) {
    try {
        await sql.connect(config);
        const request = new sql.Request();
        const query = `
            INSERT INTO Events (Name, Age, Email)
            VALUES (@Name, @Age, @Email)
        `;
        request.input('Name', sql.NVarChar(50), name);
        request.input('Age', sql.Int, age);
        request.input('Email', sql.NVarChar(100), email);
        await request.query(query);
        console.log("Event created successfully.");
    } catch (err) {
        console.error("Error creating event:", err.message);
    } finally {
        sql.close();
    }
}

async function getEventData(eventId) {
    try {
        await sql.connect(config);
        const request = new sql.Request();
        const query = `
            SELECT * FROM Events WHERE ID = @EventId
        `;
        request.input('EventId', sql.Int, eventId);
        const result = await request.query(query);
        if (result.recordset.length > 0) {
            const eventData = result.recordset[0];
            console.log("Event data:", eventData);
        } else {
            console.log("Event not found.");
        }
    } catch (err) {
        console.error("Error getting event data:", err.message);
    } finally {
        sql.close();
    }
}

console.log("Creating event...");
createEvent('Example Event', 25, 'example@example.com');

console.log("Getting event data...");
getEventData(1); // Assuming event ID is 1
