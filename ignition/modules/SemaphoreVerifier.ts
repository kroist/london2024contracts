import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const SemaphoreVerifierModule = buildModule("SemaphoreVerifierModule", (m) => {

  const semaphoreVerifier = m.contract("SemaphoreVerifier");

  return { semaphoreVerifier };
});

export default SemaphoreVerifierModule;
