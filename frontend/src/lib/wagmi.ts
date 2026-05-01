import { createConfig, http } from 'wagmi';
import { mainnet, sepolia, arbitrumSepolia } from 'wagmi/chains';

export const config = createConfig({
  chains: [arbitrumSepolia, sepolia, mainnet],
  transports: {
    [arbitrumSepolia.id]: http(),
    [sepolia.id]: http(),
    [mainnet.id]: http(),
  },
});
