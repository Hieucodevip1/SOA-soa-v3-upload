// TOPIC SERVICE – quản lý đề tài / lớp học phần tốt nghiệp (database riêng: soa_topic)
const express = require('express');
const { createService, HttpError } = require('../../shared/service-base');

function isTopicOwner(topic, user) {
    if (!user) return false;
    if (user.VaiTro === 'admin') return true;
    if (user.VaiTro !== 'giangvien') return false;

    const uName = String(user.TenDangNhap || '').trim().toLowerCase();
    const uHoTen = String(user.HoTen || '').trim().toLowerCase();
    const topicMaGV = String(topic.MaGV || '').trim().toLowerCase();
    const topicGV = String(topic.GiangVienHuongDan || '').trim().toLowerCase();

    // 1. So khớp mã giảng viên (ví dụ GV001 / gv01 / GV01)
    if (topicMaGV && uName) {
        if (topicMaGV === uName) return true;
        const normTopic = topicMaGV.replace(/^gv0*/i, '');
        const normUser = uName.replace(/^gv0*/i, '');
        if (normTopic && normUser && normTopic === normUser) return true;
    }

    // 2. So khớp họ tên giảng viên
    if (topicGV && uHoTen) {
        if (topicGV.includes(uHoTen) || uHoTen.includes(topicGV)) return true;
    }

    return false;
}

