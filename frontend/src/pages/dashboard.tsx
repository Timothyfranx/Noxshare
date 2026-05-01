import React, { useState, useEffect } from 'react';
import Head from 'next/head';
import Link from 'next/link';
import { useAccount, useReadContract, useWriteContract, useConnectorClient, useConnect, useDisconnect, useSwitchChain } from 'wagmi';
import { simulateContract } from '@wagmi/core';
import { config } from '../lib/wagmi';
import { injected } from 'wagmi/connectors';
import { createViemHandleClient } from '@iexec-nox/handle';
import { walletActions } from 'viem';
import { arbitrumSepolia } from 'viem/chains';
import Navbar from '../components/Navbar';
import toast from 'react-hot-toast';

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
  },
  {
    name: 'requestYieldCycle',
    type: 'function',
    stateMutability: 'nonpayable',
    inputs: [
      { name: 'revenueAmount', type: 'uint256' }
    ],
    outputs: [],
  },
  {
    name: 'demoMint',
    type: 'function',
    stateMutability: 'nonpayable',
    inputs: [
      { name: 'encryptedAmount', type: 'bytes32' },
      { name: 'proof', type: 'bytes' }
    ],
    outputs: [],
  }
] as const;

const NOX_SHARE_ADDRESS = '0x71c1b1977c3752836be5a093fcb6dafe417de941';
const OWNER_ADDRESS = '0xBDB82a3905a3B22B32885Bad996cbc9917436534';

// Minimal Nox Config - SDK auto-detects defaults for Arbitrum Sepolia
const NOX_CONFIG = {};

