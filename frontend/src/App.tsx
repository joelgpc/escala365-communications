import React, { useEffect, useState } from 'react';
import axios from 'axios';
import io from 'socket.io-client';

interface Recording {
    id: string;
    file: string;
    size: number;
    created: number;
}

const App: React.FC = () => {
    const [recordings, setRecordings] = useState<Recording[]>([]);
    const [loading, setLoading] = useState(false);
    const [asteriskStatus, setAsteriskStatus] = useState('Verificando...');

    useEffect(() => {
        // Conectar al backend
        const socket = io(import.meta.env.REACT_APP_WS_URL || 'http://localhost:3000');

        socket.on('connect', () => {
            console.log('✅ Conectado al servidor');
        });

        socket.on('call:new', (data: any) => {
            console.log('📞 Nueva llamada:', data);
            loadRecordings();
        });

        socket.on('call:ended', (data: any) => {
            console.log('📴 Llamada finalizada:', data);
            loadRecordings();
        });

        // Verificar Asterisk
        checkHealth();
        loadRecordings();

        // Polling cada 5 segundos
        const interval = setInterval(() => {
            loadRecordings();
        }, 5000);

        return () => {
            clearInterval(interval);
            socket.disconnect();
        };
    }, []);

    const checkHealth = async () => {
        try {
            await axios.get(
                `${import.meta.env.REACT_APP_API_URL || 'http://localhost:3000'}/health`
            );
            setAsteriskStatus('✅ Online');
        } catch (error) {
            setAsteriskStatus('❌ Offline');
        }
    };

    const loadRecordings = async () => {
        setLoading(true);
        try {
            const response = await axios.get(
                `${import.meta.env.REACT_APP_API_URL || 'http://localhost:3000'}/api/recordings`
            );
            setRecordings(response.data);
        } catch (error) {
            console.error('Error cargando grabaciones:', error);
        } finally {
            setLoading(false);
        }
    };

    const downloadRecording = (id: string) => {
        const url = `${import.meta.env.REACT_APP_API_URL || 'http://localhost:3000'}/api/recordings/${id}/download`;
        window.open(url, '_blank');
    };

    return (
        <div style={styles.container}>
            <header style={styles.header}>
                <h1>🚀 ESCALA365 COMMUNICATIONS</h1>
                <div style={styles.status}>
                    <span>{asteriskStatus}</span>
                </div>
            </header>

            <main style={styles.main}>
                <div style={styles.card}>
                    <h2>🎙️ Grabaciones Recientes</h2>

                    {loading && <p>Cargando...</p>}

                    {recordings.length === 0 ? (
                        <p style={styles.empty}>No hay grabaciones</p>
                    ) : (
                        <table style={styles.table}>
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Archivo</th>
                                    <th>Tamaño</th>
                                    <th>Fecha</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                {recordings.map(rec => (
                                    <tr key={rec.id}>
                                        <td>{rec.id.substring(0, 8)}...</td>
                                        <td>{rec.file}</td>
                                        <td>{(rec.size / 1024 / 1024).toFixed(2)} MB</td>
                                        <td>{new Date(rec.created).toLocaleString()}</td>
                                        <td>
                                            <button
                                                onClick={() => downloadRecording(rec.id)}
                                                style={styles.button}
                                            >
                                                ⬇️ Descargar
                                            </button>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    )}
                </div>
            </main>
        </div>
    );
};

const styles: any = {
    container: {
        fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
        backgroundColor: '#1a1a2e',
        color: '#ecf0f1',
        minHeight: '100vh',
        padding: '20px'
    },
    header: {
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: '30px',
        paddingBottom: '20px',
        borderBottom: '2px solid #00d4ff'
    },
    status: {
        padding: '10px 20px',
        background: 'rgba(0, 212, 255, 0.1)',
        borderRadius: '4px',
        fontSize: '14px'
    },
    main: {
        maxWidth: '1200px',
        margin: '0 auto'
    },
    card: {
        background: 'rgba(0, 0, 0, 0.4)',
        border: '1px solid rgba(0, 212, 255, 0.2)',
        borderRadius: '8px',
        padding: '20px'
    },
    table: {
        width: '100%',
        borderCollapse: 'collapse' as const,
        marginTop: '20px'
    },
    button: {
        background: 'rgba(0, 200, 0, 0.2)',
        border: '1px solid #00ff00',
        color: '#00ff00',
        padding: '6px 12px',
        borderRadius: '4px',
        cursor: 'pointer'
    },
    empty: {
        textAlign: 'center' as const,
        color: '#999',
        padding: '40px'
    }
};

export default App;
