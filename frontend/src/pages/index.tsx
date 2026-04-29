import React, { useState, useEffect } from 'react';
import { useAccount, useReadContract, useWriteContract, useConnectorClient, useConnect, useDisconnect, useSwitchChain } from 'wagmi';
import { injected } from 'wagmi/connectors';
import { createViemHandleClient } from '@iexec-nox/handle';
import { walletActions } from 'viem';
import { arbitrumSepolia } from 'viem/chains';

// Minimal ABIs
const NOX_SHARE_ABI = [
  {
    name: 'getShareHandle',
    type: 'function',
    stateMutability: 'view',
    inputs: [{ name: 'investor', type: 'address' }],
    outputs: [{ type: 'bytes32' }],
  },
  {
    name: 'getDividendHandle',
    type: 'function',
    stateMutability: 'view',
    inputs: [{ name: 'investor', type: 'address' }],
    outputs: [{ type: 'bytes32' }],
  },
  {
    name: 'getAuctionStatus',
    type: 'function',
    stateMutability: 'view',
    inputs: [],
    outputs: [
      { name: 'endTime', type: 'uint256' },
      { name: 'currentLeader', type: 'address' },
      { name: 'settled', type: 'bool' }
    ],
  },
  {
    name: 'submitBid',
    type: 'function',
    stateMutability: 'nonpayable',
    inputs: [
      { name: 'encryptedBid', type: 'bytes32' },
      { name: 'proof', type: 'bytes' }
    ],
    outputs: [],
  }
] as const;

const NOX_SHARE_ADDRESS = '0xdAC574e3B378dEdd3B8C76CAd3424d5b42283791';

// Explicit Nox Config for Arbitrum Sepolia
const NOX_CONFIG = {
  gatewayUrl: 'https://2e1800fc0dddeeadc189283ed1dce13c1ae28d48-3000.apps.ovh-tdx-dev.noxprotocol.dev',
  smartContractAddress: '0xd464B198f06756a1d00be223634b85E0a731c229',
  subgraphUrl: 'https://thegraph.arbitrum-sepolia-testnet.noxprotocol.io/api/subgraphs/id/BjQAX2HpmsSAzURJimKDhjZZnkSJtaczA8RPumggrStb',
};

