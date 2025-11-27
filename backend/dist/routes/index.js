"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
const router = express_1.default.Router();
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
        if (!fs_1.default.existsSync(recordingsDir)) {
            return res.json([]);
        }
        const files = fs_1.default.readdirSync(recordingsDir)
            .filter(f => f.endsWith('.mp3'))
            .map(f => ({
            id: f.replace('.mp3', ''),
            file: f,
            size: fs_1.default.statSync(path_1.default.join(recordingsDir, f)).size,
            created: fs_1.default.statSync(path_1.default.join(recordingsDir, f)).birthtimeMs
        }))
            .sort((a, b) => b.created - a.created)
            .slice(0, 50);
        res.json(files);
    }
    catch (error) {
        res.status(500).json({ error: String(error) });
    }
});
// GET download recording
router.get('/recordings/:id/download', (req, res) => {
    const { id } = req.params;
    const filePath = `/var/spool/asterisk/monitor/${id}.mp3`;
    if (!fs_1.default.existsSync(filePath)) {
        return res.status(404).json({ error: 'Recording not found' });
    }
    res.download(filePath);
});
exports.default = router;
//# sourceMappingURL=index.js.map