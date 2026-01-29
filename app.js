const CONTRACT_ADDRESS = "0xa59bba2b32f06a57c5bf842dd2913235bd7d4ca9";
const contractAbi = [
  "function updateMessage(string newMessage) external"
];

const connectBtn = document.getElementById('connectBtn');
const sendBtn = document.getElementById('sendBtn');
const walletDiv = document.getElementById('wallet');
const logDiv = document.getElementById('log');
const txLinkDiv = document.getElementById('txLink');
const newMessageInput = document.getElementById('newMessage');

let provider, signer, contract, userAddress;

function log(msg) {
  console.log(msg);
  logDiv.textContent = msg;
}

connectBtn.onclick = async () => {
  if (!window.ethereum) { 
    alert("MetaMask not detected"); 
    log("No window.ethereum"); 
    return; 
  }

  try {
    provider = new ethers.providers.Web3Provider(window.ethereum);
    await provider.send("eth_requestAccounts", []);
    signer = provider.getSigner();
    userAddress = await signer.getAddress();

    // Check if on Base mainnet (chainId 8453)
    const network = await provider.getNetwork();
    if (network.chainId !== 8453) {
      log("Please switch to the Base mainnet network in your wallet.");
      walletDiv.textContent = `Wrong network: ${network.chainId}`;
      return;
    }

    walletDiv.textContent = `Connected: ${userAddress}`;
    contract = new ethers.Contract(CONTRACT_ADDRESS, contractAbi, signer);

    log("Wallet connected!");
  } catch(e) {
    log("Error connecting wallet: " + e.message);
  }
};

sendBtn.onclick = async () => {
  try {
    if (!signer) throw new Error("Connect wallet first");
    const newMessage = newMessageInput.value.trim();
    if (!newMessage) throw new Error("Enter a message");

    log("Sending transaction...sign in Your Wallet");
    txLinkDiv.innerHTML = "";

    const tx = await contract.updateMessage(newMessage);
    log(`Tx sent: ${tx.hash}`);

    const network = await provider.getNetwork();
    let explorer = "https://basescan.org/tx/";
    if(network.chainId === 11155111) explorer = "https://sepolia.etherscan.io/tx/";
    if(network.chainId === 1) explorer = "https://etherscan.io/tx/";

    txLinkDiv.innerHTML = `<a href="${explorer}${tx.hash}" target="_blank">Check Your message directly on Base explorer</a>`;

    await tx.wait();
    // Fetch and display the updated message
    const updatedMessage = await contract.readMessage();
    log(`Transaction sent!\nCurrent message: ${updatedMessage}`);
    newMessageInput.value = "";
  } catch(e) {
    log("Error: " + e.message);
  }
};
