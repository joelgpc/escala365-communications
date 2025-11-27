export declare class AsteriskAMI {
    private ami;
    private connected;
    constructor(config: any);
    connect(): Promise<void>;
    private setupEventHandlers;
    getExtensions(): Promise<any[]>;
    isConnected(): boolean;
}
//# sourceMappingURL=asterisk.d.ts.map