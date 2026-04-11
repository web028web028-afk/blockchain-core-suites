import { ethers } from "ethers";

interface TxEvent {
    hash: string;
    from: string;
    to: string | null;
    value: string;
    timestamp: number;
    status: "pending" | "success" | "failed";
}

class TransactionMonitor {
    private provider: ethers.Provider;
    private monitoredAddresses: Set<string>;
    private txHistory: TxEvent[];

    constructor(rpcUrl: string) {
        this.provider = new ethers.JsonRpcProvider(rpcUrl);
        this.monitoredAddresses = new Set();
        this.txHistory = [];
    }

    addAddress(address: string): void {
        this.monitoredAddresses.add(address.toLowerCase());
    }

    removeAddress(address: string): void {
        this.monitoredAddresses.delete(address.toLowerCase());
    }

    async startMonitoring(): Promise<void> {
        console.log("Transaction monitor started...");
        this.provider.on("block", async (blockNumber) => {
            await this.scanBlock(blockNumber);
        });
    }

    private async scanBlock(blockNumber: number): Promise<void> {
        const block = await this.provider.getBlock(blockNumber, true);
        if (!block) return;

        for (const tx of block.prefetchedTransactions) {
            const isMonitored = this.monitoredAddresses.has(tx.from.toLowerCase()) ||
                (tx.to && this.monitoredAddresses.has(tx.to.toLowerCase()));

            if (isMonitored) {
                const receipt = await this.provider.getTransactionReceipt(tx.hash);
                const event: TxEvent = {
                    hash: tx.hash,
                    from: tx.from,
                    to: tx.to || null,
                    value: ethers.formatEther(tx.value),
                    timestamp: Math.floor(Date.now() / 1000),
                    status: receipt?.status === 1 ? "success" : "failed"
                };
                this.txHistory.push(event);
                this.onTxDetected(event);
            }
        }
    }

    private onTxDetected(event: TxEvent): void {
        console.log("[MONITOR] Detected transaction:", event);
    }

    getHistory(): TxEvent[] {
        return [...this.txHistory];
    }
}

export default TransactionMonitor;
