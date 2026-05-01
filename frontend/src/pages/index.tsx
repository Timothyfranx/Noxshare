import React from 'react';
import Head from 'next/head';
import Navbar from '../components/Navbar';

export default function Landing() {
  return (
    <>
      <Head>
        <title>NoxShare - Own a piece of the earth. Privately.</title>
        <meta name="description" content="Invest in productive land (palm groves, farms, real estate) and earn yield. Your ownership and earnings stay completely private." />
        <link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>🌴</text></svg>" />
      </Head>

      <Navbar variant="landing" />

      <main>
        {/* Hero Section */}
        <section className="hero">
          <div className="hero-content">
            <h1 className="hero-headline">
              Own a piece of the earth. Privately.
            </h1>
            <p className="hero-subheadline">
              Invest in productive land, such as palm groves, farms, and real estate, and earn yield.
              Your ownership and earnings stay completely private.
            </p>
            <a href="/dashboard" className="btn-primary">
              Start Investing →
            </a>
            <p className="hero-trust">
              Built on iExec Nox · Arbitrum · Zero mock data
            </p>

            <div className="hero-visual">
              <div className="visual-card">
                <div className="visual-content">
                  <svg className="lock-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
                    <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                    <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                  </svg>
                  <div className="balance-blur">██████ NOXPG</div>
                  <div style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>
                    ≈ $██,███ USD
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* How It Works Section */}
        <section className="section">
          <div className="section-header">
            <h2 className="section-title">How It Works</h2>
            <p className="section-subtitle">
              Three simple steps to private land ownership
            </p>
          </div>

          <div className="steps-grid">
            <div className="step-card">
              <div className="step-number">1</div>
              <h3 className="step-title">Browse Land Assets</h3>
              <p className="step-description">
                Explore tokenized productive land available for fractional investment.
              </p>
            </div>

            <div className="step-card">
              <div className="step-number">2</div>
              <h3 className="step-title">Buy Your Share Privately</h3>
              <p className="step-description">
                Purchase a fraction. Your ownership is encrypted on-chain,
                invisible to anyone but you.
              </p>
            </div>

            <div className="step-card">
              <div className="step-number">3</div>
              <h3 className="step-title">Earn Yield Confidentially</h3>
              <p className="step-description">
                When the land generates revenue, your dividend is calculated
                privately and sent directly to your wallet.
              </p>
            </div>
          </div>
        </section>

        {/* Why Privacy Matters Section */}
        <section className="section">
          <div className="section-header">
            <h2 className="section-title">Why Privacy Matters</h2>
            <p className="section-subtitle">
              Your financial information should be yours alone
            </p>
          </div>

          <div className="comparison-grid">
            <div className="comparison-card without">
              <div className="comparison-header">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <circle cx="12" cy="12" r="10" />
                  <line x1="15" y1="9" x2="9" y2="15" />
                  <line x1="9" y1="9" x2="15" y2="15" />
                </svg>
                Without NoxShare
              </div>
              <ul className="comparison-list">
                <li className="comparison-item">
                  <span className="x-icon">✕</span>
                  Your wallet balance is public
                </li>
                <li className="comparison-item">
                  <span className="x-icon">✕</span>
                  Anyone can see what you own
                </li>
                <li className="comparison-item">
                  <span className="x-icon">✕</span>
                  Yield amounts are traceable
                </li>
              </ul>
            </div>

            <div className="comparison-card with">
              <div className="comparison-header">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" />
                  <polyline points="22 4 12 14.01 9 11.01" />
                </svg>
                With NoxShare
              </div>
              <ul className="comparison-list">
                <li className="comparison-item">
                  <span className="check-icon">✓</span>
                  Your balance is encrypted
                </li>
                <li className="comparison-item">
                  <span className="check-icon">✓</span>
                  Only you can reveal your stake
                </li>
                <li className="comparison-item">
                  <span className="check-icon">✓</span>
                  Dividends calculated in secure enclave
                </li>
              </ul>
            </div>
          </div>
        </section>

        {/* CTA Section */}
        <section className="section" style={{ textAlign: 'center' }}>
          <h2 className="section-title" style={{ marginBottom: '1rem' }}>
            Ready to invest privately?
          </h2>
          <p className="section-subtitle" style={{ marginBottom: '2rem' }}>
            Join the future of confidential land ownership
          </p>
          <a href="/dashboard" className="btn-primary">
            Launch App →
          </a>
        </section>
      </main>

      {/* Footer */}
      <footer className="footer">
        <div className="footer-content">
          <div className="footer-brand">
            NoxShare · Built for iExec Hack4Privacy 2026
          </div>
          <div className="footer-links">
            <a href="https://github.com" target="_blank" rel="noopener noreferrer" className="footer-link">
              GitHub
            </a>
            <a href="https://arbiscan.io" target="_blank" rel="noopener noreferrer" className="footer-link">
              Arbiscan
            </a>
            <a href="https://explorer.iex.ec" target="_blank" rel="noopener noreferrer" className="footer-link">
              iExec Explorer
            </a>
          </div>
          <p className="footer-note">
            Deployed on Arbitrum Sepolia Testnet
          </p>
        </div>
      </footer>
    </>
  );
}