export default function Dashboard() {
  const { address, isConnected, chainId } = useAccount();
  const { connect } = useConnect();
  const { disconnect } = useDisconnect();
  const { switchChain } = useSwitchChain();
  const { data: connectorClient } = useConnectorClient();
  const { writeContractAsync } = useWriteContract();

  const isOwner = address?.toLowerCase() === OWNER_ADDRESS.toLowerCase();

  const [isPrivate, setIsPrivate] = useState(true);
  const [decryptedBalance, setDecryptedBalance] = useState<string>("0");
  const [decryptedDividends, setDecryptedDividends] = useState<string>("0");
  const [isDecrypting, setIsDecrypting] = useState(false);
  const [isBidding, setIsBidding] = useState(false);
  const [timeLeft, setTimeLeft] = useState<number | null>(null);
  const [bidAmount, setBidAmount] = useState("");
  const [isTriggering, setIsTriggering] = useState(false);
  const [revenueAmount, setRevenueAmount] = useState("");
  const [taskId, setTaskId] = useState<string | null>(null);
  const [taskStatus, setTaskStatus] = useState<'idle' | 'pending' | 'completed'>('idle');
  const [isStartingAuction, setIsStartingAuction] = useState(false);
  const [auctionDuration, setAuctionDuration] = useState("300");
  const [isJoiningDemo, setIsJoiningDemo] = useState(false);

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
      toast.error("Please switch to Arbitrum Sepolia network");
      switchChain?.({ chainId: arbitrumSepolia.id });
      return;
    }

    if (isPrivate) {
      setIsDecrypting(true);
      try {
        const fullClient = (connectorClient as any).extend(walletActions);
        const client = await createViemHandleClient(fullClient, NOX_CONFIG);

        if (shareHandle && shareHandle !== '0x0000000000000000000000000000000000000000000000000000000000000000') {
          try {
            const res = await client.decrypt(shareHandle as string);
            setDecryptedBalance(res.data);
          } catch (decErr: any) {
            console.error("Share decryption failed", decErr);
            if (decErr.message?.includes('does not exist') || decErr.message?.includes('not authorized')) {
              toast.error("This share handle was created before the latest deployment. Please mint a new share.");
            } else {
              throw decErr;
            }
          }
        }

        if (dividendHandle && dividendHandle !== '0x0000000000000000000000000000000000000000000000000000000000000000') {
          try {
            const res = await client.decrypt(dividendHandle as string);
            setDecryptedDividends(res.data);
          } catch (decErr: any) {
            console.error("Dividend decryption failed", decErr);
            if (decErr.message?.includes('does not exist') || decErr.message?.includes('not authorized')) {
              toast.error("This dividend handle is invalid for the current deployment.");
            } else {
              throw decErr;
            }
          }
        }

        setIsPrivate(false);
        toast.success("Balance revealed");
      } catch (err) {
        console.error("Decryption failed", err);
        toast.error(`Decryption failed: ${err instanceof Error ? err.message : 'Unknown error'}`);
      } finally {
        setIsDecrypting(false);
      }
    } else {
      setIsPrivate(true);
    }
  };

  const handleStartAuction = async () => {
    if (!isOwner || !isConnected) return;
    
    setIsStartingAuction(true);
    try {
      const pendingToast = toast.loading("Starting auction...");
      
      const tx = await writeContractAsync({
        address: NOX_SHARE_ADDRESS,
        abi: NOX_SHARE_ABI,
        functionName: 'startAuction' as any,
        args: [BigInt(auctionDuration)],
      });
      
      toast.dismiss(pendingToast);
      toast.success("Auction started!");
      refetchAuction();
    } catch (err) {
      console.error("Start auction failed", err);
      toast.error(`Start auction failed: ${err instanceof Error ? err.message : 'Unknown error'}`);
    } finally {
      setIsStartingAuction(false);
    }
  };

  const handleJoinDemo = async () => {
    if (!isConnected || !connectorClient) {
      toast.error("Please connect your wallet first");
      return;
    }

    setIsJoiningDemo(true);
    try {
      const fullClient = (connectorClient as any).extend(walletActions);
      const client = await createViemHandleClient(fullClient, NOX_CONFIG);

      // Encrypted amount of 1000 for the demo mint
      const { handle, handleProof } = await (client as any).encryptInput(
        BigInt(1000),
        'uint256',
        NOX_SHARE_ADDRESS
      );

      const pendingToast = toast.loading("Minting demo shares...");

      const tx = await writeContractAsync({
        address: NOX_SHARE_ADDRESS,
        abi: NOX_SHARE_ABI,
        functionName: 'demoMint',
        args: [handle as `0x${string}`, handleProof as `0x${string}`],
      });

      toast.dismiss(pendingToast);
      toast.success(
        <span>Shares minted! · <a href={`https://sepolia.arbiscan.io/tx/${tx}`} target="_blank" rel="noopener noreferrer">View on Arbiscan</a></span>
      );
    } catch (err) {
      console.error("Demo mint failed", err);
      toast.error(`Demo mint failed: ${err instanceof Error ? err.message : 'Unknown error'}`);
    } finally {
      setIsJoiningDemo(false);
    }
  };

  const handlePlaceBid = async () => {
    if (!isConnected || !connectorClient) {
      toast.error("Please connect your wallet first");
      return;
    }

    if (chainId !== arbitrumSepolia.id) {
      toast.error("Please switch to Arbitrum Sepolia network");
      switchChain?.({ chainId: arbitrumSepolia.id });
      return;
    }

    if (!bidAmount || isNaN(Number(bidAmount))) {
      toast.error("Please enter a valid bid amount");
      return;
    }

    setIsBidding(true);
    try {
      const fullClient = (connectorClient as any).extend(walletActions);
      const client = await createViemHandleClient(fullClient, NOX_CONFIG);

      // Encrypted bid for the NoxShare contract
      const { handle, handleProof } = await (client as any).encryptInput(
        BigInt(bidAmount),
        'uint256',
        NOX_SHARE_ADDRESS
      );

      console.log("Submitting Bid with Handle:", handle);

      const pendingToast = toast.loading("Submitting bid...");

      try {
        await simulateContract(config, {
          address: NOX_SHARE_ADDRESS,
          abi: NOX_SHARE_ABI,
          functionName: 'submitBid',
          args: [handle as `0x${string}`, handleProof as `0x${string}`],
          account: address,
        });
      } catch (err) {
        console.error('Simulation failed for submitBid:', err);
        toast.dismiss(pendingToast);
        toast.error(`Simulation failed: ${err instanceof Error ? err.message : 'Unknown error'}`);
        setIsBidding(false);
        return;
      }

      const tx = await writeContractAsync({
        address: NOX_SHARE_ADDRESS,
        abi: NOX_SHARE_ABI,
        functionName: 'submitBid',
        args: [handle as `0x${string}`, handleProof as `0x${string}`],
      });

      toast.dismiss(pendingToast);
      toast.success(
        <span>Bid submitted · <a href={`https://sepolia.arbiscan.io/tx/${tx}`} target="_blank" rel="noopener noreferrer">View on Arbiscan</a></span>
      );
      setBidAmount("");
      refetchAuction();
    } catch (err) {
      console.error("Bidding failed", err);
      toast.error(`Bidding failed: ${err instanceof Error ? err.message : 'Unknown error'}`);
    } finally {
      setIsBidding(false);
    }
  };

  const handleTriggerSplitter = async () => {
    if (!isConnected || !connectorClient) {
      toast.error("Please connect your wallet first");
      return;
    }

    if (chainId !== arbitrumSepolia.id) {
      toast.error("Please switch to Arbitrum Sepolia network");
      switchChain?.({ chainId: arbitrumSepolia.id });
      return;
    }

    if (!revenueAmount || isNaN(Number(revenueAmount))) {
      toast.error("Please enter a valid revenue amount");
      return;
    }

    setIsTriggering(true);
    setTaskStatus('pending');
    try {
      const pendingToast = toast.loading("Triggering NoxSplitter...");

      try {
        await simulateContract(config, {
          address: NOX_SHARE_ADDRESS,
          abi: NOX_SHARE_ABI,
          functionName: 'requestYieldCycle',
          args: [BigInt(revenueAmount)],
          account: address,
        });
      } catch (err) {
        console.error('Simulation failed for requestYieldCycle:', err);
        toast.dismiss(pendingToast);
        toast.error(`Simulation failed: ${err instanceof Error ? err.message : 'Unknown error'}`);
        setIsTriggering(false);
        setTaskStatus('idle');
        return;
      }

      const tx = await writeContractAsync({
        address: NOX_SHARE_ADDRESS,
        abi: NOX_SHARE_ABI,
        functionName: 'requestYieldCycle',
        args: [BigInt(revenueAmount)],
      });

      toast.dismiss(pendingToast);
      setTaskId(tx);
      setTaskStatus('completed');
      toast.success(
        <span>Harvest triggered · <a href={`https://sepolia.arbiscan.io/tx/${tx}`} target="_blank" rel="noopener noreferrer">View on Arbiscan</a></span>
      );
      setRevenueAmount("");
    } catch (err) {
      console.error("Trigger failed", err);
      setTaskStatus('idle');
      toast.error(`Trigger failed: ${err instanceof Error ? err.message : 'Unknown error'}`);
    } finally {
      setIsTriggering(false);
    }
  };

  const isAuctionActive = auctionStatus && timeLeft !== null && timeLeft > 0 && !auctionStatus?.[2];

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  const formatAddress = (addr: string) => {
    return `${addr.slice(0, 6)}...${addr.slice(-4)}`;
  };

  // Connect Wallet View
  if (!isConnected) {
    return (
      <>
        <Head>
          <title>NoxShare Dashboard</title>
          <link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>🌴</text></svg>" />
        </Head>
        <Navbar variant="dashboard" />
        <div className="connect-section">
          <h2 style={{ marginBottom: '1rem' }}>Connect to Continue</h2>
          <p className="connect-message">
            Connect your wallet to view your portfolio and participate in auctions
          </p>
          <button className="btn-primary" onClick={() => connect({ connector: injected() })}>
            Connect Wallet
          </button>
        </div>
      </>
    );
  }

  return (
    <>
      <Head>
        <title>NoxShare Dashboard</title>
        <link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>🌴</text></svg>" />
      </Head>
      <Navbar variant="dashboard" />
      <div style={{ borderBottom: '1px solid var(--border-color)', paddingBottom: '1rem', marginBottom: '2rem', paddingTop: '1rem' }}>
        <div style={{ maxWidth: '1200px', margin: '0 auto', padding: '0 1.5rem', display: 'flex', justifyContent: 'flex-end', alignItems: 'center', gap: '1rem' }}>
          {isOwner && (
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <input 
                type="number" 
                value={auctionDuration} 
                onChange={(e) => setAuctionDuration(e.target.value)}
                style={{ width: '80px', padding: '4px 8px', borderRadius: '4px', border: '1px solid var(--border-color)', background: 'var(--bg-card)', color: 'var(--text-primary)' }}
              />
              <button 
                onClick={handleStartAuction} 
                disabled={isStartingAuction || isAuctionActive}
                className="btn-primary btn-sm"
                style={{ fontSize: '0.75rem' }}
              >
                {isStartingAuction ? 'Starting...' : 'Start Auction (sec)'}
              </button>
            </div>
          )}
          <span className="network-badge">
            ⚠️ Arbitrum Sepolia Testnet
          </span>
        </div>
      </div>

      <main className="dashboard">

        {/* Dashboard Grid - Three Cards */}
        <div className="dashboard-grid">
          {/* Card 1 - Portfolio */}
          <div className="card">
            <div className="portfolio-header">
              <span className="portfolio-title">🔒 Share Balance</span>
              {isPrivate ? (
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--text-secondary)" strokeWidth="2">
                  <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                  <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                </svg>
              ) : (
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--accent-gold)" strokeWidth="2">
                  <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                  <path d="M7 11V7a5 5 0 0 1 9.9-1" />
                </svg>
              )}
            </div>

            <div className={`balance-display ${isPrivate && !isDecrypting ? 'encrypted' : ''} ${isDecrypting ? 'loading' : ''}`}>
              {isDecrypting ? (
                <span className="spinner" />
              ) : isPrivate ? (
                '[ Encrypted ]'
              ) : (
                `${Number(decryptedBalance).toLocaleString()} NOXPG`
              )}
            </div>

            {!isPrivate && decryptedBalance && (
              <div className="balance-equivalent">
                ≈ ${(Number(decryptedBalance) * 0.05).toLocaleString()} USD equivalent
              </div>
            )}

            <button onClick={handleReveal} className="reveal-btn" disabled={isDecrypting}>
              {isPrivate ? (
                <>
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
                    <circle cx="12" cy="12" r="3" />
                  </svg>
                  Reveal Balance
                </>
              ) : (
                <>
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24" />
                    <line x1="1" y1="1" x2="23" y2="23" />
                  </svg>
                  Hide Balance
                </>
              )}
            </button>

            <button 
              onClick={handleJoinDemo} 
              className="btn-primary" 
              style={{ width: '100%', marginTop: '1rem', fontSize: '0.75rem', padding: '0.5rem' }}
              disabled={isJoiningDemo}
            >
              {isJoiningDemo ? 'Minting...' : '🎁 Join Demo (Get 1000 NOXPG)'}
            </button>
          </div>

          {/* Card 2 - Active Auction */}
          <div className="card">
            <div className="portfolio-header">
              <span className="portfolio-title">🏛️ Palm Grove #1 Auction</span>
              <span className={`status-badge ${isAuctionActive ? '' : 'ended'}`}>
                {isAuctionActive ? 'ACTIVE' : 'ENDED'}
              </span>
            </div>

            {isAuctionActive ? (
              <>
                <div className="countdown">
                  ⏱ {formatTime(timeLeft!)}
                </div>

                <div className="auction-detail">
                  <span className="auction-label">Current Leader</span>
                  <span className="auction-value">
                    {auctionStatus?.[1] ? formatAddress(auctionStatus[1] as string) : '-'}
                  </span>
                </div>

                <input
                  type="number"
                  placeholder="Bid Amount (USDC)"
                  value={bidAmount}
                  onChange={(e) => setBidAmount(e.target.value)}
                  className="bid-input"
                  disabled={isBidding || !isAuctionActive}
                />

                <button
                  onClick={handlePlaceBid}
                  disabled={isBidding || !isAuctionActive || !bidAmount}
                  className="btn-primary"
                  style={{ width: '100%' }}
                >
                  {isBidding ? 'Submitting...' : 'Place Confidential Bid'}
                </button>
              </>
            ) : (
              <div style={{ textAlign: 'center', padding: '2rem 0' }}>
                <p style={{ color: 'var(--text-secondary)', marginBottom: '1rem' }}>
                  Auction has ended
                </p>
                <button disabled className="btn-primary" style={{ width: '100%', opacity: 0.4 }}>
                  Auction Closed
                </button>
              </div>
            )}
          </div>

          {/* Card 3 - Yield Distribution */}
          <div className="card">
            <div className="portfolio-header">
              <span className="portfolio-title">🌾 Yield Distribution</span>
            </div>

            <div className="yield-content">
              <div className="yield-row">
                <span className="yield-label">Yield Status</span>
                <span className="yield-value">
                  {decryptedDividends && Number(decryptedDividends) > 0 ? 'Dividend Available' : 'No Dividend Pending'}
                </span>
              </div>
              <div className="yield-row">
                <span className="yield-label">Your Dividend</span>
                <span className={`yield-value ${isPrivate ? 'encrypted' : ''}`}>
                  {isPrivate ? '🔒 Encrypted' : `$${Number(decryptedDividends).toLocaleString()}`}
                </span>
              </div>
            </div>

            {!isPrivate && dividendHandle && dividendHandle !== '0x0000000000000000000000000000000000000000000000000000000000000000' && (
              <button onClick={handleReveal} className="reveal-btn" style={{ marginBottom: '1rem' }}>
                Reveal Dividend
              </button>
            )}

            <div style={{ marginTop: '1rem', paddingTop: '1rem', borderTop: `1px solid var(--border-color)` }}>
              <span className="portfolio-title" style={{ display: 'block', marginBottom: '0.75rem' }}>
                Trigger New Harvest
              </span>
              <input
                type="number"
                placeholder="Revenue Amount ($)"
                value={revenueAmount}
                onChange={(e) => setRevenueAmount(e.target.value)}
                className="bid-input"
                disabled={isTriggering}
              />
              <button
                onClick={handleTriggerSplitter}
                disabled={isTriggering || !revenueAmount}
                className="btn-primary"
                style={{ width: '100%' }}
              >
                {isTriggering ? (
                  <span style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '0.5rem' }}>
                    <span className="spinner" /> Processing...
                  </span>
                ) : (
                  'Trigger NoxSplitter'
                )}
              </button>

              {taskId && (
                <div style={{ marginTop: '1rem', fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
                  Transaction:{' '}
                  <a
                    href={`https://sepolia.arbiscan.io/tx/${taskId}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="task-link"
                  >
                    {taskId.slice(0, 10)}...{taskId.slice(-8)}
                  </a>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Secondary Section */}
        <div className="dashboard-main">
          <main>
            <h2 style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', marginBottom: '1rem', textTransform: 'uppercase' }}>
              Active Harvest Auctions
            </h2>
            <div className="card">
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1rem' }}>
                <div>
                  <p style={{ color: 'var(--text-secondary)', fontSize: '0.875rem', marginBottom: '0.5rem' }}>
                    {isAuctionActive ? 'Confidential Harvest Cycle - Bidding Live' : 'No Active Auction'}
                  </p>
                  {isAuctionActive && (
                    <div style={{ color: 'var(--accent-gold)', fontSize: '1.25rem', fontWeight: '700' }}>
                      ENDS IN: {formatTime(timeLeft!)}
                    </div>
                  )}
                </div>
                {isAuctionActive && (
                  <div style={{ textAlign: 'right' }}>
                    <p style={{ color: 'var(--text-secondary)', fontSize: '0.75rem' }}>CURRENT LEADER</p>
                    <p style={{ fontSize: '0.875rem', color: 'var(--text-primary)' }}>
                      {auctionStatus?.[1] ? formatAddress(auctionStatus[1] as string) : '-'}
                    </p>
                  </div>
                )}
              </div>

              <p style={{ color: 'var(--text-secondary)', marginBottom: '1.5rem', fontSize: '0.875rem' }}>
                Secure your bid for the Harvest Cycle. All bids are encrypted via Nox KMS and compared on-chain using Nox encrypted arithmetic.
              </p>
              <button
                className="btn-primary"
                onClick={handlePlaceBid}
                disabled={isBidding || !isAuctionActive}
                style={{ width: '100%' }}
              >
                {isBidding ? 'EXECUTING ENCRYPTION...' : (isAuctionActive ? 'PLACE CONFIDENTIAL BID' : 'AUCTION CLOSED')}
              </button>
            </div>
          </main>

          <aside>
            <h2 style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', marginBottom: '1rem', textTransform: 'uppercase' }}>
              Network Status
            </h2>
            <div className="card" style={{ padding: '1.5rem' }}>
              <div className="auction-detail">
                <span className="auction-label">NETWORK</span>
                <span className="auction-value">ARBITRUM</span>
              </div>
              <div className="auction-detail">
                <span className="auction-label">ENCLAVE</span>
                <span className="auction-value">NOX ON-CHAIN</span>
              </div>
              <div className="auction-detail">
                <span className="auction-label">PROTOCOL</span>
                <span className="auction-value">ERC-7984</span>
              </div>
              <div className="auction-detail">
                <span className="auction-label">STATUS</span>
                <span className="auction-value" style={{ color: 'var(--success)' }}>ONLINE</span>
              </div>
            </div>
          </aside>
        </div>
      </main>
    </>
  );
}
