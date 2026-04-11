const ethers = require("ethers");
const crypto = require("crypto");

class BlockchainUtils {
    static generateRandomHash() {
        return crypto.randomBytes(32).toString("hex");
    }

    static async generateWallet() {
        const wallet = ethers.Wallet.createRandom();
        return {
            address: wallet.address,
            privateKey: wallet.privateKey,
            mnemonic: wallet.mnemonic.phrase
        };
    }

    static validateAddress(address) {
        try {
            return ethers.isAddress(address);
        } catch {
            return false;
        }
    }

    static weiToEther(weiAmount) {
        return ethers.formatEther(weiAmount);
    }

    static etherToWei(etherAmount) {
        return ethers.parseEther(etherAmount.toString());
    }

    static async signMessage(privateKey, message) {
        const wallet = new ethers.Wallet(privateKey);
        return wallet.signMessage(message);
    }

    static verifySignature(address, message, signature) {
        try {
            const signer = ethers.verifyMessage(message, signature);
            return signer.toLowerCase() === address.toLowerCase();
        } catch {
            return false;
        }
    }

    static getCurrentTimestamp() {
        return Math.floor(Date.now() / 1000);
    }
}

module.exports = BlockchainUtils;
