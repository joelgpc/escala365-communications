"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const dotenv_1 = __importDefault(require("dotenv"));
const http_1 = require("http");
const socket_io_1 = require("socket.io");
const pg_1 = require("pg");
dotenv_1.default.config();
const app = (0, express_1.default)();
const httpServer = (0, http_1.createServer)(app);
const io = new socket_io_1.Server(httpServer, {
    cors: { origin: '*' }
});
app.use((0, cors_1.default)());
app.use(express_1.default.json());
const pool = new pg_1.Pool({
    connectionString: process.env.DATABASE_URL
});
// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});
// API Routes
app.get('/api/extensions', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM extensions LIMIT 10');
        res.json(result.rows);
    }
    catch (error) {
        res.status(500).json({ error: String(error) });
    }
});
app.get('/api/calls', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM calls ORDER BY created_at DESC LIMIT 20');
        res.json(result.rows);
    }
    catch (error) {
        res.status(500).json({ error: String(error) });
    }
});
app.get('/api/recordings', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM recordings ORDER BY created_at DESC LIMIT 50');
        res.json(result.rows);
    }
    catch (error) {
        res.status(500).json({ error: String(error) });
    }
});
// WebSocket
io.on('connection', (socket) => {
    console.log('Client connected:', socket.id);
    socket.on('disconnect', () => {
        console.log('Client disconnected:', socket.id);
    });
});
const PORT = process.env.PORT || 3000;
httpServer.listen(PORT, () => {
    console.log(`🚀 Backend running on port ${PORT}`);
});
//# sourceMappingURL=index.js.map