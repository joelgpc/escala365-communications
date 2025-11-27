import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { createServer } from 'http';
import { Server as SocketServer } from 'socket.io';
import { Pool } from 'pg';

dotenv.config();

const app = express();
const httpServer = createServer(app);
const io = new SocketServer(httpServer, {
    cors: { origin: '*' }
});

app.use(cors());
app.use(express.json());

const pool = new Pool({
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
    } catch (error) {
        res.status(500).json({ error: String(error) });
    }
});

app.get('/api/calls', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM calls ORDER BY created_at DESC LIMIT 20');
        res.json(result.rows);
    } catch (error) {
        res.status(500).json({ error: String(error) });
    }
});

app.get('/api/recordings', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM recordings ORDER BY created_at DESC LIMIT 50');
        res.json(result.rows);
    } catch (error) {
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
