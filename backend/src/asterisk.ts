import * as ami from 'asterisk-manager';

export class AsteriskAMI {
    private ami: any;
    private connected: boolean = false;

    constructor(config: any) {
        this.ami = new ami.AMI(config);
    }

    async connect(): Promise<void> {
        return new Promise((resolve, reject) => {
            this.ami.connect((err: any) => {
                if (err) {
                    console.error('❌ Error conectando a Asterisk:', err);
                    reject(err);
                } else {
                    console.log('✅ Conectado a Asterisk AMI');
                    this.connected = true;
                    this.setupEventHandlers();
                    resolve();
                }
            });
        });
    }

    private setupEventHandlers() {
        this.ami.on('newchannel', (event: any) => {
            console.log('📞 Nueva llamada:', event);
        });

        this.ami.on('hangup', (event: any) => {
            console.log('📴 Llamada finalizada:', event);
        });
    }

    async getExtensions(): Promise<any[]> {
        return new Promise((resolve, reject) => {
            this.ami.send(new ami.Message({
                Action: 'SIPpeers',
            }), (err: any, res: any) => {
                if (err) reject(err);
                else resolve(res);
            });
        });
    }

    isConnected(): boolean {
        return this.connected;
    }
}
