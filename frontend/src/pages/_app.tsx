import React, { useState, useEffect } from 'react';
import type { AppProps } from 'next/app';
import { WagmiProvider, createConfig, http } from 'wagmi';
import { mainnet, sepolia, arbitrumSepolia } from 'wagmi/chains';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { Toaster } from 'react-hot-toast';
import '../styles/globals.css';

const config = createConfig({
  chains: [arbitrumSepolia, sepolia, mainnet],
  transports: {
    [arbitrumSepolia.id]: http(),
    [sepolia.id]: http(),
    [mainnet.id]: http(),
  },
});

const queryClient = new QueryClient();

export default function App({ Component, pageProps }: AppProps) {
  const [mounted, setMounted] = useState(false);
  useEffect(() => setMounted(true), []);

  if (!mounted) return null;

  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <Toaster
          position="bottom-right"
          toastOptions={{
            className: 'toast',
            duration: 5000,
            success: {
              className: 'toast-success',
              icon: '✓',
            },
            error: {
              className: 'toast-error',
              icon: '✕',
            },
          }}
        />
        <Component {...pageProps} />
      </QueryClientProvider>
    </WagmiProvider>
  );
}