createService({
    name: 'topic-service',
    port: 3003,
    db: {
        name: process.env.DB_NAME_TOPIC || 'soa_topic',
        schema: [
            `CREATE TABLE IF NOT EXISTS DETAI (
                MaDT VARCHAR(20) NOT NULL PRIMARY KEY,
                TenDT VARCHAR(255) NOT NULL,
                MoTa TEXT NULL,
                GiangVienHuongDan VARCHAR(100) NULL,
                MaGV VARCHAR(50) NULL,
                Nganh VARCHAR(100) DEFAULT 'Công nghệ phần mềm',
                SoTinChi INT DEFAULT 10,
                HocKy VARCHAR(50) DEFAULT 'Học kỳ 1 (Niên khóa 2022 - 2026)',
                GioiHanSV INT DEFAULT 5,
                TrangThaiMo TINYINT(1) DEFAULT 1
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`
        ]
    },
    openapi: {
        description: 'Dịch vụ quản lý đề tài / lớp học phần tốt nghiệp. Phân loại ngành dạy, giảng viên hướng dẫn, giới hạn số lượng sinh viên.',
        routes: [
            { method: 'GET', path: '/api/topics', summary: 'Danh sách đề tài (lọc theo ?ids=DT001 hoặc ?nganh=... hoặc ?giangvien=...)', query: ['ids', 'nganh', 'giangvien'] },
            { method: 'GET', path: '/api/topics/:id', summary: 'Chi tiết đề tài / lớp học phần' },
            { method: 'POST', path: '/api/topics', summary: 'Thêm đề tài mới', roles: ['admin', 'giangvien'], body: ['MaDT', 'TenDT', 'MoTa', 'GiangVienHuongDan', 'MaGV', 'Nganh', 'SoTinChi', 'HocKy', 'GioiHanSV'], required: ['MaDT', 'TenDT'] },
            { method: 'PUT', path: '/api/topics/:id', summary: 'Cập nhật đề tài', roles: ['admin', 'giangvien'], body: ['TenDT', 'MoTa', 'GiangVienHuongDan', 'Nganh', 'SoTinChi', 'HocKy', 'GioiHanSV', 'TrangThaiMo'], required: ['TenDT'] },
            { method: 'DELETE', path: '/api/topics/:id', summary: 'Xóa đề tài (phát sự kiện topic.deleted)', roles: ['admin', 'giangvien'] }
        ]
    },
    async init(app, { pool, log, publish }) {
        const router = express.Router();

        // Đảm bảo các cột mới tồn tại trong bảng DETAI
        try {
            await pool.query("ALTER TABLE DETAI ADD COLUMN IF NOT EXISTS MaGV VARCHAR(50) NULL");
            await pool.query("ALTER TABLE DETAI ADD COLUMN IF NOT EXISTS Nganh VARCHAR(100) DEFAULT 'Công nghệ phần mềm'");
            await pool.query("ALTER TABLE DETAI ADD COLUMN IF NOT EXISTS SoTinChi INT DEFAULT 10");
            await pool.query("ALTER TABLE DETAI ADD COLUMN IF NOT EXISTS HocKy VARCHAR(50) DEFAULT 'Học kỳ 1 (Niên khóa 2022 - 2026)'");
            await pool.query("ALTER TABLE DETAI ADD COLUMN IF NOT EXISTS GioiHanSV INT DEFAULT 5");
            await pool.query("ALTER TABLE DETAI ADD COLUMN IF NOT EXISTS TrangThaiMo TINYINT(1) DEFAULT 1");
            await pool.query("UPDATE DETAI SET MaGV = 'GV001' WHERE MaGV = 'gv01' OR GiangVienHuongDan LIKE '%Nguyễn Thanh Bình%'");
            await pool.query("UPDATE DETAI SET MaGV = 'GV002' WHERE MaGV = 'gv02' OR GiangVienHuongDan LIKE '%Trần Thị Mai%'");
        } catch { /* Bỏ qua nếu đã có */ }

        try {
            await pool.query("ALTER TABLE DETAI DROP COLUMN MonBatBuoc");
        } catch {}
        try {
            await pool.query("ALTER TABLE DETAI DROP COLUMN DiemGPAToiThieu");
        } catch {}



        router.get('/', async (req, res) => {
            let rows;
            const { ids, nganh, giangvien } = req.query;
            if (ids !== undefined) {
                const idList = String(ids).split(',').map((s) => s.trim()).filter(Boolean).slice(0, 500);
                rows = idList.length ? (await pool.query('SELECT * FROM DETAI WHERE MaDT IN (?)', [idList]))[0] : [];
            } else if (nganh && giangvien) {
                [rows] = await pool.query('SELECT * FROM DETAI WHERE Nganh = ? AND (MaGV = ? OR GiangVienHuongDan LIKE ?) ORDER BY MaDT', [nganh, giangvien, `%${giangvien}%`]);
            } else if (nganh) {
                [rows] = await pool.query('SELECT * FROM DETAI WHERE Nganh = ? ORDER BY MaDT', [nganh]);
            } else if (giangvien) {
                [rows] = await pool.query('SELECT * FROM DETAI WHERE MaGV = ? OR GiangVienHuongDan LIKE ? ORDER BY MaDT', [giangvien, `%${giangvien}%`]);
            } else {
                [rows] = await pool.query('SELECT * FROM DETAI ORDER BY MaDT');
            }
            res.json({ success: true, data: rows });
        });

        router.get('/:id', async (req, res) => {
            const [rows] = await pool.query('SELECT * FROM DETAI WHERE MaDT = ?', [req.params.id]);
            if (!rows[0]) throw new HttpError(404, 'Không tìm thấy đề tài / lớp học phần');
            res.json({ success: true, data: rows[0] });
        });

        router.post('/', async (req, res) => {
            const {
                MaDT, TenDT, MoTa, GiangVienHuongDan, MaGV, Nganh,
                SoTinChi, HocKy, GioiHanSV
            } = req.body || {};

            if (!MaDT || !TenDT) throw new HttpError(400, 'Mã đề tài và tên đề tài là bắt buộc');

            const gvName = (req.user && req.user.VaiTro === 'giangvien' && req.user.HoTen)
                ? req.user.HoTen
                : (GiangVienHuongDan || (req.user ? req.user.HoTen : 'Giảng viên'));
            const gvCode = (req.user && req.user.VaiTro === 'giangvien')
                ? req.user.TenDangNhap
                : (MaGV || (req.user ? req.user.TenDangNhap : null));
            const nganhVal = Nganh || (req.user && req.user.Nganh ? req.user.Nganh : 'Công nghệ phần mềm');
            const stc = SoTinChi !== undefined && SoTinChi !== '' ? Number(SoTinChi) : 10;
            const hk = HocKy || 'Học kỳ 1 (Niên khóa 2022 - 2026)';
            const gh = GioiHanSV !== undefined && GioiHanSV !== '' ? Number(GioiHanSV) : 5;

            try {
                await pool.query(
                    `INSERT INTO DETAI (MaDT, TenDT, MoTa, GiangVienHuongDan, MaGV, Nganh, SoTinChi, HocKy, GioiHanSV, TrangThaiMo)
                     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1)`,
                    [MaDT, TenDT, MoTa || null, gvName, gvCode, nganhVal, stc, hk, gh]
                );
            } catch (e) {
                if (e.code === 'ER_DUP_ENTRY') throw new HttpError(409, 'Mã đề tài đã tồn tại');
                throw e;
            }
            publish('topic.created', { MaDT, TenDT, GiangVienHuongDan: gvName, MaGV: gvCode, Nganh: nganhVal });
            res.status(201).json({ success: true, message: 'Thêm đề tài / lớp học phần thành công' });
        });

        router.put('/:id', async (req, res) => {
            const {
                TenDT, MoTa, GiangVienHuongDan, MaGV, Nganh,
                SoTinChi, HocKy, GioiHanSV, TrangThaiMo
            } = req.body || {};

            if (!TenDT) throw new HttpError(400, 'Tên đề tài là bắt buộc');

            const [cur] = await pool.query('SELECT * FROM DETAI WHERE MaDT = ?', [req.params.id]);
            if (!cur[0]) throw new HttpError(404, 'Không tìm thấy đề tài');
            const old = cur[0];

            // Kiểm tra phân quyền nghiệp vụ: Giảng viên chỉ được sửa đề tài do chính mình phụ trách hướng dẫn
            if (req.user && req.user.VaiTro === 'giangvien') {
                if (!isTopicOwner(old, req.user)) {
                    throw new HttpError(403, 'Bạn chỉ có quyền chỉnh sửa đề tài do chính mình phụ trách hướng dẫn');
                }
            }

            // Nếu giảng viên sửa, giữ nguyên thông tin giảng viên của đề tài (không cho đổi sang GV khác)
            const finalGvName = (req.user && req.user.VaiTro === 'giangvien')
                ? old.GiangVienHuongDan
                : (GiangVienHuongDan || old.GiangVienHuongDan);
            const finalMaGV = (req.user && req.user.VaiTro === 'giangvien')
                ? old.MaGV
                : (MaGV !== undefined ? MaGV : old.MaGV);

            const [r] = await pool.query(
                `UPDATE DETAI SET
                    TenDT = ?, MoTa = ?, GiangVienHuongDan = ?, MaGV = ?, Nganh = ?,
                    SoTinChi = ?, HocKy = ?, GioiHanSV = ?,
                    TrangThaiMo = ?
                 WHERE MaDT = ?`,
                [
                    TenDT,
                    MoTa !== undefined ? MoTa : old.MoTa,
                    finalGvName,
                    finalMaGV,
                    Nganh || old.Nganh,
                    SoTinChi !== undefined ? Number(SoTinChi) : old.SoTinChi,
                    HocKy || old.HocKy,
                    GioiHanSV !== undefined ? Number(GioiHanSV) : old.GioiHanSV,
                    TrangThaiMo !== undefined ? Number(TrangThaiMo) : old.TrangThaiMo,
                    req.params.id
                ]
            );

            if (r.affectedRows === 0) throw new HttpError(404, 'Không tìm thấy đề tài');
            res.json({ success: true, message: 'Cập nhật đề tài thành công' });
        });

        router.delete('/:id', async (req, res) => {
            const [cur] = await pool.query('SELECT * FROM DETAI WHERE MaDT = ?', [req.params.id]);
            if (!cur[0]) throw new HttpError(404, 'Không tìm thấy đề tài');
            const old = cur[0];

            // Giảng viên chỉ được xóa đề tài do chính mình phụ trách
            if (req.user && req.user.VaiTro === 'giangvien') {
                if (!isTopicOwner(old, req.user)) {
                    throw new HttpError(403, 'Bạn chỉ có quyền xóa đề tài do chính mình phụ trách hướng dẫn');
                }
            }

            const [r] = await pool.query('DELETE FROM DETAI WHERE MaDT = ?', [req.params.id]);
            if (r.affectedRows === 0) throw new HttpError(404, 'Không tìm thấy đề tài');
            publish('topic.deleted', { MaDT: req.params.id });
            res.json({ success: true, message: 'Xóa đề tài thành công' });
        });

        app.use('/api/topics', router);
    }
});
