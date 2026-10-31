/**
 * Script nạp dữ liệu mẫu chuẩn QNU từ file database/init_all_databases.sql
 * Đảm bảo 1 nguồn duy nhất (Single Source of Truth) cho cấu trúc CSDL và dữ liệu mẫu.
 */

const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');

const dbConfig = {
    host: process.env.DB_HOST || '127.0.0.1',
    port: Number(process.env.DB_PORT || 3306),
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    multipleStatements: true
};

async function main() {
    console.log('🔄 Đang kết nối MySQL và thực thi database/init_all_databases.sql...');
    const conn = await mysql.createConnection(dbConfig);
    const sqlPath = path.join(__dirname, '../database/init_all_databases.sql');
    const sql = fs.readFileSync(sqlPath, 'utf8');

    await conn.query(sql);
    console.log('✅ Đã nạp thành công toàn bộ CSDL và dữ liệu mẫu từ database/init_all_databases.sql!');
    await conn.end();
}

main().catch((err) => {
    console.error('❌ Lỗi khi thực thi SQL:', err);
    process.exit(1);
});
