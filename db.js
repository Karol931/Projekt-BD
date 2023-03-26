const Pool = require("pg").Pool
const pool = new Pool({
    user: '',
    host: '',
    database: '',
    password: '',
    port: ,
})

module.exports = pool;