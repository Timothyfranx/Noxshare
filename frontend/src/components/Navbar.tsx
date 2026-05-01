import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { useAccount, useDisconnect, useConnect } from 'wagmi';
import { injected } from 'wagmi/connectors';

interface NavbarProps {
  variant?: 'landing' | 'dashboard';
}

export default function Navbar({ variant = 'landing' }: NavbarProps) {
  const [scrolled, setScrolled] = useState(false);
  const { address, isConnected } = useAccount();
  const { disconnect } = useDisconnect();
  const { connect } = useConnect();

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 20);
    };

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const handleDisconnect = () => {
    disconnect();
    window.location.href = '/';
  };

  return (
    <nav className={`navbar ${scrolled ? 'scrolled' : ''}`}>
      <div className="navbar-content">
        <Link href={variant === 'dashboard' ? '/dashboard' : '/'} className="navbar-logo">
          🌴 NoxShare
        </Link>

        <div className="navbar-nav">
          {!isConnected ? (
            <button 
              onClick={() => connect({ connector: injected() })} 
              className="btn-primary btn-sm"
            >
              Connect Wallet
            </button>
          ) : (
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
              <span className="wallet-address" style={{ background: 'var(--bg-card)', border: '1px solid var(--border-color)', padding: '0.5rem 0.875rem', borderRadius: '8px', fontFamily: 'monospace', fontSize: '0.875rem', color: 'var(--text-secondary)' }}>
                {address?.slice(0, 6)}...{address?.slice(-4)}
              </span>
              <button onClick={handleDisconnect} className="btn-disconnect">
                Disconnect
              </button>
            </div>
          )}
        </div>
      </div>
    </nav>
  );
}
