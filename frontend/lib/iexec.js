import { IExec } from 'iexec';

const IEXEC_GATEWAY = 'https://gateway.sepolia.iex.ec'; // Example Sepolia gateway

export const getIExec = (provider) => {
  return new IExec({ ethProvider: provider });
};

/**
 * Triggers the NoxSplitter iApp inside a TEE.
 */
export const triggerYieldSplit = async (iexec, revenueAmount) => {
  try {
    const appAddress = '0x...'; // Address of your deployed iApp
    const { chainwait } = await iexec.app.runApp({
      app: appAddress,
      args: revenueAmount.toString(),
      tag: ['tee', 'scone'], // Requires TEE
    });
    
    const { taskid } = await chainwait;
    return taskid;
  } catch (error) {
    console.error("IExec Task Trigger Failed:", error);
    throw error;
  }
};

/**
 * Polls for the TEE task result.
 */
export const checkTaskStatus = async (iexec, taskid) => {
  return await iexec.task.show(taskid);
};
