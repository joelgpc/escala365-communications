import express from 'express';
import fs from 'fs';
import path from 'path';

const router = express.Router();

// GET recording-webhook
router.post('/recording-webhook', (req, res) => {
    const { callId, from, to } = req.body;
    console.log('🎙️ Webhook de grabación recibido:', { callId, from, to });

    // TODO: Guardar en BD
    res.json({ status: 'received' });
});

// GET recordings
router.get('/recordings', (req, res) => {
    try {
        const recordingsDir = '/var/spool/asterisk/monitor';

        if (!fs.existsSync(recordingsDir)) {
            return res.json([]);
        }

        const files = fs.readdirSync(recordingsDir)
            .filter(f => f.endsWith('.wav'))
            .map(f => ({
                id: f.replace('.wav', ''),
                file: f,
                size: fs.statSync(path.join(recordingsDir, f)).size,
                created: fs.statSync(path.join(recordingsDir, f)).birthtimeMs
            }))
            .sort((a, b) => b.created - a.created)
            .slice(0, 50);

        res.json(files);
    } catch (error) {
        res.status(500).json({ error: String(error) });
    }
});

// GET download recording
router.get('/recordings/:id/download', (req, res) => {
    const { id } = req.params;
    const filePath = `/var/spool/asterisk/monitor/${id}.wav`;

    if (!fs.existsSync(filePath)) {
        return res.status(404).json({ error: 'Recording not found' });
    }

    res.download(filePath);
});

export default router;
