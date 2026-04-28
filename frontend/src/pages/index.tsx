import React, { useState, useEffect } from 'react';
import { useAccount, useReadContract } from 'wagmi';
import { NoxHandleSDK } from '@iexec-nox/handle';
import '../styles/globals.css';

// Minimal ABIs for demo
const NOX_SHARE_ABI = [
  "function getShareHandle(address investor) external view returns (bytes32)"
];

function App() {
  const { address, isConnected } = useAccount();
  const [isPrivate, setIsPrivate] = useState(true);
  const [decryptedBalance, setDecryptedBalance] = useState<string>("0");
  const [isDecrypting, setIsDecrypting] = useState(false);

  // 1. Read the encrypted handle from the contract
  const { data: handle } = useReadContract({
    address: '0xdAC574e3B378dEdd3B8C76CAd3424d5b42283791', // LIVE NoxShare Address
    abi: NOX_SHARE_ABI,
    functionName: 'getShareHandle',
    args: [address],
  });

  // 2. Logic to reveal the private data using Nox KMS
  const handleReveal = async () => {
    if (isPrivate) {
      setIsDecrypting(true);
      try {
        // Simulate SDK decryption call
        // const sdk = new NoxHandleSDK({ kmsUrl: 'https://kms.nox.iex.ec', provider });
        // const value = await sdk.decrypt(handle);
        
        // Demo simulation delay
        setTimeout(() => {
          setDecryptedBalance("15,420.00");
          setIsPrivate(false);
          setIsDecrypting(false);
        }, 1500);
      } catch (err) {
        console.error("Decryption failed", err);
        setIsDecrypting(false);
      }
    } else {
      setIsPrivate(true);
    }
  };

  return (
    <div className="dashboard">
      <header className="header">
        <h1>NOXSHARE <span style={{color: '#2ecc71'}}>•</span></h1>
        <div className="privacy-toggle" onClick={handleReveal}>
          <span>{isPrivate ? 'PRIVACY: ON' : 'PRIVACY: OFF'}</span>
          <div style={{
            width: '12px', height: '12px', borderRadius: '50%',
            background: isPrivate ? '#2ecc71' : '#e74c3c'
          }}></div>
        </div>
      </header>

      <div className="stats-grid">
        <div className="card">
          <h3>PORTFOLIO VALUE (USDC)</h3>
          <div className={`data-value ${isPrivate && !isDecrypting ? 'hidden' : ''}`}>
            {isDecrypting ? 'DECRYPTING...' : `$ ${isPrivate ? '8,000,000.00' : decryptedBalance}`}
          </div>
        </div>
        
        <div className="card">
          <h3>LAND SHARES (NOXPG)</h3>
          <div className={`data-value ${isPrivate && !isDecrypting ? 'hidden' : ''}`}>
            {isDecrypting ? 'FETCHING...' : isPrivate ? '420,000' : '420'}
          </div>
        </div>

        <div className="card">
          <h3>ESTIMATED ANNUAL YIELD</h3>
          <div className="data-value" style={{color: '#2ecc71'}}>14.2%</div>
        </div>
      </div>

      <main style={{marginTop: '3rem'}}>
        <h2>ACTIVE HARVEST AUCTIONS</h2>
        <div className="card">
          <p style={{color: '#9ea7af'}}>Participate in sealed-bid auctions for the next harvest cycle.</p>
          <button className="btn-primary">PLACE CONFIDENTIAL BID</button>
        </div>
      </main>
    </div>
  );
}

export default App;
