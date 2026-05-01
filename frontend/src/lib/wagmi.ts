import { createConfig, http } from 'wagmi';
import { mainnet, sepolia, arbitrumSepolia } from 'wagmi/chains';
import { injected } from 'wagmi/connectors';

export const config = createConfig({
  chains: [arbitrumSepolia, sepolia, mainnet],
  connectors: [injected()],
  transports: {
    [arbitrumSepolia.id]: http(),
    [sepolia.id]: http(),
    [mainnet.id]: http(),
  },
});
