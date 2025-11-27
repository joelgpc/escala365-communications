"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.AsteriskAMI = void 0;
const ami = __importStar(require("asterisk-manager"));
class AsteriskAMI {
    constructor(config) {
        this.connected = false;
        this.ami = new ami.AMI(config);
    }
    async connect() {
        return new Promise((resolve, reject) => {
            this.ami.connect((err) => {
                if (err) {
                    console.error('❌ Error conectando a Asterisk:', err);
                    reject(err);
                }
                else {
                    console.log('✅ Conectado a Asterisk AMI');
                    this.connected = true;
                    this.setupEventHandlers();
                    resolve();
                }
            });
        });
    }
    setupEventHandlers() {
        this.ami.on('newchannel', (event) => {
            console.log('📞 Nueva llamada:', event);
        });
        this.ami.on('hangup', (event) => {
            console.log('📴 Llamada finalizada:', event);
        });
    }
    async getExtensions() {
        return new Promise((resolve, reject) => {
            this.ami.send(new ami.Message({
                Action: 'SIPpeers',
            }), (err, res) => {
                if (err)
                    reject(err);
                else
                    resolve(res);
            });
        });
    }
    isConnected() {
        return this.connected;
    }
}
exports.AsteriskAMI = AsteriskAMI;
//# sourceMappingURL=asterisk.js.map