function App() {
  const { address, isConnected, chainId } = useAccount();
  const { connect } = useConnect();
  const { disconnect } = useDisconnect();
  const { switchChain } = useSwitchChain();
  const { data: connectorClient } = useConnectorClient();
  const { writeContractAsync } = useWriteContract();
  
  const [isPrivate, setIsPrivate] = useState(true);
  const [decryptedBalance, setDecryptedBalance] = useState<string>("0");
  const [decryptedDividends, setDecryptedDividends] = useState<string>("0");
  const [isDecrypting, setIsDecrypting] = useState(false);
  const [isBidding, setIsBidding] = useState(false);
  const [timeLeft, setTimeLeft] = useState<number | null>(null);

  // 1. Read the encrypted share handle
  const { data: shareHandle } = useReadContract({
    address: NOX_SHARE_ADDRESS,
    abi: NOX_SHARE_ABI,
    functionName: 'getShareHandle',
    args: [address ? (address as `0x${string}`) : undefined],
  });

  // 2. Read the encrypted dividend handle
  const { data: dividendHandle } = useReadContract({
    address: NOX_SHARE_ADDRESS,
    abi: NOX_SHARE_ABI,
    functionName: 'getDividendHandle',
    args: [address ? (address as `0x${string}`) : undefined],
  });

  // 3. Read Auction Status
  const { data: auctionStatus, refetch: refetchAuction } = useReadContract({
    address: NOX_SHARE_ADDRESS,
    abi: NOX_SHARE_ABI,
    functionName: 'getAuctionStatus',
  });

  useEffect(() => {
    if (auctionStatus) {
      const timer = setInterval(() => {
        const now = Math.floor(Date.now() / 1000);
        const end = Number(auctionStatus[0]);
        const remaining = end - now;
        if (remaining > 0) {
          setTimeLeft(remaining);
        } else {
          setTimeLeft(0);
          clearInterval(timer);
        }
      }, 1000);
      return () => clearInterval(timer);
    }
  }, [auctionStatus]);

  const handleReveal = async () => {
    if (!connectorClient) return;

    if (chainId !== arbitrumSepolia.id) {
      alert("Please switch to Arbitrum Sepolia network");
      switchChain?.({ chainId: arbitrumSepolia.id });
      return;
    }

    if (isPrivate) {
      setIsDecrypting(true);
      try {
        const fullClient = (connectorClient as any).extend(walletActions);
        const client = await createViemHandleClient(fullClient, NOX_CONFIG);
        
        if (shareHandle && shareHandle !== '0x0000000000000000000000000000000000000000000000000000000000000000') {
          const res = await client.decrypt(shareHandle as string);
          setDecryptedBalance(res.data);
        }

        if (dividendHandle && dividendHandle !== '0x0000000000000000000000000000000000000000000000000000000000000000') {
          const res = await client.decrypt(dividendHandle as string);
          setDecryptedDividends(res.data);
        }
        
        setIsPrivate(false);
      } catch (err) {
        console.error("Decryption failed", err);
        alert(`Decryption failed: ${err instanceof Error ? err.message : 'Unknown error'}`);
      } finally {
        setIsDecrypting(false);
      }
    } else {
      setIsPrivate(true);
    }
  };

  const handlePlaceBid = async () => {
    if (!isConnected || !connectorClient) {
      alert("Please connect your wallet first");
      return;
    }

    if (chainId !== arbitrumSepolia.id) {
      alert("Please switch to Arbitrum Sepolia network");
      switchChain?.({ chainId: arbitrumSepolia.id });
      return;
    }

    const amount = prompt("Enter your confidential bid in USDC:");
    if (!amount || isNaN(Number(amount))) return;

    setIsBidding(true);
    try {
      const fullClient = (connectorClient as any).extend(walletActions);
      const client = await createViemHandleClient(fullClient, NOX_CONFIG);

      // Encrypted bid for the NoxShare contract
      // Extracting both handle and proof as per constraints
      const { handle, proof } = await (client as any).encryptInput(
        BigInt(amount),
        'uint256',
        NOX_SHARE_ADDRESS
      );

      console.log("Submitting Bid with Handle:", handle);
      
      const tx = await writeContractAsync({
        address: NOX_SHARE_ADDRESS,
        abi: NOX_SHARE_ABI,
        functionName: 'submitBid',
        args: [handle as `0x${string}`, proof as `0x${string}`],
      });

      alert(`Bid Submitted Successfully!\nTX: ${tx}\n\nYour bid is encrypted and secured.`);
      refetchAuction();
    } catch (err) {
      console.error("Bidding failed", err);
      alert(`Bidding failed: ${err instanceof Error ? err.message : 'Unknown error'}`);
    } finally {
      setIsBidding(false);
    }
  };

  const isAuctionActive = auctionStatus && timeLeft !== null && timeLeft > 0 && !auctionStatus[2];

  return (
    <div className="dashboard">
      <header className="header">
        <h1>NOXSHARE <div className="live-dot"></div></h1>
        
        <div style={{ display: 'flex', gap: '1rem', alignItems: 'center' }}>
          {isConnected ? (
            <button className="privacy-toggle" onClick={() => disconnect()} style={{ borderStyle: 'dashed' }}>
              ID: {address?.slice(0, 6)}...{address?.slice(-4)}
            </button>
          ) : (
            <button className="btn-primary" onClick={() => connect({ connector: injected() })} style={{ width: 'auto', padding: '0.6rem 1.2rem' }}>
              CONNECT TERMINAL
            </button>
          )}

          <div className="privacy-toggle" onClick={handleReveal}>
            <span style={{ color: isPrivate ? 'var(--text-secondary)' : 'var(--accent-color)' }}>
              {isPrivate ? 'SHIELDED' : 'UNSHIELDED'}
            </span>
            <div style={{
              width: '8px', height: '8px', borderRadius: '50%',
              background: isPrivate ? '#f39c12' : '#00ff88',
              boxShadow: isPrivate ? 'none' : '0 0 10px #00ff88'
            }}></div>
          </div>
        </div>
      </header>

      <div className="stats-grid">
        <div className="card">
          <h3>PORTFOLIO SHARES (Micro)</h3>
          <div className={`data-value ${isPrivate && !isDecrypting ? 'hidden' : ''}`}>
            {!isConnected ? '---' : (isDecrypting ? 'SCANNING...' : (isPrivate ? '0x00...7BB' : decryptedBalance))}
          </div>
        </div>
        
        <div className={`card ${dividendHandle && dividendHandle !== '0x0000000000000000000000000000000000000000000000000000000000000000' ? 'active' : ''}`}>
          <h3>PENDING DIVIDENDS</h3>
          <div className={`data-value ${isPrivate && !isDecrypting ? 'hidden' : ''}`} style={{color: isPrivate ? 'inherit' : '#00ff88'}}>
            {!isConnected ? '---' : (isDecrypting ? 'CALCULATING...' : (isPrivate ? 'LOCKED' : `$ ${decryptedDividends}`))}
          </div>
        </div>

        <div className="card">
          <h3>NODE STATUS</h3>
          <div className="data-value" style={{fontSize: '1rem', color: isConnected ? '#00ff88' : '#848e9c'}}>
            {isConnected ? 'ENCLAVE ACTIVE • ARBITRUM SEPOLIA' : 'OFFLINE'}
          </div>
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '24px' }}>
        <main>
          <h2 style={{ fontSize: '0.9rem', color: '#848e9c', marginBottom: '1rem', textTransform: 'uppercase' }}>Active Harvest Auctions</h2>
          <div className="card">
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1rem' }}>
              <div>
                <p style={{ color: '#848e9c', fontSize: '0.9rem', marginBottom: '0.5rem' }}>
                  {isAuctionActive ? 'Q3 Harvest Cycle - Bidding Live' : 'No Active Auction'}
                </p>
                {isAuctionActive && (
                  <div style={{ color: 'var(--accent-color)', fontSize: '1.2rem', fontWeight: 'bold' }}>
                    ENDS IN: {Math.floor(timeLeft / 60)}m {timeLeft % 60}s
                  </div>
                )}
              </div>
              {isAuctionActive && (
                <div style={{ textAlign: 'right' }}>
                  <p style={{ color: '#848e9c', fontSize: '0.8rem' }}>CURRENT LEADER</p>
                  <p style={{ fontSize: '0.9rem', color: '#fff' }}>{auctionStatus[1].slice(0, 8)}...{auctionStatus[1].slice(-6)}</p>
                </div>
              )}
            </div>
            
            <p style={{ color: '#848e9c', marginBottom: '1.5rem', fontSize: '0.9rem' }}>
              Secure your bid for the Q3 Harvest Cycle. All bids are encrypted via Nox KMS and compared inside a TEE enclave.
            </p>
            <button className="btn-primary" onClick={handlePlaceBid} disabled={isBidding || !isAuctionActive}>
              {isBidding ? 'EXECUTING ENCRYPTION...' : (isAuctionActive ? 'PLACE CONFIDENTIAL BID' : 'AUCTION CLOSED')}
            </button>
          </div>
        </main>

        <aside>
          <h2 style={{ fontSize: '0.9rem', color: '#848e9c', marginBottom: '1rem', textTransform: 'uppercase' }}>KMS Logs</h2>
          <div className="market-feed">
            <div className="feed-item">
              <span className="ticker">NETWORK</span> <span>ARBITRUM</span>
            </div>
            <div className="feed-item">
              <span className="ticker">ENCLAVE</span> <span>INTEL TDX</span>
            </div>
            <div className="feed-item">
              <span className="ticker">PROTOCOL</span> <span>ERC-7984</span>
            </div>
            <div className="feed-item">
              <span className="ticker">KMS_URL</span> <span>KMS.NOX.IEX.EC</span>
            </div>
          </div>
        </aside>
      </div>
    </div>
  );
}

export default App;
